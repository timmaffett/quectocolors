# Changelog

## 1.1.0

### Automatic ANSI Color Level Detection & Downgrade

- Make `write` exactly match the ansicolor package method
- Added `AnsiColorLevel` enum (`none`, `basic`, `ansi256`, `trueColor`) with a
  `supports()` method for checking capability tiers.
- Added `ansiColorLevel` — a mutable global that auto-detects the terminal's
  color capability from environment variables (`COLORTERM`, `TERM_PROGRAM`,
  `TERM`, `NO_COLOR`, `FORCE_COLOR`, `WT_SESSION`, `KONSOLE_VERSION`,
  `VTE_VERSION`, etc.).
- **Automatic downgrade:** RGB and 256-color methods now automatically
  downsample to the best supported level — true color falls back to 256-color
  (via `rgbToAnsi256`), 256-color falls back to the nearest basic ANSI color,
  and `AnsiColorLevel.none` produces identity (passthrough) closures.
- Dispatch is resolved once at first access via lazily-initialized top-level
  `final` function variables — zero per-call branching overhead, matching the
  library's "branch-on-creation" design philosophy.
- Platform detection: IO platforms inspect `stdout.supportsAnsiEscapes` and
  environment variables; web defaults to `trueColor`.

### Documentation

- Achieved **100% dartdoc coverage** (1236/1236 API elements).
- Added library-level doc comments to all three entry points (`quectocolors.dart`,
  `small.dart`, `supports_ansi_color.dart`) and the `ansipen.dart` barrel.
- Added doc comments to all style fields (`reset`, `bold`, `dim`, `italic`,
  `underline`, `overline`, `inverse`, `hidden`, `strikethrough`, `blink`,
  `rapidBlink`, `superscript`, `subscript`) in `QuectoPlain`, `QuectoColors`,
  and `QuectoColorsOnStrings`.
- Added doc comments to all dynamic color methods (`ansi256`, `bgAnsi256`,
  `onAnsi256`, `underlineAnsi256`, `rgb`, `bgRgb`, `onRgb`, `underlineRgb`)
  in both `QuectoPlain` and `QuectoColors`.
- Added class-level doc comments for `QuectoColors` and `QuectoPlain`.
- Added doc comments to `AnsiPen` class, constructor, all color/style methods,
  and all deprecated compatibility symbols.
- Added "Terminal Color Level Detection" section to README with enum table,
  usage examples, detection logic, and public symbols reference.
- Updated ChalkDart comparison table: "Color level downsampling" now "Yes".

## 1.0.3

- Added `blinking` and `rapidBlinking` aliases for `blink` and `rapidBlink`.

## 1.0.2
- Simplified import structure to three entry points: `quectocolors.dart`
  (everything), `small.dart` (core only), and `ansipen.dart` (AnsiPen compat).
  Removed redundant `basic.dart`, `extras.dart`, and `css.dart` — Dart's
  tree-shaker strips unused code, so the full import has no binary size penalty.
- Rounded out compatibility with ChalkDart:
- Added `blink` (SGR 5), `rapidBlink` (SGR 6), `superscript` (SGR 73), and
  `subscript` (SGR 74) to `QuectoPlain`, `QuectoColors`, and the string
  extensions.
- Added `on*` aliases for all `bg*` background colors on `QuectoPlain`,
  `QuectoColors`, and the string extensions: `onBlack`, `onRed`, `onGreen`,
  `onYellow`, `onBlue`, `onMagenta`, `onCyan`, `onWhite`, `onGray`/`onGrey`,
  and all bright variants.
- Added `onAnsi256()` and `onRgb()` method aliases.
- **Style aliases:** `normal` (reset), `underlined` (underline), `overlined`
  (overline), `invert` (inverse).
- **`brightXYZ` foreground aliases:** `brightRed`, `brightGreen`,
  `brightYellow`, `brightBlue`, `brightMagenta`, `brightCyan`, `brightWhite`,
  `brightBlack`.
- **`brightXYZ` background aliases:** `bgBrightRed`..`bgBrightBlack` and
  `onBrightRed`..`onBrightBlack`.
- **`visible`:** returns the string when ANSI is enabled, empty string when
  disabled.
- **Hex color methods:** `hex()`, `onHex()`, `bgHex()` — set foreground or
  background from hex values (`'#FF0000'`, `'FF0000'`, `'#F00'`, `0xFF0000`).
- **ANSI string extensions utilities:** `stripAnsi`, `ansiLength`,
  `lengthWithoutAnsi`.

## 1.0.1
- Explain quecto and fix import version in README.md

## 1.0.0

Initial release of QuectoColors — a high-performance ANSI terminal color
styling library for Dart with correct nested color support.

### Core Architecture

- All-static design using pre-computed `static final` closures for zero
  per-call allocation on the standard 16 ANSI colors and text styles.
- `createStyler()` central factory that builds closures with pre-cached close
  code bytes, pre-warmed StringBuffer, and unrolled `codeUnitAt()` ESC scanning
  for fast nested color detection and re-injection.
- Close code length branching (4 vs 5 chars) resolved at closure creation time,
  not per-call.

### Color Support

- **16 standard ANSI colors** — foreground, background, and bright variants
  (black, red, green, yellow, blue, magenta, cyan, white, gray/grey).
- **Text styles** — bold, dim, italic, underline, overline, inverse, hidden,
  strikethrough, and reset.
- **256-color xterm palette** — `ansi256()`, `bgAnsi256()`,
  `underlineAnsi256()` for foreground, background, and colored underlines.
- **16M true color RGB** — `rgb()`, `bgRgb()`, `underlineRgb()` for full
  24-bit color.
- **149 CSS/X11 named colors** — generated foreground, background, and
  underline color methods for all CSS/X11 named colors (e.g., `cornflowerBlue`,
  `onTomato`, `onAliceBlueUnderline`). Names that conflict with ANSI builtins
  are suffixed with `X11` (e.g., `greenX11`).
- **`rgbToAnsi256()` utility** — convert arbitrary RGB values to the nearest
  xterm 256-color index.

### API Styles

- **String extensions** (`'text'.red`, `'text'.bold.bgBlue`) — the most concise
  API, delegating to `QuectoColors` statics.
- **Static methods** (`QuectoColors.red('text')`) — useful for storing stylers
  in variables and passing as function references.
- **AnsiPen fluent interface** (`AnsiPen()..red()..bold`) — compatible with the
  `ansicolor` package's `AnsiPen` API including `rgb()`, `gray()`/`grey()`,
  `xterm()`, `down`, `up`, `write()`, `call()`, and cascade (`..`) syntax.
  *BUT UNLIKE the ansicolor package we properly support nesting of styles!*

### Plain Fast Path

- `QuectoPlain` provides zero-scan stylers that skip ESC byte scanning
  entirely — pure `'$openCode$string$closeCode'` interpolation for ~3x speedup
  on long strings when nesting is not needed.

### AnsiPen Compatibility

- Drop-in replacement for the `ansicolor` package — change
  `import 'package:ansicolor/ansicolor.dart'` to
  `import 'package:quectocolors/ansipen.dart'`.
- Exports `ansiColorDisabled`, `ansiEscape`, `ansiDefault`,
  `ansiResetForeground`, `ansiResetBackground`, and deprecated aliases
  (`color_disabled`, `ansi_esc`, `ansi_default`).
- `up`/`down` getters and `toString()` override for inline
  `'${pen}text${pen.up}'` usage.

### Platform Detection

- Automatic ANSI support detection via Dart conditional imports
  (`dart.library.io` checks `stdout.supportsAnsiEscapes`, web assumes true).
- Global `ansiColorDisabled` toggle to disable all color output.

### Nested Color Handling

- When a nested style's close code appears inside an outer style, the outer
  style is automatically re-injected — `('Hello ${"world".blue}!').red`
  correctly restores red after the blue text ends. Other Dart ANSI packages
  (ansicolor, colorize) do not handle this case.

### Package Structure

- Three import entry points:
  - `quectocolors.dart` — everything: core colors, styles, extras, and 149 CSS/X11 named colors.
  - `small.dart` — core only (QuectoColors, QuectoPlain, basic string extensions).
  - `ansipen.dart` — AnsiPen compatibility layer (import separately).
- Pure Dart package, no Flutter dependency.
- Inline SVG doc comments on all color fields for IDE color preview swatches.
