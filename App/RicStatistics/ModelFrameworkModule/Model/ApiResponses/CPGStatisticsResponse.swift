import Foundation

struct CPGStatisticsResponse: Codable, ApiResponse {
    let statistics: [CPGStatisticsResponse.Item]


    func getUsersIds() -> [Int] {
        return statistics.map { $0.userId }
    }
}

// MARK: - CPGStatisticsResponse.Item

extension CPGStatisticsResponse {
    struct Item: Codable {
        let userId: Int
        let type: ItemType
        let dates: [Date]

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case type
            case dates
        }

        init(from decoder:  Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)

            self.userId = try container.decode(Int.self, forKey: .userId)
            self.type = try container.decode(ItemType.self, forKey: .type)
            self.dates = try Self.parseDatesFrom(container)
        }

        static func parseDatesFrom(_ container: KeyedDecodingContainer<CodingKeys>) throws -> [Date] {
            let datesAsInt = try container.decode([Int].self, forKey: .dates)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "ddMMyyyy"

            var parsedDates: [Date] = []
            for dateAsInt in datesAsInt {
                var dateString = String(dateAsInt)
                dateString = String(repeating: "0", count: max(0, 8 - dateString.count)) + dateString
                if let parsedDate = dateFormatter.date(from: dateString) {
                    parsedDates.append(parsedDate)
                } else {
                    throw DecodingError.dataCorruptedError(
                        forKey: .dates,
                        in: container,
                        debugDescription: "Неверный формат даты: \(datesAsInt)"
                    )
                }
            }

            return parsedDates
        }
    }
}

// MARK: - CPGStatisticsResponse.ItemType

extension CPGStatisticsResponse {
    enum ItemType: String, Codable {
        case subscription
        case unsubscription
        case view
    }
}
