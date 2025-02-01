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
    var pickerValues: [String] {
      data.options
    }
  }

  enum Action: Equatable {
    enum Delegate: Equatable {
      case complete(Bool)
    }
    case valuePicked(String)
    case delegate(Delegate)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
      case let .valuePicked(value):
        return .send(.delegate(.complete(state.data.correctAnswer == value)))
      }
    }
  }
}

struct MultipleChoiceExerciseView: View {
  var store: StoreOf<MultipleChoiceExerciseFeature>
  var body: some View {
    List {
      Text(store.data.question)
      Section("Options") {
        ForEach(store.pickerValues, id: \.self) { value in
          Button {
            store.send(.valuePicked(value))
          } label: {
            Text(value)
          }
        }
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
