import Foundation


extension Collection where Iterator.Element == UInt8 {

    var base64String: String {
        return data.base64EncodedString()
    }

    var bytes: [UInt8] {
        return Array(self)
    }

    var data: Data {
        return Data(bytes: bytes)
    }

    var hex: String {
        return map { String(format: "%02X", $0) }.joined()
    }
}
