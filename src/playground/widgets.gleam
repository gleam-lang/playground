import htmb.{type Html, h, text}

pub fn icon_moon() -> Html {
  h("svg", [#("id", "icon-moon"), #("viewBox", "0 0 24 24")], [
    h(
      "path",
      [
        #(
          "d",
          "M21.996 12.882c0.022-0.233-0.038-0.476-0.188-0.681-0.325-0.446-0.951-0.544-1.397-0.219-0.95 0.693-2.060 1.086-3.188 1.162-1.368 0.092-2.765-0.283-3.95-1.158-1.333-0.985-2.139-2.415-2.367-3.935s0.124-3.124 1.109-4.456c0.142-0.191 0.216-0.435 0.191-0.691-0.053-0.55-0.542-0.952-1.092-0.898-2.258 0.22-4.314 1.18-5.895 2.651-1.736 1.615-2.902 3.847-3.137 6.386-0.254 2.749 0.631 5.343 2.266 7.311s4.022 3.313 6.772 3.567 5.343-0.631 7.311-2.266 3.313-4.022 3.567-6.772zM19.567 14.674c-0.49 1.363-1.335 2.543-2.416 3.441-1.576 1.309-3.648 2.016-5.848 1.813s-4.108-1.278-5.417-2.854-2.016-3.648-1.813-5.848c0.187-2.032 1.117-3.814 2.507-5.106 0.782-0.728 1.71-1.3 2.731-1.672-0.456 1.264-0.577 2.606-0.384 3.899 0.303 2.023 1.38 3.934 3.156 5.247 1.578 1.167 3.448 1.668 5.272 1.545 0.752-0.050 1.496-0.207 2.21-0.465z",
        ),
      ],
      [],
    ),
  ])
}

pub fn icon_sun() -> Html {
  h("svg", [#("id", "icon-sun"), #("viewBox", "0 0 24 24")], [
    h(
      "path",
      [
        #(
          "d",
          "M18 12c0-1.657-0.673-3.158-1.757-4.243s-2.586-1.757-4.243-1.757-3.158 0.673-4.243 1.757-1.757 2.586-1.757 4.243 0.673 3.158 1.757 4.243 2.586 1.757 4.243 1.757 3.158-0.673 4.243-1.757 1.757-2.586 1.757-4.243zM16 12c0 1.105-0.447 2.103-1.172 2.828s-1.723 1.172-2.828 1.172-2.103-0.447-2.828-1.172-1.172-1.723-1.172-2.828 0.447-2.103 1.172-2.828 1.723-1.172 2.828-1.172 2.103 0.447 2.828 1.172 1.172 1.723 1.172 2.828zM11 1v2c0 0.552 0.448 1 1 1s1-0.448 1-1v-2c0-0.552-0.448-1-1-1s-1 0.448-1 1zM11 21v2c0 0.552 0.448 1 1 1s1-0.448 1-1v-2c0-0.552-0.448-1-1-1s-1 0.448-1 1zM3.513 4.927l1.42 1.42c0.391 0.391 1.024 0.391 1.414 0s0.391-1.024 0-1.414l-1.42-1.42c-0.391-0.391-1.024-0.391-1.414 0s-0.391 1.024 0 1.414zM17.653 19.067l1.42 1.42c0.391 0.391 1.024 0.391 1.414 0s0.391-1.024 0-1.414l-1.42-1.42c-0.391-0.391-1.024-0.391-1.414 0s-0.391 1.024 0 1.414zM1 13h2c0.552 0 1-0.448 1-1s-0.448-1-1-1h-2c-0.552 0-1 0.448-1 1s0.448 1 1 1zM21 13h2c0.552 0 1-0.448 1-1s-0.448-1-1-1h-2c-0.552 0-1 0.448-1 1s0.448 1 1 1zM4.927 20.487l1.42-1.42c0.391-0.391 0.391-1.024 0-1.414s-1.024-0.391-1.414 0l-1.42 1.42c-0.391 0.391-0.391 1.024 0 1.414s1.024 0.391 1.414 0zM19.067 6.347l1.42-1.42c0.391-0.391 0.391-1.024 0-1.414s-1.024-0.391-1.414 0l-1.42 1.42c-0.391 0.391-0.391 1.024 0 1.414s1.024 0.391 1.414 0z",
        ),
      ],
      [],
    ),
  ])
}

pub fn icon_toggle_left() -> Html {
  h("svg", [#("id", "icon-toggle-left"), #("viewBox", "0 0 24 24")], [
    h(
      "path",
      [
        #(
          "d",
          "M8 4c-2.209 0-4.21 0.897-5.657 2.343s-2.343 3.448-2.343 5.657 0.897 4.21 2.343 5.657 3.448 2.343 5.657 2.343h8c2.209 0 4.21-0.897 5.657-2.343s2.343-3.448 2.343-5.657-0.897-4.21-2.343-5.657-3.448-2.343-5.657-2.343zM8 6h8c1.657 0 3.156 0.67 4.243 1.757s1.757 2.586 1.757 4.243-0.67 3.156-1.757 4.243-2.586 1.757-4.243 1.757h-8c-1.657 0-3.156-0.67-4.243-1.757s-1.757-2.586-1.757-4.243 0.67-3.156 1.757-4.243 2.586-1.757 4.243-1.757zM12 12c0-1.104-0.449-2.106-1.172-2.828s-1.724-1.172-2.828-1.172-2.106 0.449-2.828 1.172-1.172 1.724-1.172 2.828 0.449 2.106 1.172 2.828 1.724 1.172 2.828 1.172 2.106-0.449 2.828-1.172 1.172-1.724 1.172-2.828zM10 12c0 0.553-0.223 1.051-0.586 1.414s-0.861 0.586-1.414 0.586-1.051-0.223-1.414-0.586-0.586-0.861-0.586-1.414 0.223-1.051 0.586-1.414 0.861-0.586 1.414-0.586 1.051 0.223 1.414 0.586 0.586 0.861 0.586 1.414z",
        ),
      ],
      [],
    ),
  ])
}

pub fn icon_toggle_right() -> Html {
  h("svg", [#("id", "icon-toggle-right"), #("viewBox", "0 0 24 24")], [
    h(
      "path",
      [
        #(
          "d",
          "M8 4c-2.209 0-4.21 0.897-5.657 2.343s-2.343 3.448-2.343 5.657 0.897 4.21 2.343 5.657 3.448 2.343 5.657 2.343h8c2.209 0 4.21-0.897 5.657-2.343s2.343-3.448 2.343-5.657-0.897-4.21-2.343-5.657-3.448-2.343-5.657-2.343zM8 6h8c1.657 0 3.156 0.67 4.243 1.757s1.757 2.586 1.757 4.243-0.67 3.156-1.757 4.243-2.586 1.757-4.243 1.757h-8c-1.657 0-3.156-0.67-4.243-1.757s-1.757-2.586-1.757-4.243 0.67-3.156 1.757-4.243 2.586-1.757 4.243-1.757zM20 12c0-1.104-0.449-2.106-1.172-2.828s-1.724-1.172-2.828-1.172-2.106 0.449-2.828 1.172-1.172 1.724-1.172 2.828 0.449 2.106 1.172 2.828 1.724 1.172 2.828 1.172 2.106-0.449 2.828-1.172 1.172-1.724 1.172-2.828zM18 12c0 0.553-0.223 1.051-0.586 1.414s-0.861 0.586-1.414 0.586-1.051-0.223-1.414-0.586-0.586-0.861-0.586-1.414 0.223-1.051 0.586-1.414 0.861-0.586 1.414-0.586 1.051 0.223 1.414 0.586 0.586 0.861 0.586 1.414z",
        ),
      ],
      [],
    ),
  ])
}

pub fn icon_share() -> Html {
  h(
    "svg",
    [
      #("id", "icon-share"),
      #("viewBox", "0 0 24 24"),
      #("fill", "currentColor"),
    ],
    [
      h(
        "path",
        [
          #("fill-rule", "evenodd"),
          #(
            "d",
            "M16.5 2.25C14.7051 2.25 13.25 3.70507 13.25 5.5C13.25 5.69591 13.2673 5.88776 13.3006 6.07412L8.56991 9.38558C8.54587 9.4024 8.52312 9.42038 8.50168 9.43939C7.94993 9.00747 7.25503 8.75 6.5 8.75C4.70507 8.75 3.25 10.2051 3.25 12C3.25 13.7949 4.70507 15.25 6.5 15.25C7.25503 15.25 7.94993 14.9925 8.50168 14.5606C8.52312 14.5796 8.54587 14.5976 8.56991 14.6144L13.3006 17.9259C13.2673 18.1122 13.25 18.3041 13.25 18.5C13.25 20.2949 14.7051 21.75 16.5 21.75C18.2949 21.75 19.75 20.2949 19.75 18.5C19.75 16.7051 18.2949 15.25 16.5 15.25C15.4472 15.25 14.5113 15.7506 13.9174 16.5267L9.43806 13.3911C9.63809 12.9694 9.75 12.4978 9.75 12C9.75 11.5022 9.63809 11.0306 9.43806 10.6089L13.9174 7.4733C14.5113 8.24942 15.4472 8.75 16.5 8.75C18.2949 8.75 19.75 7.29493 19.75 5.5C19.75 3.70507 18.2949 2.25 16.5 2.25ZM14.75 5.5C14.75 4.5335 15.5335 3.75 16.5 3.75C17.4665 3.75 18.25 4.5335 18.25 5.5C18.25 6.4665 17.4665 7.25 16.5 7.25C15.5335 7.25 14.75 6.4665 14.75 5.5ZM6.5 10.25C5.5335 10.25 4.75 11.0335 4.75 12C4.75 12.9665 5.5335 13.75 6.5 13.75C7.4665 13.75 8.25 12.9665 8.25 12C8.25 11.0335 7.4665 10.25 6.5 10.25ZM16.5 16.75C15.5335 16.75 14.75 17.5335 14.75 18.5C14.75 19.4665 15.5335 20.25 16.5 20.25C17.4665 20.25 18.25 19.4665 18.25 18.5C18.25 17.5335 17.4665 16.75 16.5 16.75Z",
          ),
        ],
        [],
      ),
    ],
  )
}

pub fn icon_broom() -> Html {
  h(
    "svg",
    [
      #("id", "icon-broom"),
      #("viewBox", "0 0 24 24"),
      #("fill", "none"),
      #("stroke", "currentColor"),
      #("stroke-width", "1.5"),
      #("stroke-linecap", "round"),
      #("stroke-linejoin", "round"),
    ],
    [
      h(
        "path",
        [
          #(
            "d",
            "M9.87 5.66998L6.45 7.74999L4.89001 5.19C4.32001 4.25 4.62 3.01 5.56 2.44C6.5 1.87 7.74 2.16998 8.31 3.10998L9.87 5.66998Z",
          ),
        ],
        [],
      ),
      h(
        "path",
        [
          #(
            "d",
            "M11.82 9.15997L8.66 11.08C6.82 12.2 6.25999 14.46 7.14999 16.26L9.19999 20.44C9.85999 21.79 11.46 22.26 12.74 21.47L19.17 17.56C20.46 16.78 20.77 15.15 19.88 13.94L17.11 10.2C15.91 8.58001 13.66 8.03997 11.82 9.15997Z",
          ),
        ],
        [],
      ),
      h(
        "path",
        [
          #(
            "d",
            "M10.7567 5.09791L5.63208 8.21851L7.71248 11.6349L12.8371 8.51431L10.7567 5.09791Z",
          ),
        ],
        [],
      ),
      h("path", [#("d", "M14.31 16.8101L15.96 19.5201")], []),
      h("path", [#("d", "M11.75 18.37L13.4 21.08")], []),
      h("path", [#("d", "M16.87 15.25L18.52 17.96")], []),
    ],
  )
}

pub fn theme_picker() -> Html {
  h("div", [#("class", "theme-picker")], [
    h(
      "button",
      [
        #("type", "button"),
        #("alt", "Switch to light mode"),
        #("title", "Switch to light mode"),
        #("class", "theme-button -light"),
        #("data-light-theme-toggle", ""),
      ],
      [icon_moon(), icon_toggle_left()],
    ),
    h(
      "button",
      [
        #("type", "button"),
        #("alt", "Switch to dark mode"),
        #("title", "Switch to dark mode"),
        #("class", "theme-button -dark"),
        #("data-dark-theme-toggle", ""),
      ],
      [icon_sun(), icon_toggle_right()],
    ),
  ])
}

pub fn icon_button(id: String, label: String, icon: Html) -> Html {
  h("button", [#("id", id), #("class", "icon-button"), #("aria-label", label)], [
    icon,
  ])
}

// This script is inlined in the response to avoid FOUC when applying the theme
pub const theme_picker_js =
  "
const mediaPrefersDarkTheme = window.matchMedia('(prefers-color-scheme: dark)');
const themeStorageKey = 'theme';

function getPreferredTheme() {
  return mediaPrefersDarkTheme.matches ? 'dark' : 'light';
}

function getAppliedTheme() {
  return document.documentElement.classList.contains('theme-dark')
    ? 'dark'
    : 'light';
}

function getStoredTheme() {
  return localStorage.getItem(themeStorageKey);
}

function storeTheme(selectedTheme) {
  localStorage.setItem(themeStorageKey, selectedTheme);
}

function syncStoredTheme(theme) {
  if (theme === getPreferredTheme()) {
    // Selected theme is the same as the device's preferred theme, so we can forget this setting.
    localStorage.removeItem(themeStorageKey);
  } else {
    // Remember the selected theme to apply it on the next visit
    storeTheme(theme);
  }
}

function applyTheme(theme, initial = false) {
  // abort if theme is already applied
  if (theme === getAppliedTheme()) return;
  // apply theme css class
  document.documentElement.classList.toggle('theme-dark', theme === 'dark');
  document.documentElement.classList.toggle('theme-light', theme !== 'dark');
}

function setTheme(theme) {
  syncStoredTheme(theme);
  applyTheme(theme);
}

function toggleTheme() {
  setTheme(getAppliedTheme() === 'dark' ? 'light' : 'dark');
}

function initThemeEvents() {
  // Watch the device's preferred theme and update theme if user did not select a theme
  mediaPrefersDarkTheme.addEventListener('change', () => {
    // abort if the user already selected a theme
    if (!!getStoredTheme()) return;
    // update applied theme accordingly
    applyTheme(getPreferredTheme());
  });
  // Add handlers for theme selection button
  document
    .querySelector('.theme-picker')
    ?.addEventListener('click', toggleTheme);
}

function initTheme() {
  // apply stored or preferred theme
  applyTheme(getStoredTheme() ?? getPreferredTheme());
  initThemeEvents();
}

initTheme();
"

/// Renders an HTML anhor tag
pub fn anchor(
  to href: String,
  attrs attributes: List(#(String, String)),
  with content: List(Html),
) -> Html {
  h("a", [#("href", href), ..attributes], content)
}

pub type Link {
  Link(label: String, to: String)
}

/// Renders a styled text link
pub fn text_link(
  for link: Link,
  attributes attributes: List(#(String, String)),
) -> Html {
  let link_attributes = [#("class", "link"), ..attributes]

  anchor(link.to, link_attributes, [text(link.label)])
}

/// Renders the playground's navbar as html
pub fn navbar(gleam_version: String) -> Html {
  h("nav", [#("class", "navbar")], [
    anchor("", [#("class", "logo")], [
      h(
        "img",
        [
          #("src", "https://gleam.run/images/lucy/lucy.svg"),
          #("alt", "Lucy the star, Gleam's mascot"),
        ],
        [],
      ),
      text("Gleam Playground"),
      h("p", [#("class", "version-number")], [text(gleam_version)]),
    ]),
    h("div", [#("class", "nav-right")], [
      anchor("https://gleam.run", [#("class", "link")], [text("gleam.run")]),
      theme_picker(),
    ]),
  ])
}

/// Renders a tab for the output display
pub fn output_tab(
  label: String,
  id: String,
  value: String,
  checked: Bool,
) -> Html {
  let attrs = [
    #("type", "radio"),
    #("id", id),
    #("name", "output-display"),
    #("value", value),
    #("hidden", "true"),
  ]
  let attrs = case checked {
    True -> [#("checked", ""), ..attrs]
    False -> attrs
  }
  h("label", [#("class", "tab")], [
    h("p", [], [text(label)]),
    h("input", attrs, []),
  ])
}

/// Renders a container for containing some output
pub fn output_container(id: String, class: String) -> Html {
  h("aside", [#("id", id), #("class", class)], [])
}
