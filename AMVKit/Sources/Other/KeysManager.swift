import Foundation
import HMCrypto


public struct KeysManager {

    static var shared = KeysManager()

    let privateKeyInternal: Data
    public var privateKey: Data {
        return privateKeyInternal
    }
    
    private let publicKeyInternal: Data
    public var publicKey: Data {
        return publicKeyInternal
    }


    // MARK: Methods

    private init() {
        // If it's a FIRST LAUNCH or the keys are missing (for some mysterious reason) – create NEW keys
        if !AMVKit.shared.isFirstLaunch, let privateKey = KeychainLayer.shared.privateKey, let publicKey = KeychainLayer.shared.publicKey {
            self.privateKeyInternal = privateKey
            self.publicKeyInternal = publicKey
        }
        else {
            let keyPair = HMCryptor.generateKeyPair()

            // Save the keys to a SECURE place
            KeychainLayer.shared.privateKey = keyPair.privateKey
            KeychainLayer.shared.publicKey = keyPair.publicKey

            self.privateKeyInternal = keyPair.privateKey
            self.publicKeyInternal = keyPair.publicKey
        }
    }
}
