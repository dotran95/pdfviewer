//
//  PDFSignatureVc.swift
//  PdfViewer
//
//  Created by VTIT on 1/10/24.
//

import UIKit
import SnapKit
import SwiftSignatureView

protocol PDFSignatureDelegate: AnyObject {
    func signature(_ signature: UIImage?)
}

class PDFSignatureVc: UIViewController {
    private var signatureView = SwiftSignatureView()

    weak var delegate: PDFSignatureDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.backgroundColor = .white

        navigationItem.title = "Signature"

        let cancelBtn = UIBarButtonItem(title: "Cancel",
                                      style: .plain,
                                      target: self,
                                      action: #selector(doneAction(_:)))

        cancelBtn.tintColor = .black
        cancelBtn.setTitleTextAttributes([.font : UIFont.systemFont(ofSize: 15, weight: .semibold)], for: .normal)


        let doneBtn = UIBarButtonItem(title: "Done",
                                      style: .plain,
                                      target: self,
                                      action: #selector(doneAction(_:)))

        doneBtn.tintColor = .black
        doneBtn.setTitleTextAttributes([.font : UIFont.systemFont(ofSize: 15, weight: .bold)], for: .normal)
        navigationItem.leftBarButtonItems = [cancelBtn]
        navigationItem.rightBarButtonItems = [doneBtn]

        view.addSubview(signatureView)
        signatureView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }
    

    @objc
    func doneAction(_ sender: Any) {
        delegate?.signature(signatureView.getCroppedSignature())
        dismiss(animated: true)
    }
}
