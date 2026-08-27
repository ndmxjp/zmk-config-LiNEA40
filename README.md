# zmk-config-LiNEA40

ZMK firmware configuration for **LiNEA40** — a 40-key split keyboard on two
Seeeduino XIAO BLE controllers, with an EC11 encoder on the left half and a
PMW3610 trackball on the right. Both sit in the bottom row, which is why that
row carries five keys per half rather than six.

The keymap targets **macOS with a US input source**.

## Keymap cheat sheet

![LiNEA40 keymap](keymap-drawer/LiNEA40.svg)

Generated from `config/LiNEA40.keymap` by
[keymap-drawer](https://github.com/caksoylar/keymap-drawer) — see
[Regenerating](#regenerating-the-cheat-sheet) below.

### How the modifiers are placed

Ctrl sits on the **left** thumb, because its common partners are right-hand
letters: `^P`, `^N`, `^H`, `^K`. Cmd wants the mirror of that — `⌘C`, `⌘V`,
`⌘X`, `⌘Z`, `⌘A`, `⌘S`, `⌘W`, `⌘Q`, `⌘T`, `⌘F` are all left-hand — so it sits
on the **right** hand, on the bottom-row middle finger. It gave the right thumb
up to Enter: Cmd is held rather than tapped, so it tolerates the worse position
and Enter, tapped once per conversion in Japanese, does not.

Space, Enter, Ctrl, Cmd and both Shifts are plain keys. Only three keys carry a
layer on their hold — `Tab/Opt`, `Bspc/Nav` and `Esc/Sym` — and the Mac layer
has no key of its own at all: it comes up when Nav and Sym are held together.

Shortcuts whose chord never varies get a single key on a layer instead of a
layer-plus-modifier pile — Spotlight, input-source switch, `⌘1`–`⌘3`,
`⌘⌥←`/`⌘⌥→` for browser tabs and `⌃←`/`⌃→` for macOS spaces. The Emacs-style
cursor chords (`^P` `^N` `^B` `^F` `^A` `^E` `^H` `^D` `^K`) stay real Ctrl
chords, since they are used while typing.

`^Space` cannot be pressed as a chord — Ctrl and Space share the left thumb —
so it has its own key on the Nav layer. It was a combo on both thumb keys at
first, which was a mistake: a key in a combo has its press captured, so every
space was delayed, and a slightly wide thumb press switched the input source
instead of typing one.

### Layers

| # | Name | Entered by | Contents |
|---|------|-----------|----------|
| 0 | Base | — | US alpha block, `-` on the right pinky home key |
| 1 | Mouse | trackball movement (`automouse-layer`) | click cluster on the right home row |
| 2 | Nav | right thumb (Bspc) held | arrows on `hjkl`, page/line jumps, app shortcuts |
| 3 | Sym | left middle **or** right ring held | numbers and symbols; also `scroll-layers` |
| 4 | Mac | Nav **and** Sym held together | F-keys, Bluetooth, bootloader |
| 5 | Snipe | left index held on the Mouse layer | trackball precision (`snipe-layers`) |

Layer 3 has two entry points, one per hand, so it shows different halves
depending on which hand holds it — brackets from the right, numbers from the
left.

The right pinky home key is `-` rather than `;`, because it types the Japanese
long vowel mark and turns up about as often as a letter. `;` drops a row (Shift
still gives `:`) and `/` lives on the Sym layer.

The Nav arrows sit on `h j k l` — the keys and fingers Vim uses, h included as
the index stretch. A thumb holds the layer, so the whole right hand stays free
for them, and the left hand keeps the app shortcuts.

Space and Enter both sit under a thumb, which is what Japanese input wants —
space to convert, Enter to commit. Cmd took the bottom-row position Enter gave
up: it is held rather than tapped, so it tolerates the worse spot.

Layers 1, 3 and 5 are also referenced by the trackball in
`config/boards/shields/LiNEA40/LiNEA40_right.overlay`; keep the two in sync
when renumbering.

## Building

Firmware is built by GitHub Actions on every push; download the `firmware`
artifact from the run and flash the `.uf2` files. Studio is enabled on the
right (central) half only.

### If flashing appears to change nothing

Studio brings `ZMK_KEYMAP_SETTINGS_STORAGE` with it
(`ZMK_STUDIO_RPC` selects it), which makes the keymap live in the board's
settings partition. `keymap.c` loads that over the compiled-in keymap at boot,
so once a keymap has been saved from Studio it wins over every later flash —
the new firmware goes on and the old keymap keeps running.

Flash the `settings_reset` build to **both** halves first, then flash the real
firmware. That clears Bluetooth pairings too, so unpair the keyboard on the
host and let the halves find each other again afterwards.

Two other things worth knowing when a key behaves unexpectedly:

- The central half holds the whole keymap; the peripheral only reports key
  positions. Flashing only the left half changes nothing about the keymap.
- The bottom row moved a lot from the pre-macOS keymap — Space and Backspace in
  particular swapped halves — so an old muscle-memory press lands somewhere
  genuinely different rather than on a broken key.

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
