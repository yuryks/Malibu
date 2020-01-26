@testable import Malibu
import Foundation
import Quick
import Nimble

final class ContentTypeValidatorSpec: QuickSpec {
  override func spec() {
    describe("ContentTypeValidator") {
      let url = URL(string: "http://api.loc")!
      let request = URLRequest(url: url)
      let data = Data()
      let contentType = "application/json; charset=utf-8"
      var validator: ContentTypeValidator<[String]>!

      describe("#validate") {
        beforeEach {
          validator = ContentTypeValidator(contentTypes: [contentType])
        }

        context("when response has expected content type") {
          it("does not throw an error") {
            let httpUrlResponse = HTTPURLResponse(
              url: url,
              mimeType: contentType,
              expectedContentLength: 10,
              textEncodingName: nil
            )
            let result = Response(data: data, urlRequest: request, httpUrlResponse: httpUrlResponse)

            expect{ try validator.validate(result) }.toNot(throwError())
          }
        }

        context("when response has not expected content type") {
          it("throws an error") {
            let httpUrlResponse = HTTPURLResponse(
              url: url,
              mimeType: "text/html; charset=utf-8",
              expectedContentLength: 100,
              textEncodingName: nil
            )
            let result = Response(data: data, urlRequest: request, httpUrlResponse: httpUrlResponse)

            expect{ try validator.validate(result) }.to(throwError())
          }
        }
      }
    }
  }
}
