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

in a real terminal. Set a provider key first (rook reads it from the
environment):

```
export ANTHROPIC_API_KEY=...      # or OPENAI_API_KEY, GEMINI_API_KEY, ...
```

With no key set, rook still runs on an offline mock so you can try the
interface; the status bar shows `(mock)`.

## Talking to it

- Type a message and press Enter. The reply streams in.
- The model uses tools as it works. Reading and searching happen
  automatically; a file write, edit, or shell command pauses for your
  approval: **y** to allow, **a** to allow every call of that kind for the
  rest of the turn, **n** to deny (the denial is fed back to the model).
- **Esc** interrupts; **ctrl+c** twice quits. **PageUp/PageDown** or the
  mouse wheel scroll.

## Choosing a model

Models are `provider/model` strings (aviary's format).

- `/model` opens a picker; arrow-select and Enter. Your choice is
  remembered for next time.
- `/model anthropic/claude-3-5-sonnet-latest` sets one directly.
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
(`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, and so on). If the
selected provider has no key, rook warns and falls back to the mock.

## Tools

The model can call:

- `read_file`, `list_dir`, `grep` (read-only, run automatically)
- `write_file`, `edit_file`, `run_command` (mutating, approved by you)

`run_command` runs through the platform shell in the working directory and
returns stdout, stderr, and the exit code. Tool output is truncated so a
noisy command cannot bury the answer.

## Commands

`/help`, `/clear` (wipe the conversation), `/model`, `/quit`.

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
  agent/             the turn loop, shared state, session, mock fallback
  tools/             file, search, and shell tools, plus the schema registry
  config/            model resolution, rook.json, the /model catalog
  ui/                the transcript renderer and theme
  commands.rv        slash-command parsing
```

## Development

```
rvpm test    # 39 tests: tools, config, commands, and end-to-end turns
             # (streaming, tool calls, and approval) against a local server
rvpm build
rvpm fmt
```

The end-to-end tests drive a full turn against an in-process server posing
as a model, so the suite needs no network and no keys.

## Known limits

Interrupting a single streamed reply takes effect when it finishes or at
the next tool step, not mid-stream (that awaits a cancel token in aviary).
grep is literal substring matching, not regex. One tool call runs at a
time.

## License

MIT
