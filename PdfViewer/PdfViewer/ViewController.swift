//
//  ViewController.swift
//  PdfViewer
//
//  Created by Do Tran on 06/09/2024.
//

import UIKit
import PDFKit

class ViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let vc = PDFViewer()
        vc.modalPresentationStyle = .fullScreen
        
        guard let url = Bundle.main.url(forResource: "Sample1", withExtension: "pdf"),
                let document = PDFDocument(url: url) else {
            return
        }
        
        vc.loadContent(document: document)
        
        present(vc, animated: true)
    }
    
    
}

