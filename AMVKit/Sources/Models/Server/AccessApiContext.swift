import Foundation

public struct AccessApiContext: Codable {
    let baseUrl: String
    let appId: String
    let apiKey: String
    
    init(baseUrl: String, appId: String, apiKey: String) {
        self.baseUrl = baseUrl
        self.appId = appId
        self.apiKey = apiKey
    }
}
