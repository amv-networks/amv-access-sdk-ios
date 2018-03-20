import Foundation
import HMCrypto

public struct KeysManager {

    static var shared = KeysManager()

    private var privateKeyInternal: Data
    public var privateKey: Data {
        return privateKeyInternal
    }
    
    private var publicKeyInternal: Data
    public var publicKey: Data {
        return publicKeyInternal
    }
    
    func setKeysFromIdentity(identity: Identity) {
        KeychainLayer.shared.privateKey = Data(identity.privateKey.hexadecimal()!)
        KeychainLayer.shared.publicKey = Data(identity.publicKey.hexadecimal()!)
        
        KeysManager.shared.privateKeyInternal = KeychainLayer.shared.privateKey!
        KeysManager.shared.publicKeyInternal = KeychainLayer.shared.publicKey!
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
