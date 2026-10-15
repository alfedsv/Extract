//
//  EyeImageView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 15.10.2026.
//

import UIKit

final class EyeImageView: UIImageView {

    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        isHidden = true
        contentMode = .scaleAspectFit
        image = Icons.Eye.closed.image
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
