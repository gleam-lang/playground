import CodeFlask from "https://cdn.jsdelivr.net/npm/codeflask@1.4.1/+esm";
import hljs from "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/es/highlight.min.js";
import js from "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/es/languages/javascript.min.js";
import erlang from "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/es/languages/erlang.min.js";
import lz from "https://cdn.jsdelivr.net/npm/lz-string@1.5.0/+esm";

globalThis.CodeFlask = CodeFlask;
globalThis.hljs = hljs;

hljs.registerLanguage("javascript", js);
hljs.registerLanguage("erlang", erlang);

const outputEl = document.querySelector("#output");
const compiledJavascriptEl = document.querySelector("#compiled-javascript");
const compiledErlangEl = document.querySelector("#compiled-erlang");
const initialCode = document.querySelector("#code").innerHTML;

const prismGrammar = {
  comment: {
    pattern: /\/\/.*/,
    greedy: true,
  },
  function: /([a-z_][a-z0-9_]+)(?=\()/,
  keyword:
    /\b(use|case|if|@external|@deprecated|fn|import|let|assert|try|pub|type|opaque|const|panic|todo|as|echo)\b/,
  symbol: {
    pattern: /([A-Z][A-Za-z0-9_]+)/,
    greedy: true,
  },
  operator: {
    pattern:
      /(<<|>>|<-|->|\|>|<>|\.\.|<=\.?|>=\.?|==\.?|!=\.?|<\.?|>\.?|&&|\|\||\+\.?|-\.?|\/\.?|\*\.?|%\.?|=)/,
    greedy: true,
  },
  string: {
    pattern: /"((?:[^"\\]|\\.)*)"/,
    greedy: true,
  },
  module: {
    pattern: /([a-z][a-z0-9_]*)\./,
    inside: {
      punctuation: /\./,
    },
    alias: "keyword",
  },
  punctuation: /[.\\:,{}()]/,
  number:
    /\b(?:0b[0-1]+|0o[0-7]+|[[:digit:]][[:digit:]_]*(\\.[[:digit:]]*)?|0x[[:xdigit:]]+)\b/,
};

function clearElement(target) {
  while (target.firstChild) {
    target.removeChild(target.firstChild);
  }
}

function appendCode(target, content, className) {
  if (!content) return;
  const escapedContent = escapeHtml(content);
  const formattedContent = highlightEchoPath(escapedContent);
  const element = document.createElement("pre");
  const code = document.createElement("code");
  code.innerHTML = formattedContent;
  element.appendChild(code);
  element.className = className;
  target.appendChild(element);
}

function escapeHtml(content) {
  const div = document.createElement("div");
  div.textContent = content;
  return div.innerHTML;
}

function highlightEchoPath(content) {
  if (typeof content !== "string") return content;
  const pathRegex = /(^src\/main.gleam:\d+$)/gm;
  const newContent = content.replace(
    pathRegex,
    '<span class="echo-path">$1</span>',
  );
  return newContent;
}

function highlightOutput(target, childClassName) {
  // Disable annoying warnings from hljs
  const warn = console.warn;
  console.warn = () => {};
  target.querySelectorAll(`.${childClassName}`).forEach((element) => {
    hljs.highlightElement(element);
  });
  console.warn = warn;
}

const editor = new CodeFlask("#editor-target", {
  language: "gleam",
  defaultTheme: false,
});
editor.addLanguage("gleam", prismGrammar);
editor.updateCode(initialCode);

function debounce(fn, delay) {
  let timer = null;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), delay);
  };
}

const worker = new Worker("worker.js", { type: "module" });
const workerReady = new Promise((resolve) => (worker.onmessage = resolve));

async function callWorker(action, code) {
  await workerReady;
  const { port1, port2 } = new MessageChannel();
  const reply = new Promise((resolve) => {
    port1.onmessage = (event) => resolve(event.data);
  });
  worker.postMessage({ action, code }, [port2]);
  return reply;
}

// Whether the worker is currently working or not, used to avoid sending
// multiple messages to the worker at once.
let workerWorking = false;
let queuedWork = undefined;

async function compile(code) {
  if (workerWorking) {
    queuedWork = code;
    return;
  }
  workerWorking = true;
  showResult(await callWorker("compile", code));
  workerWorking = false;

  // Deal with any queued work
  const next = queuedWork;
  queuedWork = undefined;
  if (next) compile(next);
}

function showResult(result) {
  clearElement(outputEl);
  clearElement(compiledJavascriptEl);
  clearElement(compiledErlangEl);
  if (result.log) {
    appendCode(outputEl, result.log, "log");
  }
  if (result.error) {
    appendCode(outputEl, result.error, "error");
  }
  if (result.js) {
    appendCode(compiledJavascriptEl, result.js, "javascript");
  }
  if (result.erlang) {
    appendCode(compiledErlangEl, result.erlang, "erlang");
  }
  for (const warning of result.warnings || []) {
    appendCode(outputEl, warning, "warning");
  }

  highlightOutput(compiledJavascriptEl, "javascript");
  highlightOutput(compiledErlangEl, "erlang");
}

editor.onUpdate(debounce(compile, 200));

/**
 * Hashed object format:
 * {
 *   version: 1,
 *   content: "code"
 * }
 */
function makeV1Hash(code) {
  return lz.compressToBase64(
    JSON.stringify({
      version: 1,
      content: code,
    }),
  );
}

function parseV1Hash(obj) {
  if (obj.version !== 1) {
    throw new Error("Unsupported version");
  }
  return obj.content;
}

function parseHash(hash) {
  let obj;
  try {
    obj = JSON.parse(lz.decompressFromBase64(hash));
  } catch (e) {
    return null;
  }
  if (!obj) {
    return null;
  }
  switch (obj.version) {
    case 1:
      return parseV1Hash(obj);
  }
  return null;
}

if (window.location.hash) {
  const hash = window.location.hash.slice(1);
  const code = parseHash(hash);
  if (code) {
    editor.updateCode(code);
  }
}

const shareButton = document.querySelector("#share-button");

function share() {
  const code = editor.getCode();
  const compressed = makeV1Hash(code);
  const url = `${window.location.origin}${window.location.pathname}#${compressed}`;
  navigator.clipboard.writeText(url);
  const before = shareButton.textContent;
  shareButton.textContent = "Link copied!";
  setTimeout(() => {
    shareButton.textContent = before;
  }, 1000);
}
shareButton.addEventListener("click", share);

const formatButton = document.querySelector("#format-button");

async function format() {
  const source = editor.getCode();
  const { formatted, error } = await callWorker("format", source);
  if (error) {
    showResult({ error });
    return;
  }
  // Don't clobber edits made while the formatter was running
  if (formatted !== source && editor.getCode() === source) {
    editor.updateCode(formatted);
  }
}
formatButton.addEventListener("click", format);
