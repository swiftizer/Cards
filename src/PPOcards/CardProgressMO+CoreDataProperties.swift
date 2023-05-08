//
//  CardProgressMO+CoreDataProperties.swift
//  DBCoreData
//
//  Created by ser.nikolaev on 07.05.2023.
//
//

import Foundation
import CoreData


extension CardProgressMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardProgressMO> {
        return NSFetchRequest<CardProgressMO>(entityName: "CardProgressMO")
    }

    @NSManaged public var cardSetId: UUID?
    @NSManaged public var cardId: UUID?
    @NSManaged public var successCount: Int32
    @NSManaged public var allAttemptsCount: Int32

}

extension CardProgressMO : Identifiable {

}
