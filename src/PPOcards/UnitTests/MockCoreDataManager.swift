//
//  MockCoreDataManager.swift
//  UnitTests
//
//  Created by ser.nikolaev on 13.10.2023.
//

import MockingKit
import DBCoreData
import CoreData

class MockCoreDataManager: Mock, CoreDataManagerDescription {
    lazy var fetchRef = MockReference(fetch)
    lazy var countRef = MockReference(count)
    lazy var createRef = MockReference(create)
    lazy var deleteRef = MockReference(delete)
    lazy var deleteAllRef = MockReference(deleteAll)
    lazy var updateRef = MockReference(updateMocked)
    lazy var initIfNeededRef = MockReference(initIfNeeded)

    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        call(fetchRef, args: (request as! NSFetchRequest<NSManagedObject>)) as! [T]
    }

    func count<T: NSManagedObject>(request: NSFetchRequest<T>) -> Int {
        call(countRef, args: (request as! NSFetchRequest<NSManagedObject>))
    }

    func create<T: NSManagedObject>(entityName: String, configurationBlock: @escaping (T?) -> Void) {
        call(createRef, args: (entityName, configurationBlock as! (NSManagedObject?) -> Void))
    }

    func delete<T: NSManagedObject>(request: NSFetchRequest<T>) {
        call(deleteRef, args: (request as! NSFetchRequest<NSManagedObject>))
    }

    func deleteAll(request: NSFetchRequest<NSFetchRequestResult>) {
        call(deleteAllRef, args: (request))
    }

    func update<T: NSManagedObject>(request: NSFetchRequest<T>, configurationBlock: @escaping (T?) -> Void) {
        call(updateRef, args: (request as! NSFetchRequest<NSManagedObject>))
    }

    func initIfNeeded(successBlock: (() -> ())?, errorBlock: ((Error) -> ())?) {
    }

    private func updateMocked<T: NSManagedObject>(request: NSFetchRequest<T>) {

    }
}


