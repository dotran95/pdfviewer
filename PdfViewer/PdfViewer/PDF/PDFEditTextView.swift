//
//  PDFEditTextView.swift
//  PdfViewer
//
//  Created by VTIT on 26/9/24.
//

import UIKit
import SnapKit

class PDFEditTextView: UIViewController, UITextViewDelegate {

    let textView: UITextView = {
        let txtView = UITextView()
        txtView.textAlignment = .center
        txtView.textColor = .blue
        txtView.backgroundColor = .clear
        txtView.font = UIFont.systemFont(ofSize: 17)
        txtView.text = "Text"
        txtView.isScrollEnabled = false
        txtView.autocorrectionType = .no
        txtView.spellCheckingType = .no
        txtView.textContainerInset = .zero
        txtView.textContainer.lineFragmentPadding = 0
        return txtView
    }()

    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    var onCompleted: ((UITextView) -> Void)?

    // Initializer
    init(annotationRect: CGRect) {
        super.init(nibName: nil, bundle: nil)
        setupView(annotationRect)
        setupKeyboardNotifications()
    }
    
    func show(_ parent: UIViewController) {
        parent.addChild(self)
        parent.view.addSubview(view)
        didMove(toParent: parent)
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

    // Required initializer for using with Storyboard (if needed)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self.view)

        // If the touch location is outside the textField bounds, remove the view
        if !textView.frame.contains(touchLocation) {
            textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            onCompleted?(textView)
            remove()
        }
    }

    // Setup the text view and its constraints
    private func setupView(_ initFrame: CGRect) {
        view.backgroundColor = .black.withAlphaComponent(0)
        view.addSubview(container)

        container.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(view)
        }

        container.addSubview(textView)
        textView.frame.size = initFrame.size
//        textView.snp.makeConstraints { make in
//            make.center.equalTo(container)
//        }
        textView.frame = initFrame
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.delegate = self
        textView.becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        textView.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
    }

    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25

            container.snp.updateConstraints { make in
                make.bottom.equalTo(view).inset(keyboardHeight)
            }

            UIView.animate(withDuration: animationDuration) { [self] in
                textView.center = .init(x: container.center.x, y: container.center.y - keyboardHeight)
                textView.font = textView.font?.copyWith(fontSize: 50)
                view.backgroundColor = .black.withAlphaComponent(0.5)
            }
        }
    }

    // Resize the view to fit its content
    private func resizeToFit() {
        textView.sizeToFit()

        let fixedWidth: CGFloat = view.frame.width
        let size = CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)
        let newSize = textView.sizeThatFits(size)

        // Adjust the frame size considering padding
        textView.frame.size = CGSize(width: fixedWidth, height: newSize.height + 20)
        textView.center = container.center
    }

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
