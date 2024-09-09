//
//  PDFDocumentText.swift
//  PdfViewer
//
//  Created by dotn on 10/9/24.
//

import UIKit
import SnapKit

class PDFDocumentText: UIView {

    // Default font settings for the text view
    static let defaultFont = UIFont.systemFont(ofSize: 15, weight: .bold)
    private let kPadding: CGFloat = 30 // Padding around the text view

    // Text view setup with default properties
    private let textView: UITextView = {
        let txtView = UITextView()
        txtView.textAlignment = .center
        txtView.textColor = .blue
        txtView.backgroundColor = .clear
        txtView.font = PDFDocumentText.defaultFont
        txtView.text = "Text"
        txtView.isScrollEnabled = false
        txtView.autocorrectionType = .no
        txtView.spellCheckingType = .no
        return txtView
    }()

    // Computed properties for accessing text view attributes
    var font: UIFont {
        return textView.font ?? PDFDocumentText.defaultFont
    }

    var color: UIColor {
        return textView.textColor ?? .black
    }

    var attributedString: NSAttributedString {
        return textView.attributedText
    }

    var textFrame: CGRect {
        return textView.frame
    }

    private let maxSize: CGSize // Maximum allowable size for the view

    // Initialize the view with a maximum size
    init(maxSize: CGSize) {
        self.maxSize = maxSize
        super.init(frame: .zero)

        setupView()    // Setup subviews and constraints
        setupGestures() // Add gesture recognizers
        resizeToFit()  // Resize the view to fit its content
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup the text view and its constraints
    private func setupView() {
        layer.cornerRadius = 4 // Rounded corners for the view
        addSubview(textView)

        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(kPadding) // Padding around the text view
        }

        textView.delegate = self // Set the delegate for the text view
    }

    // Setup gesture recognizers for pan, pinch, and rotation
    private func setupGestures() {
        // Pan gesture to move the view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGesture)

        // Pinch gesture to adjust font size
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinchGesture)

        // Rotation gesture to rotate the view
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        addGestureRecognizer(rotationGesture)
    }

    // Resize the view to fit its content
    private func resizeToFit() {
        textView.sizeToFit()

        let fixedWidth = maxSize.width
        let size = CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)
        let newSize = textView.sizeThatFits(size)

        // Adjust the frame size considering padding
        frame.size = CGSize(width: min(newSize.width, fixedWidth) + 60, height: newSize.height + 60)
    }

    // Adjust the font size based on the pinch scale
    private func adjustFontSize(scale: CGFloat) {
        guard let currentFont = textView.font else { return }
        let newSize = min(max(currentFont.pointSize * scale, 10), 70)
        textView.font = currentFont.withSize(newSize)
        resizeToFit() // Resize the view to accommodate the new font size
    }

    // Handle pan gesture to move the view
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        // Ensure we have access to the view's superview
        guard let superview = gesture.view?.superview else { return }

        // Get the translation of the gesture within the superview's coordinate system
        let translation = gesture.translation(in: superview)

        // Save the current transform of the view and reset it to identity for calculations
        let transform = gesture.view?.transform
        gesture.view?.transform = .identity

        // Calculate the new position based on the current frame and translation
        let newX = frame.origin.x + translation.x
        let newY = frame.origin.y + translation.y

        // Define the maximum allowed x and y coordinates considering padding
        let maxX = maxSize.width - frame.width + kPadding
        let maxY = maxSize.height - frame.height + kPadding

        // Constrain the new x and y positions within the defined boundaries
        let constrainedX = max(min(newX, maxX), -kPadding)
        let constrainedY = max(min(newY, maxY), -kPadding)

        // Update the view's frame origin with the constrained position
        frame.origin = CGPoint(x: constrainedX, y: constrainedY)

        // Restore the original transform of the view
        gesture.view?.transform = transform ?? .identity

        // Reset the translation of the gesture recognizer to zero for the next gesture
        gesture.setTranslation(.zero, in: superview)
    }

    // Handle pinch gesture to scale the font size
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            // Save the current transform of the view and reset it to identity for calculations
            let transform = gesture.view?.transform
            gesture.view?.transform = .identity
            let scale = gesture.scale
            gesture.scale = 1.0 // Reset scale to avoid cumulative scaling
            adjustFontSize(scale: scale)
            gesture.view?.transform = transform ?? .identity
        }
    }

    // Handle rotation gesture to rotate the view
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            let rotation = gesture.rotation
            transform = transform.rotated(by: rotation)
            gesture.rotation = 0.0 // Reset rotation to avoid cumulative rotation
        }
    }
}

extension PDFDocumentText: UITextViewDelegate {
    // Update the view size when the text changes
    func textViewDidChange(_ textView: UITextView) {
        resizeToFit()
    }

    // Trim whitespace and update the view size when editing ends
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        resizeToFit()
    }
}

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
