//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController: UIViewController {
    
    private func makeLabel() -> UILabel {
        let control = UILabel()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.numberOfLines = 0
        return control
    }
    
    private func makeTextField() -> UITextField {
        let control = UITextField()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.borderStyle = .roundedRect
        return control
    }
    
    private func makeFieldStack(items: [UIView]) -> UIStackView {
        let control = UIStackView(arrangedSubviews: items)
        control.axis = .vertical
        control.translatesAutoresizingMaskIntoConstraints = false
        control.alignment = .fill
        control.distribution = .fillEqually
        control.spacing = 3.0
        return control
    }
    
    private lazy var titleLbl: UILabel = { makeLabel() }()
    private lazy var titleField: UITextField = { makeTextField() }()
        
    private lazy var descriptionLbl: UILabel = { makeLabel() }()
    private lazy var detailsField: UITextField = { makeTextField() }()
    
    private lazy var categoryLbl: UILabel = { makeLabel() }()
    private lazy var categoryField: UITextField = { makeTextField() }()
    
    private lazy var priorityLbl: UILabel = { makeLabel() }()
    
    private lazy var stack: UIStackView = {
        let control = UIStackView()
        control.axis = .vertical
        control.translatesAutoresizingMaskIntoConstraints = false
        control.alignment = .fill
        control.distribution = .fillEqually
        control.spacing = 12.0
        return control
    }()
    
    private lazy var prioritySegmented: UISegmentedControl = {
        let control = UISegmentedControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 1
        return control
    }()
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        self.view = view
        
        layoutView()
        prepareView()
    }
    
    func layoutView() {
        [makeFieldStack(items: [titleLbl, titleField]),
         makeFieldStack(items: [descriptionLbl, detailsField]),
         makeFieldStack(items: [categoryLbl, categoryField]),
         makeFieldStack(items: [priorityLbl, prioritySegmented])]
            .forEach {
                stack.addArrangedSubview($0)
            }
        
        view.addSubview(stack)
        
        let marginsGuide = view.layoutMarginsGuide
        let safeGuide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: marginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: marginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: safeGuide.topAnchor)
        ])
    }
    
    func prepareView() {
        view.backgroundColor = .systemBackground
        
        prioritySegmented.insertSegment(withTitle: "High", at: 0, animated: false)
        prioritySegmented.insertSegment(withTitle: "Medium", at: 1, animated: false)
        prioritySegmented.insertSegment(withTitle: "Low", at: 2, animated: false)
        prioritySegmented.selectedSegmentIndex = 1
        
        titleLbl.text = "Title"
        titleField.placeholder = "Add todo title string here"
        descriptionLbl.text = "Description"
        detailsField.placeholder = "Add todo description string here"
        categoryLbl.text = "Category"
        categoryField.placeholder = "Add todo category string here"
        priorityLbl.text = "Priority"
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
