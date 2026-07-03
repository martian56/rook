# rook

A coding agent for Raven, built from the shell inward. rook is the
terminal face of the agent: a conversation transcript with tool call
lines, a thinking spinner with a token count, an input box, interrupt
handling, and a status bar, all rendered flicker-free by
[plumage](https://github.com/martian56/plumage).

The brain is mocked for now. mock.rv rotates through a handful of canned
replies, some with a fake tool step in front, and the spinner just counts
ticks. Nothing leaves the process. The interface is the part that is
finished; wiring a real model and real tool execution into `_submit` and
`_finish` is the roadmap, starting with the aviary gateway library.

The name: a rook is the raven's cousin, which is exactly what this is to
the Raven language.

## Run it

```
rvpm run
```

in a real terminal (it exits politely when stdin is a pipe).

## Using it

- Type in the box and press Enter. The spinner thinks for about a second,
  then the answer lands in the transcript.
- Esc interrupts an answer while it is thinking.
- ctrl+c once arms the exit, twice quits.
- PageUp, PageDown, or the mouse wheel scroll the transcript.
- `/help`, `/clear`, and `/quit` work as commands.

## How it is put together

- `src/main.rv`: the plumage app. The `Chat` model holds the transcript,
  the input, and the thinking countdown; `update` is the only place any of
  it changes; `view` rebuilds the whole screen from the model every frame.
- `transcript.rv`: turns entries into styled, wrapped display lines. All
  the visual identity lives in `build_lines`.
- `mock.rv`: the stand-in model, its thinking verbs, and the spinner
  frames. This is the file a real backend replaces.

## Roadmap

- Swap mock.rv for a real model client over `std/http`, streaming replies
  into the transcript as they arrive.
- Execute real tools (shell, file reads, greps) and render their output
  under the tool bullets.
- Sessions: persist and reload transcripts.

## License

MIT
