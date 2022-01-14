//
//  TodoListController.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 24.12.2021.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxRelay

final class TodoListController: UIViewController, TodoListView {
    
    // part of the state we must hold here in View, to be a datasource for controls
    // that shows not all data at the time like UITableView, UICollectionView,
    //
    private var todos = BehaviorRelay<[TodoModel]>(value: [TodoModel]())
    private var lockedTaskIds = Set<Int>()
    
    private let cellId = "TodoListCellId"
    private let bag = DisposeBag()
    
    private let presenter: TodoListPresenter
    private let _actionIntent = PublishSubject<TodoListIntent>()
    var actionIntent: Observable<TodoListIntent> { _actionIntent.asObservable() }
    
    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.attributedTitle = NSAttributedString(string: "loading todos")
        return control
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(TodoListCell.self, forCellReuseIdentifier: "TodoListCellId")
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 50
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        tableView.allowsSelection = true
        
        return tableView
    }()
    
    private lazy var refreshButton: UIBarButtonItem = {
        let control = UIBarButtonItem()
        control.image = UIImage(systemName: "arrow.clockwise.circle")
        
        return control
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        let control = UIBarButtonItem()
        control.image = UIImage(systemName: "plus.circle")
        
        return control
    }()
    
    // MARK: - Lifecycle
    init(presenter: TodoListPresenter) {
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
        self._actionIntent.onNext(.start)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self._actionIntent.onNext(.load)
    }
    
    // MARK: - View
    
    private func bindControls() {
        todos.bind(to: tableView.rx.items(cellIdentifier: cellId, cellType: TodoListCell.self)) { [weak self] (_, item, cell) in
            var viewModel = TodoListCell.ViewModel(model: item, onStatusButtonTap: { model in
                self?._actionIntent.onNext(.toggleTodo(model))
            })
            let id = item.id
            let contains = self?.lockedTaskIds.contains(id) ?? false
            viewModel.isLocked = contains
            cell.setupWithViewModel(viewModel)
        }
        .disposed(by: bag)
        
        tableView
            .rx
            .itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                
                guard let self = self,
                    let cell = self.tableView.cellForRow(at: indexPath) as? TodoListCell,
                      let model = cell.viewModel?.todo else { return }
                self._actionIntent.onNext(.editTodo(model))
            })
            .disposed(by: bag)
        
        refreshControl
            .rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { [unowned self] in
                
                print("refreshControl: \(self.refreshControl)")
                if self.refreshControl.isRefreshing {
                    self._actionIntent.onNext(.load)
                }
            })
            .disposed(by: bag)
        
        refreshButton.rx.tap.bind { self._actionIntent.onNext(.load) }.disposed(by: bag)
        addButton.rx.tap.bind { self._actionIntent.onNext(.addTodo) }.disposed(by: bag)
    }
    
    private func layoutView() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewSafeAreaLayoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: viewSafeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: viewSafeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func prepareView() {
        // navigationController?.navigationBar.prefersLargeTitles = true
        title = "List"
        view.backgroundColor = .systemBackground
        tableView.refreshControl = refreshControl
        navigationItem.leftBarButtonItem = refreshButton
        navigationItem.rightBarButtonItem = addButton
    }
    
    func render(for state: TodoListState) {
        todos.accept(state.items)
        lockedTaskIds = state.blockedItems
        
        if state.isLoading && !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
        
        if !state.isLoading && refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        tableView.reloadData()
    }
}
