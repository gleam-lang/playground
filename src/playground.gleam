import filepath
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/string_builder
import htmb.{type Html, h}
import simplifile
import snag
import playground/widgets.{Link}
import playground/html.{
  PageConfig, ScriptConfig, ScriptOptions, html_dangerous_inline_script,
  html_script, render_page,
}

const static = "static"

const public = "public"

const public_precompiled = "public/precompiled"

const prelude = "build/dev/javascript/prelude.mjs"

const stdlib_compiled = "build/dev/javascript/gleam_stdlib/gleam"

const stdlib_sources = "build/packages/gleam_stdlib/src/gleam"

const stdlib_external = "build/packages/gleam_stdlib/src"

const compiler_wasm = "./wasm-compiler"

const home_title = "Gleam Playground"

const pages_path = "src/pages"

const hello_joe = "import gleam/io

pub fn main() {
  io.println(\"Hello, Joe!\")
}
"

// page paths

const path_home = "/"

// Don't include deprecated stdlib modules
const skipped_stdlib_modules = [
  "bit_string.gleam", "bit_builder.gleam", "map.gleam",
]

pub fn main() {
  let _ = {
    use f <- result.try(load_file_names(pages_path, []))
    io.debug(read_pages(f))
  }

  let result = {
    use _ <- result.try(reset_output())
    use _ <- result.try(make_prelude_available())
    use _ <- result.try(make_stdlib_available())
    use _ <- result.try(copy_wasm_compiler())
    use filenames <- result.try(load_file_names(pages_path, []))
    use pages <- result.try(read_pages(filenames))
    use _ <- result.try(write_pages(pages))

    io.debug("Done rendering pages")
    // use p <- result.try(load_content())
    // use _ <- result.try(write_content(p))
    Ok(Nil)
  }

  case result {
    Ok(_) -> {
      io.println("Site compiled to ./public 🎉")
    }
    Error(snag) -> {
      panic as snag.pretty_print(snag)
    }
  }
}

type FileNames {
  FileNames(path: String, name: String, slug: String)
}

/// Recursively list files in a directory
fn load_file_names(
  path: String,
  filenames: List(FileNames),
) -> snag.Result(List(FileNames)) {
  use files <- result.try(
    simplifile.read_directory(path)
    |> file_error("Failed to read directory " <> path),
  )

  files
  |> list.filter(fn(file) { !string.starts_with(file, ".") })
  |> list.fold(Ok(filenames), fn(filenames, file_or_dir_path) {
    use filenames <- result.try(filenames)
    let full_file_path = path <> "/" <> file_or_dir_path
    case simplifile.is_directory(full_file_path) {
      True -> load_file_names(full_file_path, filenames)
      False -> {
        let slug =
          full_file_path
          |> string.replace(pages_path <> "/", "")
          |> string.split("/")
          |> list.reverse
          |> list.drop(1)
          |> list.reverse
          |> string.join("/")
          |> fn(s) { path_home <> s }

        let name =
          slug
          |> string.replace("/", " ")
          |> string.replace("-", " ")
          |> string.capitalise
          |> string_coalesce(home_title)

        let file = FileNames(path: full_file_path, name: name, slug: slug)
        Ok([file, ..filenames])
      }
    }
  })
}

fn string_coalesce(coalesce value: String, with replacement: String) -> String {
  case value {
    "" -> replacement
    _ -> value
  }
}

type Page {
  Page(filenames: FileNames, content: String)
}

fn read_pages(filenames: List(FileNames)) -> snag.Result(List(Page)) {
  filenames
  |> list.fold(Ok([]), fn(pages, filename) {
    use pages <- result.try(pages)
    use content <- result.try(read_file(filename.path))
    let page = Page(filenames: filename, content: content)
    Ok([page, ..pages])
  })
}

fn read_file(path: String) -> snag.Result(String) {
  simplifile.read(path)
  |> file_error("Failed to read file " <> path)
}

fn ensure_directory(path: String) -> snag.Result(Nil) {
  simplifile.create_directory_all(path)
  |> file_error("Failed to create directory " <> path)
}

fn write_text(path: String, text: String) -> snag.Result(Nil) {
  simplifile.write(path, text)
  |> file_error("Failed to write " <> path)
}

fn copy_wasm_compiler() -> snag.Result(Nil) {
  use <- require(
    simplifile.is_directory(compiler_wasm),
    "compiler-wasm must have been compiled",
  )

  simplifile.copy_directory(compiler_wasm, public <> "/compiler")
  |> file_error("Failed to copy compiler-wasm")
}

fn make_prelude_available() -> snag.Result(Nil) {
  use _ <- result.try(
    simplifile.create_directory_all(public_precompiled)
    |> file_error("Failed to make " <> public_precompiled),
  )

  simplifile.copy_file(prelude, public_precompiled <> "/gleam.mjs")
  |> file_error("Failed to copy prelude.mjs")
}

fn make_stdlib_available() -> snag.Result(Nil) {
  use files <- result.try(
    simplifile.read_directory(stdlib_sources)
    |> file_error("Failed to read stdlib directory"),
  )

  let modules =
    files
    |> list.filter(fn(file) { string.ends_with(file, ".gleam") })
    |> list.filter(fn(file) { !list.contains(skipped_stdlib_modules, file) })
    |> list.map(string.replace(_, ".gleam", ""))

  use _ <- result.try(
    generate_stdlib_bundle(modules)
    |> snag.context("Failed to generate stdlib.js bundle"),
  )

  use _ <- result.try(
    copy_compiled_stdlib(modules)
    |> snag.context("Failed to copy precompiled stdlib modules"),
  )

  use _ <- result.try(
    copy_stdlib_externals()
    |> snag.context("Failed to copy stdlib external files"),
  )

  Ok(Nil)
}

fn copy_stdlib_externals() -> snag.Result(Nil) {
  use files <- result.try(
    simplifile.read_directory(stdlib_external)
    |> file_error("Failed to read stdlib external directory"),
  )
  let files = list.filter(files, string.ends_with(_, ".mjs"))

  list.try_each(files, fn(file) {
    let from = stdlib_external <> "/" <> file
    let to = public_precompiled <> "/" <> file
    simplifile.copy_file(from, to)
    |> file_error("Failed to copy stdlib external file " <> from)
  })
}

fn copy_compiled_stdlib(modules: List(String)) -> snag.Result(Nil) {
  use <- require(
    simplifile.is_directory(stdlib_compiled),
    "Project must have been compiled for JavaScript",
  )

  let dest = public_precompiled <> "/gleam"
  use _ <- result.try(
    simplifile.create_directory_all(dest)
    |> file_error("Failed to make " <> dest),
  )

  use _ <- result.try(
    list.try_each(modules, fn(name) {
      let from = stdlib_compiled <> "/" <> name <> ".mjs"
      let to = dest <> "/" <> name <> ".mjs"
      simplifile.copy_file(from, to)
      |> file_error("Failed to copy stdlib module " <> from)
    }),
  )

  Ok(Nil)
}

fn generate_stdlib_bundle(modules: List(String)) -> snag.Result(Nil) {
  use entries <- result.try(
    list.try_map(modules, fn(name) {
      let path = stdlib_sources <> "/" <> name <> ".gleam"
      use code <- result.try(
        simplifile.read(path)
        |> file_error("Failed to read stdlib module " <> path),
      )
      let name = string.replace(name, ".gleam", "")
      let code =
        code
        |> string.replace("\\", "\\\\")
        |> string.replace("`", "\\`")
        |> string.split("\n")
        |> list.filter(fn(line) { !string.starts_with(string.trim(line), "//") })
        |> list.filter(fn(line) {
          !string.starts_with(line, "@external(erlang")
        })
        |> list.filter(fn(line) { line != "" })
        |> string.join("\n")

      Ok("  \"gleam/" <> name <> "\": `" <> code <> "`")
    }),
  )

  entries
  |> string.join(",\n")
  |> string.append("export default {\n", _)
  |> string.append("\n}\n")
  |> simplifile.write(public <> "/stdlib.js", _)
  |> file_error("Failed to write stdlib.js")
}

fn reset_output() -> snag.Result(Nil) {
  use _ <- result.try(
    simplifile.create_directory_all(public)
    |> file_error("Failed to delete public directory"),
  )

  use files <- result.try(
    simplifile.read_directory(public)
    |> file_error("Failed to read public directory"),
  )

  use _ <- result.try(
    files
    |> list.map(string.append(public <> "/", _))
    |> simplifile.delete_all
    |> file_error("Failed to delete public directory"),
  )

  simplifile.copy_directory(static, public)
  |> file_error("Failed to copy static directory")
}

fn require(
  that condition: Bool,
  because reason: String,
  then next: fn() -> snag.Result(t),
) -> snag.Result(t) {
  case condition {
    True -> next()
    False -> Error(snag.new(reason))
  }
}

fn file_error(
  result: Result(t, simplifile.FileError),
  context: String,
) -> snag.Result(t) {
  case result {
    Ok(value) -> Ok(value)
    Error(error) ->
      snag.error("File error: " <> string.inspect(error))
      |> snag.context(context)
  }
}

// Shared stylesheets paths

const css__gleam_common = "/common.css"

/// Loads fonts and defines font sizes
const css_fonts = "/css/fonts.css"

/// Derives app colors for both dark & light themes from common.css variables
const css_theme = "/css/theme.css"

/// Defines layout unit variables
const css_layout = "/css/layout.css"

/// Sensitive defaults for any page
const css_defaults_page = [css_fonts, css_theme, css__gleam_common, css_layout]

// Page stylesheet paths

/// Common stylesheet for all tour pages
const css_root = "/css/root.css"

// Path to the css speciic to to lesson & main pages
const css_lesson_page = "/css/pages/lesson.css"

// Defines code syntax highlighting for highlightJS & CodeFlash
// based on dark / light mode and the currenly loaded color scheme
const css_syntax_highlight = "/css/code/syntax-highlight.css"

// Color schemes
// TODO: add more color schemes

/// Atom One Dark & Atom One Light colors
const css_scheme_atom_one = "/css/code/color-schemes/atom-one.css"

/// Sensitive defaults for any page needing to display Gleam code
/// To be used alonside defaults_page
const css_defaults_code = [css_syntax_highlight, css_scheme_atom_one]

// Common page HTML elements renders

/// Renders the navbar with common links
fn render_navbar() -> Html {
  widgets.navbar(titled: "Gleam Language Tour", links: [
    Link(label: "gleam.run", to: "http://gleam.run"),
  ])
}

/// Renders the script that that contains the code
/// needed for the light/dark theme picker to work
pub fn theme_picker_script() -> Html {
  html_dangerous_inline_script(
    widgets.theme_picker_js,
    ScriptOptions(module: True, defer: False),
    [],
  )
}

// Page Renders

fn render_page_object(page: Page) -> String {
  render_page(PageConfig(
    path: page.filenames.path,
    title: page.filenames.name,
    stylesheets: list.flatten([
      css_defaults_page,
      css_defaults_code,
      [css_root, css_lesson_page],
    ]),
    static_content: [render_navbar()],
    content: [
      htmb.dangerous_unescaped_fragment(string_builder.from_string(page.content)),
    ],
    scripts: ScriptConfig(
      body: [
        theme_picker_script(),
        h("script", [#("type", "gleam"), #("id", "code")], [
          htmb.dangerous_unescaped_fragment(string_builder.from_string(
            hello_joe,
          )),
        ]),
        html_script("/index.js", ScriptOptions(module: True, defer: False), []),
      ],
      head: [],
    ),
  ))
}

fn write_pages(pages: List(Page)) -> snag.Result(Nil) {
  list.try_each(pages, fn(page) {
    let dir = filepath.join(public, slugify_path(page.filenames.slug))
    use _ <- result.try(ensure_directory(dir))
    let path = filepath.join(dir, "index.html")
    let html = render_page_object(page)
    write_text(path, html)
  })
}

/// Renders a Lesson's page
/// Complete with title, lesson, editor and output
/// Transform a path into a slug
fn slugify_path(path: String) -> String {
  string.replace(path, "/", "-")
  |> string.drop_left(up_to: 1)
}
