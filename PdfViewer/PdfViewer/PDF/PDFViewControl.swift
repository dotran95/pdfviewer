//
//  PDFViewControl.swift
//  PdfViewer
//
//  Created by Do Tran on 06/09/2024.
//

import UIKit

protocol PDFViewControlDelegate: AnyObject {
    func bookmark() -> Bool
    func showSearch()
    func showEditMode()
    func showOutline()
}

class PDFViewControl: UIView {

    @IBOutlet weak private var editDocumentButton: UIButton!
    @IBOutlet weak private var bookmarkButton: UIButton!
    @IBOutlet weak private var searchButton: UIButton!
    @IBOutlet weak private var outlineMenuButton: UIButton!
    private let bookmarkImage = UIImage(systemName: "bookmark")
    private let bookmarkedImage = UIImage(systemName: "bookmark.fill")

    weak var delegate: PDFViewControlDelegate?
    var config: PDFViewerConfig

    var allowBookmark: Bool = false {
        didSet {
            bookmarkButton.isEnabled = allowBookmark
        }
    }

    init(_ config: PDFViewerConfig) {
        self.config = config
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func bookmark(enable: Bool) {
        bookmarkButton.tintColor = enable ? config.primaryColor : config.secondColor
        bookmarkButton.setImage(.init(systemName: enable ? "bookmark.fill":"bookmark"), for: .normal)
    }

    func onEdit(enable: Bool) {
        editDocumentButton.tintColor = enable ? config.primaryColor : config.secondColor
        editDocumentButton.setImage(.init(systemName: enable ? "pencil.tip.crop.circle.fill":"pencil.tip.crop.circle"), for: .normal)
    }

    private func commonInit() {
        let name = String(describing: type(of: self))
        let bundle = Bundle(for: type(of: self))
        guard let view = bundle.loadNibNamed(name, owner: self, options: nil)?.first as? UIView else {
            fatalError("Nib not found.")
        }
        addSubview(view)
        view.frame = self.bounds
        
        bookmark(enable: false)
        onEdit(enable: false)
    }
    
    @IBAction private func bookmarkAction(_ sender: UIButton) {
        let bookmarked = delegate?.bookmark() ?? false
        bookmark(enable: bookmarked)
    }

    @IBAction private func searchAction(_ sender: UIButton) {
        delegate?.showSearch()
    }

    @IBAction private func editAction(_ sender: UIButton) {
        delegate?.showEditMode()
    }
    @IBAction func outlineMenuAction(_ sender: UIButton) {
        delegate?.showOutline()
    }
}

