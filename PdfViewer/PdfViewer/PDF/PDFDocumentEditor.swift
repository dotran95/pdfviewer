//
//  PDFDocumentEditor.swift
//  PdfViewer
//
//  Created by dotn on 9/9/24.
//

import UIKit
import SnapKit
import PDFKit
import CoreGraphics

class PDFDocumentEditor: UIView {

    static let kTag = 1100

    var page: PDFPage
    var scaleFactor: CGFloat

    private var drawView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        return v
    }()

    private var annotations: [UIView] = []

    init(page: PDFPage, scaleFactor: CGFloat) {
        self.page = page
        self.scaleFactor = scaleFactor
        super.init(frame: .zero)
        makeUIs()
    }

    func onSave() {
        for annotation in annotations {
            guard let textA = annotation as? PDFDocumentText else { continue }

            // Convert point of text with the scale factor of page
            var rect = drawView.convert(textA.textFrame, from: textA) / scaleFactor
            rect.origin.y = (drawView.frame / scaleFactor).height - rect.origin.y -  rect.height

            let attributedStr = NSMutableAttributedString(attributedString: textA.attributedString)
            let scaleFont = textA.font.withSize(textA.font.pointSize / scaleFactor)
            attributedStr.addAttributes([.font: scaleFont], range: NSRange(location: 0, length: textA.attributedString.length))
            let textAnnotation = PDFImageAnnotation(attributedStr, properties: nil, rect: rect)

            page.addAnnotation(textAnnotation)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layouts
extension PDFDocumentEditor {

    func makeUIs() {
        tag = PDFDocumentEditor.kTag
        backgroundColor = UIColor.clear
        clipsToBounds = true

        let scaleFrame = page.bounds(for: .cropBox).scale(scaleFactor)
        addSubview(drawView)
        drawView.snp.makeConstraints { make in
            make.width.equalTo(scaleFrame.width)
            make.height.equalTo(scaleFrame.height)
            make.center.equalTo(self)
        }

        // Get center point of the page scale frame
        addText(sizeOfPage: scaleFrame.size)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Allows touches to pass through to other views
        addGestureRecognizer(tapGesture)
    }

    private func addText(sizeOfPage maxSize : CGSize) {
        let center = maxSize.scale(0.5).toPoint()
        let newLabel = PDFDocumentText(maxSize: maxSize)
        newLabel.center = center

        drawView.addSubview(newLabel)
        annotations.append(newLabel)
    }

    @objc
    private func dismissKeyboard() {
        // Resign first responder status from the text field to hide the keyboard
        endEditing(true)
    }
}

extension PDFDocumentEditor: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.sizeToFit()
    }
}

