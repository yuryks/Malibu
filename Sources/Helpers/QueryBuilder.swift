import Foundation

public struct QueryBuilder {

  public typealias Component = (String, String)

  let escapingCharacters = ":#[]@!$&'()*+,;="

  public init() {}

  public func buildQuery(from parameters: [String: Any]) -> String {
    return buildComponents(from: parameters).map({ "\($0)=\($1)" }).joined(separator: "&")
  }

  public func buildComponents(from parameters: [String: Any]) -> [Component] {
    var components: [Component] = []

    parameters.forEach { key, value in
      components += buildComponents(key: key, value: value)
    }

    return components
  }

  public func buildComponents(key: String, value: Any) -> [Component] {
    var components: [Component] = []

    if let dictionary = value as? [String: Any] {
      dictionary.forEach { nestedKey, value in
        components += buildComponents(key: "\(key)[\(nestedKey)]", value: value)
      }
    } else if let array = value as? [Any] {
      array.forEach { value in
        components += buildComponents(key: "\(key)[]", value: value)
      }
    } else {
      components.append((escape(key), escape("\(value)")))
    }

    return components
  }

  public func escape(_ string: String) -> String {
    let allowedCharacters = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
    allowedCharacters.removeCharacters(in: escapingCharacters)

    var escapedString = ""

    if #available(iOS 8.3, *) {
      escapedString = string.addingPercentEncoding(
        withAllowedCharacters: allowedCharacters as CharacterSet) ?? string
    } else {
      var index = string.startIndex

      while index != string.endIndex {
        guard let endIndex = string.index(index, offsetBy: 50, limitedBy: string.endIndex) else {
          break
        }
        
        let range = Range(index..<endIndex)
        let substring = string.substring(with: range)

        index = endIndex
        escapedString += substring.addingPercentEncoding(
          withAllowedCharacters: allowedCharacters as CharacterSet) ?? substring
      }
    }

    return escapedString
  }
}
