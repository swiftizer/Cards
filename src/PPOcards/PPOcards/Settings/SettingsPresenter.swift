//
//  SettingsPresenter.swift
//  PPOcards
//
//  Created by ser.nikolaev on 01.05.2023.
//

import Foundation
import Core

final class SettingsPresenter {
    private let settingsController: SettingsControllerDescription?
    
    init(settingsController: SettingsControllerDescription?) {
        self.settingsController = settingsController
    }
    
    var sliderValue: Float {
        Float((settingsController?.getSettings().mixingInPower ?? 0))/100
    }
    
    var isMixingValue: Bool {
        settingsController?.getSettings().isMixed ?? false
    }
    
    func sliderDidStopEditing(newSliderValue: Float) {
        if var settings = settingsController?.getSettings() {
            settings.mixingInPower = Int(round(newSliderValue * 100))
            let _ = settingsController?.updateSettings(to: settings)
        }
    }
    
    func switherEdit(newState: Bool) {
        if var settings = settingsController?.getSettings() {
            settings.isMixed = newState
            let _ = settingsController?.updateSettings(to: settings)
        }
    }
}
