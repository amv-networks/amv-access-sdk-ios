import Foundation

struct SimpleCommand : Command {
    let command : [UInt8]
    
    init(bytes : [UInt8]) {
        self.command = bytes
    }
    
    func bytes() -> [UInt8] {
        return command
    }
}
