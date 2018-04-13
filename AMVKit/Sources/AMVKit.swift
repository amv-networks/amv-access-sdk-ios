
import AutoAPI
import Foundation
import HMKit


public struct AMVKit {

    /// Singleton access point for AMVKit
    public static internal(set) var shared = AMVKit()
    
    private var accessApiContext: AccessApiContext?

    // MARK: Methods
    
    /// Initialises the AMVKit.
    ///
    /// Tries to load the Device Certificate from a local database,
    /// if not present, tries to download one from the server.
    ///
    /// - Parameters:
    ///     - accessApiContext: Contains the URL and credentials to be able to communciate with the backend.
    ///     - handler: returns an async error or success
    /// - Throws: if an error occured initially
    /// - Warning: Must be called before other functionality can be used.
    public func initialise(accessApiContext newAccessApiContext : AccessApiContext,
                            handler done: @escaping (Result<DeviceCertificate>) -> Void) throws {

        AMVKit.shared.accessApiContext = newAccessApiContext
        
        // The outer do-catch block is used to understand when to reset the DB
        do {
            if let deviceCertificate = DeviceCertificate.load() {
                try deviceCertificate.initialiseLocalDevice()
                
                done(.success(deviceCertificate))
            }
            else {
                try DeviceCertificate.download(publicKey: KeysManager.shared.publicKey,
                                               accessApiContext: newAccessApiContext) {
                    if case .success(let deviceCertificate) = $0 {
                        do {
                            try deviceCertificate.initialiseLocalDevice()
                        }
                        catch {
                            self.resetDatabase()
                            
                            return done(.error(error))
                        }
                        
                        deviceCertificate.save()
                    }
                    
                    done($0)
                }
            }
        }
        catch {
            resetDatabase()
            
            throw error
        }
    }

    /// Connect to an Access Certificate.
    ///
    /// Starts the Bluetooth broadcasting, connects with a suitable device (vehicle),
    /// authenticates and gets the initial info.
    ///
    /// - Parameters:
    ///   - accessCertificate: certificate (for a device / vehicle) to connect with
    ///   - handler: returns an async error or success (and subsequent updates)
    /// - Throws: if an error occured when starting (other errors are returned async in the handler)
    public func connect(to accessCertificate: AccessCertificate, handler: @escaping (Result<VehicleUpdate>) -> Void) throws {
        // Try to register the certificates-pair with HMKit
        try LocalDevice.shared.registerCertificate(accessCertificate.deviceCertificate)

        LocalDevice.shared.storeCertificate(accessCertificate.vehicleCertificate)

        // Just in case it was started before with a different one
        if LocalDevice.shared.state == .broadcasting {
            LocalDevice.shared.stopBroadcasting()
        }

        // Set the filter and start
        try LocalDevice.shared.setBroadcastingFilter(vehicleSerial: accessCertificate.deviceCertificate.gainingSerial)
        try LocalDevice.shared.startBroadcasting()

        AMVKit.shared.vehicleUpdateHandler = handler
    }
    
    /// Load Access Certificates from the local database.
    ///
    /// - Returns: the certificates, if any are present
    public func getAccessCertificates() -> [AccessCertificate]? {
        guard let _ = DeviceCertificate.load() else {
            // Makes sure the kit was initialised before
            return nil
        }
        
        guard let accessCertificates = AccessCertificates.load() else {
            return nil
        }
        
        guard accessCertificates.all.count > 0 else {
            return nil
        }
        
        return accessCertificates.all
    }
    
    public func getAccessCertificateById(_ identifier: String) -> AccessCertificate? {
        let accessCertificatesFiltered = getAccessCertificates()?.filter({$0.identifier == identifier})
        return accessCertificatesFiltered?.first
    }
    
    /// Download Access Certificates from the server.
    ///
    /// Tries to download certificates from the server,
    /// if successful, wipes the local database and replaces it with the downloaded one.
    ///
    /// - Parameter done: returns an async error or success
    /// - Throws: if an error occured initially
    public func refreshAccessCertificates(_ done: @escaping (Result<[AccessCertificate]>) -> Void) throws {
        guard let serial = DeviceCertificate.load()?.serial else {
            throw Failure.uninitialised
        }
        
        try AccessCertificates.download(deviceSerial: serial, accessApiContext: accessApiContext!) {
            switch $0 {
            case .error(let error):
                done(.error(error))
                
            case .success(var accessCertificates):
                // Reset the HMKit Access Certificates database
                LocalDevice.shared.resetStorage()
                
                // Remove invalid certificates
                accessCertificates.removeInvalidCertificates(deviceSerial: serial)
                
                // Save and complete
                accessCertificates.save()
                done(.success(accessCertificates.all))
            }
        }
    }
    
    /// Revoke an Access Certificate.
    ///
    /// First tries to delete the certificate from the server,
    /// if successful, deletes it from the local database and returns the deleted certificate.
    ///
    /// - Parameters:
    ///   - accessCertificate: certificate to delete
    ///   - done: returns an async error or success
    /// - Throws: if an error occured initially
    @available(*, unavailable, message: "Revoke Access Certificate is currently not supported.")
    public func revokeAccessCertificate(_ accessCertificate: AccessCertificate, done: @escaping (Result<AccessCertificate>) -> Void) throws {
    }
    
    /// Sends a command to the connected and authenticated device.
    ///
    /// - Throws: an error before sending the command if the we're not authenticated
    public func sendCommand(_ commandType: CommandType) throws {
        guard let activeLink = LocalDevice.shared.link, activeLink.state == .authenticated else {
            throw Failure.disconnected
        }
        
        try activeLink.sendCommand(HmCommandFactory.createCommand(commandType).bytes())
    }
    
    /// Disconnect from another device.
    ///
    /// If not connected, stops the broadcasting.
    public func disconnect() {
        AMVKit.shared.vehicleUpdateHandler = nil
        
        if LocalDevice.shared.state == .broadcasting {
            LocalDevice.shared.stopBroadcasting()
        }
        
        LocalDevice.shared.disconnect()
    }

    /// Resets the local database.
    ///
    /// Deletes the Device Certificate and Access Certificates.
    public func resetDatabase() {
        AccessCertificates.load()?.delete()
        DeviceCertificate.load()?.delete()
        LocalDevice.shared.resetStorage()

        KeychainLayer.shared.privateKey = nil
        KeychainLayer.shared.publicKey = nil
    }

    // MARK: Vars

    /// Used for helping to debug integration tests results
    var logRequestsResponse: Bool = false

    /// The function that's called when a new VehicleUpdate is received
    var vehicleUpdateHandler: ((Result<VehicleUpdate>) -> Void)? = nil

    var isFirstLaunch: Bool = {
        let key = "hasLaunchedBeforeKey"

        // UserDefaults is used to keep track of install-uninstall, because it gets deleted with the app (unlike Keychain entries)
        if UserDefaults.standard.bool(forKey: key) {
            return false
        }
        else {
            UserDefaults.standard.set(true, forKey: key)
            UserDefaults.standard.synchronize()

            return true
        }
    }()


    // MARK: Init

    private init() {
        LocalDevice.shared.delegate = BluetoothManager.shared
        LocalDevice.loggingOptions = [.command, .error, .general, .bluetooth]

        if isFirstLaunch {
            // Keychain doesn't get reset after an uninstall-install
            resetDatabase()
        }
    }
}
