
func stateMachine(state: State, event: Event) -> (Action, State) {
    switch (state.field, state.button, event) {
        
    case (.empty, _, .field(.select(let value))):
        return ({}, State(field: .filled(value: value), button: state.button))
        
    case (.empty, _, .button):
        return ({}, state)
    case (.filled, _, _):
        return ({}, state)
    }
}

typealias Action = () -> Void

protocol StateMachine {
    associatedtype State
    associatedtype Event
    
    func update(from state: State, with event: Event) -> (Action, State)
}

struct ActiveMachine: StateMachine {
    func update(from state: FilledFormState, with event: FilledFormEvent) -> (Action, FilledFormState) {
        fatalError()
    }
}

enum InputFieldState {
    case empty
    case filled(activeMachine: ActiveMachine)
}

enum FilledFormState {
    case ready
    case loading
}

enum FilledFormEvent {
    case submit
}
