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

  assert string.trim(gleam_version) == "v" <> version
    as "GLEAM_VERSION must match the Gleam compiler version."
}
