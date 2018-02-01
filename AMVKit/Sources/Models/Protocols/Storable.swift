import Foundation


protocol Storable: Codable {

    static func load() -> Self?

    func delete()
    func save()
}

extension Storable {

    static func load() -> Self? {
        guard let data = KeychainLayer.shared.loadData(for: "\(Self.self)") else {
            return nil
        }

        return try? JSONDecoder().decode(Self.self, from: data)
    }


    func delete() {
        KeychainLayer.shared.saveData(nil, label: "\(Self.self)")
    }

    func save() {
        let data = try? JSONEncoder().encode(self)

        KeychainLayer.shared.saveData(data, label: "\(Self.self)")
    }
}

