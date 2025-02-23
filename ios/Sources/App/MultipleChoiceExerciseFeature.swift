// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import Domain
import SwiftUI

@Reducer
struct MultipleChoiceExerciseFeature {
  @ObservableState
  struct State: Equatable {
    var data: MultipleChoiceData
    var options: IdentifiedArrayOf<WordCellFeature.State>

    init(data: MultipleChoiceData) {
      self.data = data
      self.options = IdentifiedArrayOf<WordCellFeature.State>(
        uniqueElements: data.options.map {
          WordCellFeature.State(word: $0, state: .normal)
        }
      )
    }
  }

  enum Action: Equatable {
    enum Delegate: Equatable {
      case complete
    }
    case options(IdentifiedActionOf<WordCellFeature>)
    case completeMatch(id: String)
    case completeError(id: String)
    case delegate(Delegate)
  }

  @Dependency(\.continuousClock) var clock

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
      case let .completeMatch(id):
        withAnimation {
          state.options[id: id]?.state = .disabled
        }
        return .send(.delegate(.complete))
      case let .completeError(id):
        withAnimation {
          state.options[id: id]?.state = .normal
        }
        return .none
      case let .options(.element(id, action: .tapped)):
        let match = state.data.correctAnswer == state.options[id: id]?.word
        withAnimation {
          state.options[id: id]?.state = match ? .matched : .error
        }
        return .run { send in
          try await clock.sleep(for: wordCellTransitionDuration)
          await send(match ? .completeMatch(id: id) : .completeError(id: id))
        }
      }
    }.forEach(\.options, action: \.options) {
      WordCellFeature()
    }
  }
}

struct MultipleChoiceExerciseView: View {
  var store: StoreOf<MultipleChoiceExerciseFeature>
  var body: some View {
    VStack {
      Text(store.data.question)
        .font(.headline)
        .padding()
      ForEach(store.scope(state: \.options, action: \.options)) { cellStore in
        WordButton(store: cellStore).padding()
      }
    }
  }
}

#Preview {
  MultipleChoiceExerciseView(
    store: Store(
      initialState: MultipleChoiceExerciseFeature.State(
        data: MultipleChoiceData(
          question: "What does 'pas' mean in English?",
          options: ["dog", "cat", "bird"],
          correctAnswer: "dog"
        )
      )
    ) {
      MultipleChoiceExerciseFeature()._printChanges()
    }
  )
}
