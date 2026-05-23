//
//  ContentView.swift
//  Lexickon
//
//  Created by Sergey Borovikov on 20.05.2026.
//

import SwiftUI
import Translation

struct ContentView: View {
    @State private var sourceText = ""
    @State private var translatedText = ""
    @State private var routeTitle = "Авто -> English"
    @State private var isTranslating = false
    @State private var translationConfiguration: TranslationSession.Configuration?
    @State private var pendingText = ""

    var body: some View {
        VStack(spacing: 0) {
            TranslationTextField(
                title: "Оригинал",
                subtitle: routeTitle,
                placeholder: "Введите текст",
                text: $sourceText,
                isEditable: true
            )
            .accessibilityIdentifier("sourceTextEditor")

            Divider()

            Button(action: translate) {
                HStack(spacing: 8) {
                    if isTranslating {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.down")
                    }

                    Text(isTranslating ? "Перевод..." : "Перевести")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isTranslateDisabled)
            .padding()
            .accessibilityIdentifier("translateButton")

            Divider()

            TranslationTextField(
                title: "Перевод",
                subtitle: "Результат",
                placeholder: "Здесь появится перевод",
                text: $translatedText,
                isEditable: false
            )
            .accessibilityIdentifier("translatedTextEditor")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .translationTask(translationConfiguration) { session in
            await runTranslation(with: session)
        }
    }

    private var isTranslateDisabled: Bool {
        isTranslating || sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func translate() {
        guard !isTranslateDisabled else { return }

        let text = sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        let route = TranslationLanguageRouter.route(for: text)

        pendingText = text
        translatedText = ""
        routeTitle = route.title
        isTranslating = true

        if translationConfiguration == nil {
            translationConfiguration = TranslationSession.Configuration(source: route.source, target: route.target)
        } else {
            translationConfiguration?.source = route.source
            translationConfiguration?.target = route.target
            translationConfiguration?.invalidate()
        }
    }

    private func runTranslation(with session: TranslationSession) async {
        do {
            let response = try await session.translate(pendingText)

            translatedText = response.targetText
        } catch {
            translatedText = error.localizedDescription
        }

        isTranslating = false
    }
}

private struct TranslationTextField: View {
    let title: String
    let subtitle: String
    let placeholder: String
    @Binding var text: String
    let isEditable: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ZStack(alignment: .topLeading) {
                TextEditor(text: isEditable ? $text : readOnlyText)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .disabled(!isEditable)

                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.quaternary, lineWidth: 1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var readOnlyText: Binding<String> {
        Binding(
            get: { text },
            set: { _ in }
        )
    }
}
