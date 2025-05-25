import Foundation
import CoreData

final class Store {
    private init() {}
    private static let shared: Store = Store()

    lazy var container: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "PDF100CoreData")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    // MARK: - APIs

    static var viewContext: NSManagedObjectContext { return shared.container.viewContext }

    static var newContext: NSManagedObjectContext { return shared.container.newBackgroundContext() }
}
