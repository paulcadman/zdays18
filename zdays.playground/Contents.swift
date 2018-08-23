import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport

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

class Field {
    let title: String
    let bag = DisposeBag()
    let fieldPickerDelegate = FieldPickerDelegate()
    
    init(title: String) {
        self.title = title
    }
    
    func makeView() -> UIView {
        let topStack = makeBasicStackView(axis: .vertical)
        topStack.spacing = 12
        topStack.layoutMargins = .init(top: 40, left: 40, bottom: 40, right: 40)
        
        let topLabel = UILabel()
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
    
        toolBar.setItems([cancelButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textFieldTop.inputAccessoryView = toolBar
        
        picker.rx.itemSelected.subscribe(onNext: { row, _ in
            textFieldTop.text = String(row)
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


public final class ZDaysFormViewController: UIViewController {
    let field = Field(title: "Value")
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let button = UIButton(type: .roundedRect)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.red, for: .disabled)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        
        let stack = makeBasicStackView(axis: .vertical)
        stack.spacing = 12
        
        stack.addArrangedSubview(field.makeView())
        stack.addArrangedSubview(button)
        
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
        window.rootViewController = self
        window.makeKeyAndVisible()
        
        page.needsIndefiniteExecution = true
        page.liveView = window
    }
}


ZDaysFormViewController().display(using: PlaygroundPage.current)
