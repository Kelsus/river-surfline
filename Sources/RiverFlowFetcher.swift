import Foundation

enum RiverFlowError: Error {
    case invalidResponse
    case networkError(Error)
    case invalidData
}

struct RiverFlowFetcher {
    private static let baseURL = "https://dwr.state.co.us/Rest/GET/api/v2/telemetrystations/telemetrytimeseries/"
    private static let stationID = "ARKSALCO"
    
    static func fetchCurrentFlow() async throws -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -1, to: now)!
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "dateFormat", value: "dateTime"),
            URLQueryItem(name: "fields", value: "measValue"),
            URLQueryItem(name: "parameter", value: "DISCHRG"),
            URLQueryItem(name: "abbrev", value: stationID),
            URLQueryItem(name: "startDate", value: formatDate(startDate)),
            URLQueryItem(name: "endDate", value: formatDate(now))
        ]
        
        let (data, response) = try await URLSession.shared.data(from: components.url!)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RiverFlowError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(FlowResponse.self, from: data)
        
        guard let lastReading = result.resultList.last?.measValue else {
            throw RiverFlowError.invalidData
        }
        
        return lastReading
    }
    
    static func analyzeTrend() async throws -> RiverFlowEntry.FlowTrend {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -1, to: now)!
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "dateFormat", value: "dateTime"),
            URLQueryItem(name: "fields", value: "measValue"),
            URLQueryItem(name: "parameter", value: "DISCHRG"),
            URLQueryItem(name: "abbrev", value: stationID),
            URLQueryItem(name: "startDate", value: formatDate(startDate)),
            URLQueryItem(name: "endDate", value: formatDate(now))
        ]
        
        let (data, response) = try await URLSession.shared.data(from: components.url!)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RiverFlowError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(FlowResponse.self, from: data)
        
        guard result.resultList.count >= 2 else {
            return .stable
        }
        
        let readings = result.resultList.suffix(24) // Last 24 readings
        let values = readings.map { $0.measValue }
        let trend = calculateTrend(values)
        
        return trend
    }
    
    private static func calculateTrend(_ values: [Double]) -> RiverFlowEntry.FlowTrend {
        guard values.count >= 2 else { return .stable }
        
        let threshold = 5.0 // CFS threshold for considering a change significant
        let first = values.prefix(values.count/2).reduce(0.0, +) / Double(values.count/2)
        let last = values.suffix(values.count/2).reduce(0.0, +) / Double(values.count/2)
        
        let difference = last - first
        
        if abs(difference) < threshold {
            return .stable
        }
        return difference > 0 ? .rising : .falling
    }
    
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// Response models
struct FlowResponse: Codable {
    let resultList: [FlowReading]
}

struct FlowReading: Codable {
    let measValue: Double
}
