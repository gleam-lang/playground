import htmb.{type Html, h, text}

fn output_tab(label: String, id: String, value: String, checked: Bool) -> Html {
  let checked = case checked {
    True -> "true"
    False -> "false"
  }
  h("label", [#("class", "tab")], [
    h("p", [], [text(label)]),
    h(
      "input",
      [
        #("type", "radio"),
        #("id", id),
        #("name", "output-display"),
        #("value", value),
        #("hidden", "true"),
        #("checked", checked),
      ],
      [],
    ),
  ])
}

pub fn home_page() -> Html {
  h("article", [#("id", "playground-container")], [
    h("section", [#("id", "playground")], [
      h("div", [#("id", "playground-header")], [
        h(
          "input",
          [
            #("id", "title-input"),
            #("type", "text"),
            #("name", "title"),
            #("value", "A Gleam Playground project"),
            #("placeholder", "Project title"),
          ],
          [],
        ),
        h("button", [#("id", "share-button")], [text("Share")]),
      ]),
      h("div", [#("id", "playground-content")], [
        h("section", [#("id", "editor")], [
          h("div", [#("id", "editor-target")], []),
        ]),
        h("div", [#("id", "output-container")], [
          h("div", [#("id", "tabs")], [
            output_tab("Output", "output-radio", "output", True),
            // output_tab(
            //   "Compiled Erlang",
            //   "compiled-erlang-radio",
            //   "erlang",
            //   False,
            // ),
            output_tab(
              "Compiled JavaScript",
              "compiled-javascript-radio",
              "javascript",
              False,
            ),
          ]),
          h("aside", [#("id", "output"), #("class", "output")], []),
          h(
            "aside",
            [
              #("id", "compiled-javascript"),
              #("class", "output language-javascript"),
            ],
            [],
          ),
        ]),
      ]),
    ]),
  ])
}
