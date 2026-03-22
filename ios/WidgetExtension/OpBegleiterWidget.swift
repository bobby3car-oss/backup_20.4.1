import WidgetKit
import SwiftUI

// MARK: - Shared Data

struct WidgetData {
    let nextTaskTitle: String
    let nextTaskType: String
    let nextTaskTime: String
    let openTaskCount: Int
    let currentStreak: Int
    let longestStreak: Int
    let level: Int
    let xp: Int
    let nextAppointmentTitle: String
    let nextAppointmentTime: String
    let lastPainLevel: Int
    let lastUpdated: String

    static let placeholder = WidgetData(
        nextTaskTitle: "Wundkontrolle",
        nextTaskType: "wound",
        nextTaskTime: "09:00",
        openTaskCount: 3,
        currentStreak: 5,
        longestStreak: 12,
        level: 3,
        xp: 280,
        nextAppointmentTitle: "Nachsorge",
        nextAppointmentTime: "Mo 24.3. 10:00",
        lastPainLevel: 3,
        lastUpdated: ""
    )

    static func load() -> WidgetData {
        let defaults = UserDefaults(suiteName: "group.com.example.operationsbegleiterV3")
        return WidgetData(
            nextTaskTitle: defaults?.string(forKey: "nextTaskTitle") ?? "",
            nextTaskType: defaults?.string(forKey: "nextTaskType") ?? "",
            nextTaskTime: defaults?.string(forKey: "nextTaskTime") ?? "",
            openTaskCount: defaults?.integer(forKey: "openTaskCount") ?? 0,
            currentStreak: defaults?.integer(forKey: "currentStreak") ?? 0,
            longestStreak: defaults?.integer(forKey: "longestStreak") ?? 0,
            level: defaults?.integer(forKey: "level") ?? 1,
            xp: defaults?.integer(forKey: "xp") ?? 0,
            nextAppointmentTitle: defaults?.string(forKey: "nextAppointmentTitle") ?? "",
            nextAppointmentTime: defaults?.string(forKey: "nextAppointmentTime") ?? "",
            lastPainLevel: defaults?.integer(forKey: "lastPainLevel") ?? -1,
            lastUpdated: defaults?.string(forKey: "lastUpdated") ?? ""
        )
    }
}

// MARK: - Timeline Provider

struct OpBegleiterProvider: TimelineProvider {
    func placeholder(in context: Context) -> OpBegleiterEntry {
        OpBegleiterEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (OpBegleiterEntry) -> Void) {
        let data = context.isPreview ? WidgetData.placeholder : WidgetData.load()
        completion(OpBegleiterEntry(date: Date(), data: data))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<OpBegleiterEntry>) -> Void) {
        let data = WidgetData.load()
        let entry = OpBegleiterEntry(date: Date(), data: data)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct OpBegleiterEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// MARK: - Theme Colors

struct WidgetColors {
    static let primary = Color(red: 0.29, green: 0.47, blue: 0.90)       // #4A78E6
    static let primaryLight = Color(red: 0.29, green: 0.47, blue: 0.90).opacity(0.15)
    static let accent = Color(red: 0.98, green: 0.60, blue: 0.20)        // #FA9933
    static let surface = Color(red: 0.97, green: 0.97, blue: 0.99)       // #F7F8FC
    static let textPrimary = Color(red: 0.11, green: 0.11, blue: 0.12)   // #1C1C1E
    static let textSecondary = Color(red: 0.56, green: 0.56, blue: 0.58) // #8E8E93
    static let streakOrange = Color(red: 1.0, green: 0.58, blue: 0.0)    // #FF9500
    static let painGreen = Color(red: 0.20, green: 0.78, blue: 0.35)     // #34C759
    static let painYellow = Color(red: 1.0, green: 0.80, blue: 0.0)      // #FFCC00
    static let painRed = Color(red: 1.0, green: 0.23, blue: 0.19)        // #FF3B30
}

// MARK: - Helper

enum WidgetHelpers {
    static func taskIcon(for type: String) -> String {
        switch type {
        case "wound": return "bandage"
        case "meds": return "pills"
        case "checklist": return "checklist"
        case "appointment": return "calendar"
        case "message": return "message"
        case "nutrition": return "fork.knife"
        case "note": return "note.text"
        default: return "circle.dotted"
        }
    }

    static func painColor(for level: Int) -> Color {
        if level <= 3 { return WidgetColors.painGreen }
        if level <= 6 { return WidgetColors.painYellow }
        return WidgetColors.painRed
    }
}

// MARK: - 1. Next Task Widget (Small)

struct NextTaskWidgetView: View {
    let data: WidgetData

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: WidgetHelpers.taskIcon(for: data.nextTaskType))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(WidgetColors.primary)
                Spacer()
                if !data.nextTaskTime.isEmpty {
                    Text(data.nextTaskTime)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(WidgetColors.textSecondary)
                }
            }

            Spacer()

            if data.nextTaskTitle.isEmpty {
                Text("Alles erledigt! ✓")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(WidgetColors.painGreen)
            } else {
                Text(data.nextTaskTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(WidgetColors.textPrimary)
                    .lineLimit(2)
            }

            if data.openTaskCount > 0 {
                Text("\(data.openTaskCount) offene Tasks")
                    .font(.system(size: 11))
                    .foregroundColor(WidgetColors.textSecondary)
            }
        }
        .padding(14)
        .widgetURL(URL(string: "opbegleiter://timeline"))
    }
}

// MARK: - 2. Streak Counter Widget (Small)

struct StreakWidgetView: View {
    let data: WidgetData

    var body: some View {
        VStack(spacing: 4) {
            Spacer()

            Text("🔥")
                .font(.system(size: 32))

            Text("\(data.currentStreak)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(WidgetColors.streakOrange)

            Text(data.currentStreak == 1 ? "Tag" : "Tage")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(WidgetColors.textSecondary)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 10))
                    .foregroundColor(WidgetColors.accent)
                Text("Rekord: \(data.longestStreak)")
                    .font(.system(size: 10))
                    .foregroundColor(WidgetColors.textSecondary)
            }
        }
        .padding(14)
        .widgetURL(URL(string: "opbegleiter://gamification"))
    }
}

// MARK: - 3. Day Overview Widget (Medium)

struct DayOverviewWidgetView: View {
    let data: WidgetData

    var body: some View {
        HStack(spacing: 12) {
            // Left column: Appointment + Tasks
            VStack(alignment: .leading, spacing: 8) {
                // Next appointment
                VStack(alignment: .leading, spacing: 2) {
                    Label {
                        Text("Nächster Termin")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(WidgetColors.textSecondary)
                    } icon: {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                            .foregroundColor(WidgetColors.primary)
                    }

                    if data.nextAppointmentTitle.isEmpty {
                        Text("Kein Termin")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(WidgetColors.textSecondary)
                    } else {
                        Text(data.nextAppointmentTitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(WidgetColors.textPrimary)
                            .lineLimit(1)
                        Text(data.nextAppointmentTime)
                            .font(.system(size: 11))
                            .foregroundColor(WidgetColors.textSecondary)
                    }
                }

                Spacer()

                // Next task
                VStack(alignment: .leading, spacing: 2) {
                    Label {
                        Text("Nächster Task")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(WidgetColors.textSecondary)
                    } icon: {
                        Image(systemName: WidgetHelpers.taskIcon(for: data.nextTaskType))
                            .font(.system(size: 10))
                            .foregroundColor(WidgetColors.primary)
                    }

                    if data.nextTaskTitle.isEmpty {
                        Text("Alles erledigt ✓")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(WidgetColors.painGreen)
                    } else {
                        Text(data.nextTaskTitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(WidgetColors.textPrimary)
                            .lineLimit(1)
                        Text("\(data.openTaskCount) offen · \(data.nextTaskTime)")
                            .font(.system(size: 11))
                            .foregroundColor(WidgetColors.textSecondary)
                    }
                }
            }

            // Right column: Streak + Pain
            VStack(spacing: 8) {
                // Streak
                VStack(spacing: 2) {
                    Text("🔥")
                        .font(.system(size: 20))
                    Text("\(data.currentStreak)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(WidgetColors.streakOrange)
                    Text("Streak")
                        .font(.system(size: 10))
                        .foregroundColor(WidgetColors.textSecondary)
                }

                Spacer()

                // Pain level
                VStack(spacing: 2) {
                    if data.lastPainLevel >= 0 {
                        Text("\(data.lastPainLevel)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(WidgetHelpers.painColor(for: data.lastPainLevel))
                        Text("Schmerz")
                            .font(.system(size: 10))
                            .foregroundColor(WidgetColors.textSecondary)
                    } else {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 22))
                            .foregroundColor(WidgetColors.painGreen)
                        Text("Kein Wert")
                            .font(.system(size: 10))
                            .foregroundColor(WidgetColors.textSecondary)
                    }
                }
            }
            .frame(width: 72)
        }
        .padding(14)
        .widgetURL(URL(string: "opbegleiter://timeline"))
    }
}

// MARK: - 4. Quick Actions Widget (Medium)

struct QuickActionsWidgetView: View {
    var body: some View {
        HStack(spacing: 0) {
            quickActionButton(icon: "gauge", label: "Schmerz", scheme: "opbegleiter://pain")
            quickActionButton(icon: "heart.text.square", label: "Vitals", scheme: "opbegleiter://vitals")
            quickActionButton(icon: "camera.fill", label: "Wundfoto", scheme: "opbegleiter://wound")
            quickActionButton(icon: "sparkle", label: "Bella", scheme: "opbegleiter://bella")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
    }

    func quickActionButton(icon: String, label: String, scheme: String) -> some View {
        Link(destination: URL(string: scheme)!) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(WidgetColors.primaryLight)
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(WidgetColors.primary)
                }
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(WidgetColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Glass Background Modifier

struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content
                .containerBackground(for: .widget) {
                    ZStack {
                        Color.white.opacity(0.72)
                        Rectangle()
                            .fill(.ultraThinMaterial)
                    }
                }
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.85))
                )
        }
    }
}

extension View {
    func glassBackground() -> some View {
        modifier(GlassBackground())
    }
}

// MARK: - Widget Configurations

struct NextTaskWidget: Widget {
    let kind = "NextTaskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: OpBegleiterProvider()) { entry in
            NextTaskWidgetView(data: entry.data)
                .glassBackground()
        }
        .configurationDisplayName("Nächster Task")
        .description("Zeigt den nächsten offenen Task an.")
        .supportedFamilies([.systemSmall])
    }
}

struct StreakWidget: Widget {
    let kind = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: OpBegleiterProvider()) { entry in
            StreakWidgetView(data: entry.data)
                .glassBackground()
        }
        .configurationDisplayName("Streak Counter")
        .description("Dein aktueller Streak.")
        .supportedFamilies([.systemSmall])
    }
}

struct DayOverviewWidget: Widget {
    let kind = "DayOverviewWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: OpBegleiterProvider()) { entry in
            DayOverviewWidgetView(data: entry.data)
                .glassBackground()
        }
        .configurationDisplayName("Tages-Übersicht")
        .description("Termin, Tasks, Streak und Schmerz auf einen Blick.")
        .supportedFamilies([.systemMedium])
    }
}

struct QuickActionsWidget: Widget {
    let kind = "QuickActionsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: OpBegleiterProvider()) { entry in
            QuickActionsWidgetView()
                .glassBackground()
        }
        .configurationDisplayName("Quick Actions")
        .description("Schnellzugriff auf Schmerz, Vitals, Wundfoto & Bella.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Widget Bundle

@main
struct OpBegleiterWidgetBundle: WidgetBundle {
    var body: some Widget {
        NextTaskWidget()
        StreakWidget()
        DayOverviewWidget()
        QuickActionsWidget()
    }
}
