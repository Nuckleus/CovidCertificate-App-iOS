//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

class InfoBoxView: UIView {
    // MARK: - Subviews

    private let backgroundView = UIView()

    private let contentView = UIView()
    private let stackView = UIStackView()

    private let titleLabel = Label(.title, textAlignment: .center)
    private let textLabel = Label(.text, textAlignment: .center)
    private let button = Button(title: "", style: .normal(.cc_blue))
    private let closeButton = Button(title: "", style: .text(.cc_blue))

    private var buttonView = UIView()
    private var closeButtonView = UIView()

    private var viewPoint: CGPoint = .zero

    // MARK: - API

    public var showCallback: ((Bool) -> Void)?

    public var infoBox: InfoBox? {
        didSet { update() }
    }

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Animation

    public func presentFrom(view: UIView) {
        showCallback?(true)

        isUserInteractionEnabled = true

        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = 1.0
        }

        viewPoint = convert(view.center, to: superview)
        let p2 = convert(contentView.center, to: superview)

        contentView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01).concatenating(CGAffineTransform(translationX: viewPoint.x - p2.x, y: viewPoint.y - p2.y))

        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
            self.contentView.transform = .identity
            self.contentView.alpha = 1.0
        }, completion: { _ in })
    }

    public func dismiss() {
        if viewPoint == .zero {
            return
        }

        showCallback?(false)

        isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = 0.0
        }

        let p2 = convert(contentView.center, to: superview)
        contentView.transform = .identity

        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01).concatenating(CGAffineTransform(translationX: self.viewPoint.x - p2.x, y: self.viewPoint.y - p2.y))
            self.contentView.alpha = 0.0

        }, completion: { _ in
        })

        if let id = infoBox?.infoId {
            var ids = InfoBoxVisibilityManager.shared.dismissedInfoBoxIds
            ids.append(id)
            InfoBoxVisibilityManager.shared.dismissedInfoBoxIds = ids
        }
    }

    // MARK: - Setup

    private func setup() {
        addSubview(backgroundView)

        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backgroundView.backgroundColor = UIColor.cc_black.withAlphaComponent(0.54)
        contentView.backgroundColor = .cc_white
        contentView.layer.cornerRadius = 20.0

        addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Padding.large)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().inset(3.0 * Padding.large)
            make.bottom.lessThanOrEqualToSuperview().inset(3.0 * Padding.large)
        }

        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(Padding.large)
            make.bottom.equalToSuperview().inset(Padding.medium)
        }

        stackView.axis = .vertical

        stackView.addArrangedView(titleLabel)
        stackView.addSpacerView(Padding.medium + Padding.small - 2.0)
        stackView.addArrangedView(textLabel)
        stackView.addSpacerView(Padding.medium + Padding.small + 2.0)

        closeButtonView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }

        buttonView.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview().inset(Padding.small)
        }

        stackView.addArrangedView(buttonView)
        stackView.addArrangedView(closeButtonView)

        closeButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss()
        }

        backgroundView.alpha = 0.0
        contentView.alpha = 0.0
        isUserInteractionEnabled = false

        button.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            if let url = strongSelf.infoBox?.url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    // MARK: - Update

    private func update() {
        titleLabel.text = infoBox?.title
        textLabel.text = infoBox?.msg
        buttonView.ub_setHidden(infoBox?.url == nil)
        button.title = infoBox?.urlTitle
        closeButton.title = button.isHidden ? UBLocalized.ok_button : UBLocalized.close_button
        layoutIfNeeded()
    }
}
