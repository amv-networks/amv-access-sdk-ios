import Foundation
import HMCrypto

public struct KeysManager {

    static var shared = KeysManager()

    private(set) var privateKey: Data
    private(set) var publicKey: Data

    func setKeysFromIdentity(identity: Identity) {
        if let privateKey = identity.privateKey.hexadecimal(), let publicKey = identity.publicKey.hexadecimal() {
            storeKeys(privateKey: privateKey, publicKey: publicKey)
            
            KeysManager.shared.privateKey = privateKey
            KeysManager.shared.publicKey = publicKey
        }
    }
    
    func storeKeys(privateKey: Data, publicKey: Data) {
        // Save the keys to a SECURE place
        KeychainLayer.shared.privateKey = privateKey
        KeychainLayer.shared.publicKey = publicKey
    }

    // MARK: Methods
    private init() {
        // If it's a FIRST LAUNCH or the keys are missing (for some mysterious reason) – create NEW keys
        if !AMVKit.shared.isFirstLaunch, let privateKey = KeychainLayer.shared.privateKey, let publicKey = KeychainLayer.shared.publicKey {
            self.privateKey = privateKey
            self.publicKey = publicKey
        } else {
            let keyPair = HMCryptor.generateKeyPair()
            self.privateKey = keyPair.privateKey
            self.publicKey = keyPair.publicKey
            
            self.storeKeys(privateKey: self.privateKey, publicKey: self.publicKey)
        }
    }
}
