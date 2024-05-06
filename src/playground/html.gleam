import gleam/list
import gleam/string
import gleam/string_builder
import htmb.{type Html, h, text}

/// Generic HTML rendering utils
pub type HtmlAttribute =
  #(String, String)

pub type ScriptOptions {
  ScriptOptions(module: Bool, defer: Bool)
}

/// Formats js script options into usage html attributes
fn html_script_common_attributes(
  attributes: ScriptOptions,
) -> List(HtmlAttribute) {
  let type_attr = #("type", case attributes.module {
    True -> "module"
    _ -> "text/javascript"
  })
  let defer_attr = #("defer", "")

  case attributes.defer {
    True -> [defer_attr, type_attr]
    _ -> [type_attr]
  }
}

/// Renders an HTML script tag
pub fn html_script(
  src source: String,
  options attributes: ScriptOptions,
  attributes additional_attributes: List(HtmlAttribute),
) -> Html {
  let attrs = {
    let src_attr = #("src", source)
    let base_attrs = [src_attr, ..html_script_common_attributes(attributes)]
    list.flatten([base_attrs, additional_attributes])
  }
  h("script", attrs, [])
}

/// Renders an inline HTML script tag
pub fn html_dangerous_inline_script(
  script content: String,
  options attributes: ScriptOptions,
  attributes additional_attributes: List(HtmlAttribute),
) -> Html {
  let attrs = {
    list.flatten([
      html_script_common_attributes(attributes),
      additional_attributes,
    ])
  }
  h("script", attrs, [
    htmb.dangerous_unescaped_fragment(string_builder.from_string(content)),
  ])
}

/// Renders an HTML meta tag
pub fn html_meta(data attributes: List(HtmlAttribute)) -> Html {
  h("meta", attributes, [])
}

/// Renders an HTML meta property tag
pub fn html_meta_prop(property: String, content: String) -> Html {
  html_meta([#("property", property), #("content", content)])
}

/// Renders an HTML link tag
pub fn html_link(rel: String, href: String) -> Html {
  h("link", [#("rel", rel), #("href", href)], [])
}

/// Renders a stylesheet link tag
pub fn html_stylesheet(src: String) -> Html {
  html_link("stylesheet", src)
}

/// Renders an HTML title tag
pub fn html_title(title: String) -> Html {
  h("title", [], [text(title)])
}

pub type HeadConfig {
  HeadConfig(
    path: String,
    title: String,
    description: String,
    url: String,
    image: String,
    meta: List(Html),
    stylesheets: List(String),
    scripts: List(Html),
  )
}

/// Renders the page head as HTML
fn head(with config: HeadConfig) -> htmb.Html {
  let meta_tags = [
    html_meta_prop("og:type", "website"),
    html_meta_prop("og:title", config.title),
    html_meta_prop("og:description", config.description),
    html_meta_prop("og:url", config.url),
    html_meta_prop("og:image", config.image),
    html_meta_prop("twitter:card", "summary_large_image"),
    html_meta_prop("twitter:url", config.url),
    html_meta_prop("twitter:title", config.title),
    html_meta_prop("twitter:description", config.description),
    html_meta_prop("twitter:image", config.image),
    ..config.meta
  ]

  let head_meta = [
    html_meta([#("charset", "utf-8")]),
    html_meta([
      #("name", "viewport"),
      #("content", "width=device-width, initial-scale=1"),
    ]),
    html_title(config.title),
    html_meta([#("name", "description"), #("content", config.description)]),
    ..meta_tags
  ]

  let head_links = [
    html_link("shortcut icon", "https://gleam.run/images/lucy/lucy.svg"),
    ..list.map(config.stylesheets, html_stylesheet)
  ]

  let head_content = list.concat([head_meta, head_links, config.scripts])

  h("head", [], head_content)
}

pub type BodyConfig {
  BodyConfig(
    content: List(Html),
    static_content: List(Html),
    scripts: List(Html),
    attributes: List(HtmlAttribute),
  )
}

/// Renders an Html body tag
fn html_body(with config: BodyConfig) -> Html {
  let content =
    list.flatten([config.static_content, config.content, config.scripts])

  h("body", config.attributes, content)
}

pub type HtmlConfig {
  HtmlConfig(
    attributes: List(HtmlAttribute),
    lang: String,
    head: HeadConfig,
    body: BodyConfig,
  )
}

/// Renders an HTML tag and its children
fn html(with config: HtmlConfig) -> Html {
  let attributes = [#("lang", config.lang), ..config.attributes]

  h("html", attributes, [head(config.head), html_body(config.body)])
}

pub type ScriptConfig {
  ScriptConfig(head: List(Html), body: List(Html))
}

pub type PageConfig {
  PageConfig(
    path: String,
    title: String,
    content: List(Html),
    static_content: List(Html),
    stylesheets: List(String),
    scripts: ScriptConfig,
  )
}

/// Renders a page in the language tour
pub fn render_page_html(page config: PageConfig) -> Html {
  // add path-specific class to body to make styling easier
  let body_class = #("id", "page" <> string.replace(config.path, "/", "-"))

  // render html
  html(HtmlConfig(
    head: HeadConfig(
      description: "An interactive introduction and reference to the Gleam programming language. Learn Gleam in your browser!",
      image: "https://gleam.run/images/og-image.png",
      title: config.title <> " - The Gleam Language Tour",
      url: "https://tour.gleam.run/" <> config.path,
      path: config.path,
      meta: [],
      stylesheets: config.stylesheets,
      scripts: [
        html_script(
          "https://plausible.io/js/script.js",
          ScriptOptions(defer: True, module: False),
          [#("data-domain", "tour.gleam.run")],
        ),
        ..config.scripts.head
      ],
    ),
    lang: "en-GB",
    attributes: [#("class", "theme-light")],
    body: BodyConfig(
      attributes: [body_class],
      scripts: config.scripts.body,
      static_content: config.static_content,
      content: config.content,
    ),
  ))
}

/// Renders an HTML document in String form from a PageConfig
pub fn render_page(page config: PageConfig) -> String {
  config
  |> render_page_html
  |> htmb.render_page("html")
  |> string_builder.to_string
}
