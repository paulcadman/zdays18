import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport

public enum FieldState<Value> {
    case set(Value)
    case unset
}

public enum FieldEvent<Value> {
    case select(Value)
    case clear
}

public struct Field<Value> {
    public var value: AnyObserver<FieldState<Value>>
}

public struct Selector<Value> {
    public var selected: Observable<FieldEvent<Value>>
}

public struct Button {
    public var isEnabled: AnyObserver<Bool>
}

func makeBasicStackView(axis: NSLayoutConstraint.Axis) -> UIStackView {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = axis
    stack.isLayoutMarginsRelativeArrangement = true
    
    return stack
}

class FieldPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
}

final class NumberPickerField {
    let value: AnyObserver<FieldState<Int>>
    let selected: Observable<FieldEvent<Int>>
    
    private let _value = BehaviorSubject<FieldState<Int>>(value: .unset)
    private let _selected = PublishSubject<FieldEvent<Int>>()
    
    private let title: String
    private let bag = DisposeBag()
    private let fieldPickerDelegate = FieldPickerDelegate()
    
    init(title: String) {
        self.title = title
        value = _value.asObserver()
        selected = _selected
    }
    
    func makeView() -> UIView {
        let topStack = makeBasicStackView(axis: .vertical)
        topStack.spacing = 12
        topStack.layoutMargins = .init(top: 20, left: 40, bottom: 40, right: 40)
        topStack.distribution = .fill
        
        let topLabel = UILabel()
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topLabel.text = title
        let textFieldTop = UITextField()
        
        let picker = UIPickerView()
        
        picker.delegate = self.fieldPickerDelegate
        picker.dataSource = self.fieldPickerDelegate
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = .blue
        toolBar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(title: "Clear", style: .plain, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: nil, action: nil)
        
        cancelButton.rx.tap.subscribe(onNext: { _ in
            textFieldTop.text = nil
            textFieldTop.resignFirstResponder() }).disposed(by: bag)
        
        doneButton.rx.tap.subscribe(onNext: { _ in
            textFieldTop.resignFirstResponder() }).disposed(by: bag)
        
        textFieldTop.inputAssistantItem.leadingBarButtonGroups.removeAll()
        textFieldTop.inputAssistantItem.trailingBarButtonGroups.removeAll()
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([flexible, cancelButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textFieldTop.inputAccessoryView = toolBar
        
        _value.map { value -> String? in
            switch value {
            case .set(let v):
                return String(v)
            case .unset:
                return nil
            }
            }.bind(to: textFieldTop.rx.text).disposed(by: bag)
        
        picker.rx.itemSelected.subscribe(onNext: { (row, _) in
            self._selected.onNext(.select(row))
        }).disposed(by: bag)
        
        textFieldTop.autocorrectionType = .no
        textFieldTop.borderStyle = .roundedRect
        textFieldTop.inputView = picker
        textFieldTop.translatesAutoresizingMaskIntoConstraints = false
        
        topStack.addArrangedSubview(topLabel)
        topStack.addArrangedSubview(textFieldTop)
        topStack.alignment = .fill
        
        return topStack
    }
}

final class SubmitButton {
    let isEnabled: AnyObserver<Bool>
    let bag = DisposeBag()
    
    private let _isEnabled = BehaviorSubject<Bool>(value: false)
    
    init() {
        isEnabled = _isEnabled.asObserver()
    }
    
    func makeView() -> UIView {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.red, for: .disabled)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        _isEnabled.bind(to: button.rx.isEnabled).disposed(by: bag)
        return button
    }
}

public final class ZDaysFormViewController: UIViewController {
    private let numberPicker = NumberPickerField(title: "Pick a number")
    private let _button = SubmitButton()
    
    public let field: Field<Int>
    public let selector: Selector<Int>
    public let button: Button
    
    public init() {
        field = Field(value: numberPicker.value)
        selector = Selector(selected: numberPicker.selected)
        button = Button(isEnabled: _button.isEnabled)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let stack = makeBasicStackView(axis: .vertical)
        stack.spacing = 12
        
        stack.addArrangedSubview(numberPicker.makeView())
        stack.addArrangedSubview(_button.makeView())
        
        stack.layoutMargins = .init(top: 40, left: 40, bottom: 40, right: 40)
        
        self.view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: self.view.topAnchor)])
    }
}

extension UIViewController {
    public func display(using page: PlaygroundPage) {
        let window = UIWindow(frame: CGRect(x: 0,
                                            y: 0,
                                            width: 768,
                                            height: 1024))
        window.backgroundColor = .white
        window.rootViewController = self
        window.makeKeyAndVisible()
        
        page.needsIndefiniteExecution = true
        page.liveView = window
    }
}