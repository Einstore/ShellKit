import XCTest
import LocalShell
import NIO


class Tests: XCTestCase {
    
    var shell: LocalExecutor!
    
    override func setUp() {
        super.setUp()
        
        let e = EmbeddedEventLoop()
        shell = LocalExecutor(currentDirectoryPath: "/", on: e)
    }
    
    func testLocalCommand() {
        let out = try! shell.run(bash: "cd /tmp && pwd").future.wait().trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(out, "/tmp")
    }
    
}
