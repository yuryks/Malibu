@testable import Malibu
import Foundation
import Quick
import Nimble

final class UtilsSpec: QuickSpec {
  override func spec() {
    describe("Utils") {
      let fileManager = FileManager.default

      afterSuite {
        do {
          try fileManager.removeItem(atPath: Utils.storageDirectory)
        } catch {}
      }

      describe(".documentDirectory") {
        it("returns document directory") {
          let documentDirectory =  NSSearchPathForDirectoriesInDomains(.documentDirectory,
            .userDomainMask, true).first!

          expect(Utils.documentDirectory).to(equal(documentDirectory))
        }
      }

      describe(".storageDirectory") {
        it("returns a test storage directory path") {
          let directory = "\(Utils.documentDirectory)/Malibu"
          var isDir: ObjCBool = true

          expect(Utils.storageDirectory).to(equal(directory))
          expect(fileManager.fileExists(atPath: Utils.storageDirectory, isDirectory: &isDir)).to(beTrue())
        }
      }

      describe(".filePath") {
        it("returns a full file path") {
          let name = "filename"
          let path = "\(Utils.storageDirectory)/\(name)"

          expect(Utils.filePath(name)).to(equal(path))
        }
      }
    }
  }
}
