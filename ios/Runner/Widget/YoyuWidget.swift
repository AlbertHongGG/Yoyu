import WidgetKit
import SwiftUI
import Foundation

// MARK: - Model
struct CardEntity: Codable, Identifiable {
    var id: String { cardNo }
    let cardNo: String
    let cardName: String
    let cardFaceUrl: String
    let lastTranSum: Double
    let isRegister: Bool
}

// MARK: - Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), cards: [CardEntity(cardNo: "1234 5678", cardName: "我的卡片", cardFaceUrl: "", lastTranSum: 100.0, isRegister: false)])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let cards = loadCardsFromUserDefaults()
        let entry = SimpleEntry(date: Date(), cards: cards.isEmpty ? placeholder(in: context).cards : cards)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let cards = loadCardsFromUserDefaults()
        let entry = SimpleEntry(date: Date(), cards: cards)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    private func loadCardsFromUserDefaults() -> [CardEntity] {
        // Must match App Group ID defined in Flutter
        let sharedDefaults = UserDefaults(suiteName: "group.com.yoyu.app")
        if let jsonString = sharedDefaults?.string(forKey: "widget_cards_data"),
           let data = jsonString.data(using: .utf8) {
            do {
                return try JSONDecoder().decode([CardEntity].self, from: data)
            } catch {
                print("Error decoding cards: \(error)")
            }
        }
        return []
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let cards: [CardEntity]
}

// MARK: - UI View
struct YoyuWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if entry.cards.isEmpty {
            Text("無卡片資料")
                .foregroundColor(.gray)
        } else {
            // In iOS 17+, you can use interactive AppIntent for scrolling,
            // but for simple widget, we just display the first card or a VStack of cards.
            // Using a simple stack for the first card for demonstration.
            let card = entry.cards.first!
            
            VStack(alignment: .leading) {
                // Image
                if let url = URL(string: card.cardFaceUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 100)
                    .cornerRadius(12)
                }
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(card.cardName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                        Text(card.cardNo)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("$\(Int(card.lastTranSum))")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.white)
        }
    }
}

@main
struct YoyuWidget: Widget {
    let kind: String = "YoyuWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            YoyuWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Yoyu 卡片")
        .description("快速查看您的卡片餘額。")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
