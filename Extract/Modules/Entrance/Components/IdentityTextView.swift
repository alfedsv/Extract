//
//  IdentityTextView.swift
//  Extract
//
//  Created by  Alexander Fedoseev on 04.10.2026.
//

import UIKit

final class IdentityTextView: UITextView {

    let textViewType: IdentityTextViewType

    private let placeholderLabel = PlaceholderLabel()
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
                realText = newValue ?? ""
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

    init(textViewType: IdentityTextViewType) {
        self.textViewType = textViewType
        self.maxChars = textViewType.maxChars()
        super.init(frame: .zero, textContainer: .none)
        setupUI()
        setupAppearance()
        setupConstraints()
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
                self.setupAppearance()
            }
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        addSubview(placeholderLabel)
        placeholderLabel.text = textViewType.placeholder()
        backgroundColor = Colors.TextView.background.color
        font = Fonts.identityTextView.value
        autocorrectionType = .no
        spellCheckingType = .no
        layer.borderWidth = Layout.Identity.textViewBorderWidth
        layer.cornerRadius = Layout.Identity.textViewRadius
        layer.masksToBounds = true
        textContainer.maximumNumberOfLines = 0
        isScrollEnabled = false
        keyboardType = UIKeyboardType.default
        returnKeyType = .done
        tintColor = Colors.Text.common.color
        isSecureTextEntry = false
        switch textViewType {
        case .username:
            textContainerInset = Layout.Identity.textViewSpecialInsets
            autocapitalizationType = .none
        case .password:
            textContainerInset = Layout.Identity.textViewSpecialInsets
            autocapitalizationType = .none
            textContentType = .password
        case .confirm:
            textContainerInset = Layout.Identity.textViewSpecialInsets
            autocapitalizationType = .none
            textContentType = .newPassword
        case .firstName, .lastName:
            textContainerInset = Layout.Identity.textViewInsets
            autocapitalizationType = .allCharacters
        }
    }

    func toggleSecureTextEntry() -> Bool {
        isPasswordSecure.toggle()
        super.text = isPasswordSecure
            ? String(repeating: "•", count: realText.count)
            : realText
        selectedRange = NSRange(location: (super.text as NSString).length, length: 0)
        setupAppearance()
        delegate?.textViewDidChange?(self)
        return isPasswordSecure
    }

    func setupAppearance() {
        let trait = traitCollection

        if isError {
            layer.borderColor = Colors.TextView.Border.error.cgColor(with: trait)
            textColor = Colors.TextView.Text.active.color
        } else {
            if isFirstResponder {
                if isCharsAtMax() {
                    layer.borderColor = Colors.TextView.Border.inactive.cgColor(with: trait)
                    textColor = Colors.TextView.Text.inactive.color
                } else {
                    layer.borderColor = Colors.TextView.Border.active.cgColor(with: trait)
                    textColor = Colors.TextView.Text.active.color
                }
            } else {
                if self.text.isEmpty {
                    layer.borderColor = Colors.TextView.Border.inactive.cgColor(with: trait)
                    textColor = Colors.TextView.Text.inactive.color
                } else {
                    layer.borderColor = Colors.TextView.Border.active.cgColor(with: trait)
                    textColor = Colors.TextView.Text.active.color
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
        let newText = current.replacingCharacters(in: range, with: text)
        if newText.count > maxChars { return false }
        realText = newText
        return true
    }

    private func applySecureReplacement(range: NSRange, replacement: String) {
        let nsReal = realText as NSString
        let realRange = NSRange(location: range.location, length: range.length)

        // Защита от выхода за границы realText (бывает при быстрой вставке/удалении).
        let safeLocation = min(max(0, realRange.location), nsReal.length)
        let safeLength = min(realRange.length, nsReal.length - safeLocation)
        let safeRange = NSRange(location: safeLocation, length: safeLength)

        let newReal = nsReal.replacingCharacters(in: safeRange, with: replacement)
        guard newReal.count <= maxChars else { return }

        realText = newReal
        super.text = String(repeating: "•", count: realText.count)

        let caret = safeLocation + (replacement as NSString).length
        selectedRange = NSRange(location: caret, length: 0)

        setupAppearance()

        delegate?.textViewDidChange?(self)
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

        let trailingInset = (textViewType == .password || textViewType == .confirm || textViewType == .username)
            ? Layout.Identity.textViewSpecialInsets.right
            : Layout.Identity.textViewInsets.right

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
