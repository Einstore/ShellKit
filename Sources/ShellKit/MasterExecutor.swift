import ExecutorKit


public protocol MasterExecutor: Executor {
    
    var executor: Executor { get }
    
}
