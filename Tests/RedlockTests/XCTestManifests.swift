extension RedlockTests {
    static var allTests : [(String, (RedlockTests) -> () throws -> Void)] {
        return [
            ("testLock", testLock),
            ("testDoubleLock", testDoubleLock),
            ("testExpiration", testExpiration),
            ("testUnlock", testUnlock)
        ]
    }
}
