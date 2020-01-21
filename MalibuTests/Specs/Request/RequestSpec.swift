@testable import Malibu
import Foundation
import Quick
import Nimble

final class RequestSpec: QuickSpec {
  override func spec() {
    describe("Request") {
      var request: Request!
      var urlRequest: URLRequest!

      beforeEach {
        request = Request.post(
          "http://api.loc/posts",
          parameters: ["key": "value"],
          headers: ["key": "value"]
        )
      }

      afterSuite {
        do {
          try FileManager.default.removeItem(atPath: Utils.storageDirectory)
        } catch {}
      }

      describe("#storePolicy") {
        it("has default value") {
          expect(request.storePolicy).to(equal(StorePolicy.unspecified))
        }
      }

      describe("#cachePolicy") {
        it("has default value") {
          expect(request.cachePolicy).to(equal(URLRequest.CachePolicy.useProtocolCachePolicy))
        }
      }

      describe("#toURLRequest") {
        context("when request URL is invalid") {
          it("throws an error") {
            request = Request.post("not an URL")
            expect{ try request.toUrlRequest() }.to(throwError(NetworkError.invalidRequestURL))
          }
        }

        context("when there are no errors") {
          beforeEach {
            request = Request.post(
              "http://api.loc/posts",
              parameters: ["key": "value"],
              headers: ["key": "value"])
          }

          context("without base URL") {
            it("does not throw an error and returns created URLRequest") {
              expect { urlRequest = try request.toUrlRequest() }.toNot(throwError())
              expect(urlRequest.url).to(equal(URL(string: request.resource.urlString)))
              expect(urlRequest.httpMethod).to(equal(Method.post.rawValue))
              expect(urlRequest.cachePolicy).to(equal(request.cachePolicy))
              expect(urlRequest.allHTTPHeaderFields?["Content-Type"]).to(equal(request.contentType.header))
              expect(urlRequest.httpBody).to(
                equal(try! request.contentType.encoder?.encode(parameters: request.parameters)))
              expect(urlRequest.allHTTPHeaderFields?["key"]).to(equal("value"))
            }
          }

          context("with base URL") {
            it("does not throw an error and returns created URLRequest") {
              request = Request.post("/about")

              expect {
                urlRequest = try request.toUrlRequest(baseUrl: "http://api.loc")
              }.toNot(throwError())
              expect(urlRequest.url?.absoluteString).to(equal("http://api.loc/about"))
            }
          }

          context("with base URL with slash") {
            it("does not throw an error and returns created URLRequest") {
              request = Request.post("/about")

              expect {
                urlRequest = try request.toUrlRequest(baseUrl: "http://api.loc/")
                }.toNot(throwError())
              expect(urlRequest.url?.absoluteString).to(equal("http://api.loc/about"))
            }
          }

          context("with base URL without slash") {
            it("does not throw an error and returns created URLRequest") {
              request = Request.post("about")

              expect {
                urlRequest = try request.toUrlRequest(baseUrl: "http://api.loc")
                }.toNot(throwError())
              expect(urlRequest.url?.absoluteString).to(equal("http://api.loc/about"))
            }
          }

          context("with base URL without slash and query parameters") {
            it("does not throw an error and returns created URLRequest") {
              request = Request.post("about?q=1")

              expect {
                urlRequest = try request.toUrlRequest(baseUrl: "http://api.loc")
                }.toNot(throwError())
              expect(urlRequest.url?.absoluteString).to(equal("http://api.loc/about?q=1"))
            }
          }

          context("with additional headers") {
            it("returns created URLRequest with new header added") {
              let headers = ["foo": "bar", "key": "bar"]
              request = Request.post("/about", headers: ["key": "value"])

              expect {
                urlRequest = try request.toUrlRequest(
                baseUrl: "http://api.loc",
                additionalHeaders: headers)
              }.toNot(throwError())

              expect(urlRequest.allHTTPHeaderFields?["foo"]).to(equal("bar"))
              expect(urlRequest.allHTTPHeaderFields?["key"]).to(equal("value"))
            }
          }

          context("with Query content type") {
            beforeEach {
              request = Request.get(
                "http:/api.loc/posts",
                parameters: ["key": "value", "number": 1])
            }

            it("does not set Content-Type header") {
              expect{ urlRequest = try request.toUrlRequest() }.toNot(throwError())
              expect(urlRequest.allHTTPHeaderFields?["Content-Type"]).to(beNil())
            }

            it("does not set body") {
              expect{ urlRequest = try request.toUrlRequest() }.toNot(throwError())
              expect(urlRequest.httpBody).to(beNil())
            }
          }

          context("with MultipartFormData content type") {
            beforeEach {
              request = Request.post(
                "http:/api.loc/posts",
                contentType: .multipartFormData,
                parameters: ["key": "value", "number": 1])
            }

            it("sets Content-Type header") {
              expect{ urlRequest = try request.toUrlRequest() }.toNot(throwError())
              expect(urlRequest.allHTTPHeaderFields?["Content-Type"]).to(
                equal("multipart/form-data; boundary=\(boundary)")
              )
            }

            it("sets Content-Length header") {
              expect{ urlRequest = try request.toUrlRequest() }.toNot(throwError())
              expect(urlRequest.allHTTPHeaderFields?["Content-Length"]).to(
                equal("\(urlRequest.httpBody!.count)")
              )
            }
          }

          context("upload task with data") {
            let data = Data(bytes: [UInt8](repeating: 0, count: 10))

            beforeEach {
              request = Request.upload(data: data, to: "http:/api.loc/posts")
            }

            it("creates URL request") {
              expect{ urlRequest = try request.toUrlRequest() }.toNot(throwError())
              expect(urlRequest.allHTTPHeaderFields?["Content-Type"]).to(
                equal("application/x-www-form-urlencoded")
              )
              expect(urlRequest.httpMethod).to(equal("POST"))
              expect(urlRequest.httpBody).to(equal(data))
            }
          }

          context("upload task with multipart parameters") {
            beforeEach {
              request = Request.upload(
                multipartParameters: ["key": "value"],
                to: "http:/api.loc/posts"
              )
            }

            it("sets Content-Type header") {
              expect{ urlRequest = try request.toUrlRequest() }.toNot(throwError())
              expect(urlRequest.allHTTPHeaderFields?["Content-Type"]).to(
                equal("multipart/form-data; boundary=\(boundary)")
              )
            }

            it("sets Content-Length header") {
              expect{ urlRequest = try request.toUrlRequest() }.toNot(throwError())
              expect(urlRequest.allHTTPHeaderFields?["Content-Length"]).to(
                equal("\(urlRequest.httpBody!.count)")
              )
            }
          }
        }

        describe("#buildURL") {
          context("when request URL is invalid") {
            it("throws an error") {
              expect {
                try request.buildUrl(from: "not an URL")
              }.to(throwError(NetworkError.invalidRequestURL))
            }
          }

          context("when content type is not Query") {
            beforeEach {
              request = Request.post(
                "http:/api.loc/posts",
                parameters: ["key": "value"])
            }

            it("returns URL") {
              let urlString = "http://api.loc"
              let result = URL(string: urlString)
              expect(try! request.buildUrl(from: urlString)).to(equal(result))
            }
          }

          context("when content type is Query but there are no parameters") {
            beforeEach {
              request = Request.get("http:/api.loc/posts")
            }

            it("returns URL") {
              let urlString = "http://api.loc"
              let result = URL(string: urlString)

              expect(try! request.buildUrl(from: urlString)).to(equal(result))
            }
          }

          context("when content type is Query and request has parameters") {
            beforeEach {
              request = Request.get(
                "http:/api.loc/posts",
                parameters: ["key": "value", "number": 1])
            }

            it("returns URL") {
              let urlString = "http://api.loc/posts"
              let result1 = URL(string: "http://api.loc/posts?key=value&number=1")
              let result2 = URL(string: "http://api.loc/posts?number=1&key=value")
              let url = try! request.buildUrl(from: urlString)

              expect(url == result1 || url == result2).to(beTrue())
            }
          }
        }

        describe("#key") {
          it("bulds a description based on rmethod and request URL") {
            expect(request.key).to(equal("POST http://api.loc/posts"))
          }
        }

        describe("#adding:parameters:headers") {
          it("creates a new request by adding parameters and headers") {
            let newRequest = request.adding(parameters: ["foo": "bar"], headers: ["header": "test"])
            let expectedRequest = Request.post(
              "http://api.loc/posts",
              parameters: ["key": "value", "foo": "bar"],
              headers: ["key": "value", "header": "test"]
            )
            expect(newRequest).to(equal(expectedRequest))
          }
        }
      }
    }
  }
}
