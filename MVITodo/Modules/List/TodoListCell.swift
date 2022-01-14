//
//  TodoListCell.swift
//  MVITodo
//
//  Created by Oleksandr Karpenko on 24.12.2021.
//

import UIKit
import RxSwift

final class TodoListCell: UITableViewCell {
    
    struct ViewModel {
        
        let todo: TodoModel
        var priorityImage: UIImage? {
            
            if todo.priority == 1 {
                return UIImage(systemName: "h.circle")
            }
            
            if todo.priority == 3 {
                return UIImage(systemName: "l.circle")
            }
                
            return UIImage(systemName: "m.circle")
            
        }
        var stateImage: UIImage? {
            if todo.completed {
                return UIImage(systemName: "checkmark.circle")
            }
            return UIImage(systemName: "circle.dashed")
        }
        var onStatusButtonTap: ((TodoModel) -> Void)?
        
        var isLocked: Bool = false
        
        init(model: TodoModel, onStatusButtonTap: ((TodoModel) -> Void)?) {
            self.todo = model
            self.onStatusButtonTap = onStatusButtonTap
        }
    }
    
    var viewModel: ViewModel?

    private(set) var bag = DisposeBag()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var priorityImage: UIImageView = {
        let control = UIImageView()
        control.contentMode = .scaleToFill
        return control
    }()
    
    private lazy var doneStatusButton: UIButton = {
        let control = UIButton()
        var config = UIButton.Configuration.tinted()
        control.configuration = config
        control.addTarget(self, action: #selector(self.statusButtonTapped), for: .touchUpInside)
        return control
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        bag = DisposeBag()
    }
    
    private func setupLayout() {
        backgroundColor = .clear
        
        [priorityImage, titleLabel, categoryLabel, doneStatusButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            priorityImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            priorityImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
            priorityImage.widthAnchor.constraint(equalToConstant: 30),
            priorityImage.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: priorityImage.trailingAnchor, constant: 8),
            
            categoryLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: priorityImage.trailingAnchor, constant: 8),
            
            doneStatusButton.widthAnchor.constraint(equalToConstant: 50),
            doneStatusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            doneStatusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22)
        ])
        
    }
    
    func setupWithViewModel(_ viewModel: ViewModel) {
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.todo.title
        categoryLabel.text = viewModel.todo.category
        priorityImage.image = viewModel.priorityImage
        doneStatusButton.setImage(viewModel.stateImage, for: .normal)
        doneStatusButton.configuration?.showsActivityIndicator = viewModel.isLocked
    }
    
    @objc func statusButtonTapped() {
        if let viewModel = viewModel, let action = viewModel.onStatusButtonTap {
            action(viewModel.todo)
        }
    }
}
