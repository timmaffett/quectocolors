# QuectoColors

[![Pub](https://img.shields.io/pub/v/quectocolors.svg)](https://pub.dartlang.org/packages/quectocolors)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://flutterawesome.com/console-terminal-text-coloring-and-styling-library-for-dart)
[![License](https://img.shields.io/badge/License-BSD%203.0-blue.svg)](/LICENSE)
[![GitHub contributors](https://img.shields.io/github/contributors/timmaffett/quectocolors)](https://github.com/timmaffett/quectocolors/graphs/contributors)
[![GitHub forks](https://img.shields.io/github/forks/timmaffett/quectocolors)](https://github.com/timmaffett/quectocolors)
[![GitHub stars](https://img.shields.io/github/stars/timmaffett/quectocolors?)](https://github.com/timmaffett/quectocolors)

A high-performance ANSI terminal color styling library for Dart and Flutter with **correct nested color support**.

QuectoColors provides multiple API styles for applying colors, text styles, and background colors to terminal output. Unlike other Dart ANSI color packages, QuectoColors properly handles nested colors — when you write `('Hello ${"world".blue} outside!').red`, the red color is correctly restored after the blue text ends.

## Features

- **Full color range** — standard 16 colors, 256-color xterm palette, 16M true color (24-bit RGB), and 149 named CSS/X11 colors
- **Correct nested color handling** — parent colors are automatically restored after inner styles close
- **Multiple API styles** — string extensions, static methods, and AnsiPen-compatible fluent API
- **Drop-in AnsiPen replacement** — migrate from the `ansicolor` package by changing a single import
- **Plain fast path** — skip ESC scanning entirely for known-plain text, matching raw string interpolation speed
- **Colored underlines** — set underline color independently via 256-color or RGB
- **Automatic ANSI detection** — detects terminal support on IO, web, and other platforms
- **Global toggle** — disable all color output with a single flag

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  quectocolors: ^0.0.1
```

## Imports

QuectoColors is split into three imports so you only pull in what you need:

```dart
// Core — QuectoColors, QuectoPlain, basic string extensions
import 'package:quectocolors/quectocolors.dart';

// AnsiPen — drop-in replacement for the ansicolor package (import separately)
import 'package:quectocolors/ansipen.dart';

// CSS/X11 named colors — adds 149 named color string extensions (includes core)
import 'package:quectocolors/quectocolors_css.dart';
```

## Quick Start

```dart
import 'package:quectocolors/quectocolors.dart';

void main() {
  // String extensions — the most concise syntax
  print('This is red text'.red);
  print('Bold blue text'.blue.bold);

  // Nested colors work correctly:
  print(('Red ${'Blue'.blue} Red again').red);
}
```

## API Styles

QuectoColors offers three ways to style text, each suited to different use cases.

### 1. String Extensions

The most concise and intuitive syntax. Chain styles directly on any `String`.

```dart
import 'package:quectocolors/quectocolors.dart';

print('Hello'.red);
print('Important'.bold);
print('Hello'.red.italic.strikethrough);

// Nested with string extensions
print(('Hello ${'world'.blue} !').red);
```

### 2. Static Methods

All styles are also available as static fields on the `QuectoColors` class. Useful when you want to store a styler in a variable or pass it as a function argument.

```dart
import 'package:quectocolors/quectocolors.dart';

print(QuectoColors.red('Hello'));
print(QuectoColors.bold('Important'));
print(QuectoColors.bgYellow(QuectoColors.black('Warning')));

// Nested colors — red is restored after blue closes
print(QuectoColors.red('Start ${QuectoColors.blue("middle")} end'));
```

### 3. AnsiPen-Compatible Fluent API

A drop-in replacement for the `ansicolor` package's `AnsiPen`. Supports the same method signatures (`red()`, `blue(bg: true)`, etc.) plus additional styles like `italic`, `strikethrough`, and `overline` that `ansicolor` doesn't offer — and correctly handles nested colors.

```dart
import 'package:quectocolors/ansipen.dart';

// Same API as ansicolor's AnsiPen
final pen = AnsiPen()..red();
print(pen('Hello'));

// But you can also chain styles that ansicolor can't do
final fancy = AnsiPen().red().bold.italic.strikethrough;
print(fancy('Fancy text'));
```

See [Migrating from ansicolor](#migrating-from-ansicolor) below for details.

## Plain Fast Path

When you know your input string contains no ANSI escape codes (it's a literal or plain text), you can use `QuectoPlain` to skip ESC scanning entirely. This is the fastest possible styling — pure string interpolation with zero overhead.

```dart
import 'package:quectocolors/quectocolors.dart';

print(QuectoPlain.red('Hello World'));
print(QuectoPlain.bold('Important'));
```

**When to use `QuectoPlain`:** Log messages, user input, file contents, string literals — any text you know doesn't already contain ANSI codes.

**When NOT to use `QuectoPlain`:** When the input might contain styled text from other color calls (nested styling). Use `QuectoColors` for that — it handles nesting automatically.

### Performance: QuectoPlain vs QuectoColors

| Scenario | `QuectoPlain.red()` | `QuectoColors.red()` | Speedup |
|---|---|---|---|
| Short string ("Hello") | ~3.7 ns | ~4.5 ns | ~same |
| 200-char plain string | ~251 ns | ~793 ns | **3.2x faster** |

The plain fast path eliminates the ESC byte scan that the normal path performs. On short strings the scan is negligible, but on longer strings the difference is substantial.

## Extended Colors

QuectoColors supports the full range of terminal colors beyond the standard 16.

### 256-Color Xterm Palette

```dart
// Foreground
print(QuectoColors.ansi256(196)('Bright red'));
print('Bright red'.ansi256(196));

// Background
print(QuectoColors.bgAnsi256(21)('Blue background'));

// Underline color (terminals that support it)
print(QuectoColors.underlineAnsi256(82)('Green underline'));
```

### 16M True Color (RGB)

```dart
// Foreground
print(QuectoColors.rgb(255, 128, 0)('Orange text'));
print('Orange text'.rgb(255, 128, 0));

// Background
print(QuectoColors.bgRgb(0, 0, 128)('Dark blue background'));

// Underline color
print(QuectoColors.underlineRgb(255, 0, 255)('Magenta underline'));
```

### RGB to Xterm256 Conversion

```dart
// Convert RGB to nearest xterm 256-color index
int code = QuectoColors.rgbToAnsi256(255, 128, 0); // orange
print(QuectoColors.ansi256(code)('Orange via xterm256'));
```

### Performance: Cache Extended Stylers in Hot Loops

Extended color methods create a new closure per call. For hot loops, cache the styler:

```dart
final myStyle = QuectoColors.ansi256(196);  // cache once
for (final line in lines) print(myStyle(line));  // reuse
```

### Plain Fast Path for Extended Colors

`QuectoPlain` also supports extended colors for known-plain text:

```dart
print(QuectoPlain.ansi256(196)('Known-plain red'));
print(QuectoPlain.rgb(255, 128, 0)('Known-plain orange'));
```

## CSS/X11 Named Colors

QuectoColors includes all 149 standard CSS/X11 named colors as convenient string extensions and static stylers. Import `quectocolors_css.dart` to access them.

```dart
import 'package:quectocolors/quectocolors_css.dart';

// String extensions — the most concise syntax
print('Hello'.cornflowerBlue);
print('Warning'.tomato);
print('Hello'.onAliceBlue);                // background
print('Hello'.onCornflowerBlueUnderline);  // underline color

// Static stylers — reusable closures, support nesting
final styler = QuectoColorsX11.cornflowerBlue;
print(styler('Hello'));

// Nesting works automatically
print(QuectoColorsX11.cornflowerBlue('Hello ${QuectoColorsX11.tomato("world")} !'));
```

### Naming Conventions

- **Foreground:** `colorName` — e.g. `'text'.cornflowerBlue`, `'text'.tomato`
- **Background:** `onColorName` — e.g. `'text'.onCornflowerBlue`, `'text'.onTomato`
- **Underline color:** `onColorNameUnderline` — e.g. `'text'.onTomatoUnderline`

Colors that conflict with the basic ANSI color names use an `X11` suffix to avoid ambiguity: `redX11`, `blueX11`, `greenX11`, `blackX11`, `whiteX11`, `cyanX11`, `magentaX11`, `yellowX11`, `grayX11`, `greyX11`.

```dart
// ANSI red (standard terminal red, escape code \x1B[31m)
print('Hello'.red);

// CSS/X11 red (true color rgb(255, 0, 0), escape code \x1B[38;2;255;0;0m)
print('Hello'.redX11);
```

### Performance

CSS color stylers are lazily cached — the first access to a color creates the styler, subsequent accesses return the cached instance. All 149 colors × 3 variants (fg/bg/underline) share a single 447-element cache.

## Available Styles

### Text Styles

| Style | Example |
|---|---|
| `bold` | **bold text** |
| `dim` | dimmed text |
| `italic` | *italic text* |
| `underline` | underlined text |
| `overline` | overlined text |
| `inverse` | reversed colors |
| `hidden` | hidden text |
| `strikethrough` | ~~strikethrough text~~ |

### Foreground Colors

`black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`, `gray`

Bright variants: `redBright`, `greenBright`, `yellowBright`, `blueBright`, `magentaBright`, `cyanBright`, `whiteBright`

### Background Colors

`bgBlack`, `bgRed`, `bgGreen`, `bgYellow`, `bgBlue`, `bgMagenta`, `bgCyan`, `bgWhite`, `bgGray`

Bright variants: `bgRedBright`, `bgGreenBright`, `bgYellowBright`, `bgBlueBright`, `bgMagentaBright`, `bgCyanBright`, `bgWhiteBright`

## Comparison with ansicolor

The [`ansicolor`](https://pub.dev/packages/ansicolor) package is a widely used Dart library for ANSI terminal colors. QuectoColors is a strict superset of ansicolor — it matches every ansicolor feature, adds many more (text styles, true color, string extensions, plain fast path), fixes ansicolor's most significant limitation (**broken nested color output**), and is dramatically faster.

### The Nesting Problem

With `ansicolor`, nesting colors produces incorrect output:

```dart
import 'package:ansicolor/ansicolor.dart';

final red = AnsiPen()..red();
final blue = AnsiPen()..blue();

// ansicolor output:
print(red('Hello ${blue("world")} !'));
// Produces: ESC[38;5;1mHello ESC[38;5;4mworldESC[0m !ESC[0m
//                                                ^^^^^^
//                     After "world", the terminal resets to DEFAULT — not red.
//                     The " !" appears unstyled instead of red.
```

The `ansicolor` package wraps text with `ESC[38;5;Xm...ESC[0m` (a full reset). When blue text ends inside red text, the `ESC[0m` resets *everything* — the red foreground is lost.

QuectoColors detects these nested close codes and re-injects the parent color:

```dart
import 'package:quectocolors/quectocolors.dart';

// QuectoColors output:
print(('Hello ${"world".blue} !').red);
// Produces: ESC[31mHello ESC[34mworldESC[31m !ESC[39m
//                                       ^^^^^^
//                     After "world", red is RESTORED. The " !" appears red.
```

### Feature Comparison

| Feature | ansicolor | QuectoColors |
|---|---|---|
| Basic colors (8 + 8 bright) | Yes | Yes |
| Background colors | Yes | Yes |
| 256-color xterm palette | Yes | Yes |
| RGB colors | Via xterm256 mapping | Direct 24-bit + xterm256 mapping |
| 16M true color (24-bit RGB) | No | **Yes** |
| Colored underlines | No | **Yes** (256-color and RGB) |
| Bold, italic, strikethrough, etc. | No | **Yes** |
| Correct nested colors | **No** | **Yes** |
| String extensions (`'text'.red`) | No | **Yes** |
| Plain fast path | No | **Yes** |
| Drop-in AnsiPen compatible | — | **Yes** |
| `ansiColorDisabled` global toggle | Yes | Yes |

QuectoColors is a strict superset: every feature ansicolor has, QuectoColors has too — plus text styles, true color, colored underlines, string extensions, and correct nesting.

### Performance Comparison

Benchmarked with `dart compile exe` (AOT native), 100,000 iterations:

| Test | QuectoColors | ansicolor | Notes |
|---|---|---|---|
| Simple `red("Hello")` | **~4 ns** | ~143 ns | QuectoColors uses pre-built closures |
| 3-style nesting | **~10 ns** | ~235 ns | ansicolor can only do 1 style per pen |
| Complex nested colors | **~1,000 ns** | ~1,970 ns | ansicolor output is incorrect here |
| Complex (large strings) | **~1,800 ns** | ~3,125 ns | ansicolor output is incorrect here |

QuectoColors is significantly faster across all test levels while also producing correct output for nested colors.

## Migrating from ansicolor

QuectoColors provides a drop-in `AnsiPen` replacement. To migrate:

**1. Change your import:**

```dart
// Before:
import 'package:ansicolor/ansicolor.dart';

// After:
import 'package:quectocolors/ansipen.dart';
```

**2. Your existing code works as-is:**

```dart
// This code works identically with both packages:
final pen = AnsiPen()..red();
print(pen('Hello'));

final bgPen = AnsiPen()..blue(bg: true);
print(bgPen('Blue background'));
```

**3. Gain new capabilities:**

After switching, you can also use features that `ansicolor` doesn't support:

```dart
// Chain multiple styles (ansicolor only supports one color per pen)
final fancy = AnsiPen().red().bold.italic.strikethrough;
print(fancy('Red bold italic strikethrough'));

// Nested colors now work correctly
final red = AnsiPen()..red();
final blue = AnsiPen()..blue();
print(red('Hello ${blue("world")} !')); // "!" is now correctly red

// 16M true color RGB (ansicolor can't do this)
final orange = AnsiPen()..rgbFg(255, 128, 0);
print(orange('True color orange'));

// 256-color xterm via AnsiPen
final xterm = AnsiPen()..ansi256Fg(196);
print(xterm('Xterm red'));
```

**4. The `ansiColorDisabled` global flag and `color_disabled` deprecated getter/setter are both supported** for full backwards compatibility.

## Comparison with ChalkDart

[ChalkDart](https://pub.dev/packages/chalkdart) is a full-featured ANSI styling library for Dart (by the same author as QuectoColors). It is modeled after the popular [chalk](https://www.npmjs.com/package/chalk) npm package for Node.js.

QuectoColors now covers the vast majority of what most terminal applications need — standard colors, 256-color xterm, 16M true color RGB, 149 named CSS/X11 colors, text styles, colored underlines, and correct nesting — at 30-90x higher performance. ChalkDart remains the choice for niche features like HTML output mode, hex/HSL/HSV color input, and exotic color model conversions.

### Feature Comparison

| Feature | QuectoColors | ChalkDart |
|---|---|---|
| Basic colors (8 + 8 bright) | Yes | Yes |
| Background colors | Yes | Yes |
| 256-color xterm palette | Yes | Yes |
| 16M true color (24-bit RGB) | Yes | Yes |
| RGB to xterm256 mapping | Yes | Yes |
| Hex / HSL / HSV / HWB / LAB / XYZ | No | Yes |
| 149 named CSS/X11 colors | Yes | Yes |
| Bold, italic, underline, strikethrough, overline | Yes | Yes |
| Colored underlines (256-color / RGB) | Yes | Yes |
| Double underline, blink, superscript, subscript | No | Yes |
| Alternative fonts | No | Yes |
| Correct nested colors | Yes | Yes |
| String extensions (`'text'.red`) | Yes | Yes |
| Chainable API | Yes (AnsiPen) | Yes (chalk) |
| HTML output mode | No | Yes |
| Custom color keywords | No | Yes |
| Color level downsampling | No | Yes |
| Drop-in for ansicolor | Yes (AnsiPen compatible) | No |
| Plain fast path (zero-scan) | Yes | No |
| Package size | Minimal | Larger |

### Performance Comparison

Benchmarked with `dart compile exe` (AOT native), 100,000 iterations:

| Test | QuectoColors | ChalkDart | Speedup |
|---|---|---|---|
| Simple `red("Hello")` | **~4 ns** | ~366 ns | **~90x** |
| 3-style nesting | **~10 ns** | ~384 ns | **~38x** |
| Complex nested colors | **~1,000 ns** | ~7,793 ns | **~8x** |
| Complex (large strings) | **~1,800 ns** | ~18,352 ns | **~10x** |

### Choosing the Right Tool

**Use QuectoColors when** (most terminal applications):
- You need any combination of standard colors, 256-color xterm, or 16M true color RGB
- You need text styles: bold, italic, underline, strikethrough, overline, dim, inverse
- You need colored underlines
- Performance matters — CLI tools, high-frequency logging, real-time output
- You're migrating from the `ansicolor` package
- You want minimal overhead and a small dependency footprint

**Use ChalkDart when:**
- You need hex (`#FF8000`), HSL, HSV, HWB, LAB, or XYZ color input
- You need HTML `<span>` output mode for web dashboards or log viewers
- You need double underline, blink, superscript/subscript, or alternative fonts
- You need automatic color level downsampling (truecolor to 256-color to 16-color fallback)

Both packages handle nested colors correctly. For the features they share, QuectoColors is 30-90x faster.

## Disabling Colors

```dart
import 'package:quectocolors/quectocolors.dart';

// Disable all ANSI output globally
ansiColorDisabled = true;

// All styling functions now return the input string unchanged
print(QuectoColors.red('Hello')); // prints "Hello" with no color codes
```

QuectoColors automatically detects whether the terminal supports ANSI escape codes. On platforms without support, colors are disabled by default.

## How It Works

QuectoColors uses pre-built closures for maximum performance. Everything is all-static — there is exactly one set of closures for the entire package, shared by `QuectoColors`, `QuectoPlain`, `AnsiPen`, and the String extensions.

At initialization time, `QuectoColors.createStyler()` builds a closure for each style that:

1. Pre-computes the ANSI open/close code strings (`\x1B[31m` / `\x1B[39m` for red)
2. Pre-caches the individual code unit bytes of the close code for fast scanning
3. Pre-warms a StringBuffer (write + clear) so the closure's captured buffer has internal capacity from the start
4. On each call, performs a single-pass scan for the ESC byte (`0x1B`) using unrolled `codeUnitAt()` comparisons
5. If no nested close codes are found (the common case), returns a simple string interpolation: `'$openCode$string$closeCode'`
6. If nested close codes are found, uses the pre-warmed StringBuffer with a do-while loop to re-inject the parent open code after each occurrence

This approach avoids the overhead of `String.indexOf()` pattern matching and branches on close code length (4 vs 5 chars) at closure creation time rather than per-call.

## License

See [LICENSE](LICENSE) for details.
