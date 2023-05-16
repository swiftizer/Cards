//
//  CardsVC.swift
//  PPOcards
//
//  Created by ser.nikolaev on 29.04.2023.
//

import UIKit
import PinLayout
import Logger

final class CardsLearningVC: UIViewController {
    private let presenter: CardsLearningPresenter
    
    private let counterLabel = UILabel()
    private let learningContainer = UIView()
    private let curNotlearnedCardView = UIView()
    private let cardFeedbackView = UIView()
    private let curTextLabel = UILabel()
    private let curImageView = UIImageView()
    private let progressLabel = UILabel()
    
    private let acceptButton = UIButton()
    private let declineButton = UIButton()
    private let restartButton = UIButton()
    private let cardsListButton = UIButton()
    
    private var curSide = CardSide.question
    
    convenience init() {
        self.init(config: PresenterConfig(cardController: nil, cardSetController: nil, cardSetID: nil))
    }
    
    init(config: PresenterConfig) {
        presenter = CardsLearningPresenter(config: config)
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
        
        learningContainer.pin
            .left()
            .right()
            .top(view.pin.safeArea.top)
            .height(view.bounds.height*0.7)
        
        counterLabel.pin
            .hCenter()
            .top()
            .maxHeight(28)
            .maxWidth(view.bounds.width)
            .sizeToFit(.width)
        
        curNotlearnedCardView.pin
            .hCenter()
            .top(30)
            .bottom(55)
            .width(learningContainer.bounds.width*0.75)
        
        cardFeedbackView.frame = curNotlearnedCardView.bounds
        
        layoutForCard(.question)
        
        acceptButton.pin
            .width(50)
            .height(40)
            .topRight(to: curNotlearnedCardView.anchor.bottomRight)
            .marginTop(15)
        
        declineButton.pin
            .width(50)
            .height(40)
            .topLeft(to: curNotlearnedCardView.anchor.bottomLeft)
            .marginTop(15)
        
        restartButton.pin
            .width(100)
            .height(70)
            .center()
        
        cardsListButton.pin
            .width(50)
            .height(40)
            .bottom(view.pin.safeArea.bottom)
            .hCenter()
        
        progressLabel.pin
            .topCenter(to: curNotlearnedCardView.anchor.bottomCenter)
            .marginTop(15)
            .maxHeight(28)
            .maxWidth(view.bounds.width)
            .sizeToFit(.width)
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
        view.backgroundColor = .systemBackground
        view.addSubview(learningContainer)
        view.addSubview(cardsListButton)
        learningContainer.addSubview(counterLabel)
        learningContainer.addSubview(curNotlearnedCardView)
        learningContainer.addSubview(acceptButton)
        learningContainer.addSubview(declineButton)
        learningContainer.addSubview(restartButton)
        learningContainer.addSubview(progressLabel)
        curNotlearnedCardView.addSubview(cardFeedbackView)
        curNotlearnedCardView.addSubview(curTextLabel)
        curNotlearnedCardView.addSubview(curImageView)
        
        curNotlearnedCardView.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        curNotlearnedCardView.layer.borderWidth = 2
        curNotlearnedCardView.layer.cornerRadius = 10
        curNotlearnedCardView.isUserInteractionEnabled = true
        let tapOnViewGR = UITapGestureRecognizer()
        tapOnViewGR.addTarget(self, action: #selector(turn))
        curNotlearnedCardView.addGestureRecognizer(tapOnViewGR)
        
        curImageView.isUserInteractionEnabled = true
        let tapOnImageGR = UITapGestureRecognizer()
        tapOnImageGR.addTarget(self, action: #selector(showImage))
        curImageView.addGestureRecognizer(tapOnImageGR)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressRecognizer.minimumPressDuration = 0.5
        curNotlearnedCardView.addGestureRecognizer(longPressRecognizer)
        
        acceptButton.layer.cornerRadius = 10
        acceptButton.backgroundColor = .systemGreen.withAlphaComponent(0.6)
        acceptButton.setImage(UIImage(systemName: "checkmark")?.withTintColor(UIColor.label, renderingMode: .alwaysOriginal), for: .normal)
        acceptButton.addTarget(self, action: #selector(accept), for: .touchUpInside)
        
        declineButton.layer.cornerRadius = 10
        declineButton.backgroundColor = .systemRed.withAlphaComponent(0.6)
        declineButton.setImage(UIImage(systemName: "xmark")?.withTintColor(UIColor.label, renderingMode: .alwaysOriginal), for: .normal)
        declineButton.addTarget(self, action: #selector(decline), for: .touchUpInside)
        
        restartButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle")?.withTintColor(UIColor.label, renderingMode: .alwaysOriginal), for: .normal)
        restartButton.addTarget(self, action: #selector(restart), for: .touchUpInside)
        restartButton.isHidden = presenter.curNotlearnedCard != nil
        restartButton.layer.cornerRadius = 20
        restartButton.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        restartButton.layer.borderWidth = 2
        
        cardsListButton.setImage(UIImage(systemName: "list.bullet.below.rectangle")?.withTintColor(UIColor.label, renderingMode: .alwaysOriginal), for: .normal)
        cardsListButton.addTarget(self, action: #selector(showCardsList), for: .touchUpInside)
        cardsListButton.layer.borderColor = UIColor.label.withAlphaComponent(0.6).cgColor
        cardsListButton.layer.borderWidth = 2
        cardsListButton.layer.cornerRadius = 10
        
        if let _ = presenter.curNotlearnedCard {
            layoutForCard(.question)
        } else {
            acceptButton.isHidden = true
            declineButton.isHidden = true
            restartButton.isHidden = false
            curNotlearnedCardView.isHidden = true
            progressLabel.isHidden = true
        }
        
        counterLabel.text = presenter.counterLabelText()
        counterLabel.textAlignment = .center
        curTextLabel.textAlignment = .center
        curTextLabel.numberOfLines = 0
        
        cardFeedbackView.layer.cornerRadius = 10
        cardFeedbackView.isHidden = true
        
        progressLabel.text = presenter.progressLabelText()
        progressLabel.textAlignment = .center
        
        presenter.nextCardNotify = {
            self.counterLabel.text = self.presenter.counterLabelText()
            self.progressLabel.text = self.presenter.progressLabelText()
        }
    }
    
    private func layoutForCard(_ side: CardSide) {
        let data = presenter.prepareCardLayout(side: side)
        let text = data.0
        let image = ImagesProvider.shared.getImageFromDB(path: data.1)
        
        curImageView.isHidden = true
        if let image = image, let text = text, text != "" {
            curImageView.image = image
            curTextLabel.text = text
            curTextLabel.pin
                .hCenter()
                .vCenter(-curNotlearnedCardView.bounds.height/4)
                .maxWidth(curNotlearnedCardView.bounds.width)
                .maxHeight(curNotlearnedCardView.bounds.height/2)
                .sizeToFit(.width)
            
            curImageView.isHidden = false
            curImageView.contentMode = .scaleAspectFit
            curImageView.pin
                .hCenter()
                .vCenter(curNotlearnedCardView.bounds.height/4)
                .maxWidth(curNotlearnedCardView.bounds.width)
                .maxHeight(curNotlearnedCardView.bounds.height/2)
                .sizeToFit(.width)
        } else if let text = text, image == nil {
            curTextLabel.text = text
            curTextLabel.pin
                .center()
                .maxWidth(curNotlearnedCardView.bounds.width)
                .maxHeight(curNotlearnedCardView.bounds.height)
                .sizeToFit(.width)
        } else if let image = image {
            curTextLabel.text = ""
            curImageView.image = image
            curImageView.isHidden = false
            curImageView.contentMode = .scaleAspectFit
            curImageView.pin
                .center()
                .maxWidth(curNotlearnedCardView.bounds.width)
                .maxHeight(curNotlearnedCardView.bounds.height*0.75)
                .sizeToFit(.width)
        }
    }
    
    func reload() {
        presenter.reload()
        counterLabel.text = presenter.counterLabelText()
        progressLabel.text = presenter.progressLabelText()
        
        if let _ = presenter.curNotlearnedCard {
            layoutForCard(.question)
        } else {
            acceptButton.isHidden = true
            declineButton.isHidden = true
            restartButton.isHidden = false
            curNotlearnedCardView.isHidden = true
            progressLabel.isHidden = true
        }
    }
    
    @objc
    private func turn() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if curSide == .question {
            layoutForCard(.answer)
            curSide = .answer
        } else {
            layoutForCard(.question)
            curSide = .question
        }
    }
    
    @objc
    private func accept() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        presenter.accept()
        
        cardFeedbackView.isHidden = false
        cardFeedbackView.backgroundColor = .green
        cardFeedbackView.alpha = 0.4
        
        UIView.animate(withDuration: 0.5) {
            self.cardFeedbackView.alpha = 0
        } completion: { _ in
            self.cardFeedbackView.isHidden = true
            if let _ = self.presenter.curNotlearnedCard {
                self.layoutForCard(.question)
            } else {
                self.acceptButton.isHidden = true
                self.declineButton.isHidden = true
                self.restartButton.isHidden = false
                self.curNotlearnedCardView.isHidden = true
                self.progressLabel.isHidden = true
            }
        }
    }
    
    @objc
    private func decline() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        presenter.decline()
        
        cardFeedbackView.isHidden = false
        cardFeedbackView.backgroundColor = .red
        cardFeedbackView.alpha = 0.4
        
        UIView.animate(withDuration: 0.5) {
            self.cardFeedbackView.alpha = 0
        } completion: { _ in
            self.cardFeedbackView.isHidden = true
            if let _ = self.presenter.curNotlearnedCard {
                self.layoutForCard(.question)
            } else {
                self.acceptButton.isHidden = true
                self.declineButton.isHidden = true
                self.restartButton.isHidden = false
                self.curNotlearnedCardView.isHidden = true
                self.progressLabel.isHidden = true
            }
        }
    }
    
    @objc
    private func restart() {
        acceptButton.isHidden = false
        declineButton.isHidden = false
        restartButton.isHidden = true
        curNotlearnedCardView.isHidden = false
        progressLabel.isHidden = false
        
        presenter.restart()
        
        if let _ = presenter.curNotlearnedCard {
            layoutForCard(.question)
        } else {
            acceptButton.isHidden = true
            declineButton.isHidden = true
            restartButton.isHidden = false
            curNotlearnedCardView.isHidden = true
        }
    }
    
    @objc
    private func showImage() {
        navigationController?.pushViewController(ImageViewerVC(image: curImageView.image), animated: true)
    }
    
    @objc
    private func showCardsList() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let vc = presenter.prepareCardsListVC(rootVC: self)
        navigationController?.present(vc, animated: true)
    }
    
    @objc
    private func handleLongPress() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let vc = presenter.prepareEditCardVC()
        self.present(vc, animated: true)
    }
}
