//
//  TapView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 06.10.2026.
//

import UIKit

// Для вью которые реагируют на tap без анимации
class TapView: UIView {
    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    required init?(coder: NSCoder) { fatalError() }

    @objc private func handleTap() { onTap?() }
}
