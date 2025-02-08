//// Generic HTML rendering utils

import gleam/list
import gleam/string_tree
import htmb.{type Html, h, text}

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
    htmb.dangerous_unescaped_fragment(string_tree.from_string(content)),
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
