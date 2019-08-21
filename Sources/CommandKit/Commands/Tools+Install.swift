import Foundation


extension Install {
    
    /// Install HomeBrew
    ///     - Note: macOS only
    public func brew() -> EventLoopFuture<Void> {
        return shell.run(bash: "/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"", output: nil).future.void()
    }
    
    /// Install cURL
    ///     - Note: brew & apt
    public func curl() -> EventLoopFuture<Void> {
        return package(named: "curl")
    }
    
    /// Install wget
    ///     - Note: brew & apt
    public func wget() -> EventLoopFuture<Void> {
        return package(named: "wget")
    }
    
    /// Generic install function
    ///     - Note: brew & apt
    public func package(named name: String) -> EventLoopFuture<Void> {
        return shell.cmd.os().flatMap { os in
            switch os {
            case .macOs:
                return self.shell.run(bash: "brew install \(name)", output: nil).future.void()
            case .linux:
                return self.shell.run(bash: "sudo apt-get install \(name)", output: nil).future.void()
            default:
                return self.shell.eventLoop.makeFailedFuture(Cmd.CmdError.unsupportedPlatform)
            }
        }
    }
    
    /// Einstore own system monitoring server
    ///     - Note: macOS only
    public func systemator() -> EventLoopFuture<Void> {
        return shell.cmd.os().flatMap { os in
            switch os {
            case .macOs:
                return self.shell.run(bash: "brew install einstore/homebrew-tap/systemator", output: nil).future.void()
            default:
                return self.shell.eventLoop.makeFailedFuture(Cmd.CmdError.unsupportedPlatform)
            }
        }
    }
    
}

