import Foundation

struct State {
    var field: FieldState
    var button: ButtonState
}


enum Event {
    case field(FieldEvent)
    case button(ButtonEvent)
}

enum FieldState {
    case empty
    case filled(value: Int)
}

enum ButtonState {
    case enabled
    case disabled
}

enum FieldEvent {
    case select(value: Int)
}

enum ButtonEvent {
    case click
}

func fsm(state: State, event: Event) -> (Action, State) {
    switch (state.field, state.button, event) {
        
    case (.empty, _, .field(.select(let value))):
        return ({}, State(field: .filled(value: value), button: state.button))
        
    case (.empty, _, .button):
        return ({}, state)
    case (.filled, _, _):
        return ({}, state)
    }
}

