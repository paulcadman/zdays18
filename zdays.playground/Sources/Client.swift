import RxSwift


public class Client {
    public var events: Observable<Void>
    
    var _events = PublishSubject<Void>()
    var bag = DisposeBag()
    
    public init() {
        events = _events.asObservable()
    }
    
    public func submit(_ value: Int) {
         Observable.just(())
            .delay(5.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in self?._events.onNext(()) })
            .disposed(by: bag)

    }
}
