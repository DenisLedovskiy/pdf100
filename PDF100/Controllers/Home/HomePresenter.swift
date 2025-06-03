import UIKit

protocol HomePresenterInterface {
    func viewDidLoad(withView view: HomePresenterOutputInterface)
    func viewWillAppear()
    func createPDFFromImg(_ images: [UIImage])
    func addPDF(_ title: String)
    func needShare(_ index: Int)
    func needDeleteDoc(_ index: Int)
    func needShowConverMenu(sheet: UIViewController)
    func needShowDocument(index: Int)
    func needShowDocumentByName(docName: String)
    func needRouteCompress(docName: String)
}

final class HomePresenter: NSObject {

    private weak var view: HomePresenterOutputInterface?
    private var router: HomeRouterInterface

    private let cdDataSource: PDF100CDataSource = Store.viewContext.pdfDataSource

    private var pdfDocArray = [HomeCellModel]()

    init(router: HomeRouterInterface) {
        self.router = router
    }
}

private extension HomePresenter {
    func fetchDocs(_ completion: (() -> Void)? = nil) {
        cdDataSource.fetch { result in
            switch result {
            case .fail(let error): print("Error: ", error)
            case .success:
                print("Success fetch Docs. Count = \(self.cdDataSource.count)")
                if self.cdDataSource.count > 0 {
                    let docs = self.cdDataSource.getAllPDFModels()
                    self.pdfDocArray = docs
                    DispatchQueue.main.async {
                        self.view?.updateCollection(docs)
                    }
                } else {
                    self.pdfDocArray = [HomeCellModel]()
                    DispatchQueue.main.async {
                        self.view?.updateCollection([HomeCellModel]())
                    }
                }
                completion?()
            }
        }
    }

    func addNewPDF(_ title: String) {
        var nameWithoutPdf = title
        if let lastDotIndex = title.lastIndex(of: ".") {
            let nameWithoutExtension = title[..<lastDotIndex]
            nameWithoutPdf = String(nameWithoutExtension)
        }
        Store.viewContext.addPDF(title: nameWithoutPdf, date: Date(), id: UUID()) { result in
            switch result {
            case .fail(let error): print("Error: ", error)
            case .success: print("Success new entitiy - \(title)")
                self.fetchDocs()
            }
        }
    }

    func saveAsPDF(images: [UIImage]) {
        let document = images.makePDF()
        let fileName = getFileNameForPDF()


        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let fileURL = documentsDirectory?.appendingPathComponent("\(fileName).pdf") else {return}

        document.write(to: fileURL)
        self.addNewPDF(fileName)
    }

    func getFileNameForPDF() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM HH:mm:ss"
        let currentDateTimeString = dateFormatter.string(from: Date())
        return "\(currentDateTimeString)"
    }

    func deleteFromFolder(index: Int) {
        let pdf = pdfDocArray[index]
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let fileURL = directory.appendingPathComponent("\(pdf.title).pdf")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Файл удален успешно!")
            } catch {
                print("\(error)")
            }
        }
    }
}

// MARK: - HomePresenterInterface

extension HomePresenter: HomePresenterInterface {
    func needShowDocumentByName(docName: String) {
        router.showDocument(docName:docName)
    }
    
    func needRouteCompress(docName: String) {
        router.showCompress(docName: docName)
    }
    
    func needShowDocument(index: Int) {
        let name = pdfDocArray[index].title
        router.showDocument(docName: name)
    }
    
    func needShowConverMenu(sheet: UIViewController) {
        router.showConvertMenu(sheet: sheet)
    }
    
    func needDeleteDoc(_ index: Int) {
        let pdf = pdfDocArray[index]
        let docs = cdDataSource.getAllPdf()
        if let indsxInCD = docs.firstIndex(where: {$0.id == pdf.idCD}) {
            Store.viewContext.deleteItem(object: docs[indsxInCD]) { result in
                switch result {
                case .fail(let error): print("Error: ", error)
                case .success: print("Succes delete from CoreData")
                    self.fetchDocs()
                }
            }
        }
        deleteFromFolder(index: index)
    }
    
    func needShare(_ index: Int) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let file = pdfDocArray[index]
        let name = "\(file.title).pdf"
        guard let fileURL = documentsDirectory?.appendingPathComponent(name) else {return}
        router.showShare(fileURL)
    }

    func addPDF(_ title: String) {
        addNewPDF(title)
    }

    func createPDFFromImg(_ images: [UIImage]) {
        saveAsPDF(images: images)
    }

    func viewWillAppear() {
        fetchDocs()

        if !(UserDefSettings.isShowedLikeIt ?? false) && UserDefSettings.isWasGoodMove ?? false {
            router.showFeedback()
        }
    }
    
    func viewDidLoad(withView view: HomePresenterOutputInterface) {
        self.view = view
        UserDefSettings.isNotOneEnter = true
    }
}
