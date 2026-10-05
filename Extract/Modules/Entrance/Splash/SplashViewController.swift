//
//  SplashViewController.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

final class SplashViewController: BaseViewController {

    private var viewModel: SplashViewModel
    
    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.App.background.color
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.check()
    }

}
