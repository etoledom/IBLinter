//
//  MisplacedViewRule.swift
//  IBLinterKit
//
//  Created by SaitoYuta on 2017/12/15.
//

import IBLinterCore

extension Rules {

    public struct TextAlignmentRule: Rule {

        public static var identifier: String = "alignLeft"

        public init() {}

        public func validate(xib: XibFile) -> [Violation] {
            guard let views = xib.document.views else { return [] }
            return views.flatMap { validate(for: $0, file: xib) }
        }

        public func validate(storyboard: StoryboardFile) -> [Violation] {
            guard let scenes = storyboard.document.scenes else { return [] }
            let views = scenes.flatMap { $0.viewController?.rootView }
            return views.flatMap { validate(for: $0, file: storyboard) }
        }

        private func validate(for view: ViewProtocol, file: InterfaceBuilderFile) -> [Violation] {
            let violation: [Violation] = {
                guard let view = view as? InterfaceBuilderNode.View else { return [] }
                switch view {
                    case .label(let label):
                        let alignment = label.textAlignment ?? "left"
                        if alignment == "left" || alignment == "right" {
                            let message = "Forced text alignment \(alignment) in \(view.customClass ?? view.elementClass). Prefer to use textAlignment natural."
                            return [Violation.init(interfaceBuilderFile: file, message: message, level: .warning)]
                        }
                    case .textField(let textField):
                        let alignment = textField.textAlignment ?? "left"
                        if alignment == "left" || alignment == "right" {
                            let message = "Forced text alignment \(alignment) in \(view.customClass ?? view.elementClass). Prefer to use textAlignment natural."
                            return [Violation.init(interfaceBuilderFile: file, message: message, level: .warning)]
                        }                     
                    default: break
                }
               
                return []
            }()
            return violation + (view.subviews?.flatMap { validate(for: $0, file: file) } ?? [])
        }
    }
}
