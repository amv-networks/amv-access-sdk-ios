import Foundation

public class AccessSdkOptions {
    private(set) var accessApiContext: AccessApiContext
    private(set) var identity: Identity?
    
    public init(_ accessApiContext: AccessApiContext, _ identity: Identity? = nil) {
        self.accessApiContext = accessApiContext
        self.identity = identity
    }
}
