import Foundation
import Redbird
import Redscript

public class Redlock {
    let redis: Redbird
    let redscript: Redscript
    
    public init(redis: Redbird) {
        self.redis = redis
        self.redscript = Redscript(redis: redis)
    }
    
    func lock(name: String, timeToLive: TimeInterval, handler: ((((Void)->Void)?) -> Void)) throws {
        let key = "\(name):key"
        
        let identifier = UUID().uuidString.data(using: .utf8)!.base64EncodedString()
        let timeToLiveMilliseconds = String(Int(timeToLive * 1000.0))
        let response = try self.redis.command("SET", params: [ key, identifier, "NX", "PX", timeToLiveMilliseconds ])

        if response.respType == .Error {
            handler(nil)
        } else if response.respType == .NullBulkString {
            handler(nil)
        } else {
            handler({
                try! self.unlock(name: name, identifier: identifier)
            })
        }
    }

    func unlock(name: String, identifier: String) throws {
        let script = try self.redscript.load(source: parityDel, name: "parityDel")
        _ = try self.redscript.run(script: script, params: [ String(1), "\(name):key", identifier])
    }
}

let parityDel =
    "local key = KEYS[1]\n" +
    "local content = ARGV[1]\n" +
    "local value = redis.call('get', key)\n" +
    "if value == content then\n" +
    "    return redis.call('del', key);\n" +
    "end\n" +
    "return 0"
