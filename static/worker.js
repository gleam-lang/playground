import initGleamCompiler from "./compiler.js";
import { files as libFiles } from "./precompiled.js";

const compiler = await initGleamCompiler();
const project = compiler.newProject();

function libUrl(file) {
  const url = new URL(import.meta.url);
  url.pathname = file ? `precompiled/${file}` : "precompiled";
  url.hash = "";
  url.search = "";
  return url.toString();
}

// Write all files from /lib ahead of time.
// Use binary because we also need capnp cache files here.
for (const file of libFiles) {
  const url = libUrl(file);
  const res = await fetch(url);
  const bytes = await res.bytes();
  project.writeFileBytes(`/lib/${file}`, bytes);
}

// Monkey patch console.log to keep a copy of the output
let logged = "";
const log = console.log;
console.log = (...args) => {
  log(...args);
  logged += args.map((e) => `${e}`).join(" ") + "\n";
};

async function loadProgram(js) {
  const href = libUrl();
  const js1 = js
    // Importing a dependency uses `../{packageName}/{module}.mjs`
    .replaceAll(/from\s+"\.\.\/(.+)"/g, `from "${href}/$1"`)
    // The root package depending on prelude `./gleam.mjs`.
    .replaceAll(/from\s+"\.\/gleam\.mjs\"/g, `from "${href}/prelude.mjs"`);
  const js2 = btoa(unescape(encodeURIComponent(js1)));
  const module = await import("data:text/javascript;base64," + js2);
  return module.main;
}

async function compileEval(code) {
  logged = "";
  const result = {
    log: null,
    js: null,
    erlang: null,
    error: null,
    warnings: [],
  };

  try {
    project.writeModule("main", code);
    project.compilePackage("javascript");
    const js = project.readCompiledJavaScript("main");
    project.compilePackage("erlang");
    const erlang = project.readCompiledErlang("main");
    const main = await loadProgram(js);
    if (main) main();

    result.js = js;
    result.erlang = erlang;
  } catch (error) {
    console.error(error);
    result.error = error.toString();
  }
  for (const warning of project.takeWarnings()) {
    result.warnings.push(warning);
  }
  result.log = logged;

  return result;
}

self.onmessage = async (event) => {
  const result = compileEval(event.data);
  postMessage(await result);
};

// Send an initial message to the main thread to indicate that the worker is
// ready to receive messages.
postMessage({});
