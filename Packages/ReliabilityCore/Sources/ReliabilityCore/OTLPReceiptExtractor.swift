import Foundation

public enum OTLPReceiptExtractor {
    public static func sequences(in data: Data, matching runID: UUID) throws -> [Int] {
        let envelope = try JSONDecoder().decode(Envelope.self, from: data)
        let expectedRunID = runID.uuidString.lowercased()

        return envelope.resourceSpans.flatMap(\.scopeSpans).flatMap(\.spans).compactMap { span in
            let attributes = Dictionary(
                uniqueKeysWithValues: span.attributes.map { ($0.key, $0.value) }
            )
            guard attributes["lab.run.id"]?.stringValue?.lowercased() == expectedRunID,
                  let sequenceString = attributes["lab.sequence"]?.intValue,
                  let sequence = Int(sequenceString)
            else {
                return nil
            }
            return sequence
        }
    }
}

private struct Envelope: Decodable {
    let resourceSpans: [ResourceSpans]
}

private struct ResourceSpans: Decodable {
    let scopeSpans: [ScopeSpans]
}

private struct ScopeSpans: Decodable {
    let spans: [OTLPSpan]
}

private struct OTLPSpan: Decodable {
    let attributes: [KeyValue]
}

private struct KeyValue: Decodable {
    let key: String
    let value: AnyValue
}

private struct AnyValue: Decodable {
    let stringValue: String?
    let intValue: String?
}

