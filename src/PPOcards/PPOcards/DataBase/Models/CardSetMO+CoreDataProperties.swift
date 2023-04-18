//
//  CardSetMO+CoreDataProperties.swift
//  PPOcards
//
//  Created by ser.nikolaev on 17.04.2023.
//
//

import Foundation
import CoreData


extension CardSetMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardSetMO> {
        return NSFetchRequest<CardSetMO>(entityName: "CardSetMO")
    }

    @NSManaged public var color: Int32
    @NSManaged public var id: UUID?
    @NSManaged public var allCardsCount: Int32
    @NSManaged public var title: String?
    @NSManaged public var learnedCardsCount: Int32

}

extension CardSetMO : Identifiable {

}
