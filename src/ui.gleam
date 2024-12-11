import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{Some}
import lustre/attribute
import lustre/element/html
import lustre/event
import model.{type Msg}

pub type OnClickCallback =
  fn(model.Question, String) -> Msg

pub type StyleList =
  List(#(String, String))

fn style_nav_bar() -> StyleList {
  [
    #("background-color", "#333"),
    #("color", "#FFD700"),
    #("padding", "1rem"),
    #("font-family", "Courier, monospace"),
    #("font-size", "1.2rem"),
    #("text-align", "center"),
    #("border-bottom", "3px solid #FFD700"),
    #("text-transform", "uppercase"),
  ]
}

fn style_game_screen_container() -> StyleList {
  [
    #("margin", "2rem auto"),
    #("max-width", "800px"),
    #("font-family", "Courier, monospace"),
    #("background-color", "#FAFAFA"),
    #("border", "4px solid #333"),
    #("padding", "1.5rem"),
    #("box-shadow", "8px 8px 0 #FFD700"),
  ]
}

fn style_question_title() -> StyleList {
  [
    #("color", "#E63946"),
    #("font-size", "2rem"),
    #("margin-bottom", "1rem"),
    #("text-align", "center"),
    #("text-transform", "uppercase"),
  ]
}

fn style_choice_button() -> StyleList {
  [
    #("background-color", "#457B9D"),
    #("color", "#fff"),
    #("padding", "1rem"),
    #("border", "none"),
    #("border-radius", "0"),
    #("cursor", "pointer"),
    #("font-size", "1rem"),
    #("text-align", "center"),
    #("text-transform", "uppercase"),
    #("transition", "all 0.2s"),
    #("box-shadow", "4px 4px 0 #333"),
  ]
}

fn style_solution_container() -> StyleList {
  [
    #("margin-top", "1rem"),
    #("padding", "1rem"),
    #("background-color", "#F1FAEE"),
    #("border-left", "6px solid #E63946"),
    #("font-size", "1rem"),
    #("font-family", "Courier, monospace"),
  ]
}

fn style_next_button() -> StyleList {
  [
    #("margin-top", "1.5rem"),
    #("background-color", "#A8DADC"),
    #("color", "#1D3557"),
    #("padding", "0.8rem 1.2rem"),
    #("border", "2px solid #457B9D"),
    #("cursor", "pointer"),
    #("font-size", "1rem"),
    #("font-family", "Courier, monospace"),
    #("box-shadow", "4px 4px 0 #333"),
  ]
}

fn style_separation() -> StyleList {
  [
    #("margin-top", "1rem"),
    #("border-top", "2px dashed #333"),
    #("padding-top", "0.5rem"),
  ]
}

pub fn nav_bar(model: model.Model) {
  html.nav([attribute.style(style_nav_bar())], [
    html.text(
      "Score : "
      <> int.to_string(model.state.score)
      <> "/"
      <> int.to_string(list.length(model.state.history)),
    ),
  ])
}

pub fn game_screen(model: model.Model, on_click: OnClickCallback) {
  use <- bool.guard(
    model.current_question |> option.is_none,
    html.text("Unable to load the current question. Please try again..."),
  )

  let assert Some(current_question): option.Option(model.Question) =
    model.current_question

  html.div([attribute.style(style_game_screen_container())], [
    html.h1([attribute.style(style_question_title())], [
      html.text("Quel est le sens du mot `" <> current_question.word <> "`"),
    ]),
    html.div(
      [
        attribute.style([
          #("display", "flex"),
          #("flex-direction", "column"),
          #("gap", "1rem"),
        ]),
      ],
      current_question.choices
        |> list.map(fn(choice: String) {
          html.button(
            [
              attribute.style(style_choice_button()),
              case model.step {
                model.UserCanSeeSolution -> attribute.none()
                _ -> event.on_click(on_click(current_question, choice))
              },
            ],
            [html.text(choice)],
          )
        }),
    ),
    html.div([attribute.style(style_separation())], [solution(model)]),
  ])
}

fn solution(m: model.Model) {
  let assert Some(current_question): option.Option(model.Question) =
    m.current_question
  case m.step {
    model.UserCanSeeSolution ->
      html.div([], [
        html.div([attribute.style(style_solution_container())], [
          html.text(current_question.solution),
        ]),
        html.div([attribute.style(style_separation())], [
          html.button(
            [
              attribute.style(style_next_button()),
              event.on_click(model.UserClickedNext),
            ],
            [html.text("Suivant")],
          ),
        ]),
      ])
    _ -> html.div([], [])
  }
}
