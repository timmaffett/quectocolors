# QuectoColors

A high-performance ANSI terminal color styling library for Dart and Flutter with **correct nested color support**.

QuectoColors provides multiple API styles for applying colors, text effects, and background colors to terminal output. Unlike other Dart ANSI color packages, QuectoColors properly handles nested colors — when you write `red('Hello ${blue("world")}!')`, the red color is correctly restored after the blue text ends.

## Features

- **Correct nested color handling** — parent colors are automatically restored after inner styles close
- **Multiple API styles** — instance methods, static methods, string extensions, and AnsiPen-compatible fluent API
- **Drop-in AnsiPen replacement** — migrate from the `ansicolor` package by changing a single import
- **Plain fast path** — skip ESC scanning entirely for known-plain text, matching raw string interpolation speed
- **Automatic ANSI detection** — detects terminal support on IO, web, and other platforms
- **Global toggle** — disable all color output with a single flag

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  quectocolors: ^0.0.1
```

## Quick Start

```dart
import 'package:quectocolors/quectocolors.dart';

void main() {
  print(quectoColors.red('This is red text'));
  print(quectoColors.bold(quectoColors.blue('Bold blue text')));

  // Nested colors work correctly:
  print(quectoColors.red('Red ${quectoColors.blue("Blue")} Red again'));
}
```

## API Styles

QuectoColors offers four ways to style text, each suited to different use cases.

### 1. Instance Methods

```dart
import 'package:quectocolors/quectocolors.dart';

// Uses the global `quectoColors` instance
print(quectoColors.red('Hello'));
print(quectoColors.bold('Important'));
print(quectoColors.bgYellow(quectoColors.black('Warning')));

// Nested colors — red is restored after blue closes
print(quectoColors.red('Start ${quectoColors.blue("middle")} end'));
```

### 2. Static Methods

Better performance when compiled to native (AOT). Identical API, just accessed via the class name.

```dart
import 'package:quectocolors/quectocolors_static.dart';

print(QuectoColorsStatic.red('Hello'));
print(QuectoColorsStatic.bold(QuectoColorsStatic.italic('Styled')));
```

### 3. String Extensions

The most concise syntax. Chain styles directly on any `String`.

```dart
import 'package:quectocolors/quectocolors_static.dart';

print('Hello'.red);
print('Important'.bold);
print('Hello'.red.italic.strikethrough);

// Nested with string extensions
print(('Hello ${'world'.blue} !').red);
```

### 4. AnsiPen-Compatible Fluent API

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

When you know your input string contains no ANSI escape codes (it's a literal or plain text), you can use the `plain` accessor to skip ESC scanning entirely. This is the fastest possible styling — pure string interpolation with zero overhead.

```dart
// Instance
print(quectoColors.plain.red('Hello World'));

// Static
print(QuectoColorsStatic.plain.red('Hello World'));
```

**When to use `plain`:** Log messages, user input, file contents, string literals — any text you know doesn't already contain ANSI codes.

**When NOT to use `plain`:** When the input might contain styled text from other color calls (nested styling). Use the normal methods for that — they handle nesting automatically.

### Performance: plain vs normal

| Scenario | `plain.red()` | `red()` (normal) | Speedup |
|---|---|---|---|
| Short string ("Hello") | ~2.4 ns | ~2.3 ns | ~same |
| 200-char plain string | ~251 ns | ~793 ns | **3.2x faster** |

The plain fast path eliminates the ESC byte scan that the normal path performs. On short strings the scan is negligible, but on longer strings the difference is substantial.

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

The [`ansicolor`](https://pub.dev/packages/ansicolor) package is a widely used Dart library for ANSI terminal colors. QuectoColors was designed to be faster while also fixing ansicolor's most significant limitation: **broken nested color output**.

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
print(quectoColors.red('Hello ${quectoColors.blue("world")} !'));
// Produces: ESC[31mHello ESC[34mworldESC[31m !ESC[39m
//                                       ^^^^^^
//                     After "world", red is RESTORED. The " !" appears red.
```

### Feature Comparison

| Feature | ansicolor | QuectoColors |
|---|---|---|
| Basic colors (8 + 8 bright) | Yes | Yes |
| Background colors | Yes | Yes |
| 256-color xterm palette | Yes | No (standard 16) |
| RGB colors | Yes (via xterm mapping) | No |
| Bold, italic, strikethrough, etc. | No | Yes |
| Correct nested colors | **No** | **Yes** |
| String extensions (`'text'.red`) | No | Yes |
| Plain fast path | N/A | Yes |
| `ansiColorDisabled` global toggle | Yes | Yes |

### Performance Comparison

Benchmarked with `dart compile exe` (AOT native), 100,000 iterations:

| Test | QuectoColors | ansicolor | Notes |
|---|---|---|---|
| Simple `red("Hello")` | **~2 ns** | ~56 ns | QuectoColors uses pre-built closures |
| 3-style nesting | **~7 ns** | ~90 ns | ansicolor can only do 1 style per pen |
| Complex nested colors | **~540 ns** | ~970 ns | ansicolor output is incorrect here |
| Complex (large strings) | **~650 ns** | ~1,100 ns | ansicolor output is incorrect here |

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
```

**4. The `ansiColorDisabled` global flag and `color_disabled` deprecated getter/setter are both supported** for full backwards compatibility.

## Comparison with ChalkDart

[ChalkDart](https://pub.dev/packages/chalkdart) is a full-featured ANSI styling library for Dart (by the same author as QuectoColors). It is modeled after the popular [chalk](https://www.npmjs.com/package/chalk) npm package for Node.js and provides an extensive set of capabilities far beyond basic terminal colors.

### What ChalkDart offers

ChalkDart is a comprehensive styling toolkit:

- **Full color spectrum** — 16 basic colors, 256-color xterm palette, and 24-bit truecolor (16 million colors) via RGB, hex, HSL, HSV, HWB, LAB, and XYZ color models
- **140+ named colors** — all standard X11/CSS/SVG color keywords (`cornflowerBlue`, `darkSeaGreen`, `lightGoldenrodYellow`, etc.) with IDE autocompletion
- **Advanced text styles** — everything QuectoColors has plus double underline, blink, rapid blink, superscript, subscript, alternative fonts, and colored underlines
- **Chainable API** — `chalk.red.bold.underline('text')` — styles build upon each other naturally
- **String extensions** — `'text'.red.bold.underline` with full feature parity
- **HTML output mode** — switch the same API to produce HTML `<span>` output instead of ANSI codes, with customizable stylesheets and color schemes
- **Correct nested colors** — full nesting support with style stack tracking
- **Dynamic arguments** — pass strings, numbers, maps, lists, and even closures directly
- **Custom color keywords** — register your own named colors
- **IDE integration** — optimized for VSCode, Android Studio, XCode, and browser debug consoles
- **Automatic color level downsampling** — truecolor gracefully falls back to 256-color or 16-color when the terminal doesn't support it

### When to use QuectoColors vs ChalkDart

| Consideration | QuectoColors | ChalkDart |
|---|---|---|
| **Performance is critical** | Best choice — ~2 ns per simple style, optimized scanning | ~150-200 ns per simple style |
| **Standard 16 colors + styles** | Full support | Full support |
| **RGB / hex / HSL colors** | Not supported | Full support |
| **256-color xterm palette** | Not supported | Full support |
| **Named CSS colors** | Not supported | 140+ colors |
| **HTML output** | Not supported | Full support |
| **Colored underlines** | Not supported | Full support |
| **Superscript / subscript** | Not supported | Full support |
| **Drop-in for ansicolor** | Yes (AnsiPen compatible) | No |
| **Package size** | Minimal | Larger (comprehensive feature set) |

### Performance comparison

Benchmarked with `dart compile exe` (AOT native), 100,000 iterations:

| Test | QuectoColors | ChalkDart |
|---|---|---|
| Simple `red("Hello")` | **~2 ns** | ~152 ns |
| 3-style nesting | **~7 ns** | ~142 ns |
| Complex nested colors | **~540 ns** | ~2,575 ns |
| Complex (large strings) | **~650 ns** | ~6,716 ns |

QuectoColors is faster across all levels. The gap is most significant in the complex cases with longer strings, where QuectoColors is roughly 5-10x faster. The simple cases show a large ratio but the absolute difference is small (nanoseconds). ChalkDart's additional per-call overhead comes from its richer architecture — chainable style resolution, dynamic argument handling, color level negotiation, and support for color models that QuectoColors doesn't offer.

### Choosing the right tool

**Use QuectoColors when:**
- You need the standard 16 ANSI colors and text styles (bold, italic, underline, strikethrough, etc.)
- Performance matters — CLI tools that style thousands of lines, high-frequency logging, real-time output
- You're migrating from the `ansicolor` package and want a drop-in replacement with correct nesting
- You want minimal overhead and a small dependency footprint

**Use ChalkDart when:**
- You need RGB, hex, HSL, or any precise color specification
- You want access to named colors like `cornflowerBlue` or `darkSeaGreen`
- You need the 256-color xterm palette for richer terminal UIs
- You want HTML output mode for web dashboards, log viewers, or server-side rendering
- You need advanced features like colored underlines, superscript/subscript, or alternative fonts
- You're building a feature-rich terminal UI where color expressiveness matters more than raw throughput

Both packages handle nested colors correctly. QuectoColors covers the cases that the vast majority of terminal applications need, at the highest possible speed. ChalkDart covers everything else.

## Disabling Colors

```dart
import 'package:quectocolors/quectocolors.dart';

// Disable all ANSI output globally
ansiColorDisabled = true;

// All styling functions now return the input string unchanged
print(quectoColors.red('Hello')); // prints "Hello" with no color codes
```

QuectoColors automatically detects whether the terminal supports ANSI escape codes. On platforms without support, colors are disabled by default.

## How It Works

QuectoColors uses pre-built closures for maximum performance. At initialization time, `createStyler()` builds a closure for each style that:

1. Pre-computes the ANSI open/close code strings (`\x1B[31m` / `\x1B[39m` for red)
2. Pre-caches the individual code unit bytes of the close code for fast scanning
3. On each call, performs a single-pass scan for the ESC byte (`0x1B`) using unrolled `codeUnitAt()` comparisons
4. If no nested close codes are found (the common case), returns a simple string interpolation: `'$openCode$string$closeCode'`
5. If nested close codes are found, uses a StringBuffer with a do-while loop to re-inject the parent open code after each occurrence

This approach avoids the overhead of `String.indexOf()` pattern matching and branches on close code length (4 vs 5 chars) at closure creation time rather than per-call.

## License

See [LICENSE](LICENSE) for details.
