@testable import Malibu
import Foundation
import Quick
import Nimble

final class NetworkErrorSpec: QuickSpec {
  override func spec() {
    describe("NetworkError") {
      var error: NetworkError!

      context("when it's noDataInResponse") {
        beforeEach {
          error = .noDataInResponse
        }

        describe("#reason") {
          it("returns a correct string value") {
            expect(error.reason).to(equal("No data in response"))
          }
        }
      }

      context("when it's noDataInResponse") {
        beforeEach {
          error = .noResponseReceived
        }

        describe("#reason") {
          it("returns a correct string value") {
            expect(error.reason).to(equal("No response received"))
          }
        }
      }

      context("when it's unacceptableStatusCode") {
        let statusCode = 401

        beforeEach {
          error = .unacceptableStatusCode(
            statusCode: statusCode,
            response: self.makeResponse(statusCode: 200)
          )
        }

        describe("#reason") {
          it("returns a correct string value") {
            expect(error.reason).to(equal("Response status code \(statusCode) was unacceptable"))
          }
        }
      }

      context("when it's unacceptableStatusCode") {
        let contentType = "application/weirdo"

        beforeEach {
          error = .unacceptableContentType(
            contentType: contentType,
            response: self.makeResponse(statusCode: 200)
          )
        }

        describe("#reason") {
          it("returns a correct string value") {
            expect(error.reason).to(equal("Response content type \(contentType) was unacceptable"))
          }
        }
      }

      context("when it's noDataInResponse") {
        beforeEach {
          error = .missingContentType(response: self.makeResponse(statusCode: 200))
        }

        describe("#reason") {
          it("returns a correct string value") {
            expect(error.reason).to(equal("Response content type was missing"))
          }
        }
      }

      context("when it's offline error") {
        var offlineError: NSError!

        beforeEach {
          offlineError = NSError(
            domain: "io.github.vadymmarkov.Malibu",
            code: Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue),
            userInfo: nil
          )
        }

        describe("#reason") {
          it("returns true") {
            expect(offlineError.isOffline).to(beTrue())
          }
        }
      }
    }
  }
}
