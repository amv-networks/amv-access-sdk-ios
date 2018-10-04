import Foundation
import HMCryptoKit
import Security


extension URLRequest {

    mutating func setAMVNonceHeaders() throws {
        var nonce = [UInt8](repeating: 0x00, count: 9)

        guard SecRandomCopyBytes(kSecRandomDefault, 9, &nonce) == 0 else {
            throw Failure.nonceGeneration
        }

        let privateKey = try HMCryptoKit.privateKey(privateKeyBinary: KeysManager.shared.privateKey, publicKeyBinary: KeysManager.shared.publicKey)
        let signature = try HMCryptoKit.signature(message: nonce, privateKey: privateKey)

        setValue(nonce.base64String, forHTTPHeaderField: "amv-api-nonce")
        setValue(signature.base64String, forHTTPHeaderField: "amv-api-signature")
    }


    init(url: URL, amvNonceHeaders: Bool) throws {
        self.init(url: url)

        if amvNonceHeaders {
            try setAMVNonceHeaders()
        }
    }
}
