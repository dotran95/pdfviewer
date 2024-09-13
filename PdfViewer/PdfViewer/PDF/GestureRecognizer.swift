//
//  PanGestureRecognizer.swift
//  PdfViewer
//
//  Created by VTIT on 19/9/24.
//

import UIKit.UIPanGestureRecognizer

class PanGestureRecognizer: UIPanGestureRecognizer {
    private(set) var initialTouchLocation: CGPoint?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        initialTouchLocation = touches.first?.location(in: view)
    }
}
