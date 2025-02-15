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

extension VerificationError {
    func displayName() -> NSAttributedString {
        switch self {
        case .signature:
            let bold = UBLocalized.wallet_error_invalid_signature_bold
            return UBLocalized.wallet_error_invalid_signature.formattingOccurrenceBold(bold)
        case .revocation:
            let bold = UBLocalized.wallet_error_revocation_bold
            return UBLocalized.wallet_error_revocation.formattingOccurrenceBold(bold)
        case .otherNationalRules:
            return UBLocalized.wallet_error_national_rules.formattingOccurrenceBold("")
        case .expired:
            let bold = UBLocalized.wallet_error_expired_bold
            return UBLocalized.wallet_error_expired.formattingOccurrenceBold(bold)
        case let .notYetValid(date):
            let dayDate = DateFormatter.ub_dayString(from: date)
            return UBLocalized.wallet_error_valid_from.replacingOccurrences(of: "{DATE}", with: dayDate).formattingOccurrenceBold(dayDate)
        case .unknown:
            return UBLocalized.unknown_error.formattingOccurrenceBold("")
        }
    }

    func icon(with color: UIColor? = nil) -> UIImage? {
        switch self {
        case .signature: return UIImage(named: "ic-info-alert")?.ub_image(with: color ?? UIColor.cc_grey)
        case .revocation: return UIImage(named: "ic-info-alert")?.ub_image(with: color ?? UIColor.cc_grey)
        case .otherNationalRules: return UIImage(named: "ic-info-alert")?.ub_image(with: color ?? UIColor.cc_grey)
        case .expired:
            if let c = color {
                return UIImage(named: "ic-invalid")?.ub_image(with: c)
            } else {
                return UIImage(named: "ic-invalid")
            }
        case .notYetValid:
            if let c = color {
                return UIImage(named: "ic-timelapse")?.ub_image(with: c)
            } else {
                return UIImage(named: "ic-timelapse")
            }
        case .unknown:
            if let c = color {
                return UIImage(named: "ic-invalid")?.ub_image(with: c)
            } else {
                return UIImage(named: "ic-invalid")
            }
        }
    }
}
