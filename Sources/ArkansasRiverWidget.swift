import WidgetKit
import SwiftUI

struct RiverFlowProvider: TimelineProvider {
    func placeholder(in context: Context) -> RiverFlowEntry {
        RiverFlowEntry(date: Date(), flow: 0, trend: .stable)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (RiverFlowEntry) -> ()) {
        let entry = RiverFlowEntry(date: Date(), flow: 0, trend: .stable)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<RiverFlowEntry>) -> ()) {
        Task {
            do {
                let flow = try await RiverFlowFetcher.fetchCurrentFlow()
                let trend = try await RiverFlowFetcher.analyzeTrend()
                let entry = RiverFlowEntry(date: Date(), flow: flow, trend: trend)
                
                // Update every hour or when the widget becomes active
                let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                // Handle error case
                let entry = RiverFlowEntry(date: Date(), flow: 0, trend: .stable)
                let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
                completion(timeline)
            }
        }
    }
}

struct RiverFlowEntry: TimelineEntry {
    let date: Date
    let flow: Double
    let trend: FlowTrend
    
    enum FlowTrend {
        case rising
        case falling
        case stable
    }
}

struct ArkansasRiverWidgetEntryView : View {
    var entry: RiverFlowProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    var trendColor: Color {
        switch entry.trend {
        case .rising:
            return .green
        case .falling:
            return .red
        case .stable:
            return .primary
        }
    }
    
    var body: some View {
        Text("\(Int(entry.flow))cfs")
            .font(.system(.title2, design: .rounded, weight: .bold))
            .foregroundColor(trendColor)
            .widgetAccentable()
    }
}

@main
struct ArkansasRiverWidget: Widget {
    let kind: String = "ArkansasRiverWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RiverFlowProvider()) { entry in
            ArkansasRiverWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Arkansas River Flow")
        .description("Shows current flow at Salida")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}
