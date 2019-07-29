import Foundation
import WebErrorKit


/// Basic Shell error
public enum ShellError: SerializableWebError {
    
    /// Bad exit code error
    case badExitCode(command: String, exit: Exit, output: String)
    
    /// Umable to convert string to `.utf8` data
    case unableToConvertStringToData
    
    /// Process has been terminated manually
    case processTerminated
    
    public var serializedCode: String {
        switch self {
        case .badExitCode:
            return "bad_exit_code"
        case .unableToConvertStringToData:
            return "unable_to_convert_string_to_data"
        case .processTerminated:
            return "process_terminated"
        }
    }
    
    public var reason: String? {
        switch self {
        case .badExitCode(let command, let exit, _):
            let termination = exit.terminationReason == .exit ? "Exit" : "Signal"
            return "\(termination) \(exit.terminationStatus) received for \(command)"
        case .unableToConvertStringToData:
            return "Unabe to convert `String` to `Data`"
        case .processTerminated:
            return "Process has been manually terminated"
        }
    }
    
}
