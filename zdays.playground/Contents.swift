import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport


enum FormState {
    case invalid
    case valid(number: Int)
    case submitting(number: Int)
    case submitted
}

enum FormEvent {
    case clear
    case select(number: Int)
    case submit
    case confirm
}

struct FormStateMachine: StateMachine {
    typealias State = FormState
    typealias Event = FormEvent
    
    func update(from state: State, with event: Event) -> State {
        switch (state, event) {
        case (.submitting, .confirm):
            return .submitted
        case (.submitting, _):
            return state
        case (_, .select(let item)):
            return .valid(number: item)
        case (_, .clear):
            return .invalid
        case (.valid(let number), .submit):
            return .submitting(number: number)
        case (_, .submit):
            return state
        case (_, .confirm):
            return .invalid
        }
    }
}

final class RxStateProcessor<S: StateMachine> {
    private let state: Observable<S.State>
    
    init(wrapping base: S, initialState: S.State, events: Observable<S.Event>) {
        state = events.scan(initialState, accumulator: base.update(from:with:))
    }
    
    func process(with sideEffect: @escaping (S.State) -> Void) -> Disposable {
        return self.state
            .subscribeOn(MainScheduler.instance)
            .do(onNext: sideEffect).subscribe()
    }
}

// setup components

let viewController = ZDaysFormViewController()
let network = Network()


// Events

let networkEvents = network.events.map { _ in FormEvent.confirm }

let tapEvents = viewController.button.tap.map { _ in FormEvent.submit }

let selectEvents = viewController.selector.events.map { event -> FormEvent in
    switch event {
    case .select(let number):
        return .select(number: number)
    case .clear:
        return .clear
    }
}

let allEvents = Observable.merge(tapEvents, selectEvents, networkEvents)

// Side effects

let field = viewController.field
let button = viewController.button


// State machine

let loggingMachine = LoggingStateMachine(wrapping: FormStateMachine())

let machine = RxStateProcessor(wrapping: loggingMachine,
                               initialState: FormState.invalid,
                               events: allEvents)

// Execution

machine.process { state in
    switch state {
    case .invalid:
        field.enable()
        field.set(.empty)
        button.disable()
    case .valid(let number):
        field.set(.selected(number))
        button.enable()
    case .submitting(let number):
        button.disable()
        field.disable()
        network.submit(number)
    case .submitted:
        button.disable()
        field.enable()
        field.set(.empty)
    }
}

viewController.display(using: PlaygroundPage.current)
