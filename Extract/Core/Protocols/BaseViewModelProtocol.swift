//
//  BaseViewModelProtocol.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import Foundation


protocol BaseViewModelProtocol {
    var onError: ()->Void { get set }
}
