//
//  BaseViewController.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

class BaseViewController: UIViewController {

    private let viewModel: BaseViewModelProtocol
    
    private let loadingView = LoadingView()
    
    init(viewModel: BaseViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.App.background.color
        view.addSubview(loadingView)
        bindViewModel()
        setupConstrains()
    }
    
    private func bindViewModel() {
        viewModel.onSetLoading = { [weak self] isLoading in
            self?.setLoading(isLoading)
        }
        
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            let alert = UIAlertController(title: L10n.appError.localized, message: message + "\n" + L10n.appErrorSupport.localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    func setLoading(_ isLoading: Bool) {
        if isLoading {
            view.bringSubviewToFront(loadingView)
        }
        loadingView.isHidden = !isLoading
    }
}

private extension BaseViewController {
    func setupConstrains() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
