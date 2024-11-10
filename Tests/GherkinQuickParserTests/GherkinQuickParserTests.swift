import Testing
@testable import GherkinQuickParser
import Foundation

@Test func setupGherkinQuickParser() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.

    GherkinQuickParser(bundle: .module).createFeatureTestFile()
}
