//
//  AlertManager.swift
//  PPOcards
//
//  Created by ser.nikolaev on 15.04.2023.
//

import UIKit

public protocol BasicAlertDescription {
    func showAlert(presentTo: UIViewController, title: String?, message: String?)
}

public final class AlertManager: BasicAlertDescription {
    public static let shared: BasicAlertDescription = AlertManager()
    
    private init() {}
    
    public func showAlert(presentTo controller: UIViewController, title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(okAction)
        controller.present(alertController, animated: true, completion: nil)
    }
}
