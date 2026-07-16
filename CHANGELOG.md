# Changelog

## 0.3.31

- Prepared the cumulative release of Rook's recent safety, reliability, workflow, MCP, plugin, and developer-experience improvements.

## 0.3.30

- Added deterministic behavior evals for planning, verification, permissions, instruction conflicts, and commit safety.

## 0.3.29

- Applied per-server MCP environment variables on Windows and surfaced invalid entries without exposing their values.

## 0.3.28

- Made hook launch failures visible and added per-hook fail-closed behavior for pre-tool guards.

## 0.3.27

- Made plugin installs and updates transactional so failed replacements leave the working plugin in place.

## 0.3.26

- Added quoted strings, typed JSON values, and visible parse errors to `/mcp prompt` arguments.

## 0.3.25

- Limited concurrent background shells to five by default, with a configurable maximum and actionable refusal message.

## 0.3.24

- Added mutation previews to subagent approvals and successful subagent tool results.

## 0.3.23

- Preserved manual transcript scrolling while a turn is active and resumed live tail after scrolling back to the bottom.

## 0.3.22

- Added total character and file-count budgets for `@` file mention attachments with an omitted-files notice.

## 0.3.21

- Added structured `ask_user` options with array/object parsing while keeping comma-separated options as a fallback.

## 0.3.20

- Skipped common build, dependency, cache, and VCS directories during grep unless the ignored directory is searched directly.

## 0.3.19

- Reported session save, list, and load failures instead of silently dropping persistence errors.

## 0.3.18

- Counted subagent model calls in turn and session token totals, including parallel dispatches.

## 0.3.17

- Surfaced malformed plugin marketplace index JSON and fetch failures instead of treating them as an empty index.

## 0.3.16

- Reported plugin removal failures when recursive deletion commands fail or the plugin directory remains on disk.

## 0.3.15

- Reported ambiguous MCP resource URIs instead of reading from the first matching server when `server` is omitted.

## 0.3.14

- Detected colliding MCP tool names after sanitization and skipped ambiguous tools instead of exposing duplicate provider-facing names.

## 0.3.13

- Added an explicit instruction hierarchy to the system prompt and labeled project guidance, skills, subagents, and shell state as lower-priority context.

## 0.3.12

- Rejected unsafe plugin manifest names with the same validation used for plugin install, remove, and update paths.

## 0.3.11

- Preserved original tool-call order when parallel subagent dispatches finish out of order.

## 0.3.8

- Ran pre-tool and post-tool hooks for subagent tool calls, including the subagent name in hook context.

## 0.3.7

- Prevented malformed `auth.json` files from being overwritten during API key saves and surfaced config persistence errors in the UI.

## 0.3.6

- Required approval before `web_fetch` can read hostnames, localhost, private network, link-local, shared-address, benchmark, or metadata targets.

## 0.3.5

- Failed closed for permission checks when an existing `.agents/settings.json` file is invalid or unreadable.

## 0.3.4

- Surfaced invalid or unreadable `.agents/settings.json` files as startup notices instead of silently ignoring them.

## 0.3.3

- Rejected unsafe plugin names before remove and update commands resolve plugin paths.

## 0.3.2

- Rejected unsafe plugin install directory names before cloning or deleting plugin paths.

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
