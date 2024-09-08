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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUIs()
    }
    
    func loadContent(document: PDFDocument) {
        pdfView.document = document
        controlView.allowBookmark = document.allowsDocumentChanges
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
        pdfView.currentPage?.bookmark()
        return pdfView.currentPage?.bookmarked ?? false
    }
    
    func search() { }
}
