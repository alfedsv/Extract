//
//  SplashViewController.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

final class SplashViewController: BaseViewController {


    var viewModel: SplashViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.App.background.color
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.check()
    }

}
