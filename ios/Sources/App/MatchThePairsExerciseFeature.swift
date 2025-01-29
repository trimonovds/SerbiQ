// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import Domain
import SwiftUI

@Reducer
struct WordCellFeature {
  @ObservableState
  struct State: Equatable, Identifiable {
    var word: String
    var state: WordCellState

    var id: String { word }
  }

  enum Action: Equatable {
    case tapped
  }
}

@Reducer
struct MatchThePairsExerciseFeature {
  enum Column: Equatable {
    case left
    case right

    var opposite: Column {
      switch self {
      case .left: .right
      case .right: .left
      }
    }
  }

  @ObservableState
  struct State: Equatable {
    var leftCells: IdentifiedArrayOf<WordCellFeature.State>
    var rightCells: IdentifiedArrayOf<WordCellFeature.State>
    var data: MatchThePairsData

    static func cellsKeyPath(
      column: Column
    ) -> WritableKeyPath<Self, IdentifiedArrayOf<WordCellFeature.State>> {
      switch column {
      case .left: \.leftCells
      case .right: \.rightCells
      }
    }

    subscript(column: Column) -> IdentifiedArrayOf<WordCellFeature.State> {
      get {
        return self[keyPath: Self.cellsKeyPath(column: column)]
      }
      set {
        self[keyPath: Self.cellsKeyPath(column: column)] = newValue
      }
    }

    subscript(id: String, column: Column) -> WordCellFeature.State? {
      get {
        return self[column][id: id]
      }
      set {
        self[column][id: id] = newValue
      }
    }

    init(data: MatchThePairsData) {
      self.data = data
      leftCells = IdentifiedArrayOf<WordCellFeature.State>(
        uniqueElements: data.pairs.map {
          WordCellFeature.State(word: $0.key, state: .normal)
        }
      )
      rightCells = IdentifiedArrayOf<WordCellFeature.State>(
        uniqueElements: data.pairs.shuffled().map {
          WordCellFeature.State(word: $0.value, state: .normal)
        }
      )
    }
  }

  enum Action: Equatable {
    enum Delegate: Equatable {
      case complete
    }

    case delegate(Delegate)
    case leftCells(IdentifiedActionOf<WordCellFeature>)
    case rightCells(IdentifiedActionOf<WordCellFeature>)
    case completeMatchError
    case completeMatch
  }

  @Dependency(\.continuousClock) var clock

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
      case .completeMatch:
        return switchCells(into: &state, that: .matched, to: .disabled)
      case .completeMatchError:
        return switchCells(into: &state, that: .error, to: .normal)
      case let .leftCells(.element(id, action: .tapped)):
        return onCellTapped(into: &state, column: .left, id: id)
      case let .rightCells(.element(id, action: .tapped)):
        return onCellTapped(into: &state, column: .right, id: id)
      }
    }
    .forEach(\.leftCells, action: \.leftCells) {
      WordCellFeature()
    }
    .forEach(\.rightCells, action: \.rightCells) {
      WordCellFeature()
    }
  }

  private func switchCells(
    into state: inout State,
    that cellState: WordCellState,
    to newCellState: WordCellState
  ) -> Effect<Action> {
    guard let leftCell = state[.left].first(that: cellState),
          let rightCell = state[.right].first(that: cellState)
    else {
      return .none
    }
    state[leftCell.id, .left]?.state = newCellState
    state[rightCell.id, .right]?.state = newCellState
    return .none
  }

  private func onCellTapped(
    into state: inout State,
    column: Column,
    id: String
  ) -> Effect<Action> {
    guard let cell = state[id, column] else {
      assertionFailure("Unknown word \(id) tapped in column \(column)")
      return .none
    }
    let otherColumn = column.opposite
    if state[column].selectedCell == nil && state[otherColumn].selectedCell == nil { // select if no selected word
      state[id, column]?.state = .selected
    } else if cell.state == .selected { // deselect if selected
      state[id, column]?.state = .normal
    } else if let tappedColumnSelectedCell = state[column].selectedCell { // change tapped column cells selection if already has selected cell
      state[tappedColumnSelectedCell.id, column]?.state = .normal
      state[id, column]?.state = .selected
    } else if let otherColumnSelectedCell = state[otherColumn].selectedCell {
      let leftColumnCell = switch column {
      case .left: cell
      case .right: otherColumnSelectedCell
      }
      let rightColumnCell = switch column {
      case .left: otherColumnSelectedCell
      case .right: cell
      }
      let match = state.data.pairs[leftColumnCell.word] == rightColumnCell.word
      if match { // change to matched if other column cells has selected and it is a match
        state[id, column]?.state = .matched
        state[otherColumnSelectedCell.id, otherColumn]?.state = .matched
        return .run { send in
          try await clock.sleep(for: transitionDuration)
          await send(.completeMatch)
        }
      } else { // change to error if other column cells has selected and it is not a match
        state[id, column]?.state = .error
        state[otherColumnSelectedCell.id, otherColumn]?.state = .error
        return .run { send in
          try await clock.sleep(for: transitionDuration)
          await send(.completeMatchError)
        }
      }
    } else {
      assertionFailure()
    }
    return .none
  }
}

extension IdentifiedArrayOf<WordCellFeature.State> {
  func first(that state: WordCellState) -> WordCellFeature.State? {
    first(where: { $0.state == state })
  }

  var selectedCell: WordCellFeature.State? {
    first(that: .selected)
  }
}

private let transitionDuration: Duration = .seconds(1.0)

struct MatchThePairsExerciseView: View {
  var store: StoreOf<MatchThePairsExerciseFeature>
  var body: some View {
    VStack(spacing: 16) {
      if let prompt = store.data.prompt {
        Text(prompt)
          .font(.headline)
          .padding()
      }
      HStack {
        VStack {
          ForEach(store.scope(state: \.leftCells, action: \.leftCells)) { cellStore in
            WordButton(store: cellStore)
          }
        }
        Spacer(minLength: 24)
        VStack {
          ForEach(store.scope(state: \.rightCells, action: \.rightCells)) { cellStore in
            WordButton(store: cellStore)
          }
        }
      }
      .padding(.horizontal)
      Spacer()
    }
  }
}

/// Состояние отображения отдельного слова
enum WordCellState: Equatable {
  case normal
  case selected
  case matched
  case disabled
  case error
}

/// Кнопка-серый прямоугольник. В зависимости от состояния меняет цвет фона.
struct WordButton: View {
  var store: StoreOf<WordCellFeature>

  var body: some View {
    Button {
      store.send(.tapped)
    } label: {
      Text(store.state.word)
        .foregroundColor(stateColor)
        .frame(maxWidth: .infinity, minHeight: 44)
        .padding(.vertical, 8)
        .background(stateColor.opacity(0.3))
        .cornerRadius(12)
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(stateColor, lineWidth: 2)
        )
    }
    .disabled(store.state.state != .selected && store.state.state != .normal)
  }

  private var stateColor: Color {
    switch store.state.state {
    case .normal:
      return Color.black
    case .selected:
      return Color.blue
    case .matched:
      return Color.green
    case .disabled:
      return Color.gray.opacity(0.5)
    case .error:
      return Color.red
    }
  }
}

#Preview {
  MatchThePairsExerciseView(
    store: Store(
      initialState: MatchThePairsExerciseFeature.State(
        data: MatchThePairsData(
          prompt: "Match these Serbian words to their English translations:",
          pairs: [
            "mačka": "cat",
            "pas": "dog",
            "kuća": "house",
          ]
        )
      )
    ) {
      MatchThePairsExerciseFeature()._printChanges()
    }
  )
}
