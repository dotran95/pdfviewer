//
//  PDFDocumentSideBar.swift
//  PdfViewer
//
//  Created by VTIT on 17/9/24.
//

import UIKit

enum PDFDocumentSideBarbuttons: Int {
    case text = 0
    case oval
    case circle
    case signature
}

protocol PDFDocumentSideBarDelegate: AnyObject {
    func onAddText(_ sender: UIButton)
    func onAddSignature(_ sender: UIButton)
}

class PDFDocumentSideBar: UIView {

    private var buttons: [PDFDocumentSideBarbuttons]
    private let buttonSize: CGFloat = 38
    private let spacing: CGFloat = 4

    weak var delegate: PDFDocumentSideBarDelegate?

    init(_ buttons: [PDFDocumentSideBarbuttons]) {
        self.buttons = buttons
        super.init(frame: .zero)
        setupView()
    }

    override init(frame: CGRect) {
        self.buttons = []
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        self.buttons = []
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
        layer.cornerRadius = 4

        // Configure stackView
        let stackView = UIStackView()
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.verticalEdges.equalTo(self).inset(8)
            make.width.equalTo(buttonSize)
            make.height.equalTo(buttonSize * CGFloat(buttons.count) + spacing * CGFloat(buttons.count - 1))
        }

        stackView.axis = .vertical
        stackView.spacing = spacing // Adjust spacing if needed
        stackView.alignment = .fill
        stackView.distribution = .fillEqually // Distribute buttons equally

        for button in buttons {
            switch button {
            case .text:
                stackView.addArrangedSubview(createTextButton())
            case .signature:
                stackView.addArrangedSubview(createSignatureButton())
            default:
                break
            }
        }
    }

    private func createTextButton() -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle("Aa", for: .normal)
        btn.tintColor = .black
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        btn.tag = PDFDocumentSideBarbuttons.text.rawValue
        return btn
    }

    private func createSignatureButton() -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "signature"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        btn.tag = PDFDocumentSideBarbuttons.signature.rawValue
        return btn
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        guard let type = PDFDocumentSideBarbuttons(rawValue: sender.tag) else { return }
        switch type {
        case .text:
            delegate?.onAddText(sender)
        case .signature:
            delegate?.onAddSignature(sender)
        default:
            break
        }
    }

}
