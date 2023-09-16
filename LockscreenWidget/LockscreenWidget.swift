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
        DayEntry(date: Date(), count: 0, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (DayEntry) -> ()) {
        let entry = DayEntry(date: Date(), count: 0, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DayEntry] = []
        
        let userDefaults = UserDefaults(suiteName: "group.widgetGroupIdentifier")
        let count = userDefaults?.value(forKey: "group.integer") as? Int ?? 0
        let currentDate = Date()
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!

        let totalCountdown = 60
        
        for i in 0...totalCountdown {
            let component = DateComponents(minute: i)
            let refreshDate = Calendar.current.date(byAdding: component, to: Date())!
            
            let entry = DayEntry(date: refreshDate, count: count, configuration: configuration)
            entries.append(entry)
            
        }
        
//        for dayOffset in 0 ..< 7 {
//
//            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
//            let entry = DayEntry(date: entryDate, count: count, configuration: configuration)
//            entries.append(entry)
//        }

        let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
        completion(timeline)
    }
}

struct DayEntry: TimelineEntry {
    let date: Date
    let count: Int
    let configuration: ConfigurationIntent
    var url: URL?{
        guard let url = URL(string: "") else {
            fatalError("Can't get URL link")
        }
        return url
    }
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
                    .fill(.indigo.gradient)
                VStack {
                    HStack(spacing: 2) {
                        Image("calendar")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .center)
                        Text(entry.date.formatted(.dateTime.weekday(.wide)))
                            .font(.title3)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                        Spacer()
                        
                    }
                    Text(entry.date.formatted(.dateTime.day()))
                        .frame(width: 120, height: 60, alignment: .center)
                        .padding(.bottom)
                        .font(.system(size: 60,weight: .heavy))
                    Text("Number of events: \(entry.count)")
                        .font(.system(size: 12,weight: .medium))

                }
                .padding()
                
                
                
            case .accessoryInline:
                if entry.count == 0 {
                    Text("No events on today")
                } else {
                    Text("Today's event: \(entry.count)")
                }
            default:
                Text("Not implemented")
            }
        }
        
    }
}

struct LockscreenWidget: Widget {
    let kind: String = "Forget About Tasks"

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
        LockscreenWidgetEntryView(entry: DayEntry(date: Date(), count: 1, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
            .previewDisplayName("Test accessory inline")
        LockscreenWidgetEntryView(entry: DayEntry(date: Date(), count: 2 , configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Test system small")
    }
    
}
