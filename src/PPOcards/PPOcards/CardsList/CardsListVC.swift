//
//  CardsListVC.swift
//  PPOcards
//
//  Created by ser.nikolaev on 29.04.2023.
//

import UIKit
import PinLayout
import Logger

final class CardsListVC: UIViewController {
    private let presenter: CardsListPresenter
    weak var rootVC: CardsLearningVC?
    private var changedFlag = false
    
    private let cardsTV = UITableView()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.addTarget(self, action: #selector(addCardButtonPressed), for: .touchUpInside)
        return button
    }()
    
    convenience init() {
        self.init(rootVC: nil, config: PresenterConfig(cardController: nil, cardSetController: nil, cardSetID: nil))
    }
    
    init(rootVC: CardsLearningVC?, config: PresenterConfig) {
        presenter = CardsListPresenter(config: config)
        self.rootVC = rootVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        Logger.shared.log(lvl: .VERBOSE, msg: "VC loadView called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Logger.shared.log(lvl: .VERBOSE, msg: "VC viewDidLoad called")
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Logger.shared.log(lvl: .VERBOSE, msg: "VC viewWillAppear called")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        Logger.shared.log(lvl: .VERBOSE, msg: "VC viewWillLayoutSubviews called")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Logger.shared.log(lvl: .VERBOSE, msg: "VC viewDidLayoutSubviews called")
        
        addButton.frame = .init(x: view.frame.width-50, y: 0, width: 50, height: 50)
        cardsTV.frame = .init(x: 0, y: 50, width: view.frame.width, height: view.frame.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Logger.shared.log(lvl: .VERBOSE, msg: "VC viewDidAppear called")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Logger.shared.log(lvl: .VERBOSE, msg: "VC viewWillDisappear called")
        if changedFlag {
            rootVC?.reload()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Logger.shared.log(lvl: .VERBOSE, msg: "VC viewDidDisappear called")
    }
    
    deinit {
        Logger.shared.log(lvl: .WARNING, msg: "VC deinited")
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(cardsTV)
        view.addSubview(addButton)
        cardsTV.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        cardsTV.delegate = self
        cardsTV.dataSource = self
        cardsTV.separatorStyle = .singleLine
        cardsTV.separatorColor = .label
        
        presenter.dataEditedNotify = {
            self.cardsTV.reloadData()
            self.changedFlag = true
        }
    }
    
    @objc
    private func addCardButtonPressed() {
        let vc = presenter.prepareEditCardVCForAdd()
        self.present(vc, animated: true)
    }
}

extension CardsListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfTVRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        let card = presenter.cardForTVRow(index: indexPath.row)
        
        content.text = (card?.questionText ?? "") + presenter.rateForCard(index: indexPath.row)
        content.secondaryText = card?.answerText

        cell.contentConfiguration = content
        cell.backgroundColor = (card?.isLearned ?? false) ? .systemGreen.withAlphaComponent(0.5) : .systemRed.withAlphaComponent(0.5)
        cell.accessoryView = UIImageView(image: UIImage(systemName: "square.and.pencil")?.withTintColor(UIColor.label, renderingMode: .alwaysOriginal))

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = presenter.prepareEditCardVCForEdit(index: indexPath.row)
        self.present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, sourceView, completionHandler) in
            
            self.presenter.deleteCard(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.changedFlag = true
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        
        // *********** SHARE ***********
        let shareAction = UIContextualAction(style: .normal, title: "Share") {
            (action, sourceView, completionHandler) in
            let choosingVC = self.presenter.prepareCardSetsChoosingVC(index: indexPath.row)
            
            self.present(choosingVC, animated: true)
        }
        
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        shareAction.backgroundColor = UIColor(red: 255/255.0, green: 128.0/255.0, blue: 0.0, alpha: 1.0)
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        
        return swipeConfiguration
    }
}
