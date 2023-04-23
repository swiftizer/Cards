//
//  ViewController.swift
//  PPOcards
//
//  Created by Сергей Николаев on 21.03.2023.
//

import UIKit
import Core
import DBCoreData

class ViewController: UIViewController {
    let settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
    lazy var cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)
    lazy var cardController = CardController(dataSource: CoreDataCardRepository(), cardSetController: cardSetController)
    
    enum State {
        case mainOverView
        case cardSetsOverView
        case cardsOverView
        case cardOverView
        case addingSetTitle
        case deletingCardSet
        case updatingCardSet
        case allCardsOverviewRequest
        case notLearnedCardsOverviewRequest
        case enteringNewCardSetTitle(id: UUID)
        case addingCardQuestion
        case addingCardAnswer(question: String)
        case deletingCard
        case updatingCard
        case enteringNewCardData
        case enteringNewCardQuestion
        case enteringNewCardAnswer
        case settingsOverView
        case changingMixingInPower
    }
    
    private var startMenu = "Меню:\n1. Просмотреть наборы\n2. Просмотреть настройки"
    
    private var cardSetsMenu = "Меню:\n1. Добавить набор\n2. Удалить набор\n3. Изменить набор\n4. Просмотреть все карточки\n5. Просмотреть невыученные карточки\n\n0.Назад"
    
    private var cardsMenu = "Меню:\n1. Добавить карточку\n2. Удалить карточку\n3. Изменить карточку\n\n0.Назад"
    
    private func showCardUpdatingMenu(cardID: UUID) -> String {
        let card = cardController.getCard(ID: cardID)!
        let menu = "Карточка: \n\(card.description)\n\nМеню:\n1. Изменить вопрос\n2. Изменить ответ\n3. Пометить как \(card.isLearned ? "невыученную" : "выученную")\n\n0.Назад"
        return menu
    }
    
    private func showSettingsMenu() -> String {
        let settings = settingsController.getSettings()
        let menu = "Настройки: \n\(settings.description)\n\nМеню:\n1. \(settings.isMixed ? "Выключить" : "Включить") перемешивание\n2. Изменить силу подмешивания\n\n0.Назад"
        return menu
    }
    
    private lazy var showCardSets = {
        let cardSets = self.cardSetController.getAllCardSets()
        var menu = "Наборы:\n"
        
        for (n, cs) in cardSets.enumerated() {
            menu += "\n\(n + 1).\n\(cs.description)"
        }
        return menu + "\n\n" + self.cardSetsMenu
    }
    
    private var showNotLearnedCardsFlag = false
    
    func showCardsForSet(id: UUID) -> String {
        var cardIDs = self.cardSetController.getAllCardIDsFromSet(from: id)
        if showNotLearnedCardsFlag {
            cardIDs = self.cardSetController.getNotLearnedCardIDsFromSet(from: id)
        }
        let cards = cardIDs.map { cardController.getCard(ID: $0)! }
        var menu = "\(showNotLearnedCardsFlag ? "Невыученные" : "Все") карточки для набора [\(id)]:\n"
        
        for (n, c) in cards.enumerated() {
            menu += "\n\(n + 1).\n\(c.description)"
        }
        return menu + "\n\n" + self.cardsMenu
    }
    
    private lazy var showAddCardSetMenu = {
        let cardSets = self.cardSetController.getAllCardSets()
        var menu = "Наборы:\n"
        
        for (n, cs) in cardSets.enumerated() {
            menu += "\n\(n + 1).\n\(cs.description)"
        }
        return menu
    }
    
    private var curCardSetId = UUID()
    private var curCardId = UUID()
    
    private var input: String = "" {
        didSet {
            inputTF.text = ""
            
            switch curState {
                
            case .mainOverView:
                switch input {
                case "1":
                    outputContent = showCardSets()
                    curState = .cardSetsOverView
                case "2":
                    outputContent = showSettingsMenu()
                    curState = .settingsOverView
                    
                default:
                    AlertManager.shared.showAlert(presentTo: self, title: nil, message: "Некорректная команда")
                }
            case .cardSetsOverView:
                switch input {
                case "0":
                    outputContent = startMenu
                    curState = .mainOverView
                case "1":
                    outputContent = "Введите название\n\n0. Назад"
                    curState = .addingSetTitle
                case "2":
                    outputContent = "Введите id набора для удаления\n\n0. Назад"
                    curState = .deletingCardSet
                case "3":
                    outputContent = "Введите id набора для изменения\n\n0. Назад"
                    curState = .updatingCardSet
                case "4":
                    outputContent = "Введите id набора для просмотра карточек\n\n0. Назад"
                    curState = .allCardsOverviewRequest
                case "5":
                    outputContent = "Введите id набора для просмотра карточек\n\n0. Назад"
                    curState = .notLearnedCardsOverviewRequest
                    
                default:
                    AlertManager.shared.showAlert(presentTo: self, title: nil, message: "Некорректная команда")
                }
            case .cardOverView:
                print("f")
            case .addingSetTitle:
                switch input {
                case "0":
                    outputContent = showCardSets()
                    curState = .cardSetsOverView
                    
                default:
                    let _ = cardSetController.createCardSet(title: input)
                    outputContent = showCardSets()
                    curState = .cardSetsOverView
                }
            case .deletingCardSet:
                switch input {
                case "0":
                    outputContent = showCardSets()
                    curState = .cardSetsOverView
                    
                default:
                    if !cardSetController.deleteCardSet(ID: UUID(uuidString: input) ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!) {
                        AlertManager.shared.showAlert(presentTo: self, title: nil, message: "Объекта нет в базе!")
                    }
                    outputContent = showCardSets()
                    curState = .cardSetsOverView
                }
            case .updatingCardSet:
                switch input {
                case "0":
                    outputContent = showCardSets()
                    curState = .cardSetsOverView
                    
                default:
                    if let cardSet = cardSetController.getCardSet(ID: UUID(uuidString: input) ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!) {
                        outputContent = "Введите новое название\n\n0. Назад"
                        curState = .enteringNewCardSetTitle(id: cardSet.id)
                    } else {
                        AlertManager.shared.showAlert(presentTo: self, title: nil, message: "Объекта нет в базе!")
                        outputContent = showCardSets()
                        curState = .cardSetsOverView
                    }
                }
            case .enteringNewCardSetTitle(let id):
                switch input {
                case "0":
                    outputContent = "Введите id набора для изменения\n\n0. Назад"
                    curState = .updatingCardSet
                    
                default:
                    var new = cardSetController.getCardSet(ID: id)!
                    new.title = input
                    let _ = cardSetController.updateCardSet(oldID: id, new: new)
                    outputContent = showCardSets()
                    curState = .cardSetsOverView
                }
            case .allCardsOverviewRequest:
                switch input {
                case "0":
                    outputContent = showCardSets()
                    curState = .cardSetsOverView
                    
                default:
                    if let cardSet = cardSetController.getCardSet(ID: UUID(uuidString: input) ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!) {
                        showNotLearnedCardsFlag = false
                        outputContent = showCardsForSet(id: cardSet.id)
                        curCardSetId = cardSet.id
                        curState = .cardsOverView
                    } else {
                        AlertManager.shared.showAlert(presentTo: self, title: nil, message: "Объекта нет в базе!")
                        outputContent = showCardSets()
                        curState = .cardSetsOverView
                    }
                }
            case .notLearnedCardsOverviewRequest:
                switch input {
                case "0":
                    outputContent = showCardSets()
                    curState = .cardSetsOverView
                    
                default:
                    if let cardSet = cardSetController.getCardSet(ID: UUID(uuidString: input) ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!) {
                        showNotLearnedCardsFlag = true
                        outputContent = showCardsForSet(id: cardSet.id)
                        curCardSetId = cardSet.id
                        curState = .cardsOverView
                    } else {
                        AlertManager.shared.showAlert(presentTo: self, title: nil, message: "Объекта нет в базе!")
                        outputContent = showCardSets()
                        curState = .cardSetsOverView
                    }
                }
            case .cardsOverView:
                switch input {
                case "0":
                    outputContent = showCardSets()
                    curState = .cardSetsOverView
                case "1":
                    outputContent = "Введите вопрос\n\n0. Назад"
                    curState = .addingCardQuestion
                case "2":
                    outputContent = "Введите id карточки для удаления\n\n0. Назад"
                    curState = .deletingCard
                case "3":
                    outputContent = "Введите id карточки для изменения\n\n0. Назад"
                    curState = .updatingCard
                    
                default:
                    AlertManager.shared.showAlert(presentTo: self, title: nil, message: "Некорректная команда")
                }
            case .addingCardQuestion:
                switch input {
                case "0":
                    outputContent = showCardsForSet(id: curCardSetId)
                    curState = .cardsOverView
                    
                default:
                    outputContent = "Введите ответ\n\n0. Назад"
                    curState = .addingCardAnswer(question: input)
                }
            case .addingCardAnswer(let question):
                switch input {
                case "0":
                    outputContent = "Введите вопрос\n\n0. Назад"
                    curState = .addingCardQuestion
                    
                default:
                    let _ = cardSetController.addCard(card: Card(id: UUID(), setID: curCardSetId, questionText: question, answerText: input, isLearned: false), toSet: curCardSetId)
                    outputContent = showCardsForSet(id: curCardSetId)
                    curState = .cardsOverView
                }
            case .deletingCard:
                switch input {
                case "0":
                    outputContent = showCardsForSet(id: curCardSetId)
                    curState = .cardsOverView
                    
                default:
                    if !cardController.deleteCard(ID: UUID(uuidString: input) ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!) {
                        AlertManager.shared.showAlert(presentTo: self, title: nil, message: "Объекта нет в базе!")
                    }
                    outputContent = showCardsForSet(id: curCardSetId)
                    curState = .cardsOverView
                }
            case .updatingCard:
                switch input {
                case "0":
                    outputContent = showCardsForSet(id: curCardSetId)
                    curState = .cardsOverView
                    
                default:
                    if let card = cardController.getCard(ID: UUID(uuidString: input) ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!) {
                        curCardId = card.id
                        outputContent = showCardUpdatingMenu(cardID: card.id)
                        curState = .enteringNewCardData
                    } else {
                        AlertManager.shared.showAlert(presentTo: self, title: nil, message: "Объекта нет в базе!")
                        outputContent = showCardsForSet(id: curCardSetId)
                        curState = .cardsOverView
                    }
                }
            case .enteringNewCardData:
                switch input {
                case "0":
                    outputContent = showCardsForSet(id: curCardSetId)
                    curState = .cardsOverView
                case "1":
                    outputContent = "Введите новый вопрос\n\n0. Назад"
                    curState = .enteringNewCardQuestion
                case "2":
                    outputContent = "Введите новый ответ\n\n0. Назад"
                    curState = .enteringNewCardAnswer
                case "3":
                    var card = cardController.getCard(ID: curCardId)!
                    card.isLearned = !card.isLearned
                    let _ = cardController.updateCard(oldID: curCardId, new: card)
                    curState = .enteringNewCardData
                    outputContent = showCardUpdatingMenu(cardID: card.id)
                    
                default:
                    AlertManager.shared.showAlert(presentTo: self, title: nil, message: "Некорректная команда")
                }
            case .enteringNewCardQuestion:
                switch input {
                case "0":
                    curState = .enteringNewCardData
                    outputContent = showCardUpdatingMenu(cardID: curCardId)
                    
                default:
                    var card = cardController.getCard(ID: curCardId)!
                    card.questionText = input
                    let _ = cardController.updateCard(oldID: curCardId, new: card)
                    curState = .enteringNewCardData
                    outputContent = showCardUpdatingMenu(cardID: curCardId)
                }
            case .enteringNewCardAnswer:
                switch input {
                case "0":
                    curState = .enteringNewCardData
                    outputContent = showCardUpdatingMenu(cardID: curCardId)
                    
                default:
                    var card = cardController.getCard(ID: curCardId)!
                    card.answerText = input
                    let _ = cardController.updateCard(oldID: curCardId, new: card)
                    curState = .enteringNewCardData
                    outputContent = showCardUpdatingMenu(cardID: curCardId)
                }
            case .settingsOverView:
                switch input {
                case "0":
                    outputContent = startMenu
                    curState = .mainOverView
                case "1":
                    var settings = settingsController.getSettings()
                    settings.isMixed = !settings.isMixed
                    let _ = settingsController.updateSettings(to: settings)
                    curState = .settingsOverView
                    outputContent = showSettingsMenu()
                case "2":
                    outputContent = "Введите новую силу подмешивания (от 0 до 100)\n\n0. Назад"
                    curState = .changingMixingInPower
                    
                default:
                    AlertManager.shared.showAlert(presentTo: self, title: nil, message: "Некорректная команда")
                }
            case .changingMixingInPower:
                if let newPower = Int(input), newPower >= 0, newPower <= 100 {
                    var settings = settingsController.getSettings()
                    settings.mixingInPower = newPower
                    let _ = settingsController.updateSettings(to: settings)
                    curState = .settingsOverView
                    outputContent = showSettingsMenu()
                } else {
                    AlertManager.shared.showAlert(presentTo: self, title: nil, message: "Некорректное значение")
                    curState = .settingsOverView
                    outputContent = showSettingsMenu()
                }
            }
        }
    }
    
    private var curState: State = .mainOverView {
        didSet {
            
        }
    }
    
    private lazy var outputContent = "" {
        didSet {
            outputTV.text = outputContent
        }
    }
    
    private let outputTV = UITextView()
    private var inputTF = UITextField()
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.tintColor = .white
        button.setImage(UIImage(systemName: "chevron.right.circle"), for: .normal)
        button.addTarget(self, action: #selector(done), for: .touchUpInside)
        return button

    }()

    override func loadView() {
        super.loadView()
        Logger.shared.log(lvl: .INFO, msg: "VC loadView called")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Logger.shared.log(lvl: .INFO, msg: "VC viewDidLoad called")
        
        setupUI()
        setupDB()
        
        outputContent = startMenu
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Logger.shared.log(lvl: .INFO, msg: "VC viewWillAppear called")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        Logger.shared.log(lvl: .INFO, msg: "VC viewWillLayoutSubviews called")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Logger.shared.log(lvl: .INFO, msg: "VC viewDidLayoutSubviews called")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Logger.shared.log(lvl: .INFO, msg: "VC viewDidAppear called")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Logger.shared.log(lvl: .INFO, msg: "VC viewWillDisappear called")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Logger.shared.log(lvl: .INFO, msg: "VC viewDidDisappear called")
    }
    
    deinit {
        Logger.shared.log(lvl: .INFO, msg: "VC deinited")
    }
    
    private func setupDB() {
        cardSetController.cardController = cardController
        
//        fillDB()
    }
    
    private func fillDB() {
        let setID1 = cardSetController.createCardSet(title: "test1").id
        let setID2 = cardSetController.createCardSet(title: "test2").id
        let setID3 = cardSetController.createCardSet(title: "test3").id
        
        var c11 = cardController.createCard(for: setID1)
        c11.answerText = "Answer11"
        c11.questionText = "Question11"
        c11.isLearned = true
        let _ = cardController.updateCard(oldID: c11.id, new: c11)
        var c12 = cardController.createCard(for: setID1)
        c12.answerText = "Answer12"
        c12.questionText = "Question12"
        c12.isLearned = false
        let _ = cardController.updateCard(oldID: c12.id, new: c12)
        var c13 = cardController.createCard(for: setID1)
        c13.answerText = "Answer13"
        c13.questionText = "Question13"
        c13.isLearned = true
        let _ = cardController.updateCard(oldID: c13.id, new: c13)
        
        var c21 = cardController.createCard(for: setID2)
        c21.answerText = "Answer21"
        c21.questionText = "Question21"
        c21.isLearned = false
        let _ = cardController.updateCard(oldID: c21.id, new: c21)
        var c22 = cardController.createCard(for: setID2)
        c22.answerText = "Answer22"
        c22.questionText = "Question22"
        c22.isLearned = false
        let _ = cardController.updateCard(oldID: c22.id, new: c22)
        
        var c31 = cardController.createCard(for: setID3)
        c31.answerText = "Answer31"
        c31.questionText = "Question31"
        c31.isLearned = false
        let _ = cardController.updateCard(oldID: c31.id, new: c31)
        var c32 = cardController.createCard(for: setID3)
        c32.answerText = "Answer32"
        c32.questionText = "Question32"
        c32.isLearned = false
        let _ = cardController.updateCard(oldID: c32.id, new: c32)
        var c33 = cardController.createCard(for: setID3)
        c33.answerText = "Answer33"
        c33.questionText = "Question33"
        c33.isLearned = true
        let _ = cardController.updateCard(oldID: c33.id, new: c33)
        var c34 = cardController.createCard(for: setID3)
        c34.answerText = "Answer34"
        c34.questionText = "Question34"
        c34.isLearned = false
        let _ = cardController.updateCard(oldID: c34.id, new: c34)
    }
    
    private func setupUI() {
        view.addSubview(outputTV)
        view.addSubview(inputTF)
        view.addSubview(doneButton)
        
        [inputTF].forEach {
            $0.font = UIFont.boldSystemFont(ofSize: 16)
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
            $0.layer.cornerRadius = 15
            $0.autocorrectionType = .no
            $0.leftViewMode = .always
            $0.returnKeyType = .done
            $0.keyboardType = .numbersAndPunctuation
            $0.clearButtonMode = .whileEditing
            $0.backgroundColor = .systemGray6
            $0.textColor = .label
            $0.tintColor = .label
            $0.delegate = self
        }
        
        outputTV.delegate = self
        outputTV.font = UIFont.boldSystemFont(ofSize: 16)
        outputTV.backgroundColor = .systemGray6
        outputTV.layer.cornerRadius = 15
        outputTV.tintColor = .label
        outputTV.textContainer.lineFragmentPadding = 10
        
        outputTV.frame = .init(x: 25, y: 115, width: view.bounds.width - 50, height: view.bounds.height/2)
        inputTF.frame = .init(x: 25, y: 50, width: view.bounds.width - 50, height: 50)
        doneButton.frame = .init(x: view.bounds.width - 80, y: 55, width: 50, height: 40)
    }
    
    @objc
    private func done() -> String {
        input = inputTF.text!
        return inputTF.text!
    }
}


extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        done()
        return true
    }
}

extension ViewController: UITextViewDelegate {
    
}
