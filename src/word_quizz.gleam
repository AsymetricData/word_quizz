import gleam/io
import gleam/list
import gleam/option.{Some}
import lustre
import lustre/effect
import lustre/element/html
import lustre_http
import model.{
  type Msg, ApplicationStarted, Model, SelectQuestion, UserClickedNext,
  UserSubmitResponse,
}
import question
import ui

pub fn main() {
  lustre.application(init, update, view)
  |> lustre.start("#app", Nil)
}

fn init(_flags) -> #(model.Model, effect.Effect(model.Msg)) {
  #(model.new_model(), init_app())
}

fn update(model: model.Model, msg: Msg) -> #(model.Model, effect.Effect(Msg)) {
  case msg {
    ApplicationStarted(Ok(question_set)) -> init_question(model, question_set)
    ApplicationStarted(Error(err)) -> {
      io.debug(err)
      #(model, effect.none())
    }
    UserSubmitResponse(question, answer) ->
      handle_submit_answer(question, answer, model)
    UserClickedNext -> handle_next_question(model)
    SelectQuestion -> todo
  }
}

fn view(model) {
  html.div([], [
    ui.nav_bar(model),
    ui.game_screen(model, fn(a, b) { UserSubmitResponse(a, b) }),
  ])
}

fn init_app() {
  lustre_http.get(
    "https://raw.githubusercontent.com/AsymetricData/word_quizz/refs/heads/main/priv/static/words.json",
    lustre_http.expect_json(question.question_decoder, ApplicationStarted),
  )
}

fn init_question(
  model: model.Model,
  questions: model.QuestionSet,
) -> #(model.Model, effect.Effect(Msg)) {
  let assert Ok(current_question) =
    questions.questions |> list.shuffle |> list.last
  let new_model =
    model.Model(
      step: model.UserShouldAnswer,
      state: model.QuizzState(0, []),
      current_question: Some(current_question),
      questions: questions.questions,
    )

  #(new_model, effect.none())
}

fn handle_submit_answer(
  question: model.Question,
  answer: String,
  m: model.Model,
) {
  let is_correct = question.answer == answer
  let score = case is_correct {
    False -> m.state.score
    True -> m.state.score + 1
  }

  let model =
    Model(
      step: model.UserCanSeeSolution,
      state: model.QuizzState(score, [question, ..m.state.history]),
      current_question: m.current_question,
      questions: m.questions,
    )

  #(model, effect.none())
}

fn handle_next_question(m: model.Model) {
  let assert Ok(next) =
    m.questions
    |> list.shuffle
    |> list.last

  let next = model.Question(..next, choices: next.choices |> list.shuffle)

  #(
    model.Model(..m, current_question: Some(next), step: model.UserShouldAnswer),
    effect.none(),
  )
}
