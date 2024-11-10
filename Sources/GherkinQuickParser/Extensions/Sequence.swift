//
//  Sequence.swift
//  GherkinQuickParser
//
//  Created by Murilo Teixeira on 09/11/24.
//

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
