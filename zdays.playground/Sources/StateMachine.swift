import RxSwift

public protocol StateMachine {
    associatedtype State
    associatedtype Event
    
    func update(from state: State, with event: Event) -> State
}


public struct LoggingStateMachine<S: StateMachine>: StateMachine {
    
    var wrapping: S
    
    public init(wrapping: S) {
        self.wrapping = wrapping
    }
    
    public func update(from state: S.State, with event: S.Event) -> S.State {
        print("previous state: \(state)")
        print("new event: \(event)")
        
        let newState = wrapping.update(from: state, with: event)
        print("new state: \(newState)")
        print()
        return newState
    }
}

public struct DebugEventStateMachine<S: StateMachine>: StateMachine {
    
    var wrapping: S
    public var debugString: Observable<String>
    
    private var _debugString = PublishSubject<String>()
    
    public init(wrapping: S) {
        self.wrapping = wrapping
        self.debugString = _debugString.asObservable()
    }
    
    public func update(from state: S.State, with event: S.Event) -> S.State {

        let newState = wrapping.update(from: state, with: event)
        
        _debugString.onNext("""
previous state: \(state)
new event: \(event)
new state: \(newState)
""")
        return newState
    }
}
