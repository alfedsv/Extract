//
//  BaseViewModel.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 06.10.2026.
//

import Foundation


class BaseViewModel: BaseViewModelProtocol {
    var onError: ((String) -> Void)?
    var onSetLoading: ((Bool) -> Void)?
    
}
