# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

QuectoColors is a high-performance Dart/Flutter package for ANSI terminal color styling. It provides multiple API styles for applying colors, text effects, and background colors to terminal output. Performance is a primary design goal. The same author also maintains the `chalkdart` package (at `C:\src\chalkdart`), which is a more feature-rich but slower alternative.

## Build and Test Commands

```bash
dart pub get                          # Install dependencies
dart analyze                          # Run linter (uses flutter_lints)
flutter test                          # Run unit tests
dart run test/perftest.dart           # Run performance benchmarks
dart run test/perftest_harness.dart   # Run enhanced performance benchmarks (needs terminal or falls back to 120 cols)
dart compile exe test/perftest_harness.dart -o test/perftest_harness.exe  # Compile for accurate AOT benchmarking
dart compile exe test/quick_perf.dart -o test/quick_perf.exe             # Quick A/B comparison benchmark
```

## Architecture

### All-Static Design

Everything is all-static — there is exactly one set of closures for the entire package, shared by `QuectoColors`, `QuectoPlain`, `AnsiPen`, and the String extensions. All defined in `lib/src/quectocolors.dart`.

### API Styles

The package exposes three ways to apply ANSI styling:

1. **Static methods** (`QuectoColors`): `QuectoColors.red("text")` — primary API, `static final` closures
2. **String extensions** (`QuectoColorsOnStrings`): `"text".red` — extension on String, delegates to `QuectoColors.X(this)`
3. **AnsiPen fluent interface** (`lib/src/quectocolors_ansipen.dart`): `AnsiPen().red().bold()("text")` — compatible with ansicolor package API, references `QuectoColors` statics directly

### Plain Fast Path

`QuectoPlain` provides zero-scan stylers for known-plain text via `static final` fields:
- `QuectoPlain.red("text")`

These skip ESC byte scanning entirely — pure `'$openCode$string$closeCode'` interpolation. ~3x faster than normal stylers on long strings.

### Entry Points

- `lib/quectocolors.dart` — Main export: QuectoColors, QuectoPlain, String extensions, AnsiPen, ANSI support detection
- `lib/quectocolors_static.dart` — Re-exports `quectocolors.dart` (backward compatibility)
- `lib/ansipen.dart` — AnsiPen compatibility layer (drop-in for ansicolor package)

### Core Mechanism

`createStyler()` is the central function that builds ANSI styling closures for the standard 16 colors. It:
1. Pre-computes open/close code strings via string interpolation
2. Pre-caches close code unit bytes for fast scanning
3. Pre-warms the StringBuffer to avoid first-call reallocation
4. Returns a closure that scans for ESC bytes using unrolled `codeUnitAt()` comparisons
5. Handles **nested color reinjection** — re-applies the parent style after each nested close code using a do-while loop over a StringBuffer
6. Branches on close code length (4 vs 5 chars) at closure creation time, not per-call

### Extended Color Mechanism

`createExtendedStyler()` is a fully independent method for 256-color and 16M true color (RGB). It:
1. Takes a pre-built open code string and a close code int (39, 49, or 59)
2. Uses the same WAY 4 unrolled `codeUnitAt()` scanning and StringBuffer nesting as `createStyler`
3. Only handles the length-5 close code path (all extended close codes are 5 chars)
4. Creates a new closure per call (not `static final`) — users should cache for hot loops
5. **`createStyler` is completely untouched** — zero risk to existing performance

### Platform Detection

ANSI support detection uses Dart conditional imports (`lib/supports_ansi_color.dart`):
- `src/supports_ansi_io.dart` — checks `stdout.supportsAnsiEscapes`
- `src/supports_ansi_web.dart` — assumes true for browsers
- `src/supports_ansi.dart` — default fallback (true)

Global toggle: `ansiColorDisabled` disables all color output.

### Performance Testing

The `test/` directory contains benchmark infrastructure comparing QuectoColors against `ansicolor` and `chalkdart` packages across test levels (simple, 3-style, complex, large random complex). Results are visualized with ASCII bar charts (`test/chart.dart`). Always compile to native exe for accurate benchmarks — JIT numbers are unreliable.

## Key Types

- `QuectoStyler = String Function(String)` — typedef for all styling functions
- `QuectoColors` — all-static class with `static final QuectoStyler` fields, `createStyler()`, `createExtendedStyler()`, and `rgbToAnsi256()`
- `QuectoPlain` — all-static class with `static final QuectoStyler` fields, `createPlainStyler()`, and `createPlainExtendedStyler()`
- `AnsiPen` — fluent style builder with method chaining (returns `this`), references `QuectoColors` statics, includes `ansi256Fg/Bg`, `rgbFg/Bg`, `underlineAnsi256/Rgb` methods

## Dependencies

- `ansicolor` and `chalkdart` are dependencies used for compatibility and performance comparison testing
- SDK constraint: Dart ^3.8.0

## Branch Info

- Main branch for PRs: `main`
- Development branch: `master`
