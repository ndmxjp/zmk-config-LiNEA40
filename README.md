# zmk-config-LiNEA40

ZMK firmware configuration for **LiNEA40** — a 41-key split keyboard on two
Seeeduino XIAO BLE controllers, with an EC11 encoder on the left half and a
PMW3610 trackball on the right.

The keymap targets **macOS with a US input source**.

## Keymap cheat sheet

![LiNEA40 keymap](keymap-drawer/LiNEA40.svg)

Generated from `config/LiNEA40.keymap` by
[keymap-drawer](https://github.com/caksoylar/keymap-drawer) — see
[Regenerating](#regenerating-the-cheat-sheet) below.

### How the modifiers are placed

Ctrl sits on the **left** thumb and Cmd on the **right** thumb, because their
common partners live on the opposite hand: `^P`, `^N`, `^H`, `^K` are
right-hand letters, while `⌘C`, `⌘V`, `⌘X`, `⌘Z`, `⌘A`, `⌘S`, `⌘W`, `⌘Q`,
`⌘T`, `⌘F` are left-hand letters. Every common chord therefore spans both
hands.

Space, Ctrl, Cmd and both Shifts are plain keys. Hold-taps are confined to
four keys that never appear mid-word: `Tab/Opt`, `Esc/Mac`, `Bspc/Nav` and
`Enter/Mac`.

Shortcuts whose chord never varies get a single key on a layer instead of a
layer-plus-modifier pile — Spotlight, input-source switch, `⌘1`–`⌘3`,
`⌘⌥←`/`⌘⌥→` for browser tabs and `⌃←`/`⌃→` for macOS spaces. The Emacs-style
cursor chords (`^P` `^N` `^B` `^F` `^A` `^E` `^H` `^D` `^K`) stay real Ctrl
chords, since they are used while typing.

`^Space` is the one chord the layout cannot express directly — Ctrl and Space
share the left thumb — so it is a combo on both left thumb keys at once.

### Layers

| # | Name | Entered by | Contents |
|---|------|-----------|----------|
| 0 | Base | — | US alpha block |
| 1 | Mouse | trackball movement (`automouse-layer`) | click cluster on the right home row |
| 2 | Nav | right thumb (Bspc) held | arrows, browser tabs, macOS spaces |
| 3 | Sym | left index **or** right ring held | numbers and symbols; also `scroll-layers` |
| 4 | Mac | left middle **or** right middle held | app shortcuts, F-keys, Bluetooth |
| 5 | Snipe | `&tog` from the Mac layer | trackball precision (`snipe-layers`) |

Layers 3 and 4 each have two entry points, one per hand, so one layer shows
different halves depending on which hand holds it — brackets versus numbers,
and app shortcuts versus F-keys.

Layers 1, 3 and 5 are also referenced by the trackball in
`config/boards/shields/LiNEA40/LiNEA40_right.overlay`; keep the two in sync
when renumbering.

## Building

Firmware is built by GitHub Actions on every push; download the `firmware`
artifact from the run and flash the `.uf2` files. Studio is enabled on the
right (central) half only.

To build locally against a ZMK tree in a dev container:

```sh
make build container_name=<your container>
```

## Regenerating the cheat sheet

```sh
make draw
```

This creates a local virtualenv (`.venv-keymap-drawer/`, git-ignored) and
rewrites `keymap-drawer/LiNEA40.yaml` and `keymap-drawer/LiNEA40.svg`. Drawing
settings live in `keymap_drawer.config.yaml`. Run it after editing the keymap
and commit the result.
