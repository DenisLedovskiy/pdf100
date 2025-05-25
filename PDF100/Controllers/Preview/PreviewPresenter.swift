import UIKit
import PDFKit

protocol PreviewPresenterInterface {
    func viewDidLoad(withView view: PreviewPresenterOutputInterface)
    func needShowDelete(sheet: UIViewController)
    func needDismiss()
    func needAddImagesToPdf(document: String, pdfDoc: PDFDocument, images: [UIImage])
    func needAddPdfToPdf(document: String, pdfDoc1: PDFDocument, pdfDoc2: PDFDocument)
}

final class PreviewPresenter: NSObject {

    private weak var view: PreviewPresenterOutputInterface?
    private var router: PreviewRouterInterface

    init(router: PreviewRouterInterface) {
        self.router = router
    }
}

// MARK: - Private
private extension PreviewPresenter {

    func addImagesToPDf(document: String, pdfDoc: PDFDocument, images: [UIImage]) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = document
        guard let fileURL = documentsDirectory?.appendingPathComponent(fileName) else {return}

        let pdfFromImg = images.makePDF()

        let myDocPageCount = pdfDoc.pageCount
        for index in 0..<pdfFromImg.pageCount {
            if let page = pdfFromImg.page(at: index) {
                pdfDoc.insert(page, at: myDocPageCount + index)
            }
        }
        pdfDoc.write(to: fileURL)
        DispatchQueue.main.async {
            self.view?.needUpdatePDf()
        }
    }

    func mergePDf(document: String, pdfDoc1: PDFDocument, pdfDoc2: PDFDocument) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = document
        guard let fileURL = documentsDirectory?.appendingPathComponent(fileName) else {return}

        let myDocPageCount = pdfDoc1.pageCount
        for index in 0..<pdfDoc2.pageCount {
            if let page = pdfDoc2.page(at: index) {
                pdfDoc1.insert(page, at: myDocPageCount + index)
            }
        }

        pdfDoc1.write(to: fileURL)
        DispatchQueue.main.async {
            self.view?.needUpdatePDf()
        }
    }

}

// MARK: - PreviewPresenterInterface

extension PreviewPresenter: PreviewPresenterInterface {
    func needAddImagesToPdf(document: String, pdfDoc: PDFDocument, images: [UIImage]) {
        addImagesToPDf(document: document, pdfDoc: pdfDoc, images: images)
    }
    
    func needAddPdfToPdf(document: String, pdfDoc1: PDFDocument, pdfDoc2: PDFDocument) {
        mergePDf(document: document, pdfDoc1: pdfDoc1, pdfDoc2: pdfDoc2)
    }
    
    func needDismiss() {
        router.dismiss()
    }
    
    func needShowDelete(sheet: UIViewController) {
        router.showDelete(sheet: sheet)
    }
    
    func viewDidLoad(withView view: PreviewPresenterOutputInterface) {
        self.view = view
    }
}
