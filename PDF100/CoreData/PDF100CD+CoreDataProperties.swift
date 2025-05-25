import Foundation
import CoreData

extension PDF100CD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PDF100CD> {
        return NSFetchRequest<PDF100CD>(entityName: "PDF100CD")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var name: String?

}

extension PDF100CD : Identifiable {

}
