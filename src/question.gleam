import gleam/dynamic
import model

pub fn question_decoder(
  dynamic: dynamic.Dynamic,
) -> Result(model.QuestionSet, List(dynamic.DecodeError)) {
  dynamic.decode1(
    model.QuestionSet,
    dynamic.field(
      "questions",
      dynamic.list(dynamic.decode4(
        model.Question,
        dynamic.field("word", dynamic.string),
        dynamic.field("choices", dynamic.list(of: dynamic.string)),
        dynamic.field("answer", dynamic.string),
        dynamic.field("solution", dynamic.string),
      )),
    ),
  )(dynamic)
}
