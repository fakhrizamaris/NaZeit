//
//  CircadianTests.swift
//  NazeitAppTests
//
//  Unit tests validating all formulas from RumusSchedule.md.
//

import XCTest
@testable import NazeitApp

final class CircadianTests: XCTestCase {

    // MARK: - Helpers

    private func makeTime(hour: Int, minute: Int = 0) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }

    private func offset(hours: Int) -> Int { hours * 3600 }

    // MARK: - CBTmin (§1.A)

    func testCBTmin_manual_isWakeTimeMinus2Point5h() {
        let wake = makeTime(hour: 7)
        let result = Circadian.cbtMin(wakeTime: wake, method: .manual)

        let cal = Calendar.current
        XCTAssertEqual(cal.component(.hour, from: result), 4)
        XCTAssertEqual(cal.component(.minute, from: result), 30)
    }

    func testCBTmin_watch_usesNadirWhenAvailable() {
        let nadir = makeTime(hour: 3, minute: 15)
        let result = Circadian.cbtMin(wakeTime: makeTime(hour: 7), method: .watch, temperatureNadir: nadir)

        let cal = Calendar.current
        XCTAssertEqual(cal.component(.hour, from: result), 3)
        XCTAssertEqual(cal.component(.minute, from: result), 15)
    }

    func testCBTmin_watch_fallsBackToFormula() {
        let result = Circadian.cbtMin(wakeTime: makeTime(hour: 7), method: .watch)
        XCTAssertEqual(Calendar.current.component(.hour, from: result), 4)
    }

    // MARK: - Timezone Gap & 12-Hour Rule

    func testTimezoneGap_jakartaToTokyo() {
        XCTAssertEqual(Circadian.timezoneGap(fromOffset: offset(hours: 7), toOffset: offset(hours: 9)), 2)
    }

    func testEffectiveGap_smallEastward() {
        let (gap, dir) = Circadian.effectiveGap(fromOffset: offset(hours: 7), toOffset: offset(hours: 9))
        XCTAssertEqual(gap, 2.0)
        XCTAssertEqual(dir, .eastward)
    }

    func testEffectiveGap_smallWestward() {
        let (gap, dir) = Circadian.effectiveGap(fromOffset: offset(hours: 9), toOffset: offset(hours: 7))
        XCTAssertEqual(gap, 2.0)
        XCTAssertEqual(dir, .westward)
    }

    func testEffectiveGap_12hRuleFlips() {
        let (gap, dir) = Circadian.effectiveGap(fromOffset: offset(hours: 7), toOffset: offset(hours: -8))
        XCTAssertEqual(gap, 9.0)
        XCTAssertEqual(dir, .eastward)
    }

    func testEffectiveGap_exactly12h() {
        let (gap, dir) = Circadian.effectiveGap(fromOffset: offset(hours: 0), toOffset: offset(hours: 12))
        XCTAssertEqual(gap, 12.0)
        XCTAssertEqual(dir, .eastward)
    }

    // MARK: - Daily Shift (§2.B)

    func testDailyShift_normal_capped() {
        XCTAssertEqual(Circadian.dailyShift(gap: 6.0, days: 3, profile: .normal), 1.0)
    }

    func testDailyShift_gentle_capped() {
        XCTAssertEqual(Circadian.dailyShift(gap: 6.0, days: 3, profile: .gentle), 0.5)
    }

    func testDailyShift_smallGap_noCap() {
        XCTAssertEqual(Circadian.dailyShift(gap: 1.5, days: 3, profile: .normal), 0.5)
    }

    func testDailyShift_zeroDays() {
        XCTAssertEqual(Circadian.dailyShift(gap: 6.0, days: 0, profile: .normal), 0)
    }

    // MARK: - Total Loading Shift

    func testTotalLoading_normal_3days() {
        XCTAssertEqual(Circadian.totalLoadingShift(gap: 6.0, days: 3, profile: .normal), 3.0)
    }

    func testTotalLoading_gentle_3days() {
        XCTAssertEqual(Circadian.totalLoadingShift(gap: 6.0, days: 3, profile: .gentle), 1.5)
    }

    func testTotalLoading_cappedAtGap() {
        XCTAssertEqual(Circadian.totalLoadingShift(gap: 2.0, days: 3, profile: .normal), 2.0)
    }

    // MARK: - Remaining Gap

    func testRemainingGap() {
        XCTAssertEqual(Circadian.remainingGap(totalGap: 6.0, days: 3, profile: .normal), 3.0)
    }

    // MARK: - Recovery Days (§4)

    func testRecoveryDays_eastward() {
        XCTAssertEqual(Circadian.recoveryDays(remaining: 3.0, direction: .eastward), 4) // ceil(3/0.95)
    }

    func testRecoveryDays_westward() {
        XCTAssertEqual(Circadian.recoveryDays(remaining: 3.0, direction: .westward), 2) // ceil(3/1.53)
    }

    func testRecoveryDays_zero() {
        XCTAssertEqual(Circadian.recoveryDays(remaining: 0, direction: .eastward), 0)
    }

    // MARK: - Light Windows (§5.A/B)

    func testLightWindows_eastward() {
        let cbt = makeTime(hour: 4, minute: 30)
        let w = Circadian.lightWindows(cbtMin: cbt, direction: .eastward, profile: .normal)
        let cal = Calendar.current
        XCTAssertEqual(cal.component(.hour, from: w.seekStart), 4)
        XCTAssertEqual(cal.component(.hour, from: w.seekEnd), 8)
    }

    func testLightWindows_insomnia_hasBuffer() {
        let cbt = makeTime(hour: 4, minute: 30)
        let normal = Circadian.lightWindows(cbtMin: cbt, direction: .eastward, profile: .normal)
        let insomnia = Circadian.lightWindows(cbtMin: cbt, direction: .eastward, profile: .insomnia)
        let diff = normal.seekStart.timeIntervalSince(insomnia.seekStart)
        XCTAssertEqual(diff, 30 * 60, accuracy: 1)
    }

    // MARK: - Caffeine Cutoff (§5.2/6.1)

    func testCaffeineCutoff_normal() {
        let bed = makeTime(hour: 22)
        let cut = Circadian.caffeineCutoff(bedtime: bed, profile: .normal)
        XCTAssertEqual(Calendar.current.component(.hour, from: cut), 14) // 22 - 8 = 14
    }

    func testCaffeineCutoff_insomnia() {
        let bed = makeTime(hour: 22)
        let cut = Circadian.caffeineCutoff(bedtime: bed, profile: .insomnia)
        XCTAssertEqual(Calendar.current.component(.hour, from: cut), 10) // 22 - 12 = 10
    }

    // MARK: - Adaptation Profile Parameters

    func testProfile_normal() {
        let p = AdaptationProfile.normal
        XCTAssertEqual(p.maxDailyShiftHours, 1.0)
        XCTAssertEqual(p.caffeineCutoffHours, 8.0)
        XCTAssertEqual(p.graceWindowMinutes, 60)
        XCTAssertEqual(p.lightBufferMinutes, 0)
    }

    func testProfile_gentle() {
        let p = AdaptationProfile.gentle
        XCTAssertEqual(p.maxDailyShiftHours, 0.5)
        XCTAssertEqual(p.caffeineCutoffHours, 12.0)
        XCTAssertEqual(p.graceWindowMinutes, 90)
    }

    func testProfile_insomnia() {
        let p = AdaptationProfile.insomnia
        XCTAssertEqual(p.maxDailyShiftHours, 0.5)
        XCTAssertEqual(p.lightBufferMinutes, 30)
    }

    // MARK: - State Label

    func testStateLabel() {
        XCTAssertEqual(Circadian.stateLabel(for: 0.1), "Misaligned")
        XCTAssertEqual(Circadian.stateLabel(for: 0.35), "Adjusting")
        XCTAssertEqual(Circadian.stateLabel(for: 0.65), "Aligned")
    }

    // MARK: - Prep Days

    func testPrepDays_cappedAt3() {
        let future = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        XCTAssertEqual(Circadian.prepDays(departure: future), 3)
    }

    func testPrepDays_sameDay() {
        XCTAssertEqual(Circadian.prepDays(departure: Date()), 0)
    }
}

extension ArrivalWindow: Equatable {
    public static func == (lhs: ArrivalWindow, rhs: ArrivalWindow) -> Bool {
        switch (lhs, rhs) {
        case (.daytime, .daytime), (.nighttime, .nighttime): return true
        default: return false
        }
    }
}
