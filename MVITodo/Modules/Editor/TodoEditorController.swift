//
//  TodoEditorController.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 26.12.2021.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxRelay

protocol TodoEditorView: View {
    var actionIntent: Observable<TodoEditorViewIntent> { get }
    func render(for state: TodoEditorState)
}

final class TodoEditorController: UIViewController, TodoEditorView {
    
    private var presenter: TodoEditorPresenter
    private let bag = DisposeBag()
    
    private var todoId: Int = -1
    private var todoIsCompleted = false
    
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
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let control = UIActivityIndicatorView()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.style = .large
        return control
    }()
    
    private let prioritySegmented = UISegmentedControl()
    private let saveBtn = UIBarButtonItem()
    private let cancelBtn = UIBarButtonItem()
    private let _actionIntent = PublishSubject<TodoEditorViewIntent>()
    var actionIntent: Observable<TodoEditorViewIntent> { _actionIntent.asObservable() }
    
    // MARK: - Lifecycle
    init(presenter: TodoEditorPresenter) {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutView()
        prepareView()
        bindControls()
        presenter
            .bindIntents(for: self)
            .subscribe(onNext: { [weak self] state in self?.render(for: state) })
            .disposed(by: bag)
    }
    
    private func bindControls() {
        
        saveBtn.rx.tap.bind { [unowned self] in
            self.isEditing = false
            let todo =
                TodoModel(
                    id: todoId,
                    title: titleField.text ?? "",
                    details: detailsField.text ?? "",
                    priority: prioritySegmented.selectedSegmentIndex + 1,
                    category: categoryField.text ?? "",
                    completed: todoIsCompleted
                )
            self._actionIntent.onNext(.save(todo))
            
        }.disposed(by: bag)
        
        cancelBtn.rx.tap.bind { [unowned self] in
            self.isEditing = false
            self._actionIntent.onNext(.discard)
        }.disposed(by: bag)
    }
    
    private func layoutView() {

        [makeFieldStack(items: [titleLbl, titleField]),
         makeFieldStack(items: [descriptionLbl, detailsField]),
         makeFieldStack(items: [categoryLbl, categoryField]),
         makeFieldStack(items: [priorityLbl, prioritySegmented])].forEach {
            stack.addArrangedSubview($0)
        }
        
        view.addSubview(stack)
        
        view.addSubview(activityIndicator)
        
        let marginsGuide = view.layoutMarginsGuide
        let safeGuide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: marginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: marginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: safeGuide.topAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func prepareView() {
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = cancelBtn
        navigationItem.rightBarButtonItem = saveBtn
        
        prioritySegmented.insertSegment(withTitle: "High", at: 0, animated: false)
        prioritySegmented.insertSegment(withTitle: "Medium", at: 1, animated: false)
        prioritySegmented.insertSegment(withTitle: "Low", at: 2, animated: false)
        prioritySegmented.selectedSegmentIndex = 1
        
        saveBtn.title = "Save"
        cancelBtn.title = "Cancel"
        
        titleLbl.text = "Title"
        titleField.placeholder = "Add todo title string here"
        descriptionLbl.text = "Description"
        detailsField.placeholder = "Add todo description string here"
        categoryLbl.text = "Category"
        categoryField.placeholder = "Add todo category string here"
        priorityLbl.text = "Priority"
    }
    
    func render(for state: TodoEditorState) {
        
        if state.isLoading {
            todoId = state.todo.id
            title = todoId > 0 ? "Edit Todo #\(todoId)" : "New Todo"
            titleField.text = state.todo.title
            detailsField.text = state.todo.details
            categoryField.text = state.todo.category
            prioritySegmented.selectedSegmentIndex = state.todo.priority - 1
            todoIsCompleted = state.todo.completed
        }
        
        saveBtn.isEnabled = !state.isSaving
        cancelBtn.isEnabled = !state.isSaving
        titleField.isEnabled = !state.isSaving
        detailsField.isEnabled = !state.isSaving
        categoryField.isEnabled = !state.isSaving
        prioritySegmented.isEnabled = !state.isSaving
        
        if state.isSaving {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
    }
}
