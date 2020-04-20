import Foundation

final class FormURLEncoder: ParameterEncoding {
  func encode(parameters: [String: Any]) throws -> Data {
    guard let data = QueryBuilder().buildQuery(from: parameters).data(using: .utf8, allowLossyConversion: false) else {
        throw NSError(domain: "FormURLEncoder", code: -1, userInfo: .none)
    }
    
    return data
  }
}
