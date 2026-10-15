//
//  AccessoryLabelView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 06.10.2026.
//

import UIKit

final class AccessoryLabelView: TapView {

    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17)
        l.textColor = Colors.Text.common.color
        return l
    }()

    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }

    init(text: String?) {
        super.init(frame: .zero)
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        label.text = text
        addSubview(label)
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError() }

}
private extension AccessoryLabelView {
    func setupConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let minH = heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        minH.priority = .defaultHigh
        minH.isActive = true
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        
    }
}
