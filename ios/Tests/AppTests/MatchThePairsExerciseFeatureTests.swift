import ComposableArchitecture
import Domain
import Testing

@testable import App

@Suite("MatchThePairsExerciseFeatureTests")
@MainActor
struct MatchThePairsExerciseFeatureTests {
    @Test func testSelection() async throws {
        let store = TestStore(
            initialState: MatchThePairsExerciseFeature.State(data: .mock)
        ) {
            MatchThePairsExerciseFeature()
        }
        await store.send(.leftCells(.element(id: "pas", action: .tapped))) {
            $0[.left][id: "pas"]?.state = .selected
        }
        await store.send(.leftCells(.element(id: "kuća", action: .tapped))) {
            $0[.left][id: "pas"]?.state = .normal
            $0[.left][id: "kuća"]?.state = .selected
        }
    }

    @Test func testDeselection() async throws {
        let store = TestStore(
            initialState: MatchThePairsExerciseFeature.State(data: .mock)
        ) {
            MatchThePairsExerciseFeature()
        }
        store.exhaustivity = .off
        await store.send(.leftCells(.element(id: "pas", action: .tapped)))
        await store.send(.leftCells(.element(id: "pas", action: .tapped)))
        store.assert { state in
            state[.left][id: "pas"]?.state = .normal
        }
    }

    @Test func testMatchSuccess() async throws {
        let testClock = TestClock()
        let store = TestStore(
            initialState: MatchThePairsExerciseFeature.State(data: .mock)
        ) {
            MatchThePairsExerciseFeature()
        } withDependencies: {
            $0.continuousClock = testClock
        }
        await store.withExhaustivity(.off) {
            await store.send(.leftCells(.element(id: "pas", action: .tapped)))
            await store.send(.rightCells(.element(id: "dog", action: .tapped)))
            store.assert {
                $0[.left][id: "pas"]?.state = .matched
                $0[.right][id: "dog"]?.state = .matched
            }
            await testClock.advance(by: .seconds(0.9))
            store.assert {
                $0[.left][id: "pas"]?.state = .matched
                $0[.right][id: "dog"]?.state = .matched
            }
        }
        await testClock.advance(by: .seconds(0.1))
        await store.receive(.completeMatch) {
            $0[.left][id: "pas"]?.state = .disabled
            $0[.right][id: "dog"]?.state = .disabled
        }
    }

    @Test func testMatchFailure() async throws {
        let testClock = TestClock()
        let store = TestStore(
            initialState: MatchThePairsExerciseFeature.State(data: .mock)
        ) {
            MatchThePairsExerciseFeature()
        } withDependencies: {
            $0.continuousClock = testClock
        }
        await store.withExhaustivity(.off) {
            await store.send(.leftCells(.element(id: "pas", action: .tapped)))
            await store.send(.rightCells(.element(id: "cat", action: .tapped)))
            store.assert {
                $0[.left][id: "pas"]?.state = .error
                $0[.right][id: "cat"]?.state = .error
            }
            await testClock.advance(by: .seconds(0.9))
            store.assert {
                $0[.left][id: "pas"]?.state = .error
                $0[.right][id: "cat"]?.state = .error
            }
        }
        await testClock.advance(by: .seconds(0.1))
        await store.receive(.completeMatchError) {
            $0[.left][id: "pas"]?.state = .normal
            $0[.right][id: "cat"]?.state = .normal
        }
    }
}

extension MatchThePairsData {
    fileprivate static let mock = Self(
        prompt: "Match these Serbian words to their English translations:",
        pairs: [
            "mačka": "cat",
            "pas": "dog",
            "kuća": "house",
        ]
    )
}
