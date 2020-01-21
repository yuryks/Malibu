@testable import Malibu
import Foundation
import Quick
import Nimble

final class StatusCodeValidatorSpec: QuickSpec {
  override func spec() {
    describe("StatusCodeValidator") {
      let url = Foundation.URL(string: "http://api.loc")!
      let request = URLRequest(url: url)
      let data = Data()
      var validator: StatusCodeValidator<[Int]>!

      describe("#validate") {
        beforeEach {
          validator = StatusCodeValidator(statusCodes: [200])
        }

        context("when response has expected status code") {
          it("does not throw an error") {
            let httpUrlResponse = HTTPURLResponse(
              url: url,
              statusCode: 200,
              httpVersion: "HTTP/2.0",
              headerFields: nil
            )!
            let result = Response(data: data, urlRequest: request, httpUrlResponse: httpUrlResponse)

            expect{ try validator.validate(result) }.toNot(throwError())
          }
        }

        context("when response has not expected status code") {
          it("throws an error") {
            let httpUrlResponse = HTTPURLResponse(
              url: url,
              statusCode: 404,
              httpVersion: "HTTP/2.0",
              headerFields: nil
            )!
            let result = Response(data: data, urlRequest: request, httpUrlResponse: httpUrlResponse)

            expect{ try validator.validate(result) }.to(throwError())
          }
        }
      }
    }
  }
}
