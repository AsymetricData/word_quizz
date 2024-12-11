import gleam/option.{type Option}
import lustre_http

pub type Msg {
  ApplicationStarted(Result(QuestionSet, lustre_http.HttpError))
  SelectQuestion
  UserSubmitResponse(question: Question, response: String)
  UserClickedNext
}

pub type Model {
  Model(
    step: QuizzStep,
    state: QuizzState,
    current_question: Option(Question),
    questions: List(Question),
  )
}

pub fn new_model() {
  Model(
    step: NoStep,
    state: QuizzState(0, []),
    current_question: option.None,
    questions: [],
  )
}

/// Reprensent the current step in the quizz
pub type QuizzStep {
  UserShouldAnswer
  UserCanSeeSolution
  NoStep
}

/// Store the state of the current instance of the app
pub type QuizzState {
  QuizzState(score: Int, history: List(Question))
}

/// Represent a single question
pub type Question {
  Question(
    word: String,
    choices: List(String),
    answer: String,
    solution: String,
  )
}

pub type QuestionSet {
  QuestionSet(questions: List(Question))
}
