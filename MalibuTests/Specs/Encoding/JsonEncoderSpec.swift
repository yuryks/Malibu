@testable import Malibu
import Foundation
import Quick
import Nimble

final class JsonEncoderSpec: QuickSpec {
  override func spec() {
    describe("JsonEncoder") {
      var encoder: JsonEncoder!

      beforeEach {
        encoder = JsonEncoder()
      }

      describe("#encode:parameters") {
        it("encodes a dictionary of parameters to NSData object") {
          let parameters = ["firstname": "John", "lastname": "Doe"]
          let data = try! JSONSerialization.data(
            withJSONObject: parameters,
            options: JSONSerialization.WritingOptions()
          )

          expect{ try encoder.encode(parameters: parameters) }.to(equal(data))
        }
      }
    }
  }
}
