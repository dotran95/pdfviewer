//
//  PDFViewControl.swift
//  PdfViewer
//
//  Created by Do Tran on 06/09/2024.
//

import UIKit

protocol PDFViewControlDelegate: AnyObject {
    func bookmark() -> Bool
    func search()
}

class PDFViewControl: UIView {
    
    @IBOutlet weak private var bookmarkButton: UIButton!
    @IBOutlet weak private var searchButton: UIButton!
    private let bookmarkImage = UIImage(systemName: "bookmark")
    private let bookmarkedImage = UIImage(systemName: "bookmark.fill")
    
    weak var delegate: PDFViewControlDelegate?
    var allowBookmark: Bool = false {
        didSet {
            bookmarkButton.isEnabled = allowBookmark
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func bookmark(enable: Bool) {
        bookmarkButton.tintColor = enable ? .red : .black
        bookmarkButton.setImage(enable ? bookmarkedImage:bookmarkImage, for: .normal)
    }
    
    private func commonInit() {
        let name = String(describing: type(of: self))
        let bundle = Bundle(for: type(of: self))
        guard let view = bundle.loadNibNamed(name, owner: self, options: nil)?.first as? UIView else {
            fatalError("Nib not found.")
        }
        addSubview(view)
        view.frame = self.bounds
        
        bookmarkButton.tintColor = .black
        bookmark(enable: false)
    }
    
    @IBAction private func bookmarkAction(_ sender: Any) {
        let bookmarked = delegate?.bookmark() ?? false
        bookmark(enable: bookmarked)
    }
    @IBAction private func searchAction(_ sender: Any) {
        delegate?.search()
    }
}

