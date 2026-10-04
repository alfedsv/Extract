//
//  IdentityTextView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit


final class IdentityTextView: UITextView {

    enum TextViewType {
        case username
        case password
        case confirm
        case firstName
        case lastName
        
        func placeholder() -> String {
            switch self {
            case .username:
                L10n.Entrance.Identity.Placeholder.username.localized
            case .password:
                L10n.Entrance.Identity.Placeholder.password.localized
            case .confirm:
                L10n.Entrance.Identity.Placeholder.confirm.localized
            case .firstName:
                L10n.Entrance.Identity.Placeholder.firstName.localized
            case .lastName:
                L10n.Entrance.Identity.Placeholder.lastName.localized
            }
        }
        
        func maxChars() -> Int {
            switch self {
            case .username:
                Settings.IdentityTextView.usernameClosedRange.upperBound
            case .password, .confirm:
                Settings.IdentityTextView.passwordClosedRange.upperBound
            case .firstName, .lastName:
                Settings.IdentityTextView.nameClosedRange.upperBound
            }
        }
    }

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.TextView.placeholder.color
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let textViewType: TextViewType
    private let maxChars: Int
    
    private var realText: String = ""
    private var isPasswordSecure: Bool = true
    
    override var text: String! {
        get {
            // наружу отдаём реальный текст
            if isSecureMode { return realText }
            return super.text
        }
        set {
            if isSecureMode {
                realText = newValue ?? ""
                super.text = String(repeating: "•", count: realText.count)
            } else {
                super.text = newValue
            }
        }
    }

    private var isSecureMode: Bool {
        switch textViewType {
        case .password, .confirm: return isPasswordSecure
        default: return false
        }
    }

    var isError: Bool = false {
        didSet {
            if oldValue != isError {
                setupAppearance()
            }
        }
    }

    init(textViewType: TextViewType) {
        self.textViewType = textViewType
        self.maxChars = textViewType.maxChars()
        super.init(frame: .zero, textContainer: .none)
        setupUI()
        setupAppearance()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(placeholderLabel)
        placeholderLabel.text = textViewType.placeholder()
        backgroundColor = Colors.TextView.background.color
        font = UIFont(name: "Menlo-Regular", size: 16)
        autocorrectionType = .no
        spellCheckingType = .no
        returnKeyType = .done
        layer.borderWidth = Layout.Identity.textViewBorderWidth
        layer.cornerRadius = Layout.Identity.textViewRadius
        layer.masksToBounds = true
        textContainer.maximumNumberOfLines = 0
        isScrollEnabled = false
        keyboardType = UIKeyboardType.default
        returnKeyType = .done
        switch textViewType {
        case .username:
            textContainerInset = Layout.Identity.textViewInsets
            autocapitalizationType = .none
            isSecureTextEntry = false
        case .password:
            textContainerInset = Layout.Identity.textViewPasswordInsets
            autocapitalizationType = .none
            isSecureTextEntry = true
        case .confirm:
            textContainerInset = Layout.Identity.textViewInsets
            autocapitalizationType = .none
            isSecureTextEntry = true
        case .firstName, .lastName:
            textContainerInset = Layout.Identity.textViewInsets
            autocapitalizationType = .allCharacters
            isSecureTextEntry = false
        }
    }
    
    func toggleSecureTextEntry() -> Bool {
        isPasswordSecure.toggle()
        super.text = isPasswordSecure ? String(repeating: "•", count: realText.count) : realText
        selectedRange = NSRange(location: (super.text as NSString).length, length: 0)
        return isPasswordSecure
    }

    
    func setupAppearance() {
        if isError {
            self.layer.borderColor = Colors.TextView.Border.error.cgColor
            self.textColor = Colors.TextView.Text.active.color
        } else {
            if isFirstResponder {
                if isCharsAtMax() {
                    self.layer.borderColor = Colors.TextView.Border.inactive.cgColor
                    self.textColor = Colors.TextView.Text.inactive.color
                } else {
                    self.layer.borderColor = Colors.TextView.Border.active.cgColor
                    self.textColor = Colors.TextView.Text.active.color
                }
            } else {
                if self.text.isEmpty {
                    self.layer.borderColor = Colors.TextView.Border.inactive.cgColor
                    self.textColor = Colors.TextView.Text.inactive.color
                } else {
                    self.layer.borderColor = Colors.TextView.Border.active.cgColor
                    self.textColor = Colors.TextView.Text.active.color
                }
            }
        }
        placeholderHandler()
    }
    
    private func placeholderHandler() {
        if isFirstResponder {
            placeholderLabel.isHidden = true
        } else {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
    
    private func isCharsAtMax() -> Bool {
        text.count >= maxChars
    }
    
    func shouldChange(in range: NSRange, replacementText text: String) -> Bool {
        if text.rangeOfCharacter(from: .newlines) != nil { return false }
        if textViewType == .username {
            if !text.isEmpty,
                text.rangeOfCharacter(from: Settings.IdentityTextView.loginAllowedCharacterSet.inverted) != nil {
                return false
            }
            if text.contains("@") { return false }
            if range.location == 0 { return false }   // защита @
        }

        if isSecureMode {
            applySecureReplacement(range: range, replacement: text)
            return false
        }

        let current = super.text as NSString
        let newLength = current.replacingCharacters(in: range, with: text).count
        if newLength > maxChars { return false }

        return true
    }
    
    private func applySecureReplacement(range: NSRange, replacement: String) {
        if replacement.isEmpty {
            if !realText.isEmpty { realText.removeLast() }
        } else {
            for ch in replacement {
                if realText.count >= maxChars { break }
                realText.append(ch)
            }
        }
        super.text = String(repeating: "•", count: realText.count)
        selectedRange = NSRange(location: (super.text as NSString).length, length: 0)
        setupAppearance()
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        guard result else { return result }

        if textViewType == .username, super.text.isEmpty {
            super.text = "@"
            selectedRange = NSRange(location: 1, length: 0)
            setupAppearance()
        }
        return result
    }

    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        guard result else { return result }

        if textViewType == .username, super.text == "@" {
            super.text = ""
            setupAppearance()
        }
        return result
    }

}
private extension IdentityTextView {
    func setupConstraints() {
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        let trailingInset = textViewType == .password ? Layout.Identity.textViewPasswordInsets.right : Layout.Identity.textViewInsets.right

        NSLayoutConstraint.activate([
            placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.Identity.textViewInsets.left),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -trailingInset)
        ])
    }
}
extension IdentityTextView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setupAppearance()
        }
    }
}
