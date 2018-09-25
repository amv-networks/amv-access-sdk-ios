import Foundation
import HMKit


struct AMVAccessCertificates: Codable {

    internal(set) var all: [AMVAccessCertificate]


    // MARK: CodingKey

    enum CodingKeys: String, CodingKey {
        case all = "access_certificates"
    }


    // MARK: Methods

    static func deleteFromDatabase(accessCertificate: AMVAccessCertificate) {
        var accessCertificates = AMVAccessCertificates.load()

        if let idx = accessCertificates?.all.index(where: { $0.identifier == accessCertificate.identifier }) {
            accessCertificates?.all.remove(at: idx)
            accessCertificates?.save()
        }
    }

    @available(*, unavailable, message: "Delete Access Certificate from server is not supported.")
    static func deleteFromServer(accessCertificate: AMVAccessCertificate, deviceSerial: Hex, completion: @escaping (Result<AMVAccessCertificate>) -> Void) throws {
    }

    static func download(deviceSerial: Hex, accessApiContext: AccessApiContext, completion: @escaping (Result<AMVAccessCertificates>) -> Void) throws {
        guard let url = URL(baseUrl: accessApiContext.baseUrl, suffix: "/device/\(deviceSerial.lowercased())/access_certificates") else {
            throw Failure.invalidURL
        }

        let request = try URLRequest(url: url, amvNonceHeaders: true)

        URLSession.shared.dataTask(with: request, completion: completion) {
            if AMVKit.shared.logRequestsResponse, let json = try? JSONSerialization.jsonObject(with: $0, options: []) {
                print(json)
            }

            return try JSONDecoder().decode(AMVAccessCertificates.self, from: $0)
        }.resume()
    }


    mutating func removeInvalidCertificates(deviceSerial: Hex) {
        all = all.filter { $0.deviceCertificate.providingSerial.hex == deviceSerial }
    }
}

extension AMVAccessCertificates: Storable { }


public struct AMVAccessCertificate {

    /// A name
    public let name: String

    /// If the certificates-pair is valid for a given Date
    public var isValid: (Date) -> Bool {
        guard deviceCertificate.validity == vehicleCertificate.validity else {
            return { _ in false }
        }

        return deviceCertificate.validity.isValid
    }
    
    public var isValidNow: Bool {
        get {
            return isValid(Date())
        }
    }

    /// Gaining serial (of the vehicle)
    public var vehicleSerial: Hex {
        return deviceCertificate.gainingSerial.hex
    }

    public let identifier: String

    let deviceValue: Base64
    let deviceCertificate: AccessCertificate
    let vehicleValue: Base64
    let vehicleCertificate: AccessCertificate
}

extension AMVAccessCertificate: Codable {

    enum Keys: String, CodingKey {
        case identifier = "id"
        case name = "name"
        case deviceValue = "device_access_certificate"
        case vehicleValue = "vehicle_access_certificate"
    }


    // MARK: Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        identifier = try container.decode(String.self, forKey: .identifier)
        name = try container.decode(String.self, forKey: .name)

        deviceValue = try container.decode(Base64.self, forKey: .deviceValue)
        vehicleValue = try container.decode(Base64.self, forKey: .vehicleValue)

        // Try to create Access Certificates from the data
        guard let deviceCert = AccessCertificate(base64Encoded: deviceValue) else {
            throw Failure.invalidData
        }

        guard let vehicleCert = AccessCertificate(base64Encoded: vehicleValue) else {
            throw Failure.invalidData
        }

        deviceCertificate = deviceCert
        vehicleCertificate = vehicleCert
    }


    // MARK: Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)

        try container.encode(identifier, forKey: .identifier)
        try container.encode(name, forKey: .name)

        try container.encode(deviceValue, forKey: .deviceValue)
        try container.encode(vehicleValue, forKey: .vehicleValue)
    }
}

extension AMVAccessCertificate: Equatable {

    public static func ==(lhs: AMVAccessCertificate, rhs: AMVAccessCertificate) -> Bool {
        return (lhs.identifier == rhs.identifier) && (lhs.name == rhs.name) && (lhs.deviceValue == rhs.deviceValue) && (lhs.vehicleValue == rhs.vehicleValue)
    }
}