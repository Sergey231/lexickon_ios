//
//  TranslationLanguageRouter.swift
//  Lexickon
//
//  Created by Sergey Borovikov on 20.05.2026.
//

import Foundation
import NaturalLanguage

struct TranslationRoute: Equatable {
    let source: Locale.Language?
    let target: Locale.Language
    let title: String
}

enum TranslationLanguageRouter {
    private static let english = Locale.Language(identifier: "en")
    private static let russian = Locale.Language(identifier: "ru")

    static func route(for text: String) -> TranslationRoute {
        switch detectedLanguage(for: text) {
        case .russian:
            TranslationRoute(source: russian, target: english, title: "Русский -> English")
        case .english:
            TranslationRoute(source: english, target: russian, title: "English -> Русский")
        default:
            TranslationRoute(source: nil, target: english, title: "Авто -> English")
        }
    }

    private static func detectedLanguage(for text: String) -> NLLanguage? {
        if text.range(of: #"\p{Cyrillic}"#, options: .regularExpression) != nil {
            return .russian
        }

        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        return recognizer.dominantLanguage
    }
}
