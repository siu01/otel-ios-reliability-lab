import Foundation

public struct ExperimentID: RawRepresentable, Codable, Hashable, Sendable,
    CustomStringConvertible
{
    public let rawValue: String

    public init?(rawValue: String) {
        guard rawValue.count == 4,
              rawValue.first == "E",
              rawValue.dropFirst().allSatisfy(\.isNumber)
        else {
            return nil
        }
        self.rawValue = rawValue
    }

    public var description: String { rawValue }
}
