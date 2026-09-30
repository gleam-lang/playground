import gleam/list
import gleam/string
import gleeunit
import simplifile

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn gleam_version_matches_compiler_test() {
  let assert Ok(fingerprint) =
    simplifile.read("build/dev/javascript/fingerprint")
  let assert [version, ..] = string.split(fingerprint, " ")
  let assert Ok(gleam_version) = simplifile.read("GLEAM_VERSION")
  let assert Ok(deploy_workflow) =
    simplifile.read(".github/workflows/deploy.yml")
  let assert Ok(test_workflow) = simplifile.read(".github/workflows/test.yml")

  assert string.trim(gleam_version) == "v" <> version
    as "GLEAM_VERSION must match the Gleam compiler version."
  assert workflow_gleam_version(deploy_workflow) == version
    as "The deploy workflow must match the Gleam compiler version."
  assert workflow_gleam_version(test_workflow) == version
    as "The test workflow must match the Gleam compiler version."
}

fn workflow_gleam_version(workflow: String) -> String {
  let version_lines =
    workflow
    |> string.split("\n")
    |> list.filter(fn(line) { string.contains(line, "gleam-version:") })

  case version_lines {
    [line] ->
      line
      |> string.trim
      |> string.replace("gleam-version: ", "")
      |> string.replace("\"", "")
    _ -> ""
  }
}
