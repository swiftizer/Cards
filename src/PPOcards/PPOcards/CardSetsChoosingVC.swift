//
//  CardSetsChoosingVC.swift
//  PPOcards
//
//  Created by ser.nikolaev on 08.05.2023.
//

import UIKit
import PinLayout
import Core
import DBCoreData
import Logger

class CardSetsChoosingVC: UIViewController {
    private var cardController: CardControllerDescription?
    private var cardSetController: CardSetControllerDescription?
    private let cardSetID: UUID
    
    var completion: ((UUID) -> ())?
    
    private let cardSetsTV = UITableView()
    
    convenience init() {
        self.init(config: PresenterConfig(cardController: nil, cardSetController: nil, cardSetID: nil))
    }
    
    init(config: PresenterConfig) {
        cardSetController = config.cardSetController
        cardController = config.cardController
        cardSetID = config.cardSetID ?? UUID()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var getCardSets: [CardSet] {
        var res = self.cardSetController?.getAllCardSets() ?? []
        var ind = res.firstIndex { $0.id == cardSetID } ?? 0
        res.remove(at: ind)
        
        return res
    }
    private lazy var cardSets = getCardSets
    
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
    
    private func setupUI() {
        view.addSubview(cardSetsTV)
        cardSetsTV.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        cardSetsTV.delegate = self
        cardSetsTV.dataSource = self
    }
}

extension CardSetsChoosingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cardSets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        var content = cell.defaultContentConfiguration()
        
        let cardSet = cardSets[indexPath.row]
        
        content.text = cardSet.title
        content.secondaryText = "\(cardSet.learnedCardsCount)/\(cardSet.allCardsCount)"

        cell.contentConfiguration = content
        
        let red = (255 - 255 * cardSet.learnedCardsCount / (cardSet.allCardsCount == 0 ? 1 : cardSet.allCardsCount)) << 16
        let green = (255 - (red >> 16)) << 8
        cell.backgroundColor = UIColor(rgb: red + green).withAlphaComponent(0.6)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        completion?(cardSets[indexPath.row].id)
        dismiss(animated: true)
    }
}

