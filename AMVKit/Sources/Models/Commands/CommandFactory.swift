
import Foundation

protocol CommandFactory {
    static func createCommand(_ commandType : CommandType) -> Command
}
