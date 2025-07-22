//
//  MyArticlesView.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 28.06.2025.
//

import Foundation
import SwiftUI
import Speech
import SwiftData


struct MyArticlesView: View {
    @State private var searchBarText = ""
    @StateObject private var vm: MyArticlesViewModel
    @State private var showMicAlert = false
    
    private var filteredCategories: [Category] {
        vm.filteredCategories
    }
    
    init(modelContainer: ModelContainer) {
        _vm = StateObject(wrappedValue: MyArticlesViewModel(modelContainer: modelContainer))
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                SearchBarApp(text: $searchBarText) {}

                listArticles
                
                Spacer()
            }
            
            if vm.isLoading {
                ZStack {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.backgroundScreenColor)
        .navigationTitle("Мои статьи")
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: searchBarText) { newValue in
            vm.searchCategories(searchText: newValue)
        }
        .task {
            await vm.loadCategories()
        }
        .onTapGesture {
            UIApplication.shared.endEditing(true)
        }
        .alert(isPresented: Binding(
            get: { vm.alertMessage != nil },
            set: { if !$0 { vm.dismissAlert() } }
        )) {
            Alert(
                title: Text("Ошибка"),
                message: Text(vm.alertMessage ?? "Неизвестная ошибка"),
                dismissButton: .default(Text("Ок")) { vm.dismissAlert() }
            )
        }
    }
    
    private var articlesSubtitle: some View {
        Text.makeSubTitle(subTitle: "Статьи")
    }
    
    private var listArticles: some View {
        VStack(alignment: .leading, spacing: 12) {
            articlesSubtitle
                .font(.caption)
                .padding(.leading)
            
            ScrollView {
                VStack(spacing: 0) {
                    if filteredCategories.isEmpty {
                        Text("Ничего не найдено")
                            .foregroundColor(.gray)
                            .padding()
                            .transition(.opacity)
                    } else {
                        ForEach(filteredCategories, id: \.id) { category in
                            MyArticlesCellView(category: category)
                                .transition(.move(edge: .leading).combined(with: .opacity))
                            if category.id != filteredCategories.last?.id {
                                Divider().padding(.leading, 56)
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.white)
                .cornerRadius(10)
                .animation(.easeInOut, value: searchBarText)
            }
        }
        .padding(.horizontal, 14)
    }


}


//TODO: Вынести реализоацию в отдельный сервиc
class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    private let recognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var onResult: ((String) -> Void)?
    
    func startRecording() throws {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.removeTap(onBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("No request") }
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let recognizedText = result.bestTranscription.formattedString
                self.onResult?(recognizedText)
            }
            if error != nil || (result?.isFinal ?? false) {
                self.audioEngine.stop()
                node.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}
