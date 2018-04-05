import XCTest
@testable import AMVKit

class AMVKitTests: XCTestCase {
    
    // valid from 2018-04-05 10:06 until 2018-04-13 10:04
    let accessCertificateJSON = """
    {
        "id": "1",
        "name" : "Test",
        "device_access_certificate": "ASPnnwX4LULu8n0gGxdWPBinq6a8B50U0er+PIQah2cYsxtb0dJaEmrzlnFRWGx/qe58uT/07HXiLYePyJebUaFABbi9q2eVoMSncPRcchtQPBIEBQgGEgQNCAQHEAAfCAAAQMoTmg6ldPxnK3zIAuQuXeceVlqJtECtLBqy4Ff3Y3JZ3t7aiFuK5UC6HfndIXHcwSPV1pwU9kyvrxhNyTFMB4k=",
        "vehicle_access_certificate": "xKdw9FxyG1A8iVbu7cxJyeTmoo4jWbng39rhc8rgGUHXtkxtiWGITEH2XV3/Ox+pqOLs4rjxLqAZ9x2ExCqzn6KSWglEDLkbHwEj558F+C1C7hIEBQgGEgQNCAQHEAAfCAAAQEf1JaqPBCmM2KbzyUtZ3Z5kUkkyuQ1UmP8ov+LwJhEapGmXYKeTAcCxUd2TzuxgIBrNeMsecvvj59XzydGwYjE="
    }
    """.data(using: .utf8, allowLossyConversion: true)!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIfCertificatesStartAndEndTimeIsValid() {
        if let accessCertificate = getTestAccessCertificate() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy-MM-dd hh:mm"
        
            // Check start date/time
            guard var startDateTime = dateFormatter.date(from: "2018-04-05 10:06") else {
                XCTFail("Invalid start date/time given");
                return
            }
            
            XCTAssertTrue(accessCertificate.isValid(startDateTime))
            startDateTime.addTimeInterval(-60) // 1 minute < start
            XCTAssertFalse(accessCertificate.isValid(startDateTime))
            
            // Check end date/time
            guard var endDateTime = dateFormatter.date(from: "2018-04-13 10:04") else {
                XCTFail("Invalid end date/time given");
                return
            }
            
            XCTAssertTrue(accessCertificate.isValid(endDateTime))
            endDateTime.addTimeInterval(60) // 1 minute > end
            XCTAssertFalse(accessCertificate.isValid(endDateTime))
        }
    }
    
    func getTestAccessCertificate() -> AccessCertificate? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(AccessCertificate.self, from: accessCertificateJSON)
        } catch {
            XCTFail("Failed to create access certificate, error: \(error)")
            return nil
        }
    }
}
