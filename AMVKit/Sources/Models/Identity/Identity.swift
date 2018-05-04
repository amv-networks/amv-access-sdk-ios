import Foundation

public struct Identity: Codable {
    public let privateKey: String
    public let publicKey: String
    public let deviceSerialNumber: String
    
    public init(privateKeyInHex: String, publicKeyInHex: String, deviceSerialNumber: String) {
        self.privateKey = privateKeyInHex.lowercased()
        self.publicKey = publicKeyInHex.lowercased()
        self.deviceSerialNumber = deviceSerialNumber.lowercased()
    }
}

extension Identity: Equatable {
    public static func ==(lhs: Identity, rhs: Identity) -> Bool {
        return (lhs.deviceSerialNumber == rhs.deviceSerialNumber) &&
            (lhs.privateKey == rhs.privateKey) &&
            (lhs.publicKey == rhs.publicKey)
    }
}
