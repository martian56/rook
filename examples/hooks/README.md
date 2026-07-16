# Example hooks

Three hooks that show what the system can do. Each is a small POSIX shell
script rook runs on a lifecycle event, reading a JSON context on stdin:

```json
{ "event": "pre-tool", "tool": "run_command", "args": "{\"command\":\"...\"}" }
```

`args` is the tool call's raw arguments (itself a JSON string).

| Script | Event | Match | What it does |
|--------|-------|-------|--------------|
| `deny-dangerous.sh` | `pre-tool` | `run_command` | Exits non-zero to **block** a command matching a dangerous pattern (`rm -rf /`, `mkfs`, a fork bomb, ...). The message goes back to the model as the reason. |
| `format-on-edit.sh` | `post-tool` | `write_file`, `edit_file` | Re-formats the file rook just touched (`rvpm fmt`). Reads the path from the context with `jq`; without `jq` it formats the whole project. |
| `notify-turn-end.sh` | `turn-end` | (all) | Posts a desktop notification when a turn ends, via `notify-send`, `osascript`, a PowerShell beep, or the terminal bell. |

## Enabling them

Copy the `hooks` block from `settings.json` here into a `settings.json`
at a root rook reads:

- `.agents/settings.json` in your project (project-scoped), or
- `~/.agents/settings.json` (every session), or
- inside a plugin bundle, so installing the plugin ships the hooks.

The example paths (`sh examples/hooks/...`) assume you run rook from this
repository. Point them at wherever you keep the scripts.

## Notes

- Only `pre-tool` hooks can block; every other event is observe-only, so
  their exit codes are ignored.
- Hook launch failures produce one notice per command and error. They fail
  open unless a `pre-tool` hook sets `"fail_closed": true`.
- `match` is a glob on the tool name and applies only to the tool events
  (`pre-tool`, `post-tool`); omit it, or use `*`, to match every tool.
- On Windows the command runs through `cmd`, so invoke these `.sh`
  scripts with `sh` (from Git Bash), or write `.cmd` equivalents.
- A hook command runs synchronously on the turn's goroutine, so keep it
  quick; a slow hook slows the turn.
