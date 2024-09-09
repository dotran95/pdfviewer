//
//  PDFBookmark.swift
//  PdfViewer
//
//  Created by Do Tran on 06/09/2024.
//

import UIKit
import PDFKit

class PDFBookmarkAnnotation: PDFAnnotation {
    
    static let identifier = "PDFBookmark"
    
    init(bounds: CGRect) {
        super.init(bounds: bounds, forType: .line, withProperties: nil)
        contents = PDFBookmarkAnnotation.identifier
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        super.draw(with: box, in: context)
        context.saveGState()
        
        // Set up the context for custom drawing
        context.setFillColor(UIColor.red.cgColor)
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setLineWidth(2)
        
        // Draw a custom shape using UIBezierPath
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.bounds.maxX, y: self.bounds.minY))
        path.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY))
        path.addLine(to: CGPoint(x: self.bounds.minX, y: self.bounds.maxY))
        path.addLine(to: CGPoint(x: self.bounds.minX, y: self.bounds.minY))
        path.addLine(to: CGPoint(x: self.bounds.minX + bounds.width / 2,
                                 y: self.bounds.maxY - bounds.height * 0.77))
        path.close()
        path.lineCapStyle = .round
        
        // Apply path to context and fill it
        context.addPath(path.cgPath)
        context.fillPath()
        context.strokePath()
    }
}
