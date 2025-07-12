//
//  MyArticlesView.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 28.06.2025.
//

import Foundation
import SwiftUI
import Speech


struct MyArticlesView: View {
    @State private var searchBarText = ""
    @StateObject private var vm = MyArticlesViewModel()
    @State private var showMicAlert = false
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    private var filteredCategories: [Category] {
        vm.filteredCategories
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SearchBarApp(text: $searchBarText) {
                // Обработка микро
                Task {
                    if isRecording {
                        speechRecognizer.stopRecording()
                        isRecording = false
                    } else {
                        let granted = await PermissionService.shared.requestMicrophonePermission()
                        if !granted {
                            showMicAlert = true
                        } else {
                            do {
                                try speechRecognizer.startRecording()
                                isRecording = true
                            } catch {
                                //TODO: показать норм ошибку (сервис ошибок)
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }

            listArticles
            
            Spacer()
        }
        .background(Color.backgroundScreenColor)
        .navigationTitle("Мои статьи")
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: searchBarText) { newValue in
            vm.searchCategories(searchText: newValue)
        }
        .task {
            vm.loadCategories()
        }
        .onAppear {
            speechRecognizer.onResult = { recognizedText in
                searchBarText = recognizedText
            }
        }
        .onTapGesture {
            UIApplication.shared.endEditing(true)
        }
        .alert("Нет доступа к микрофону", isPresented: $showMicAlert) {
            Button("OK", role: .cancel) { }
            Button("Открыть настройки") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Пожалуйста, разрешите доступ к микрофону в настройках, чтобы пользоваться голосовым поиском.")
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
            
            VStack {
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
