//
//  Model.swift
//  GherkinQuickParser
//
//  Created by Murilo Teixeira on 09/11/24.
//

struct Feature {
    let name: String
    let scenarios: [Scenario]
}

struct Scenario {
    let name: String
    let steps: [Step]
}

enum StepType: String, CaseIterable {

    case given, when, then

    init?(rawValue: String) {
        guard let type = Self.allCases.first(where: { type in type.rawValue.localizedCaseInsensitiveContains(rawValue) }) else {
            return nil
        }

        self = type
    }
}

struct Step {
    let type: StepType
    let description: String
}
