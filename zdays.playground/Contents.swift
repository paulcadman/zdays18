import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport

protocol StateMachine {
    associatedtype State
    associatedtype Event
    
    func update(from state: State, with event: Event) -> State
}

struct FormStateMachine: StateMachine {
    typealias State = FieldState<Int>
    typealias Event = FieldEvent<Int>
    
    func update(from state: State, with event: Event) -> State {
        switch (state, event) {
        case (_, .select(let item)):
            return .set(item)
        case (_, .clear):
            return .unset
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

let selectEvents = viewController.selector.selected

let machine = RxStateMachine(wrapping: FormStateMachine(),
                             initialState: FieldState<Int>.unset,
                             events: selectEvents)

machine.run { state in
    switch state {
    case .unset:
        viewController.field.value.onNext(.unset)
        viewController.button.isEnabled.onNext(false)
    case .set(let value):
        viewController.field.value.onNext(.set(value))
        viewController.button.isEnabled.onNext(true)
    }
}

viewController.display(using: PlaygroundPage.current)
