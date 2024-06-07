import filepath
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/string_builder
import htmb.{type Html, h}
import playground/html.{
  PageConfig, ScriptConfig, ScriptOptions, html_dangerous_inline_script,
  html_script, render_page,
}
import playground/pages.{home_page}
import playground/widgets.{Link}
import simplifile
import snag

const static = "static"

const public = "public"

const public_precompiled = "public/precompiled"

const prelude = "build/dev/javascript/prelude.mjs"

const stdlib_compiled = "build/dev/javascript/gleam_stdlib/gleam"

const stdlib_sources = "build/packages/gleam_stdlib/src/gleam"

const stdlib_external = "build/packages/gleam_stdlib/src"

const compiler_wasm = "./wasm-compiler"

const home_title = "Gleam Playground"

const hello_joe = "import gleam/io

pub fn main() {
  io.println(\"Hello, Joe!\")
}
"

// page paths

const path_home = "/"

pub fn main() {
  let result = {
    use _ <- result.try(reset_output())
    use _ <- result.try(make_prelude_available())
    use _ <- result.try(make_stdlib_available())
    use _ <- result.try(copy_wasm_compiler())
    use pages <- result.try(get_pages())
    use _ <- result.try(write_pages(pages))

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

type Page {
  Page(filenames: FileNames, content: Html)
}

fn get_pages() -> snag.Result(List(Page)) {
  Ok([
    Page(FileNames(path: path_home, name: home_title, slug: "/"), home_page()),
  ])
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

/// Common stylesheet for all playground pages
const css_root = "/css/root.css"

// Path to the css speciic to to lesson & main pages
const css_playground_page = "/css/pages/playground.css"

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
  widgets.navbar(titled: "Gleam Playground", links: [
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
    path: page.filenames.slug,
    title: page.filenames.name,
    stylesheets: list.flatten([
      css_defaults_page,
      css_defaults_code,
      [css_root, css_playground_page],
    ]),
    static_content: [render_navbar()],
    content: [page.content],
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
    let dir = filepath.join(public, page.filenames.slug)
    use _ <- result.try(ensure_directory(dir))
    let path = filepath.join(dir, "index.html")
    let html = render_page_object(page)
    write_text(path, html)
  })
}
