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
up to Bspc and Space: Cmd is held rather than tapped, so it tolerates the worse
position, and keys tapped once per conversion in Japanese do not.

Bspc, Ctrl, Cmd, Tab, Alt, Esc and both Shifts are plain keys. Only two keys
carry a layer, and both are the ones a thumb rests on: **Enter on the left
holds Nav**, **Space on the right holds Sym**, and holding both gives Mac.
Whichever layer the left thumb holds is also the one that makes the trackball
scroll, since that leaves the whole right hand free for the ball.

That is what lets Sym and Nav put a full ten-key row under the fingers — a
thumb hold leaves all ten free, where a finger-held layer key blocks its own
column. It is also why `Tab`, `Alt` and `Esc` got plain keys back.

Nav rides on Enter rather than Bspc. Holding one of these keys after a pause
gives its layer rather than a repeat, which costs nothing on Enter — nobody
holds it — but broke Bspc, where holding to repeat a delete is the whole point.

Shortcuts whose chord never varies get a single key on a layer instead of a
layer-plus-modifier pile — Spotlight, input-source switch, `⌘1`–`⌘3`,
`⌘⌥←`/`⌘⌥→` for browser tabs and `⌃←`/`⌃→` for macOS spaces. The Emacs-style
cursor chords (`^P` `^N` `^B` `^F` `^A` `^E` `^H` `^D` `^K`) stay real Ctrl
chords, since they are used while typing.

`^Space` — the input-source switch — is a plain chord again now that Ctrl is on
the left thumb and Space on the right: one thumb each. It spent a while unable to
be pressed at all, because both shared the left thumb; the first attempt at
working around that was a combo on the two left thumb keys, which was a mistake.
A key in a combo has its press captured, so every space was delayed, and a
slightly wide thumb press switched the input source instead of typing one. The
dedicated key on Nav stays as well.

### Layers

| # | Name | Entered by | Contents |
|---|------|-----------|----------|
| 0 | Base | — | US alpha block, `-` and `/` on the right pinky column |
| 1 | Mouse | trackball movement (`automouse-layer`) | click cluster on the right home row |
| 2 | Nav | left thumb (Enter) held | number row, arrows on `hjkl`, page/line jumps; also `scroll-layers` |
| 3 | Sym | right thumb (Space) held | symbol row, digits beneath it |
| 4 | Mac | both thumbs held together | F-keys, Bluetooth, bootloader, occasional app shortcuts |
| 5 | Snipe | left index held on the Mouse layer | trackball precision (`snipe-layers`) |

A thumb holds each of these layers, so each can carry a full ten-key row across
the top. The **left** thumb (Enter) gives the digits, the **right** thumb (Space)
the symbols above them, in the same columns either way:

```
Nav, left thumb    1  2  3  4  5      6  7  8  9  0

Sym, right thumb   !  @  #  $  %      ^  &  *  (  )
                   1  2  3  4  5      6  7  8  9  0
                   `  =  \  [  ]      {  }  ;  :  '
```

Sym keeps a digit row of its own one row down, so a number is reachable from
either thumb.

Shift covers what is left: `~` from `` ` ``, `+` from `=`, `|` from `\`, `"`
from `'`, and on the base layer `_` from `-` and `?` from `/`.

Twenty-six letters plus `,` and `.` fill 28 of the 30 alpha keys, so the right
pinky column has exactly two slots for punctuation and three candidates. `-`
takes one — it types the Japanese long vowel mark and turns up about as often as
a letter — and `/` the other. `;` is the one that loses: it and `:` sit on the
Sym layer next to each other, so each is a thumb hold plus a key rather than a
hold plus Shift plus a key. `_` needs no key of its own, being Shift and `-`.

What that extra row displaced from Nav — screenshots, DevTools, force quit,
browser history, same-app window switching, mute and play — moved to the Mac
layer, whose left hand was empty.

The Mouse layer is the one layer no key can dismiss: `pmw3610.c` deactivates it
from a `k_timer` and nowhere else, so it stays on for
`CONFIG_PMW3610_AUTOMOUSE_TIMEOUT_MS` after the ball stops moving — and it puts
mouse buttons on the right home row. That window is time in which `h`, `j`, `k`
or `l` comes out as a click, which is why the timeout is kept short (400ms)
rather than generous.

The Nav arrows sit on `h j k l` — the keys and fingers Vim uses, h included as
the index stretch. The **left** thumb holds the layer, so the arrows are a
cross-hand reach rather than the same hand doing both. Shift and Cmd stay
transparent on Nav so that shift-arrow and cmd-shift-arrow keep selecting text.

Space, Bspc and Enter all sit under a thumb, which is what Japanese input wants
— space to convert, Enter to commit, Bspc to fix. Cmd took the bottom-row
position they needed: it is held rather than tapped, so it tolerates the worse
spot. Space sits on the right thumb and Enter on the left, so convert and commit
alternate hands.

Space being a layer-tap is the one place the layout accepts real risk, and it
uses `tap-preferred` for it: no other keypress can turn its tap into a hold, so
a space never goes missing however fast the next letter follows. The trade is
that reaching Sym means holding Space for the full tapping term.

Layers 1, 2 and 5 are also referenced by the trackball in
`config/boards/shields/LiNEA40/LiNEA40_right.overlay`; keep the two in sync
when renumbering.

## Pinned dependencies

`config/west.yml` pins every project to something immutable — a tag for ZMK and
for the RGB widget, a commit for the PMW3610 driver, which publishes no tags.
The driver was tracking `main`, and this keymap leans on details of its
behaviour: `automouse-layer` only refreshes while the input mode is MOVE, and
`scroll-layers` and `snipe-layers` are matched against the highest active layer
only. Those are the sort of things that can change in a driver without anything
changing here.

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
