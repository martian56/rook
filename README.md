# rook

[![CI](https://github.com/martian56/rook/actions/workflows/ci.yml/badge.svg)](https://github.com/martian56/rook/actions/workflows/ci.yml)

A coding agent for the terminal, written in [Raven](https://github.com/martian56/raven).

rook streams a real model's reply token by token, and the model can read,
search, edit files, and run commands in your working directory, with you
approving anything that changes the repo. It is built on the
[plumage](https://github.com/martian56/plumage) TUI framework and the
[aviary](https://github.com/martian56/aviary) model gateway, so it speaks to
OpenAI, Anthropic, Gemini, and a dozen more providers behind one API.

The name: a rook is the raven's cousin, which is what this is to the Raven
language.

## Run it

```
rvpm run
```

in a real terminal, then give it an API key. Either export one:

```
export OPENROUTER_API_KEY=...     # or OPENAI_API_KEY, ANTHROPIC_API_KEY, ...
```

or type **`/key`** in the app and paste the key for the current provider. A
key entered that way is saved to `~/.rook/auth.json` and reused next time.
OpenRouter is the default provider, since one key there reaches most models.

## Talking to it

- Type a message and press Enter. The reply streams in.
- The model uses tools as it works. Reading and searching happen
  automatically; a file write, edit, or shell command pauses for your
  approval: **y** to allow, **a** to allow every call of that kind for the
  rest of the turn, **n** to deny (the denial is fed back to the model).
  A file change shows its diff right in the approval prompt, removals
  red, additions green, and again under the tool row once it runs, so
  you see exactly what changed.
- **Esc** interrupts; **ctrl+c** twice quits. **PageUp/PageDown** or the
  mouse wheel scroll.

## Choosing a model

Models are `provider/model` strings (aviary's format).

- `/model` opens a picker with a search bar: type to filter the
  catalog (the mid-2026 flagships and the models topping the OpenRouter
  usage charts), arrow-select and Enter. Your choice is remembered for
  next time.
- `/model anthropic/claude-sonnet-5` sets one directly; any
  `provider/model` string aviary can route works, listed or not.
- The startup model is resolved in order: the `--model` flag
  (`rvpm run -- --model openai/gpt-4o`), `ROOK_MODEL`, a project
  `rook.json`, a global `~/.config/rook/rook.json`, the last model you
  picked, then a built-in default.

`rook.json` is a small JSON file:

```json
{ "model": "openai/gpt-4o", "base_url": "" }
```

`base_url` (or `ROOK_BASE_URL`) points at any OpenAI-compatible endpoint,
for a local or self-hosted model.

The provider's key comes from its environment variable
(`OPENROUTER_API_KEY`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, and so on), or
from a key you entered with `/key` (stored in `~/.rook/auth.json`). Picking a
model whose provider has no key opens the key prompt automatically.

## Tools

The model can call:

- `read_file`, `list_dir`, `grep` (read-only, run automatically)
- `write_file`, `edit_file`, `run_command`, `run_background` (mutating,
  approved by you)

`run_background` starts a long-running command (a dev server, a
watcher, an app rook just built) and returns a shell id immediately
instead of blocking; the output collects in the background. The model
follows up with `read_shell` (what a shell printed since its last
look), `list_shells` (status, runtime, and command of each), and
`kill_shell` (stop one; this asks for approval). So rook can start the
app it just built, watch the log, and react to what it sees. Stored
output is capped so a chatty process cannot grow memory without bound,
old finished shells fall off the list, and quitting rook kills
everything still running so no child is orphaned.

When a decision is yours to make (which approach, which of several
fixes), the model asks with `ask_user`: a modal shows the question and
its options, arrows pick, Enter answers, Esc declines. The pick goes
back to the model as text.

`run_command` runs through the platform shell in the working directory and
returns stdout, stderr, and the exit code. Tool output is truncated so a
noisy command cannot bury the answer.

## Commands

Type `/` and a menu of every command opens above the input, filtered as
you keep typing: arrow keys move the highlight, **Tab** completes the
name, **Enter** runs the selection, **Esc** dismisses. Custom commands
from `.agents/commands/` appear right in the menu.

`/shells` opens a panel of the background shells, id, status with
runtime or exit code, and command, refreshed live while it is open.
Enter tails the highlighted shell: a full-screen pane follows its
output as it is produced, so a dev server or build log is readable
while rook keeps working. Esc steps back.

`/help` opens the same list as a menu: arrows to browse every command
(built-in and custom) with its description, Enter to run one, Esc to
close. The other built-ins: `/clear` (wipe the conversation), `/model`,
`/theme` (pick a color theme; arrow keys preview it live, and the
choice is remembered), `/key` (set the current provider's API key),
`/quit`.

Built-in themes: Rook and Rook Light, Dracula, Gruvbox Dark and Light,
Nord, Solarized Dark and Light, Catppuccin Mocha and Latte, Tokyo Night.
`/theme nord` sets one directly. With no theme chosen yet, rook starts
with the dark or light default matching the terminal background (read
from `COLORFGBG` where the terminal sets it). On terminals without
truecolor, theme colors are downsampled to the 256-color cube or the
basic 16, judged from `COLORTERM` and `TERM`.

Your own palettes go in `.agents/themes/<name>.json` (project or
global) and appear in the picker alongside the built-ins:

```json
{
  "name": "Midnight",
  "accent": "#7aa2f7",
  "dim": "#565f89",
  "text": "#c0caf5",
  "tool": "#9ece6a",
  "warn": "#e0af68",
  "error": "#f7768e"
}
```

Six colors define a palette; rook maps them onto every UI element the
same way it does for the built-ins. A palette whose name collides with
an existing theme is skipped.

## Skills and memory

rook reads the cross-agent `.agents` layout: a project `./.agents` and a
global `~/.agents`, with project entries winning. A skill is a folder
`.agents/skills/<name>/` holding a `SKILL.md`, frontmatter with a `name`
and one-line `description`, then a markdown body of instructions. The
model sees an index of skill names and descriptions in its system
prompt, and pulls in a skill's full instructions with the `use_skill`
tool when one matches the task (shown in the transcript like any other
tool call).

An `AGENTS.md` in the working directory (the cross-tool memory file:
build steps, tests, conventions) is loaded into the system context on
every turn, along with a global `~/.agents/AGENTS.md` for your own
standing notes. The global file comes first so the project one can
refine it.

`.agents/settings.json` (project or global) configures rook alongside
`rook.json`:

```json
{
  "model": "openai/gpt-4o",
  "theme": "Nord",
  "base_url": "",
  "permissions": {},
  "tools": {},
  "mcp": {}
}
```

The string fields join the resolution chain (a root's `rook.json` wins
over the same root's settings, and project beats global). The object
sections are reserved for the permission rules, tool config, and MCP
servers that will read them.

Custom slash commands live in `.agents/commands/<name>.md`: optional
frontmatter with a `description` (shown by `/help`), then a prompt
template. `/name args` sends the template with `$ARGUMENTS` replaced by
`args` (or the args appended when the template has no placeholder). The
transcript shows what you typed; the model gets the expansion. Built-in
commands cannot be overridden.

## Subagents

Three come built in, all read-only: **explorer** (scout the codebase
and report), **reviewer** (critique code and list real defects), and
**planner** (produce a step-by-step plan). Ask rook to "have the
explorer find where X happens" and it delegates.

Define your own in `.agents/subagents/<name>.md`: frontmatter with a
`description`, an optional `tools` allowlist (comma-separated; omitted
means every tool), and an optional `model` override, then the agent's
system prompt as the body. The model sees the roster in its system
prompt and delegates with the `dispatch` tool; the subagent runs an
isolated conversation (its own prompt, tools, and rounds) and only its
final answer returns to the main conversation. While it works, its
activity shows as a live nested block in the transcript, a `◆ name
agent working…` header with the agent's tool calls indented beneath it
(parallel agents each keep their own block), and when it finishes the
block collapses to one `done · N tools` line ahead of the result.
Anything mutating still stops for your approval, labeled with the
agent's name (parallel agents queue for the prompt one at a time).
Subagents cannot dispatch further agents. A definition named after a
built-in replaces it.

When the model dispatches several agents in one step they run in
parallel, each on its own goroutine with its own conversation, and the
main agent continues once every result is back, wide read-only work
like searching three areas at once finishes in one round.

## How it is built

rook is a plumage app. The one interesting problem is that a streamed
completion blocks, while the UI must keep drawing: each turn runs on a
background goroutine that emits an ordered log of display events and owns
the conversation, guarded by a mutex; the plumage loop drains and replays
that log every tick. Approval is a one-slot channel the goroutine blocks
on while the UI renders the prompt.

```
src/
  main.rv            entry: build the app and run it
  app/               model, update (events, keys, approvals), view
  agent/             the turn loop, shared state, session
  agents/            the .agents folder loader (skills, commands, settings)
  tools/             file, search, and shell tools, plus the schema registry
  config/            model resolution, rook.json, the /model catalog
  ui/                the transcript renderer, theme, and spinner
  commands.rv        slash-command parsing
```

## Development

```
rvpm test    # 42 tests: tools, config, commands, and end-to-end turns
             # (streaming, tool calls, and approval) against a local server
rvpm build
rvpm fmt
```

The end-to-end tests drive a full turn against an in-process server posing
as a model, so the suite needs no network and no keys.

## Known limits

grep is literal substring matching, not regex. A subagent's own request
(non-streaming) stops at its next tool round rather than mid-flight.

## License

MIT
