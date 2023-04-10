//
//  CardSetMO+CoreDataProperties.swift
//  PPOcards
//
//  Created by ser.nikolaev on 10.04.2023.
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
    @NSManaged public var progress: String?
    @NSManaged public var title: String?

}

extension CardSetMO : Identifiable {

}
