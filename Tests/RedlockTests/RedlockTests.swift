import XCTest
import Redbird
@testable import Redlock
import Foundation

let source = "return KEYS[1]"

class RedlockTests: XCTestCase {
    var redis: Redbird!
    var redlock: Redlock!
    
    override func setUp() {
        super.setUp()

        let config = RedbirdConfig(address: "127.0.0.1", port: 6379)
        self.redis = try! Redbird(config: config)
        self.redlock = Redlock(redis: self.redis)
    }
    
    override func tearDown() {
//        _ = try! self.redis.command("FLUSH")
    }
    
    func testLock() {
        try! self.redlock.lock(name: "testLock", timeToLive: 1.0) { unlock in
            XCTAssertNotNil(unlock)
        }
    }
    
    func testDoubleLock() {
        try! self.redlock.lock(name: "testDoubleLock", timeToLive: 1.0) { unlock in
            XCTAssertNotNil(unlock)
        }
        
        try! self.redlock.lock(name: "testDoubleLock", timeToLive: 1.0) { unlock in
            XCTAssertNil(unlock)
        }
    }
    
    func testExpiration() {
        try! self.redlock.lock(name: "testExpiration", timeToLive: 1.0) { unlock in
            XCTAssertNotNil(unlock)
        }
        
        let ttl = try! self.redis.command("PTTL", params: [ "testExpiration:key" ]).toInt()
        
        Thread.sleep(forTimeInterval: 0.01)
        
        try! self.redlock.lock(name: "testExpiration", timeToLive: 1.0) { unlock in
            XCTAssertNil(unlock)
            let ttl2 = try! self.redis.command("PTTL", params: [ "testExpiration:key" ]).toInt()
            XCTAssertLessThan(ttl2, ttl)
        }
    }
    
    func testUnlock() {
        try! self.redlock.lock(name: "testUnlock", timeToLive: 1.0) { unlock in
            unlock!()
        }
    }
}
