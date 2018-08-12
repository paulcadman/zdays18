import UIKit
import PlaygroundSupport

var str = "Hello, playground"

final class ZDaysFormCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let contentStackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.spacing = 12
        contentStackView.layoutMargins = .init(top: 24, left: 24, bottom: 24, right: 24)
        contentStackView.alignment = .leading
        
        contentStackView.addArrangedSubview(titleLabel)
        titleLabel.text = str
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        self.contentView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            self.contentStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.contentStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.contentStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.contentStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ZDaysFormListViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 400
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return ZDaysFormCell(style: .default, reuseIdentifier: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

let vc = ZDaysFormListViewController()
vc.preferredContentSize = .init(width: 376, height: 1000)
PlaygroundPage.current.liveView = vc
