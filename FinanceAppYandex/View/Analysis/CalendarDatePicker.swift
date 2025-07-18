import SwiftUI

struct CalendarDatePicker: View {
    @Binding var selectedDate: Date
    var onDone: ((Date) -> Void)?

    var body: some View {
        VStack {
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .environment(\.locale, Locale(identifier: "ru_RU"))
            .labelsHidden()
            .padding()

            Button("Готово") {
                onDone?(selectedDate)
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
        .padding()
    }
}


