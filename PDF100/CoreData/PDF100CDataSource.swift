import CoreData
import UIKit
import PDFKit

final class PDF100CDataSource {

    let controller: NSFetchedResultsController<NSFetchRequestResult>
    let request: NSFetchRequest<NSFetchRequestResult> = PDF100CD.fetchRequest()

    let defaultSort: NSSortDescriptor = NSSortDescriptor(key: #keyPath(PDF100CD.date), ascending: false)

    init(context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor] = []) {
        var sort: [NSSortDescriptor] = sortDescriptors
        if sort.isEmpty { sort = [defaultSort] }

        request.sortDescriptors = sort

        controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }

    // MARK: - DataSource APIs

    func fetch(completion: ((ResultCoreData) -> ())?) {
        self.request.predicate = nil
        do {
            try controller.performFetch()
            completion?(.success)
        } catch let error {
            completion?(.fail(error))
        }
    }

    var count: Int { return controller.fetchedObjects?.count ?? 0 }

    func getAllPdf() -> [PDF100CD] {
        guard let data: [PDF100CD] = controller.fetchedObjects as? [PDF100CD] else {return []}
        return data
    }

    func getAllPDFModels() -> [HomeCellModel] {
        guard let data: [PDF100CD] = controller.fetchedObjects as? [PDF100CD] else {return []}
        return data.map({
            HomeCellModel(idCD: $0.id ?? UUID(),
                          title: $0.name ?? "no name",
                          icon: pickFirstImage(from: $0.name ?? "") ?? .icon1,
                          size: humanReadableSize(from: $0.name ?? ""),
                          date: $0.date ?? Date())
        })
    }

    private func pickFirstImage(from docName: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = "\(docName).pdf"
        guard let fileURL = documentsDirectory?.appendingPathComponent(fileName) else {return UIImage()}
        guard let pdfDoc = PDFDocument(url: fileURL) else { return nil }
        guard let page = pdfDoc.page(at: 0) else { return nil }
        let size = page.bounds(for: .mediaBox).size
        let image = page.thumbnail(of: size, for: .mediaBox)

        return image
    }

    func humanReadableSize(from docName: String) -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = "\(docName).pdf"
        guard let fileURL = documentsDirectory?.appendingPathComponent(fileName) else {return ""}

        let fileAttributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
        guard let sizeInBytes = fileAttributes?[.size] as? Int64 else { return "" }
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useMB]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: sizeInBytes)
    }
}
