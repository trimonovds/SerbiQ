//
//  LessonFeature.swift
//  serbiq-ios
//
//  Created by Dmitry Trimonov on 10.02.2025.
//

import ComposableArchitecture
import Domain
import SwiftUI

@Reducer(state: .equatable, action: .equatable)
enum ExerciseDataFeature {
  case matchThePairs(MatchThePairsExerciseFeature)
  case multipleChoice(MultipleChoiceExerciseFeature)
}

struct ExerciseDataView: View {
  var store: StoreOf<ExerciseDataFeature>
  var body: some View {
    switch store.state {
    case .matchThePairs:
      if let matchThePairsStore = store.scope(state: \.matchThePairs, action: \.matchThePairs) {
        MatchThePairsExerciseView(store: matchThePairsStore)
      }
    case .multipleChoice:
      if let multipleChoiceStore = store.scope(state: \.multipleChoice, action: \.multipleChoice) {
        MultipleChoiceExerciseView(store: multipleChoiceStore)
      }
    }
  }
}

@Reducer
struct ExerciseFeature {
  @ObservableState
  struct State: Equatable, Identifiable {
    var id: String
    var data: ExerciseDataFeature.State

    init(exercise: Exercise) {
      self.id = exercise.id
      self.data =
        switch exercise.data {
        case .matchThePairs(let matchThePairsData):
          .matchThePairs(MatchThePairsExerciseFeature.State(data: matchThePairsData))
        case .multipleChoice(let multipleChoiceData):
          .multipleChoice(MultipleChoiceExerciseFeature.State(data: multipleChoiceData))
        default:
          fatalError()
        }
    }
  }

  enum Action: Equatable {
    case data(ExerciseDataFeature.Action)
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.data, action: \.data) {
      ExerciseDataFeature.body
    }
  }
}

struct ExerciseView: View {
  var store: StoreOf<ExerciseFeature>
  var body: some View {
    ExerciseDataView(store: store.scope(state: \.data, action: \.data))
  }
}

@Reducer
struct LessonFeature {
  @Reducer(state: .equatable, action: .equatable)
  enum Screen {
    case lessonStart(LessonStartFeature)
    case exercise(ExerciseFeature)
    case lessonCompleted(LessonCompletedFeature)
  }

  @ObservableState
  struct State {
    var exercises: [ExerciseFeature.State]
    var currentExerciseIndex: Int
    var screen: Screen.State

    init(exercises: [Exercise]) {
      let exes = exercises.map { ExerciseFeature.State(exercise: $0) }
      let currIndex = 0
      self.exercises = exes
      self.currentExerciseIndex = currIndex
      self.screen = .lessonStart(LessonStartFeature.State())
    }
  }

  enum Action: Equatable {
    enum Delegate: Equatable {
      case close
    }
    case delegate(Delegate)
    case currentExerciseComplete
    case completeLesson
    case screen(Screen.Action)
  }

  @Dependency(\.continuousClock) var clock

  var body: some ReducerOf<Self> {
    Scope(state: \.screen, action: \.screen) {
      Screen.body
    }
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
      case .completeLesson:
        withAnimation {
          state.screen = .lessonCompleted(LessonCompletedFeature.State())
        }
        return .none
      case .currentExerciseComplete:
        if state.currentExerciseIndex == state.exercises.count - 1 {
          state.currentExerciseIndex += 1
          return .run { send in
            try await clock.sleep(for: .seconds(1))
            await send(.completeLesson)
          }
        } else {
          state.currentExerciseIndex += 1
          withAnimation {
            state.screen = .exercise(state.exercises[state.currentExerciseIndex])
          }
          return .none
        }
      case .screen(.exercise(.data(.matchThePairs(.delegate(.complete))))),
        .screen(.exercise(.data(.multipleChoice(.delegate(.complete))))):
        return .send(.currentExerciseComplete)
      case .screen(.lessonStart(.startButtonTapped)):
        withAnimation {
          state.screen = .exercise(state.exercises[state.currentExerciseIndex])
        }
        return .none
      case .screen(.lessonCompleted(.continueButtonTapped)):
        return .send(.delegate(.close))
      case .screen:
        return .none
      }
    }
  }
}

struct ProgressBarView: View {
  let progress: CGFloat  // Значение от 0 до 1

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        // Фон прогресс-бара
        RoundedRectangle(cornerRadius: 8)
          .frame(height: 8)
          .foregroundColor(Color.gray.opacity(0.3))

        // Заполненная часть прогресс-бара
        RoundedRectangle(cornerRadius: 8)
          .frame(width: geometry.size.width * progress, height: 8)
          .foregroundColor(.blue)
          .animation(.easeInOut(duration: 0.3), value: progress)
      }
    }
    .frame(height: 8)
  }
}

@Reducer
struct LessonStartFeature {
  enum Action: Equatable {
    case startButtonTapped
  }
}

struct LessonStartView: View {
  var store: StoreOf<LessonStartFeature>

  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "book.fill")
        .resizable()
        .frame(width: 100, height: 100)
        .foregroundColor(.blue)
        .animation(.spring(), value: UUID())  // Добавляет лёгкую анимацию

      Text("Начало урока")
        .font(.largeTitle)
        .fontWeight(.bold)

      Text("Вы готовы? Пройдите упражнения и улучшите свой уровень! 🚀")
        .font(.headline)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 20)

      Button {
        store.send(.startButtonTapped)
      } label: {
        Text("Начать")
          .font(.title2)
          .padding()
          .frame(maxWidth: .infinity)
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(12)
      }
      .padding(.horizontal, 40)
    }
    .padding()
  }
}

@Reducer
struct LessonCompletedFeature {
  enum Action: Equatable {
    case continueButtonTapped
  }
}

struct LessonCompletedView: View {
  var store: StoreOf<LessonCompletedFeature>

  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "checkmark.circle.fill")
        .resizable()
        .frame(width: 100, height: 100)
        .foregroundColor(.green)
        .animation(.spring(), value: UUID())  // Добавляет лёгкую анимацию

      Text("Поздравляем!")
        .font(.largeTitle)
        .fontWeight(.bold)

      Text("Вы успешно завершили урок. Отличная работа! 🎉")
        .font(.headline)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 20)

      Button {
        store.send(.continueButtonTapped)
      } label: {
        Text("Продолжить")
          .font(.title2)
          .padding()
          .frame(maxWidth: .infinity)
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(12)
      }
      .padding(.horizontal, 40)
    }
    .padding()
  }
}

struct LessonView: View {
  var store: StoreOf<LessonFeature>
  var body: some View {
    switch store.screen {
    case .lessonStart:
      if let lessonStartStore = store.scope(
        state: \.screen.lessonStart,
        action: \.screen.lessonStart
      ) {
        LessonStartView(store: lessonStartStore)
      }
    case .exercise:
      VStack {
        ProgressBarView(
          progress: CGFloat(store.currentExerciseIndex) / CGFloat(store.exercises.count)
        )
        .padding()
        if let exerciseStore = store.scope(state: \.screen.exercise, action: \.screen.exercise) {
          ExerciseView(store: exerciseStore)
        }
        Spacer()
      }
    case .lessonCompleted:
      if let lessonCompletedStore = store.scope(
        state: \.screen.lessonCompleted,
        action: \.screen.lessonCompleted
      ) {
        LessonCompletedView(store: lessonCompletedStore)
      }
    }
  }
}

#Preview {
  LessonView(
    store: Store(
      initialState: LessonFeature.State(exercises: [
        Exercise(
          id: "ex1",
          data: .multipleChoice(
            MultipleChoiceData(
              question: "What does 'pas' mean in English?",
              options: ["dog", "cat", "bird"],
              correctAnswer: "dog"
            )
          )
        ),
        Exercise(
          id: "ex2",
          data: .matchThePairs(
            MatchThePairsData(
              prompt: "Match these Serbian words to their English translations:",
              pairs: [
                "mačka": "cat",
                "pas": "dog",
                "kuća": "house",
              ]
            )
          )
        ),
      ])
    ) {
      LessonFeature()._printChanges()
    }
  )
}
