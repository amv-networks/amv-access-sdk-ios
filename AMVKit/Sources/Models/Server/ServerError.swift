import Foundation


public struct ServerError: Error, Decodable {

    public let detail: String
    public let source: String
    public let title: String


    // MARK: CodingKey

    enum WrapperKeys: String, CodingKey {
        case errors
    }

    enum Keys: String, CodingKey {
        case detail
        case source
        case title
    }


    // MARK: Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: WrapperKeys.self)
        var subContainers = try container.nestedUnkeyedContainer(forKey: .errors)

        // We expect ONLY 1 error in the array
        let firstErrorContainer = try subContainers.nestedContainer(keyedBy: Keys.self)

        detail = try firstErrorContainer.decode(String.self, forKey: .detail)
        source = try firstErrorContainer.decode(String.self, forKey: .source)
        title = try firstErrorContainer.decode(String.self, forKey: .title)
    }
}
