import XCTest
import CommandKit
import NIO


class Tests: XCTestCase {
    
    var shell: Shell!
    
    override func setUp() {
        super.setUp()
        
        shell = try! Shell(.local)
    }
    
    func testLocalCommand() {
        var out = try! shell.cmd.which("ls").wait()
        XCTAssertEqual(out, "/bin/ls")
        
        out = try! shell.run(bash: "echo $PATH").wait()
        print(out)
        
        out = try! shell.cmd.which("docker").wait()
        XCTAssertEqual(out, "/usr/local/bin/docker")
    }
    
}
