import Foundation
import HMCrypto

public struct KeysManager {

    static var shared = KeysManager()

    private(set) var privateKey: Data
    private(set) var publicKey: Data

    func setKeysFromIdentity(identity: Identity) {
        KeychainLayer.shared.privateKey = Data(identity.privateKey.hexadecimal()!)
        KeychainLayer.shared.publicKey = Data(identity.publicKey.hexadecimal()!)
    }

    // MARK: Methods
    private init() {
        // If it's a FIRST LAUNCH or the keys are missing (for some mysterious reason) – create NEW keys
        if !AMVKit.shared.isFirstLaunch, let privateKey = KeychainLayer.shared.privateKey, let publicKey = KeychainLayer.shared.publicKey {
            self.privateKey = privateKey
            self.publicKey = publicKey
        } else {
            let keyPair = HMCryptor.generateKeyPair()

            // Save the keys to a SECURE place
            KeychainLayer.shared.privateKey = keyPair.privateKey
            KeychainLayer.shared.publicKey = keyPair.publicKey
            
            self.privateKey = keyPair.privateKey
            self.publicKey = keyPair.privateKey
        }
    }
}
