import Foundation

/// Represents a pair of items (e.g., "mačka" to "cat").
public struct Pair: Codable, Sendable, Equatable {
  public var itemA: String
  public var itemB: String

  public init(itemA: String, itemB: String) {
    self.itemA = itemA
    self.itemB = itemB
  }
}

/// For multiple-choice exercises.
public struct MultipleChoiceData: Codable, Sendable, Equatable {
  public var question: String
  public var options: [String]
  public var correctAnswer: String

  public init(question: String, options: [String], correctAnswer: String) {
    self.question = question
    self.options = options
    self.correctAnswer = correctAnswer
  }
}

/// For fill-in-the-blank exercises.
public struct FillInTheBlankData: Codable, Sendable, Equatable {
  public var sentence: String
  public var correctAnswer: String

  public init(sentence: String, correctAnswer: String) {
    self.sentence = sentence
    self.correctAnswer = correctAnswer
  }
}

/// For "match the pairs" exercises.
public struct MatchThePairsData: Codable, Sendable, Equatable {
  public var prompt: String?
  public var pairs: [String: String]

  public init(prompt: String? = nil, pairs: [String: String]) {
    self.prompt = prompt
    self.pairs = pairs
  }
}

/// For pronunciation exercises.
public struct PronunciationData: Codable, Sendable, Equatable {
  public var prompt: String
  public var correctAnswer: String

  public init(prompt: String, correctAnswer: String) {
    self.prompt = prompt
    self.correctAnswer = correctAnswer
  }
}

// MARK: - ExerciseData Enum

/// Represents the different types of exercises, each with its own data struct.
public enum ExerciseData: Codable, Sendable, Equatable {
  case multipleChoice(MultipleChoiceData)
  case fillInTheBlank(FillInTheBlankData)
  case matchThePairs(MatchThePairsData)
  case pronunciation(PronunciationData)

  // We store "type" in JSON to help us encode/decode the associated value properly.
  private enum CodingKeys: String, CodingKey {
    case type
    case multipleChoice
    case fillInTheBlank
    case matchThePairs
    case pronunciation
  }

  private enum ExerciseType: String, Codable {
    case multipleChoice
    case fillInTheBlank
    case matchThePairs
    case pronunciation
  }

  // MARK: Decodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(ExerciseType.self, forKey: .type)

    switch type {
    case .multipleChoice:
      let data = try container.decode(MultipleChoiceData.self, forKey: .multipleChoice)
      self = .multipleChoice(data)
    case .fillInTheBlank:
      let data = try container.decode(FillInTheBlankData.self, forKey: .fillInTheBlank)
      self = .fillInTheBlank(data)
    case .matchThePairs:
      let data = try container.decode(MatchThePairsData.self, forKey: .matchThePairs)
      self = .matchThePairs(data)
    case .pronunciation:
      let data = try container.decode(PronunciationData.self, forKey: .pronunciation)
      self = .pronunciation(data)
    }
  }

  // MARK: Encodable
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .multipleChoice(let data):
      try container.encode(ExerciseType.multipleChoice, forKey: .type)
      try container.encode(data, forKey: .multipleChoice)
    case .fillInTheBlank(let data):
      try container.encode(ExerciseType.fillInTheBlank, forKey: .type)
      try container.encode(data, forKey: .fillInTheBlank)
    case .matchThePairs(let data):
      try container.encode(ExerciseType.matchThePairs, forKey: .type)
      try container.encode(data, forKey: .matchThePairs)
    case .pronunciation(let data):
      try container.encode(ExerciseType.pronunciation, forKey: .type)
      try container.encode(data, forKey: .pronunciation)
    }
  }
}

// MARK: - Exercise

/// Top-level model representing an exercise, holding an `id` and one type of `ExerciseData`.
public struct Exercise: Codable, Sendable, Equatable {
  public var id: String
  public var data: ExerciseData

  public init(id: String, data: ExerciseData) {
    self.id = id
    self.data = data
  }
}
