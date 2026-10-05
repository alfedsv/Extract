//
//  HomeViewController.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

final class HomeViewController: BaseHomeViewController {

    var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

}
