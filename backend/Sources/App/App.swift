import Domain
import IdentifiedCollections
import Vapor

// MARK: - Routes

/// Registers application routes.
func routes(_ app: Application) throws {
  // Example in-memory store of exercises keyed by ID.
  let exercises: IdentifiedArrayOf<Exercise> = [
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
  ]

  /// GET /exercise/:id
  /// Returns a JSON representation of the exercise with the given ID.
  app.get("exercise", ":id") { req -> Exercise in
    guard let exerciseID = req.parameters.get("id"),
      let exercise = exercises[id: exerciseID]
    else {
      throw Abort(.notFound, reason: "Exercise not found.")
    }
    return exercise
  }
}

// MARK: - Entry Point

@main
struct Main {
  static func main() async throws {
    var env = try Environment.detect()
    try LoggingSystem.bootstrap(from: &env)
    let app = try await Application.make(env)
    // defer { app.shutdown() }

    // Register routes
    try routes(app)

    // Run Vapor app
    try await app.execute()
  }
}

extension Exercise: @retroactive Content {}
extension Exercise: @retroactive Identifiable {}
