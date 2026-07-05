# Changelog

## 0.3.1

- Replaced the welcome screen's ASCII wordmark with the rook logo drawn as colored terminal art, sized to the terminal.
- Trimmed the welcome screen's tips to the interrupt and quit hint.

## 0.3.0

- Added mouse selection: drag the transcript with the left button to select text, copied to the clipboard on release. You can scroll while dragging, and dragging past an edge extends the selection.
- Added a `/permissions` menu for toggling common tool grants in global user settings.
- Fixed the transcript freezing on long chats: rendered lines are cached per entry, so only changed entries re-wrap, and only the visible window is laid out each frame.
- Gave the welcome screen an ASCII rook wordmark.
- Redesigned the README with the logo banner, badges, a contents list, and an install guide.
- Capped skill, subagent, and MCP text before it enters the model context, so large sources cannot crowd it out.
- Dispatched the git tools (`git_status`, `git_diff`) properly instead of returning an unknown-tool error.

## 0.2.3

- Changed `git_commit` to commit only staged changes, and show the status, any untracked files (which are never committed), and the exact staged diff in the approval preview.

## 0.2.2

- Added workspace path normalization and boundary checks for file tools, previews, search roots, tree roots, and `@` mentions.

## 0.2.1

- Added timeout, cancellation handling, and a settings override for foreground `run_command` executions.
