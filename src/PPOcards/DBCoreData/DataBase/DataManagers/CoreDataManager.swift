//
//  CoreDataManager.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import CoreData
import Core
import Logger

protocol CoreDataManagerDescription {
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T]
    func count<T: NSManagedObject>(request: NSFetchRequest<T>) -> Int
    func create<T: NSManagedObject>(entityName: String, configurationBlock: @escaping (T?) -> Void)
    func delete<T: NSManagedObject>(request: NSFetchRequest<T>)
    func deleteAll(request: NSFetchRequest<NSFetchRequestResult>)
    func update<T: NSManagedObject>(request: NSFetchRequest<T>, configurationBlock: @escaping (T?) -> Void)

    func initIfNeeded(successBlock: (() -> ())?, errorBlock: ((Error) -> ())?)
}

final class CoreDataManager {

    static let shared: CoreDataManagerDescription = CoreDataManager()

    private let container = NSPersistentContainer(name: "DataBasePPOCards")
    private var isReady: Bool = false

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    private init() {
        self.initIfNeeded {
//            self.deleteAll(request: CardSetMO.fetchRequest())
//            self.deleteAll(request: CardMO.fetchRequest())
            Logger.shared.log(lvl: .INFO, msg: "coreData inited")
            debugPrint("[DEBUG] coreData inited. \(self.count(request: CardSetMO.fetchRequest()))")
            debugPrint("[DEBUG] coreData inited. \(self.count(request: CardMO.fetchRequest()))")
        } errorBlock: { error in
            debugPrint("[DEBUG] coreData error. \(error.localizedDescription)")
        }
    }
}

extension CoreDataManager: CoreDataManagerDescription {

    func deleteAll(request: NSFetchRequest<NSFetchRequestResult>) {
        let batchRequest = NSBatchDeleteRequest(fetchRequest: request)

        viewContext.performAndWait { [weak self] in
            _ = try? self?.viewContext.execute(batchRequest)
            try? self?.viewContext.save()
        }
    }

    func initIfNeeded(successBlock: (() -> ())?, errorBlock: ((Error) -> ())?) {
        guard !isReady else {
            successBlock?()
            return
        }

        container.loadPersistentStores { [weak self] _, error in
            if let error = error {
                errorBlock?(error)
                return
            }

            self?.isReady = true
            successBlock?()
        }
    }

    func update<T>(request: NSFetchRequest<T>, configurationBlock: @escaping (T?) -> Void) where T : NSManagedObject {
        let objects = fetch(request: request)

        guard let object = objects.first else { return }

        viewContext.performAndWait {
            configurationBlock(object)
            try? viewContext.save()
        }
    }

    func delete<T>(request: NSFetchRequest<T>) where T : NSManagedObject {

        viewContext.performAndWait { [weak self] in
            let objects = self?.fetch(request: request)

            objects?.forEach({ self?.viewContext.delete($0) })

            try? self?.viewContext.save()
        }
    }

    func fetch<T>(request: NSFetchRequest<T>) -> [T] where T : NSManagedObject {
        return (try? viewContext.fetch(request)) ?? []
    }

    func count<T>(request: NSFetchRequest<T>) -> Int where T : NSManagedObject {
        return (try? viewContext.count(for: request)) ?? 0
    }

    func create<T>(entityName: String, configurationBlock: @escaping (T?) -> Void) where T : NSManagedObject {
        viewContext.performAndWait {
            let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: viewContext) as? T

            configurationBlock(object)

            try? viewContext.save()
        }
    }

}
