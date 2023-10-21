//
//  ViewController.swift
//  PPOcards
//
//  Created by Сергей Николаев on 21.03.2023.
//

import UIKit
import PinLayout
import Logger

class CardSetsVC: UIViewController {
    private let cardSetsTV = UITableView()
    private let presenter = CardSetsPresenter()
    private let refreshControl = UIRefreshControl()

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(didPullToRefresh))
        ]
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
        presenter.viewWillAppear()
        cardSetsTV.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        Logger.shared.log(lvl: .VERBOSE, msg: "VC viewWillLayoutSubviews called")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Logger.shared.log(lvl: .VERBOSE, msg: "VC viewDidLayoutSubviews called")
        
        cardSetsTV.frame = view.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Logger.shared.log(lvl: .VERBOSE, msg: "VC viewDidAppear called")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Logger.shared.log(lvl: .VERBOSE, msg: "VC viewWillDisappear called")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Logger.shared.log(lvl: .VERBOSE, msg: "VC viewDidDisappear called")
    }
    
    deinit {
        Logger.shared.log(lvl: .WARNING, msg: "VC deinited")
    }
    
    private func fillDB() {
        presenter.fillDB()
        cardSetsTV.reloadData()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func setupUI() {
        view.addSubview(cardSetsTV)
        cardSetsTV.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        cardSetsTV.addSubview(refreshControl)

        cardSetsTV.delegate = self
        cardSetsTV.dataSource = self
        
        navigationItem.leftBarButtonItem = .init(image: UIImage(systemName: "gearshape")?.withTintColor(.label, renderingMode: .alwaysOriginal), style: .done, target: self, action: #selector(didTapSettingsButton))
        navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "plus")?.withTintColor(.label, renderingMode: .alwaysOriginal), style: .done, target: self, action: #selector(didTapAddButton))
    }
    
    @objc
    private func didTapAddButton() {
        let alertController = UIAlertController(title: "New set", message: "Enter set name", preferredStyle: .alert)

        alertController.addTextField()

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            let name = alertController.textFields?.first?.text ?? ""

            self.presenter.addCardSetAction(name: name)
            self.cardSetsTV.reloadData()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc
    private func didTapSettingsButton() {
        let vc = presenter.setupSettingsVCToPresent(with: fillDB)
        present(vc, animated: true)
    }

    @objc
    private func didPullToRefresh() {
        presenter.didPullToRefrash()
        self.cardSetsTV.reloadData()
    }
}

extension CardSetsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfTVRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        var content = cell.defaultContentConfiguration()
        
        let cardSet = presenter.cardSetForTVRow(index: indexPath.row)
        
        content.text = cardSet.title
        content.secondaryText = "\(cardSet.learnedCardsCount)/\(cardSet.allCardsCount)"

        cell.contentConfiguration = content
        
        let red = (255 - 255 * cardSet.learnedCardsCount / (cardSet.allCardsCount == 0 ? 1 : cardSet.allCardsCount)) << 16
        let green = (255 - (red >> 16)) << 8
        cell.backgroundColor = UIColor(rgb: red + green).withAlphaComponent(0.6)
        cell.accessoryType = .disclosureIndicator

        if indexPath.row == presenter.numberOfTVRows() - 1 {
            refreshControl.endRefreshing()
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = presenter.setupCardsLearningVCToPush(index: indexPath.row)
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, sourceView, completionHandler) in
            
            self.presenter.deleteCardSetFromTV(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        
        // *********** EDIT ***********
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            (action, sourceView, completionHandler) in
            let alertController = UIAlertController(title: "Edit set", message: "Enter new name", preferredStyle: .alert)

            alertController.addTextField()
            alertController.textFields?.first?.text = self.presenter.getCardSetTitle(index: indexPath.row)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let addAction = UIAlertAction(title: "Rename", style: .default) { _ in
                let name = alertController.textFields?.first?.text ?? ""

                self.presenter.updateCardSetFromTV(index: indexPath.row, name: name)
                self.cardSetsTV.reloadData()
            }

            alertController.addAction(cancelAction)
            alertController.addAction(addAction)
            self.present(alertController, animated: true, completion: nil)
            completionHandler(true)
        }
        
        editAction.image = UIImage(systemName: "square.and.pencil")
        editAction.backgroundColor = UIColor(red: 255/255.0, green: 128.0/255.0, blue: 0.0, alpha: 1.0)
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return swipeConfiguration
    }
}
