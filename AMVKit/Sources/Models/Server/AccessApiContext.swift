import Foundation

public struct AccessApiContext: Codable {
    public let baseUrl: String
    public let appId: String
    public let apiKey: String
    
    init(baseUrl: String, appId: String, apiKey: String) {
        self.baseUrl = baseUrl
        self.appId = appId
        self.apiKey = apiKey
    }
}
