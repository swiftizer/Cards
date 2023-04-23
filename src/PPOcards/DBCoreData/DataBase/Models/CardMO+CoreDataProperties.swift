//
//  CardMO+CoreDataProperties.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//
//

import Foundation
import CoreData


extension CardMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardMO> {
        return NSFetchRequest<CardMO>(entityName: "CardMO")
    }

    @NSManaged public var answerImageURL: URL?
    @NSManaged public var answerText: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isLearned: Bool
    @NSManaged public var questionImageURL: URL?
    @NSManaged public var questionText: String?
    @NSManaged public var setID: UUID?

}

extension CardMO : Identifiable {

}
