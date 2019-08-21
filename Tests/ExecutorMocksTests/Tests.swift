import XCTest
import ExecutorMocks
import CommandKit
import NIO


class Tests: XCTestCase {
    
    var shell: ExecutorMock!
    
    override func setUp() {
        super.setUp()
        
        shell = try! ExecutorMock()
    }
    
    func testBasicMock() {
        let hu = "huhuhuhu :)"
        shell.mockResults["najs woe"] = [hu]
        let out = try! shell.run(bash: "najs woe", output: nil).wait()
        XCTAssertEqual(out, hu)
    }
    
    func testCommandMock() {
        shell.mockResults["ls /tmp"] = [
            "file1"
        ]
        let out = try! shell.cmd.ls(path: "/tmp").wait()
        XCTAssertEqual(out, "file1")
    }
    
}
