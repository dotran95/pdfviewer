//
//  PDFViewer.swift
//  PdfViewer
//
//  Created by Do Tran on 06/09/2024.
//

import UIKit
import PDFKit
import SnapKit

struct PDFViewerConfig {
    var primaryColor: UIColor
    var secondColor: UIColor
    var minScaleFactor: CGFloat
    var maxScaleFactor: CGFloat
}

enum PDFViewerMode {
    case view
    case edit
}

class PDFViewer: UIViewController, PDFDocumentDelegate {

    static let defaultConfig = PDFViewerConfig(primaryColor: .red,
                                               secondColor: .black,
                                               minScaleFactor: 1,
                                               maxScaleFactor: 1)
    var pdfView = PDFView()

    private var controlView: PDFViewControl!

    private var searchVc = PDFSearchVc()

    private var documentEdit: PDFDocumentEdit!

    private var mode: PDFViewerMode = .view {
        didSet {
            controlView.onEdit(enable: mode == .edit)
            switch mode {
            case .edit:
                documentEdit.addSideBarNavigation()
            default:
                documentEdit.removeSideBar()
                break
            }
        }
    }

    var config: PDFViewerConfig = defaultConfig

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUIs()
    }

    func loadContent(document: PDFDocument) {
        pdfView.document = document
        config.minScaleFactor = pdfView.minScaleFactor
        config.maxScaleFactor = pdfView.maxScaleFactor
    }

    private func makeUIs() {
        controlView = PDFViewControl(config)
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

        documentEdit = PDFDocumentEdit(items: [.text], parent: self)

        guard let document = pdfView.document else {
            return
        }

        controlView.allowBookmark = document.allowsDocumentChanges
        searchVc.modalPresentationStyle = .fullScreen
        searchVc.delegate = self
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
        mode = .view
        pdfView.currentPage?.bookmark()
        return pdfView.currentPage?.bookmarked ?? false
    }

    func search() {
        mode = .view
        present(searchVc, animated: true)
    }

    func edit() {
        switch mode {
        case .edit:
            mode = .view
            break
        default:
            mode = .edit
            break
        }
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

// MARK: - Edit mode
extension PDFViewer: PDFDocumentSideBarDelegate {

    func onClick(_ type: PDFDocumentSideBarbuttons) {
        guard mode == .edit else {
            return
        }

        switch type {
        case .text:
            documentEdit.addTextAnnotation()
            break
        default:
            break
        }
    }
}
