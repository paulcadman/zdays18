import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport

protocol StateMachine {
    associatedtype State
    associatedtype Event
    
    func update(from state: State, with event: Event) -> State
}

enum FormState {
    case invalid
    case valid(number: Int)
    case submitted
}

enum FormEvent {
    case clear
    case select(number: Int)
    case submit
}

struct FormStateMachine: StateMachine {
    typealias State = FormState
    typealias Event = FormEvent
    
    func update(from state: State, with event: Event) -> State {
        switch (state, event) {
        case (_, .select(let item)):
            return .valid(number: item)
        case (_, .clear):
            return .invalid
        case (.valid, .submit):
            return .submitted
        case (_, .submit):
            return state
        }
    }
}

final class RxStateMachine<S: StateMachine> {
    private let state: Observable<S.State>
    
    init(wrapping base: S, initialState: S.State, events: Observable<S.Event>) {
        state = events.scan(initialState, accumulator: base.update(from:with:))
    }
    
    func run(with sideEffect: @escaping (S.State) -> Void) -> Disposable {
        return self.state.do(onNext: sideEffect).subscribe()
    }
}

let viewController = ZDaysFormViewController()

let selectEvents = viewController.selector.selected.map { event -> FormEvent in
    switch event {
    case .select(let number):
        return .select(number: number)
    case .clear:
        return .clear
    }
}

let tapEvents = viewController.button.tap.map { _ in FormEvent.submit }

let allEvents = Observable.merge(tapEvents, selectEvents)

let machine = RxStateMachine(wrapping: FormStateMachine(),
                             initialState: FormState.invalid,
                             events: allEvents)

machine.run { state in
    switch state {
    case .invalid:
        viewController.field.value.onNext(.unset)
        viewController.button.isEnabled.onNext(false)
    case .valid(let number):
        viewController.field.value.onNext(.set(number))
        viewController.button.isEnabled.onNext(true)
    case .submitted:
        viewController.button.isEnabled.onNext(false)
    }
}

viewController.display(using: PlaygroundPage.current)
