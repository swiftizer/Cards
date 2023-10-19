//
//  EditCardVC.swift
//  PPOcards
//
//  Created by ser.nikolaev on 29.04.2023.
//

import UIKit
import PinLayout
import Core
import Logger
import FileManager
import Services

final class EditCardVC: UIViewController {
    private let questionTV = UITextView()
    private let answerTV = UITextView()
    private var imagePicker: ImagePicker?
    private let isLearnedLabel = UILabel()
    private let questionLabel = UILabel()
    private let answerLabel = UILabel()
    private let isLearnedSwitcher = UISwitch()
    
    private lazy var addQuestionImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.tintColor = .white
        button.setImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        return button
    }()
    private lazy var addAnswerImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.tintColor = .white
        button.setImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        return button
    }()
    
    private lazy var showQuestionImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.tintColor = .white
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.addTarget(self, action: #selector(showQuestionImage), for: .touchUpInside)
        return button
    }()
    
    private lazy var showAnswerImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.tintColor = .white
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.addTarget(self, action: #selector(showAnswerImage), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteQuestionImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.tintColor = .red
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.addTarget(self, action: #selector(deleteQuestionImage), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteAnswerImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.tintColor = .red
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.addTarget(self, action: #selector(deleteAnswerImage), for: .touchUpInside)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        button.tintColor = .white
        button.setImage(UIImage(systemName: "chevron.right.circle"), for: .normal)
        button.addTarget(self, action: #selector(done), for: .touchUpInside)
        return button
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        return button
    }()


    private let readOnlyFlag: Bool
    private let card: Card?
    private let completion: ((Card?) -> ())?
    
    private var pickerSource: ImgSource = .question
    
    private lazy var resCard = card
    
    convenience init() {
        self.init(card: nil, completion: nil, readOnlyFlag: false)
    }
    
    init(card: Card?, completion: ((Card?) -> ())?, readOnlyFlag: Bool = false) {
        self.readOnlyFlag = readOnlyFlag
        self.card = card
        self.completion = completion
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
        closeButton.frame = .init(x: view.frame.width-50, y: 0, width: 50, height: 50)
        Logger.shared.log(lvl: .VERBOSE, msg: "VC viewDidLayoutSubviews called")
        
        questionLabel.pin
            .top(view.pin.safeArea.top + 20)
            .left(20)
            .width(100)
            .sizeToFit(.width)
        
        questionTV.pin
            .topLeft(to: questionLabel.anchor.bottomLeft)
            .marginTop(15)
//            .top(view.pin.safeArea.top + 20)
//            .left(20)
            .right(20)
            .height(view.bounds.height*0.3)
        
        addQuestionImageButton.pin
            .topLeft(to: questionTV.anchor.bottomLeft)
            .width(50)
            .height(40)
            .marginTop(15)
        
        showQuestionImageButton.pin
            .topLeft(to: addQuestionImageButton.anchor.topRight)
            .width(50)
            .height(40)
            .marginLeft(15)
        
        deleteQuestionImageButton.pin
            .topLeft(to: showQuestionImageButton.anchor.topRight)
            .width(50)
            .height(40)
            .marginLeft(15)
        
        answerLabel.pin
            .topLeft(to: addQuestionImageButton.anchor.bottomLeft)
            .marginTop(15)
            .width(100)
            .sizeToFit(.width)
        
        answerTV.pin
            .topLeft(to: answerLabel.anchor.bottomLeft)
            .right(20)
            .marginTop(15)
            .height(view.bounds.height*0.3)
        
        addAnswerImageButton.pin
            .topLeft(to: answerTV.anchor.bottomLeft)
            .width(50)
            .height(40)
            .marginTop(15)
        
        showAnswerImageButton.pin
            .topLeft(to: addAnswerImageButton.anchor.topRight)
            .width(50)
            .height(40)
            .marginLeft(15)
        
        deleteAnswerImageButton.pin
            .topLeft(to: showAnswerImageButton.anchor.topRight)
            .width(50)
            .height(40)
            .marginLeft(15)
        
        doneButton.pin
            .topRight(to: answerTV.anchor.bottomRight)
            .width(50)
            .height(40)
            .marginTop(15)
        
        isLearnedLabel.pin
            .topLeft(to: addAnswerImageButton.anchor.bottomLeft)
            .height(40)
            .marginTop(15)
            .sizeToFit(.height)
        
        isLearnedSwitcher.pin
            .centerLeft(to: isLearnedLabel.anchor.centerRight)
            .marginLeft(20)
            .marginTop(5)
            .width(50)
            .height(40)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Logger.shared.log(lvl: .VERBOSE, msg: "VC viewDidAppear called")
        
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        if #available(iOS 14.0, *) {
            addAnswerImageButton.menu = createImagePickerMenu(for: .answer)
            addAnswerImageButton.showsMenuAsPrimaryAction = true
            addQuestionImageButton.menu = createImagePickerMenu(for: .question)
            addQuestionImageButton.showsMenuAsPrimaryAction = true
        }
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
        
        view.addSubview(questionLabel)
        view.addSubview(questionTV)
        view.addSubview(answerLabel)
        view.addSubview(answerTV)
        view.addSubview(addAnswerImageButton)
        view.addSubview(addQuestionImageButton)
        view.addSubview(showAnswerImageButton)
        view.addSubview(showQuestionImageButton)
        view.addSubview(deleteAnswerImageButton)
        view.addSubview(deleteQuestionImageButton)
        view.addSubview(doneButton)
        view.addSubview(isLearnedLabel)
        view.addSubview(isLearnedSwitcher)
        view.addSubview(closeButton)

        [questionTV, answerTV].forEach {
            $0.font = UIFont.boldSystemFont(ofSize: 16)
            $0.backgroundColor = .black
            $0.layer.cornerRadius = 15
            $0.tintColor = .label
            $0.textContainer.lineFragmentPadding = 10
            $0.isEditable = !readOnlyFlag
        }
        
        isLearnedLabel.text = "Is learned"
        isLearnedSwitcher.isOn = resCard?.isLearned ?? false
        
        questionTV.text = card?.questionText
        answerTV.text = card?.answerText
        
        addAnswerImageButton.isUserInteractionEnabled = !readOnlyFlag
        addQuestionImageButton.isUserInteractionEnabled = !readOnlyFlag
        
        showQuestionImageButton.isHidden = MyFileManager.shared.getImageFromFS(path: card?.questionImageURL) == nil
        showAnswerImageButton.isHidden = MyFileManager.shared.getImageFromFS(path: card?.answerImageURL) == nil
        deleteAnswerImageButton.isHidden = MyFileManager.shared.getImageFromFS(path: card?.answerImageURL) == nil || readOnlyFlag
        deleteQuestionImageButton.isHidden = MyFileManager.shared.getImageFromFS(path: card?.questionImageURL) == nil || readOnlyFlag
        
        doneButton.isHidden = readOnlyFlag
        isLearnedLabel.isHidden = readOnlyFlag
        isLearnedSwitcher.isHidden = readOnlyFlag
        
        questionLabel.text = "Question:"
        answerLabel.text = "Answer:"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    public func createImagePickerMenu(for type: ImgSource) -> UIMenu {
        let photoAction = UIAction(
            title: "Камера",
            image: UIImage(systemName: "camera")
          ) { [unowned self] (_) in
              self.imagePicker?.performAction(type: .camera)
              switch type {
              case .question:
                  pickerSource = .question
              case .answer:
                  pickerSource = .answer
              }
          }

        let albumAction = UIAction(
            title: "Галерея",
            image: UIImage(systemName: "square.stack")
        ) { [unowned self] (_) in
            self.imagePicker?.performAction(type: .photoLibrary)
            switch type {
            case .question:
                pickerSource = .question
            case .answer:
                pickerSource = .answer
            }
        }

        let menuActions = [photoAction, albumAction]

        let addNewMenu = UIMenu(
            title: "",
            children: menuActions)

          return addNewMenu
    }
    
    enum ImgSource {
        case question
        case answer
    }
    
    func createDeniedAlertController() {
        let alert = UIAlertController(
            title: "Требуется разрешение, чтобы добавлять фото",
            message: "Пожалуйста, включите разрешение в настройках",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Отмена", style: .destructive)
        let settingsAction = UIAlertAction(
            title: "Настройки",
            style: .default
        ) { [weak self] _ in
            self?.openSettings()
        }
        alert.addAction(cancelAction)
        alert.addAction(settingsAction)
        present(alert, animated: true)
    }
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc
    private func showQuestionImage() {
        present(ImageViewerVC(image: MyFileManager.shared.getImageFromFS(path: resCard?.questionImageURL)), animated: true)
    }
    
    @objc
    private func showAnswerImage() {
        present(ImageViewerVC(image: MyFileManager.shared.getImageFromFS(path: resCard?.answerImageURL)), animated: true)
    }
    
    @objc
    private func deleteQuestionImage() {
        showQuestionImageButton.isHidden = true
        deleteQuestionImageButton.isHidden = true
    }
    
    @objc
    private func deleteAnswerImage() {
        showAnswerImageButton.isHidden = true
        deleteAnswerImageButton.isHidden = true
    }
    
    @objc
    private func done() {
        resCard?.questionText = questionTV.text
        resCard?.answerText = answerTV.text
        if showQuestionImageButton.isHidden {
            MyFileManager.shared.deleteFile(at: resCard?.questionImageURL)
            resCard?.questionImageURL = nil
        }
        if showAnswerImageButton.isHidden {
            MyFileManager.shared.deleteFile(at: resCard?.answerImageURL)
            resCard?.answerImageURL = nil
        }
        resCard?.isLearned = isLearnedSwitcher.isOn
        completion?(resCard)
        dismiss(animated: true)
    }
    
    @objc
    private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        [answerTV, questionTV].forEach {
            $0.resignFirstResponder()
        }
    }

    @objc
    private func closeButtonPressed() {
        dismiss(animated: true)
    }
}

extension EditCardVC: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard let image = image else {
            return
        }
        dismissKeyboard(UITapGestureRecognizer())
        
        switch pickerSource {
        case .question:
            resCard?.questionImageURL = MyFileManager.shared.putImageToFS(with: image)
            showQuestionImageButton.isHidden = false
            deleteQuestionImageButton.isHidden = false
        case .answer:
            resCard?.answerImageURL = MyFileManager.shared.putImageToFS(with: image)
            showAnswerImageButton.isHidden = false
            deleteAnswerImageButton.isHidden = false
        }
    }
}
