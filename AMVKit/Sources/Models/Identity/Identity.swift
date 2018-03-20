import Foundation

public struct Identity: Codable {
    public let privateKey: String
    public let publicKey: String
    public let deviceSerialNumber: String
}
