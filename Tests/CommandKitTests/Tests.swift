import XCTest
import CommandKit
import NIO


class Tests: XCTestCase {
    
    var shell: Shell!
    
    override func setUp() {
        super.setUp()
        
        shell = try! Shell(.local)
    }
    
    func testPWD() {
        try! shell.cd(path: "/tmp").wait()
        let origPath = try! shell.cmd.pwd().wait()
        XCTAssertEqual(origPath, "/tmp")
        
        var out = try! shell.cmd.pwd(relativePath: "~/.ssh").wait()
        XCTAssertTrue(out.contains("/.ssh"))
        XCTAssertTrue(!out.contains("~"))
        
        out = try! shell.cmd.pwd().wait()
        XCTAssertEqual(out, origPath)
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
