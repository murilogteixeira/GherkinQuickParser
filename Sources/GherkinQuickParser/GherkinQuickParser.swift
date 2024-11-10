// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

struct GherkinQuickParser {

    let bundle: Bundle
    let testFilePath: String

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }

    public init(bundle: Bundle, testFilePath: StaticString = #filePath) {
        self.bundle = bundle
        let fileURL = URL(string: "\(testFilePath)")
        self.testFilePath = fileURL?.deletingLastPathComponent().absoluteString ?? ""
    }

    public func createFeatureTestFile() {
        guard let urls = bundle.urls(forResourcesWithExtension: "feature", subdirectory: nil) else { return }

        for url in urls {
            let featureFilePath = url.absoluteString.replacingOccurrences(of: "file://", with: "")
            guard let feature = parseFeatureFile(at: featureFilePath) else { return }
            let testCode = generateTestCode(for: feature)

            let url = URL(string: featureFilePath)!
            let featureName = url.lastPathComponent.split(separator: ".").first ?? ""
            let featureActionsCode = generateFeatureActionsCode(for: feature)

            writeCode(testCode, to: testFilePath + "Features/", filename: featureName + "Tests.swift")
            writeCode(featureActionsCode, to: testFilePath + "FeatureActions/", filename: featureName + "Tests+Actions.swift")
        }
    }

    private func parseFeatureFile(at path: String) -> Feature? {
        guard let content = try? String(contentsOfFile: path) else {
            return nil
        }

        var featureName = ""
        var scenarios: [Scenario] = []
        var currentScenario: Scenario?

        for line in content.components(separatedBy: .newlines) {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            if trimmedLine.hasPrefix("Feature:") {
                featureName = trimmedLine.replacingOccurrences(of: "Feature:", with: "").trimmingCharacters(in: .whitespaces)
            } else if trimmedLine.hasPrefix("Scenario:") {
                // Finaliza o cenário anterior, se existir
                if let scenario = currentScenario {
                    scenarios.append(scenario)
                }

                // Inicia um novo cenário
                let scenarioName = trimmedLine.replacingOccurrences(of: "Scenario:", with: "").trimmingCharacters(in: .whitespaces)
                currentScenario = Scenario(name: scenarioName, steps: [])
            } else if let type = StepType(rawValue: "\(trimmedLine.prefix(1))") { // Determina o tipo do passo
                guard let scenario = currentScenario else { continue }

                // Extrai a descrição do passo
                let description = trimmedLine.components(separatedBy: " ").dropFirst().joined(separator: " ")
                let step = Step(type: type, description: description)

                // Adiciona o passo ao cenário atual
                currentScenario = Scenario(name: scenario.name, steps: scenario.steps + [step])
            }
        }

        // Adiciona o último cenário ao array de cenários
        if let scenario = currentScenario {
            scenarios.append(scenario)
        }

        return Feature(name: featureName, scenarios: scenarios)
    }

    private func generateTestCode(for feature: Feature) -> String {
        guard
            let featureTemplatePath = bundle.path(forResource: "FeatureTestTemplate", ofType: "txt"),
            let featureTemplateURL = URL(string: "file://\(featureTemplatePath)"),
            let featureTemplateData = try? Data(contentsOf: featureTemplateURL),
            let featureTemplate = String(data: featureTemplateData, encoding: .utf8)
        else { return "" }

        guard
            let scenarioTemplatePath = bundle.path(forResource: "ScenarioTemplate", ofType: "txt"),
            let scenarioTemplateURL = URL(string: "file://\(scenarioTemplatePath)"),
            let scenarioTemplateData = try? Data(contentsOf: scenarioTemplateURL),
            let scenarioTemplate = String(data: scenarioTemplateData, encoding: .utf8)
        else { return "" }

        let featureName = feature.name.capitalized
        let featureClass = featureName.replacingOccurrences(of: " ", with: "")

        var featureTemplateCode = featureTemplate.replacingOccurrences(of: "<#CreatedAt#>", with: dateString)
        featureTemplateCode = featureTemplateCode.replacingOccurrences(of: "<#Feature#>", with: featureName)
        featureTemplateCode = featureTemplateCode.replacingOccurrences(of: "<#FeatureClass#>", with: featureClass)

        var scenariosCode: [String] = []

        for scenario in feature.scenarios {
            var scenarioCode = scenarioTemplate
            scenarioCode = scenarioCode.replacingOccurrences(of: "<#Scenario#>", with: scenario.name.capitalized)

            let thenStep = scenario.steps.first(where: { $0.type == .then })
            scenarioCode = scenarioCode.replacingOccurrences(of: "<#Then#>", with: thenStep?.description.capitalized ?? scenario.name.capitalized)

            var stepsCode: [String] = []

            for step in scenario.steps {
                stepsCode.append(step.type.rawValue + step.description.capitalized.replacingOccurrences(of: " ", with: "") + "()")
            }

            scenarioCode = scenarioCode.replacingOccurrences(of: "<#Steps#>", with: stepsCode.joined(separator: "\n                    "))
            scenariosCode.append(scenarioCode)
        }

        featureTemplateCode = featureTemplateCode.replacingOccurrences(of: "<#Scenarios#>", with: scenariosCode.joined(separator: "\n            "))
        return featureTemplateCode
    }

    private func generateFeatureActionsCode(for feature: Feature) -> String {
        guard
            let featureActionsTemplatePath = bundle.path(forResource: "FeatureActionsTemplate", ofType: "txt"),
            let featureActionsTemplateURL = URL(string: "file://\(featureActionsTemplatePath)"),
            let featureActionsTemplateData = try? Data(contentsOf: featureActionsTemplateURL),
            let featureActionsTemplate = String(data: featureActionsTemplateData, encoding: .utf8)
        else { return "" }

        var stepsCode: [String] = []

        for scenario in feature.scenarios {
            stepsCode.append(contentsOf: generateActionsCode(for: scenario))
        }

        let featureName = feature.name.capitalized
        let featureClass = featureName.replacingOccurrences(of: " ", with: "")

        var featureActionsCode = featureActionsTemplate.replacingOccurrences(of: "<#CreatedAt#>", with: dateString)
        featureActionsCode = featureActionsCode.replacingOccurrences(of: "<#FeatureClass#>", with: featureClass)
        featureActionsCode = featureActionsCode.replacingOccurrences(of: "<#Actions#>", with: stepsCode.uniqued().joined(separator: "\n    "))

        return featureActionsCode
    }

    private func generateActionsCode(for scenario: Scenario) -> [String] {
        guard
            let actionTemplatePath = bundle.path(forResource: "ActionTemplate", ofType: "txt"),
            let actionTemplateURL = URL(string: "file://\(actionTemplatePath)"),
            let actionTemplateData = try? Data(contentsOf: actionTemplateURL),
            let actionTemplate = String(data: actionTemplateData, encoding: .utf8)
        else { return [] }

        var stepsCode: [String] = []

        for step in scenario.steps {
            let stepMethod = step.type.rawValue + step.description.capitalized.replacingOccurrences(of: " ", with: "")
            let actionCode = actionTemplate.replacingOccurrences(of: "<#function#>", with: stepMethod)
            stepsCode.append(actionCode)
        }

        return stepsCode
    }

    private func writeCode(_ code: String, to path: String, filename: String) {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: path) {
            try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        }

        fileManager.createFile(atPath: path + filename, contents: code.data(using: .utf8))
    }
}
