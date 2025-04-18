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
        case .moderate: return .orange.opacity(0.8)
        case .severe: return .red.opacity(0.9)
        }
    }
}

struct TimeArcCircle: View {
    var color: Color
    var timeSlot: String

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size / 2 - 1
            let lineWidth: CGFloat = 6

            ZStack {
                ArcSegment(startAngle: start(for: timeSlot), endAngle: end(for: timeSlot), radius: radius, center: center)
                    .stroke(color, lineWidth: lineWidth)
                ArcSegment(startAngle: start(for: timeSlot), endAngle: end(for: timeSlot), radius: radius, center: center)
                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
            }
        }
        .frame(width: 30, height: 30)
    }

    func start(for slot: String) -> Angle {
        switch slot {
        case "Morning": return .degrees(-90)
        case "Afternoon": return .degrees(30)
        case "Night": return .degrees(150)
        default: return .degrees(-90)
        }
    }

    func end(for slot: String) -> Angle {
        switch slot {
        case "Morning": return .degrees(30)
        case "Afternoon": return .degrees(150)
        case "Night": return .degrees(270)
        default: return .degrees(30)
        }
    }
}

struct PainDayCircle: View {
    var colors: [Color]
    var didTrain: Bool

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size / 2 - 1
            let lineWidth: CGFloat = 6

            ZStack {
                ForEach(0..<3) { index in
                    let startAngle = Angle(degrees: Double(index) * 120 - 90)
                    let endAngle = Angle(degrees: Double(index + 1) * 120 - 90)
                    
                    ArcSegment(startAngle: startAngle, endAngle: endAngle, radius: radius, center: center)
                        .stroke(colors[index], lineWidth: lineWidth)
                }
                Circle()
                    .fill(didTrain ? Color.blue.opacity(0.3) : Color.white)
                    .frame(width: size - lineWidth * 2, height: size - lineWidth * 2)
                Circle()
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(width: 30, height: 30)
    }
}

struct ArcSegment: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var radius: CGFloat
    var center: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        return path
    }
}

struct PainLoggerView: View {
    @State private var selectedLevel: PainLevel = .none
    @State private var selectedTimeSlot: String = "Morning"
    @State private var didTrainToday: Bool = false
    @State private var currentMonthOffset: Int = 0
    @State private var loggedPain: [Date: [String: PainLevel]] = [:]
    
    let timeSlots = ["Morning", "Afternoon", "Night"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    Text("Log Pain")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text(Date(), style: .date)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("Time of Day")
                            .font(.headline)
                        Picker("Time Slot", selection: $selectedTimeSlot) {
                            ForEach(timeSlots, id: \.self) { slot in
                                Text(slot)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("Pain Level")
                            .font(.headline)
                        Picker("Pain Level", selection: $selectedLevel) {
                            ForEach(PainLevel.allCases) { level in
                                Text(level.description).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        let timeSlotIndex = timeSlots.firstIndex(of: selectedTimeSlot) ?? 0
                        let previewColors = (0..<3).map { $0 == timeSlotIndex ? selectedLevel.color : Color.clear }
                        HStack {
                            PainDayCircle(colors: previewColors, didTrain: false)
                                .frame(width: 30, height: 30)
                            Text("You selected: \(selectedLevel.description)")
                        }
                    }
                    .padding(.horizontal)

                    VStack(spacing: 8) {
                    Button(action: {
                        let calendar = Calendar.current
                        let today = calendar.startOfDay(for: Date())
                        var dayLog = loggedPain[today, default: [:]]
                        dayLog[selectedTimeSlot] = selectedLevel
                        loggedPain[today] = dayLog
                    }) {
                            Text("Log Entry")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .bold()
                        }

                        Button(action: {
                            didTrainToday.toggle()
                        }) {
                            Text("Training")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                                .bold()
                        }
                    }
                    .padding(.horizontal)

                    VStack {
                        HStack {
                            Button(action: {
                                currentMonthOffset -= 1
                            }) {
                                Image(systemName: "chevron.left")
                            }

                            Spacer()

                            let baseDate = Calendar.current.date(byAdding: .month, value: currentMonthOffset, to: Date())!
                            Text("\(Calendar.current.monthSymbols[Calendar.current.component(.month, from: baseDate) - 1]) \(Calendar.current.component(.year, from: baseDate))")
                                .font(.title3)
                                .bold()

                            Spacer()

                            Button(action: {
                                currentMonthOffset += 1
                            }) {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .padding(.horizontal)
                    }

                    VStack(alignment: .leading) {
                        Text("Pain Calendar")
                            .font(.headline)

                        let calendar = Calendar.current
                        let baseDate = calendar.date(byAdding: .month, value: currentMonthOffset, to: Date())!
                        let today = Date()
                        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate))!
                        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
                        let numDays = range.count
                        let weekday = calendar.component(.weekday, from: firstOfMonth) // 1 = Sunday, 7 = Saturday
                        let startOffset = weekday == 1 ? 6 : weekday - 2 // Make Monday start column

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                            ForEach(0..<startOffset, id: \.self) { _ in
                                Color.clear.frame(width: 30, height: 30)
                            }

                            ForEach(1...numDays, id: \.self) { day in
                            let calendar = Calendar.current
                            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                                ZStack {
                                    let isToday = calendar.isDate(date, inSameDayAs: today)
                                    let colors: [Color] = {
                                        if date > today {
                                            return Array(repeating: Color.gray.opacity(0.3), count: 3)
                                        } else if let dayLog = loggedPain[calendar.startOfDay(for: date)] {
                                            return timeSlots.map { slot in
                                                dayLog[slot]?.color ?? Color.clear
                                            }
                                        } else {
                                            return Array(repeating: Color.gray.opacity(0.3), count: 3)
                                        }
                                    }()
                                    
                                    PainDayCircle(colors: colors, didTrain: isToday && didTrainToday)
                                    Text("\(day)")
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                                .allowsHitTesting(calendar.isDate(date, inSameDayAs: today))
                            }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    struct PainLoggerView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                PainLoggerView()
                    .previewDevice("iPhone 13 mini")
                PainLoggerView()
                    .previewLayout(.sizeThatFits)
                    .previewDisplayName("Size That Fits")
            }
        }
    }
}

#Preview {
    PainLoggerView()
}
