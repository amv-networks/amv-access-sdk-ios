import Foundation

public struct Identity: Codable {
    public let privateKey: String
    public let publicKey: String
    public let deviceSerialNumber: String
    
    public init(privateKey: String, publicKey: String, deviceSerialNumber: String) {
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.deviceSerialNumber = deviceSerialNumber
    }
}
