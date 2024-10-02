//
//  PDFPage+Bookmark.swift
//  PdfViewer
//
//  Created by Do Tran on 07/09/2024.
//

import PDFKit

extension PDFPage {
    var bookmarked: Bool {
        return annotations.contains(where: { $0 is PDFBookmarkAnnotation })
    }
    
    func bookmark() {
        if bookmarked {
            removeBookmark()
            return
        }
        addBookmark()
    }
    
    func removeBookmark() {
        for annotation in annotations where annotation is PDFBookmarkAnnotation {
            removeAnnotation(annotation)
        }
    }
    
    func addBookmark() {
        let bounds = bounds(for: .cropBox)
        let annotationBounds = CGRect(x: bounds.width - 50, y: bounds.height - 50, width: 30, height: 50)
        addAnnotation(PDFBookmarkAnnotation(bounds: annotationBounds))
    }

    var centerPoint: CGPoint {
        let bounds = bounds(for: .cropBox)
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
