//
//  BaseEntranceViewController.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

class BaseEntranceViewController: BaseViewController {

    let navBar = IdentityNavBarView()

    var contentTopAnchor: NSLayoutYAxisAnchor {
        navBar.bottomAnchor
    }
    
    private let keyboardBackdrop = ThemeAwareVisualEffectView() // TODO: перенести в базовый класс для отображения везде где есть клавиатура

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
        view.backgroundColor = Colors.App.background.color
        view.addSubview(navBar)
        view.addSubview(keyboardBackdrop)
        setupConstraints()
    }
    
    private func setupKeyboard() { // TODO: перенести в базовый класс для отображения везде где есть клавиатура
        // Скрываем подложку при старте, пока клавиатуры нет
        keyboardBackdrop.isHidden = true

        // Подписываемся на события клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow() {
        keyboardBackdrop.isHidden = false
    }

    @objc private func keyboardWillHide() {
        keyboardBackdrop.isHidden = true
    }
}
private extension BaseEntranceViewController {
    func setupConstraints() {
        navBar.translatesAutoresizingMaskIntoConstraints = false
        keyboardBackdrop.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: Layout.navigationBarsHeight),
            
            keyboardBackdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardBackdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardBackdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            keyboardBackdrop.topAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }
}
