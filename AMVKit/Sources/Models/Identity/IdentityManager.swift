import Foundation

public struct IdentityManager {
    public static func findIdentity() -> Identity? {
        if let deviceCertificate = AmvDeviceCertificate.load(), deviceCertificate.serial != nil {
            return Identity(privateKeyInHex: KeysManager.shared.privateKey.hex,
                            publicKeyInHex: KeysManager.shared.publicKey.hex,
                            deviceSerialNumber: deviceCertificate.serial!)
        }
        
        return nil
    }
}
