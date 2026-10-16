
import Foundation
import HealthKit
import Alamofire

final class HealthKitService {
    static let shared = HealthKitService()

    private let healthStore = HKHealthStore()

    private init() {}

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw NSError(
                domain: "MedAI",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "HealthKit is unavailable on this device."
                ]
            )
        }

        let identifiers: [HKQuantityTypeIdentifier] = [
            .heartRate,
            .oxygenSaturation,
            .stepCount
        ]

        let types = Set(
            identifiers.compactMap {
                HKObjectType.quantityType(forIdentifier: $0)
            }
        )

        try await healthStore.requestAuthorization(
            toShare: [],
            read: types
        )
    }

    private func latestValue(
        for identifier: HKQuantityTypeIdentifier,
        unit: HKUnit
    ) async throws -> (value: Double, date: Date)? {
        guard let type = HKQuantityType.quantityType(
            forIdentifier: identifier
        ) else {
            return nil
        }

        return try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<(value: Double, date: Date)?, Error>) in

            let sort = NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )

            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: (
                    sample.quantity.doubleValue(for: unit),
                    sample.startDate
                ))
            }

            healthStore.execute(query)
        }
    }

    func latestHeartRate() async throws -> (value: Double, date: Date)? {
        try await latestValue(
            for: .heartRate,
            unit: HKUnit.count().unitDivided(by: .minute())
        )
    }

    func latestSpO2() async throws -> (value: Double, date: Date)? {
        guard let sample = try await latestValue(
            for: .oxygenSaturation,
            unit: .percent()
        ) else {
            return nil
        }

        // HealthKit stores oxygen saturation as 0.0–1.0.
        return (sample.value * 100, sample.date)
    }

    func stepsToday() async throws -> Double {
        guard let type = HKQuantityType.quantityType(
            forIdentifier: .stepCount
        ) else {
            return 0
        }

        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: Date(),
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Double, Error>) in

            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let total = statistics?.sumQuantity()?.doubleValue(
                    for: .count()
                ) ?? 0

                continuation.resume(returning: total)
            }

            healthStore.execute(query)
        }
    }
    func syncToMedAI() async throws {
        try await requestAuthorization()

        let formatter = ISO8601DateFormatter()

        // 1. Upload the latest heart-rate measurement
        if let heartRate = try await latestHeartRate() {
            let parameters: [String: Any] = [
                "metric_type": "heart_rate",
                "value": heartRate.value,
                "unit": "bpm",
                "recorded_at": formatter.string(from: heartRate.date),
                "source": "HealthKit"
            ]

            let _: HealthMetric = try await APIService.shared.request(
                "/api/health/metrics",
                method: .post,
                parameters: parameters,
                authenticated: true
            )
        }

        // 2. Upload the latest SpO2 measurement
        if let spo2 = try await latestSpO2() {
            let parameters: [String: Any] = [
                "metric_type": "spo2",
                "value": spo2.value,
                "unit": "%",
                "recorded_at": formatter.string(from: spo2.date),
                "source": "HealthKit"
            ]

            let _: HealthMetric = try await APIService.shared.request(
                "/api/health/metrics",
                method: .post,
                parameters: parameters,
                authenticated: true
            )
        }

        // 3. Upload today's cumulative step count
        let steps = try await stepsToday()

        let parameters: [String: Any] = [
            "metric_type": "steps",
            "value": steps,
            "unit": "steps",
            "recorded_at": formatter.string(from: Date()),
            "source": "HealthKit"
        ]

        let _: HealthMetric = try await APIService.shared.request(
            "/api/health/metrics",
            method: .post,
            parameters: parameters,
            authenticated: true
        )
    }
}
