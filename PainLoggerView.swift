
import SwiftUI

enum PainLevel: Int, CaseIterable, Identifiable {
    case none = 0, mild, moderate, severe

    var id: Int { rawValue }

    var description: String {
        switch self {
        case .none: return "No Pain"
        case .mild: return "Mild Pain"
        case .moderate: return "Moderate Pain"
        case .severe: return "Severe Pain"
        }
    }

    var color: Color {
        switch self {
        case .none: return .green
        case .mild: return .yellow
        case .moderate: return .orange
        case .severe: return .red
        }
    }
}

struct PainLoggerView: View {
    @State private var selectedLevel: PainLevel = .none
    @State private var selectedTimeSlot: String = "Morning"

    let timeSlots = ["Morning", "Afternoon", "Night"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Time of Day")) {
                    Picker("Time Slot", selection: $selectedTimeSlot) {
                        ForEach(timeSlots, id: \.self) { slot in
                            Text(slot)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Pain Level")) {
                    Picker("Pain Level", selection: $selectedLevel) {
                        ForEach(PainLevel.allCases) { level in
                            Text(level.description).tag(level)
                        }
                    }
                    .pickerStyle(.wheel)
                }

                Section {
                    HStack {
                        Circle()
                            .fill(selectedLevel.color)
                            .frame(width: 30, height: 30)
                        Text("You selected: \(selectedLevel.description)")
                    }
                }
            }
            .navigationTitle("Log Pain")
        }
    }
}

struct PainLoggerView_Previews: PreviewProvider {
    static var previews: some View {
        PainLoggerView()
    }
}
