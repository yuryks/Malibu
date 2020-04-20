import Foundation

final class JsonEncoder: ParameterEncoding {
  func encode(parameters: [String: Any]) throws -> Data {
    return try JSONSerialization.data(withJSONObject: parameters)
  }
}
