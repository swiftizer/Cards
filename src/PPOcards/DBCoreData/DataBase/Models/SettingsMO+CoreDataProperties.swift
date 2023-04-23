//
//  SettingsMO+CoreDataProperties.swift
//  PPOcards
//
//  Created by Сергей Николаев on 01.04.2023.
//
//

import Foundation
import CoreData


extension SettingsMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingsMO> {
        return NSFetchRequest<SettingsMO>(entityName: "SettingsMO")
    }

    @NSManaged public var isMixed: Bool
    @NSManaged public var mixingInPower: Int32

}

extension SettingsMO : Identifiable {

}
