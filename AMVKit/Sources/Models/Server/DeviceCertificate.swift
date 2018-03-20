import Foundation
import HMKit

public struct DeviceCertificate {

    public var serial: Hex? {
        guard let cert = HMKit.DeviceCertificate(base64Encoded: value) else {
            return nil
        }

        return cert.serial.hex
    }

    let issuerPublicKey: Base64
    let value: Base64

    
    static func getDeviceCertificateURL(accessSdkOptions: AccessSdkOptions) -> URL? {
        let accessApiContext = accessSdkOptions.accessApiContext
        
        if let identity = accessSdkOptions.identity {
            return URL(baseUrl: accessApiContext.baseUrl, suffix: "device/\(identity.deviceSerialNumber.lowercased())/device_certificate")
        } else {
            return URL(baseUrl: accessApiContext.baseUrl, suffix: "device_certificates")
        }
    }

    // MARK: Methods

    static func download(publicKey: Data, accessSdkOptions: AccessSdkOptions, completion: @escaping (Result<DeviceCertificate>) -> Void) throws {
        let accessApiContext = accessSdkOptions.accessApiContext
        
        guard let url = getDeviceCertificateURL(accessSdkOptions: accessSdkOptions) else {
            throw Failure.invalidURL
        }
        
        var request: URLRequest
        
        if accessSdkOptions.identity != nil {
            request = try URLRequest(url: url, amvNonceHeaders: true)
        } else {
            
            request = URLRequest(url: url)
            
            request.httpBody = try JSONEncoder().encode(["device_public_key" : publicKey.base64String])
            request.httpMethod = "POST"
            request.setValue(accessApiContext.appId + ":" + accessApiContext.apiKey, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        URLSession.shared.dataTask(with: request, completion: completion) {
            if AMVKit.shared.logRequestsResponse, let json = try? JSONSerialization.jsonObject(with: $0, options: []) {
                print(json)
            }

            return try JSONDecoder().decode(DeviceCertificate.self, from: $0)
        }.resume()
    }

    func initialiseLocalDevice() throws {
        let privateKey = KeysManager.shared.privateKey.base64String

        try LocalDevice.shared.initialise(deviceCertificate: value, devicePrivateKey: privateKey, issuerPublicKey: issuerPublicKey)
    }
}

extension DeviceCertificate: Codable {

    enum WrapperKeys: String, CodingKey {
        case deviceCertificate = "device_certificate"
    }

    enum Keys: String, CodingKey {
        case issuerPublicKey = "issuer_public_key"
        case value = "device_certificate"
    }


    // MARK: Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: WrapperKeys.self)
        let deviceCertContainer = try container.nestedContainer(keyedBy: Keys.self, forKey: .deviceCertificate)

        issuerPublicKey = try deviceCertContainer.decode(Base64.self, forKey: .issuerPublicKey)
        value = try deviceCertContainer.decode(Base64.self, forKey: .value)
    }


    // MARK: Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: WrapperKeys.self)
        var deviceCertContainer = container.nestedContainer(keyedBy: Keys.self, forKey: .deviceCertificate)

        try deviceCertContainer.encode(issuerPublicKey, forKey: .issuerPublicKey)
        try deviceCertContainer.encode(value, forKey: .value)
    }
}

extension DeviceCertificate: Storable { }
