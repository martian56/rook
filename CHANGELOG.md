# Changelog

## 0.3.48

- Opening /sessions and resuming a session run off the UI thread, so the panel appears immediately with a loading line and switching sessions no longer stalls while reading and parsing session files. (#265)
- The transcript window is built by skipping the entries above the visible area instead of counting every line from the top of the history, so scrolling and streaming stay smooth in long conversations. The status-bar price table is built once at startup rather than on every frame. (#266)
- A turn builds its tool schemas once instead of rebuilding all of them, and re-parsing every MCP tool's schema, on every round, in both the main turn and subagent turns. (#267)
- The system prompt no longer repeats tool descriptions that the tool schemas already carry, trimming duplicated instruction from every request while keeping the workflow guidance. (#268)

## 0.3.47

- /plugins add, update, and browse, and /mcp prompt, run on a background goroutine instead of freezing the UI while they reach the network or clone a repository. Their results arrive as notices when ready, and a fetched prompt starts its turn once it lands. (#254)
- Plugin manifests are read once and cached for the process instead of re-parsed on every turn round, tool check, and hook fire. The cache is dropped when a plugin is installed, removed, or updated. (#256)
- The skills, subagents, and memory portion of the system prompt is assembled once per turn rather than rebuilt for every round. (#257)
- The background-shells panel refreshes on a tick cadence while it is open instead of on every frame, so a running command's output no longer costs several subprocess polls per redraw. (#255)
- Sending a message checks the already-loaded key instead of re-reading and parsing the auth file each time. (#258)

## 0.3.46

- Opening /sessions no longer parses every saved session's full transcript. Each session writes a small metadata sidecar that the picker reads instead, falling back to the full file only for sessions saved before this. (#252)

## 0.3.45

- Stabilized the Windows MCP launcher streaming test, which occasionally failed on a transient subprocess-startup hiccup, by retrying a few times and requiring one clean run. (#242)

## 0.3.44

- edit_file and multi_edit refuse an edit when old_text appears more than once, asking for a more specific snippet, instead of silently changing the first occurrence (which may be the wrong one). (#239)

## 0.3.43

- Copying a mouse selection maps display columns to byte offsets, so text on a line with a marker glyph or other non-ASCII characters is copied correctly instead of shifted. (#231)

## 0.3.42

- A malformed rook.json is reported as a startup notice instead of being silently ignored, so a typo in the config no longer falls back to defaults with no explanation. (#235)

## 0.3.41

- A change that only adds or removes a file's trailing newline now says so, instead of showing a diff with content but no highlighted change. (#241)
- The diff caps its work while building, so replacing a very large file's entire contents no longer materializes the whole diff before trimming it to the display cap. (#240)
- A failed fresh plugin install no longer claims the previous plugin was restored when there was none. (#237)

## 0.3.40

- Esc now aborts a running parallel-dispatch batch: each subagent request carries the turn's cancel token, so pressing Esc cancels the in-flight calls instead of waiting out their timeouts. (#229)
- Two dispatches of the same subagent name keep separate transcript blocks, matched by the dispatch id, so one no longer collapses and removes the other's rows. (#230)

## 0.3.39

- git_diff confines its path argument to the workspace like the other file tools, instead of handing a raw path to git. (#233)
- resolve_path rejects Windows reserved device names (con, nul, com1, and so on), so read_file or write_file on one no longer hangs or silently discards data on Windows. (#234)

## 0.3.38

- MCP: a server connection is used under a per-connection lock and matches each response to its request id, so parallel subagents calling the same server no longer swap or drop results, and a late reply after a timeout is discarded instead of answering the next call. (#228)
- MCP: connecting publishes the client list in one step and hands out a copy, so a turn during a background connect sees either no servers or all of them, never a half-connected list. (#236)

## 0.3.37

Correctness and safety fixes from a full audit of the codebase:

- multi_edit now obeys path-scoped permission rules like edit_file and write_file; before, a deny or allow rule targeting a path never applied to it.
- A pre-tool guard hook that exits non-zero with "access is denied" in its message is treated as a real block again, not misread as a launch failure that fails open and runs the tool.
- Answering an approval or question clears the prompt immediately, closing a race where a tick could re-show the answered prompt and a second keypress could silently approve the following tool.
- Esc pressed while the model is streaming a tool request now stops the batch before it runs, so a tool pre-approved earlier in the turn no longer executes after you ask to stop.
- Tool arguments sent as a bare JSON number or boolean (id 3, staged true, depth 5) are coerced to text instead of being read as empty.
- A glob deny rule whose trailing literal repeats, like write_file(*.env) against a.env.env, now matches at the end instead of silently missing.
- base_url resolves through the global ~/.config/rook/rook.json, the same chain model and theme already used.
- The welcome screen no longer nags about a missing API key for the keyless custom provider.
- Session titles and truncated memory no longer split a UTF-8 character.
- A subagent on a Sakana model gets the same two-hour timeout the main turn uses instead of failing at 120s.
- MCP server subprocesses are shut down on quit instead of being left running.

## 0.3.36

- Fixed the `file_tree` tool: it was offered to the model but never wired to run, so calling it returned "unknown tool". It now executes.
- `read_shell` waits briefly for a just-started shell's first output, so reading a dev server right after starting it returns its startup lines (including the URL) instead of nothing.
- Told the model its operating system and which shell `run_command` uses, so it stops sending POSIX syntax to cmd.exe on Windows.

## 0.3.35

- Added `rook --version` (and `-V`) to print the installed version, and showed it on the welcome screen. The version is kept in step with rv.toml by a test.

## 0.3.34

- Fixed the streaming stutter on long replies: incoming text is folded into the transcript once per frame instead of rebuilding the whole reply on every delta.
- Moved the end-of-turn session save onto a background thread, so finishing a turn no longer hitches while the transcript is written to disk.
- Cached the project file list the `@` picker searches, so typing a file path no longer re-walks the tree on every keystroke.
- Built the theme list once when the picker opens instead of reading theme files from disk on every frame.
- Cached the welcome-screen logo so it is rasterized once per width rather than on every frame.

## 0.3.33

- Made the `/model` picker responsive by building its catalog once and filtering the cached copy, instead of rebuilding and re-labeling the whole model list on every frame.

## 0.3.32

- Imported the OpenRouter model catalog and kept it refreshable from a sync script.
- Added direct Sakana Fugu support and accepted every Aviary provider credential.
- Expanded the built-in catalog of direct provider models.
- Showed tool support in the model picker with capability labels, and preserved OpenRouter tool capabilities.
- Updated Aviary to 0.3.1.

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
