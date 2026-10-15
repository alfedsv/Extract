//
//  BaseViewModelProtocol.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import Foundation


protocol BaseViewModelProtocol: AnyObject {
    var onError: ((String) -> Void)? { get set }
    var onSetLoading: ((Bool) -> Void)? { get set }
}
