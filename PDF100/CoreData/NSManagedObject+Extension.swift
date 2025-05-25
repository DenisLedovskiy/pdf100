import Foundation
import CoreData

enum ResultCoreData {
    case success, fail(Error)
}

// MARK: - Save, Delete
extension NSManagedObjectContext {
    func save(completion: ((ResultCoreData) -> ())?) {
        do {
            try self.save()
            completion?(.success)
        } catch let error {
            self.rollback()
            completion?(.fail(error))
        }
    }

    func deleteItem(object: NSManagedObject?, completion: ((ResultCoreData) -> ())?) {
        guard let item = object else {return}
        perform {
            self.delete(item)
            self.save(completion: completion)
        }
    }
}

// MARK: - Methods

extension NSManagedObjectContext {

    // MARK: - Load data

    var pdfDataSource: PDF100CDataSource { return PDF100CDataSource(context: self) }

    // MARK: - Data manupulation

    func addPDF(title: String,
                date: Date,
                id: UUID,
                completion: ((ResultCoreData) -> ())?) {
        perform {
            let entity: PDF100CD = PDF100CD(context: self)
            entity.id = id
            entity.name = title
            entity.date = date
            self.save(completion: completion)
        }
    }
}
