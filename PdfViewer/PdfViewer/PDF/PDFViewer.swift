//
//  PDFViewer.swift
//  PdfViewer
//
//  Created by Do Tran on 06/09/2024.
//

import UIKit
import PDFKit
import SnapKit

class PDFViewer: UIViewController {
    
    private var pdfView = PDFView()
    
    private var controlView = PDFViewControl()

    private var searchVc = PDFSearchVc()

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUIs()
    }
    
    func loadContent(document: PDFDocument) {
        pdfView.document = document
        controlView.allowBookmark = document.allowsDocumentChanges
        searchVc.document = pdfView.document
        searchVc.modalPresentationStyle = .fullScreen
        searchVc.delegate = self
    }
    
    private func makeUIs() {
        view.addSubview(controlView)
        controlView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        controlView.delegate = self
        
        view.addSubview(pdfView)
        pdfView.snp.makeConstraints { make in
            make.top.equalTo(controlView.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        pdfView.autoScales = true
        pdfView.usePageViewController(true)
        pdfView.displayDirection = .horizontal
        pdfView.displayMode = .singlePage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(pageChanged), name: .PDFViewPageChanged, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .PDFViewPageChanged, object: nil)
    }
    
    @objc
    private func pageChanged() {
        controlView.bookmark(enable: pdfView.currentPage?.bookmarked ?? false)
    }
}

extension PDFViewer: PDFViewControlDelegate {

    func bookmark() -> Bool {
        removeDocumentEditor()
        pdfView.currentPage?.bookmark()
        return pdfView.currentPage?.bookmarked ?? false
    }
    
    func search() {
        removeDocumentEditor()
//        present(searchVc, animated: true)
    }

    func edit() {
        if isShowDocumentEditor {
            removeDocumentEditor()
            return
        }
        showDocmentEditor()
    }
}

extension PDFViewer: PDFSearchDelegate {
    func onSelect(selection: PDFSelection) {
        searchVc.dismiss(animated: true) {
            self.pdfView.go(to: selection)
            self.pdfView.setCurrentSelection(selection, animate: true)
        }
    }
}

// MARK: - PDFDocumentEditor
extension PDFViewer {

    var isShowDocumentEditor: Bool {
        return view.subviews.first(where: { $0.tag == PDFDocumentEditor.kTag }) != nil
    }

    func showDocmentEditor() {
        removeDocumentEditor()

        guard let page = pdfView.currentPage else {
            return
        }
        let documentEditor = PDFDocumentEditor(page: page, scaleFactor: pdfView.scaleFactor)

        view.addSubview(documentEditor)
        
        documentEditor.snp.makeConstraints { make in
            make.top.equalTo(controlView.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func removeDocumentEditor() {
        for documentView in view.subviews.filter({ $0.tag == PDFDocumentEditor.kTag }) {
            if let doc = documentView as? PDFDocumentEditor {
               doc.onSave()
                pdfView.setNeedsDisplay()
                pdfView.layoutIfNeeded()
                print(pdfView.currentPage?.annotations)
            }
            documentView.removeFromSuperview()
        }
    }
}
