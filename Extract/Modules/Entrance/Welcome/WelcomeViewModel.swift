//
//  WelcomeViewModel.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import Foundation


final class WelcomeViewModel {

    // MARK: - Output

    var onLoginTap: (() -> Void)?
    var onRegisterTap: (() -> Void)?

    // MARK: - Input

    func buttonTapped(command: WelcomeButtonCommand) {
        switch command {
        case .login:
            onLoginTap?()
        case .registrate:
            onRegisterTap?()
        case .demo:
            break
        case .representers:
            break
        case .lock:
            break
        }
    }
}
