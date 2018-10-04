import Foundation


extension URL {
    init?(baseUrl: String, suffix: String) {
        self.init(string: baseUrl + "/api/v1/" + suffix)
    }
}
