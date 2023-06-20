//
//  LockscreenWidget.swift
//  LockscreenWidget
//
//  Created by Константин Малков on 19.06.2023.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (DayEntry) -> ()) {
        let entry = DayEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DayEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startOfDate = Calendar.current.startOfDay(for: entryDate)
            let entry = DayEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct DayEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct WidgetDataModel: Codable {
    let scheduleStartDate: Date
    let scheduleEndDate: Date
    let scheduleName: String
}

struct LockscreenWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: DayEntry

    var body: some View {
        ZStack {
            switch widgetFamily {
            case .systemSmall:
                
                ContainerRelativeShape()
                    .fill(.green.gradient)
                VStack {
                    HStack(spacing: 4) {
                        Text("📅")
                        Text(entry.date.formatted(.dateTime.weekday(.wide)))
                            .font(.title3)
                            .fontWeight(.bold)
                            .minimumScaleFactor(0.6)
                        Spacer()
                    }
                    Text(entry.date.formatted(.dateTime.day()))
                        .font(.system(size: 80,weight: .heavy))
                }
                .padding()
                
                
            case .accessoryInline:
                Text(entry.date, style: .date)
            default:
                Text("Not implemented")
            }
        }
        
    }
}

struct LockscreenWidget: Widget {
    let kind: String = "My app test"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            LockscreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Forget About Tasks Calendar Widget")
        .description("This widget include current day for creating new event on date.")
        .supportedFamilies([.accessoryInline,.systemSmall])
    }
}

struct LockscreenWidget_Previews: PreviewProvider {
    static var previews: some View {
        LockscreenWidgetEntryView(entry: DayEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
            .previewDisplayName("Test accessory inline")
        LockscreenWidgetEntryView(entry: DayEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Test system small")
    }
    
}
