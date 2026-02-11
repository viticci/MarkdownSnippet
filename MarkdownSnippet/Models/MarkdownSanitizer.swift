import Foundation

extension String {
    func sanitizedMarkdownInput() -> String {
        var scalars = String.UnicodeScalarView()
        scalars.reserveCapacity(unicodeScalars.count)

        for scalar in unicodeScalars {
            if shouldDropScalar(scalar) {
                continue
            }
            scalars.append(scalar)
        }

        return String(scalars)
    }

    func markdownSanitizationDebugString(limit: Int = 12) -> String {
        var filteredScalars: [String] = []
        filteredScalars.reserveCapacity(min(limit, 4))
        var totalFiltered = 0

        var formatScalars: [String] = []
        formatScalars.reserveCapacity(min(limit, 4))
        var totalFormat = 0

        for scalar in unicodeScalars {
            if scalar.properties.generalCategory == .format {
                totalFormat += 1
                if formatScalars.count < limit {
                    formatScalars.append(String(format: "U+%04X", scalar.value))
                }
            }

            if shouldDropScalar(scalar) {
                totalFiltered += 1
                if filteredScalars.count < limit {
                    filteredScalars.append(String(format: "U+%04X", scalar.value))
                }
            }
        }

        let filteredList = filteredScalars.joined(separator: " ")
        let filteredSuffix = totalFiltered > limit ? " ..." : ""
        let formatList = formatScalars.joined(separator: " ")
        let formatSuffix = totalFormat > limit ? " ..." : ""

        return "filtered=\(totalFiltered) \(filteredList)\(filteredSuffix) format=\(totalFormat) \(formatList)\(formatSuffix)"
    }

    private func shouldDropScalar(_ scalar: Unicode.Scalar) -> Bool {
        let allowedControls: Set<Unicode.Scalar> = ["\n", "\r", "\t"]

        if scalar == "\u{FEFF}" || scalar == "\u{FFFC}" || scalar == "\u{FFFD}" {
            return true
        }

        let value = scalar.value
        let isC0Control = value < 0x20 && !allowedControls.contains(scalar)
        let isC1Control = value >= 0x7F && value <= 0x9F
        if isC0Control || isC1Control {
            return true
        }

        if CharacterSet.controlCharacters.contains(scalar) && !allowedControls.contains(scalar) {
            return true
        }

        if CharacterSet.illegalCharacters.contains(scalar) {
            return true
        }

        if scalar.properties.generalCategory == .format {
            return true
        }

        if scalar.properties.generalCategory == .privateUse {
            return true
        }

        return false
    }
}
