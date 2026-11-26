//
//  DataTransferView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.11.2026.
//

import SwiftUI
import SwiftData

/// Экспорт всех поездок и подтверждаемое объединение данных из файла.
struct DataTransferView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @State private var viewModel = DataTransferViewModel()

    // MARK: - Тело View

    var body: some View {
        Form {
            transferSections
        }
        .navigationTitle(.dataTransferNavigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .disabled(viewModel.isWorking || viewModel.isWaitingForNotice || viewModel.plan != nil)
        .fileImporter(
            isPresented: $viewModel.isShowingImporter,
            allowedContentTypes: [DataTransferDocument.archiveType]
        ) { result in
            viewModel.importFile(result, container: context.container)
        }
        .fileExporter(
            isPresented: $viewModel.isShowingExporter,
            document: viewModel.document,
            contentType: DataTransferDocument.archiveType,
            defaultFilename: "Coinsa-\(DataTransferCodec.dateString(Date()))"
        ) { result in
            viewModel.exportCompleted(result)
        }
        .sheet(isPresented: $viewModel.isShowingImportPreview, onDismiss: viewModel.importPreviewDismissed) {
            DataTransferImportPreviewView(viewModel: viewModel)
        }
        .notificationAlert(
            isPresented: rootNoticeBinding,
            title: viewModel.noticeTitle,
            message: viewModel.noticeMessage,
            isError: viewModel.noticeIsError
        )
        .onDisappear {
            if !viewModel.isShowingImportPreview && !viewModel.isShowingImporter && !viewModel.isShowingExporter {
                viewModel.cancel()
            }
        }
    }

    // MARK: - Основной контент

    private var transferSections: some View {
        Group {
            Section {
                Button {
                    haptics.trigger(.tap)
                    viewModel.isShowingImporter = true
                } label: {
                    HStack {
                        Image(systemName: AppSymbols.squareAndArrowDown)
                            .padding(.bottom, ViewLayout.Label.arrowIconBottomInset)
                        Text(.dataTransferImport)
                    }
                }
            } footer: {
                Text(.dataTransferImportHint)
            }
            Section {
                Button {
                    haptics.trigger(.tap)
                    viewModel.exportData(container: context.container)
                } label: {
                    HStack {
                        Image(systemName: AppSymbols.squareAndArrowUp)
                            .padding(.bottom, ViewLayout.Label.arrowIconBottomInset)
                        Text(.dataTransferExport)
                    }
                }
            } footer: {
                Text(.dataTransferExportHint)
            }
        }
    }

    // MARK: - Биндинги

    private var rootNoticeBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isShowingNotice && !viewModel.isShowingImportPreview },
            set: { viewModel.isShowingNotice = $0 }
        )
    }
}

// MARK: - Превью

#Preview("Without data") {
    @Previewable @State var preview = PreviewEnvironment()

    NavigationStack {
        DataTransferView()
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}

#Preview("With data") {
    @Previewable @State var preview = PreviewEnvironment(
        trips: PreviewBuilder.builder().withScenario(.all).buildData()
    )

    NavigationStack {
        DataTransferView()
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}
