//
//  SettingsVC.swift
//  PPOcards
//
//  Created by ser.nikolaev on 30.04.2023.
//

import UIKit
import PinLayout
import Logger


final class SettingsVC: UIViewController {
    private let presenter: SettingsPresenter
    private var refillAction: (() -> ())
    
    private let isMixedLabel = UILabel()
    private let mixingSwitcher = UISwitch()
    private let mixingInPowerLabel = UILabel()
    private let mixingInPowerSlider = UISlider()
    private let mixingInPowerValueLabel = UILabel()
    private let refillButton = UIButton()
    
    convenience init() {
        self.init(presenter: SettingsPresenter(settingsController: nil), refillAction: {})
    }
    
    init(presenter: SettingsPresenter, refillAction: @escaping () -> ()) {
        self.presenter = presenter
        self.refillAction = refillAction
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
        
        isMixedLabel.pin
            .left(20)
            .top(view.pin.safeArea.top + 40)
            .height(40)
            .sizeToFit(.height)
        
        mixingSwitcher.pin
            .centerLeft(to: isMixedLabel.anchor.centerRight)
            .width(50)
            .height(40)
            .marginTop(5)
            .marginLeft(10)
        
        mixingInPowerLabel.pin
            .topLeft(to: isMixedLabel.anchor.bottomLeft)
            .marginTop(20)
            .height(40)
            .sizeToFit(.height)
        
        mixingInPowerSlider.pin
            .centerLeft(to: mixingInPowerLabel.anchor.centerRight)
            .marginLeft(10)
            .right(20)
            .height(40)
        
        mixingInPowerValueLabel.pin
            .topCenter(to: mixingInPowerSlider.anchor.bottomCenter)
            .width(100)
            .height(40)
            .sizeToFit(.width)
        
        refillButton.pin
            .center()
            .width(50)
            .height(40)
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
        view.addSubview(isMixedLabel)
        view.addSubview(mixingSwitcher)
        view.addSubview(mixingInPowerLabel)
        view.addSubview(mixingInPowerSlider)
        view.addSubview(mixingInPowerValueLabel)
        view.addSubview(refillButton)
        
        mixingInPowerSlider.addTarget(self, action: #selector(handleSliderChange(slider:)), for: .valueChanged)
        
        mixingInPowerSlider.addTarget(self, action: #selector(handleSliderDidStopEditing), for: .allTouchEvents)
        
        mixingSwitcher.addTarget(self, action: #selector(handleSwitherEdit), for: .valueChanged)
        
        refillButton.addTarget(self, action: #selector(refillDB), for: .touchUpInside)
        refillButton.layer.cornerRadius = 10
        refillButton.backgroundColor = .red.withAlphaComponent(0.8)
        refillButton.tintColor = .white
        refillButton.setImage(UIImage(systemName: "arrow.counterclockwise"), for: .normal)
        
        isMixedLabel.text = "Is mixing: "
        mixingInPowerLabel.text = "Mixing in power: "
        mixingInPowerSlider.value = presenter.sliderValue
        mixingInPowerValueLabel.text = "\(Int(round(mixingInPowerSlider.value * 100)))"
        mixingInPowerValueLabel.textAlignment = .center
        mixingSwitcher.isOn = presenter.isMixingValue
    }
    
    @objc
    private func handleSliderChange(slider: UISlider) {
        mixingInPowerValueLabel.text = "\(Int(round(mixingInPowerSlider.value * 100)))"
    }
    
    @objc
    private func handleSliderDidStopEditing() {
        presenter.sliderDidStopEditing(newSliderValue: mixingInPowerSlider.value)
    }
    
    @objc
    private func handleSwitherEdit() {
        presenter.switherEdit(newState: mixingSwitcher.isOn)
    }
    
    @objc
    private func refillDB() {
        refillAction()
        
        mixingInPowerSlider.value = presenter.sliderValue
        mixingInPowerValueLabel.text = "\(Int(round(mixingInPowerSlider.value * 100)))"
        mixingSwitcher.isOn = presenter.isMixingValue
    }
}
