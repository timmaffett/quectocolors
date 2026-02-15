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

### Multiple API Styles

The package exposes four ways to apply ANSI styling, each with different performance characteristics:

1. **Instance methods** (`lib/src/quectocolors.dart`): `quectoColors.red("text")` — global `QuectoColors` instance with closures for each style
2. **Static methods** (`lib/src/quectocolors_static.dart`): `QuectoColorsStatic.red("text")` — static finals, better performance when compiled
3. **String extensions** (in `quectocolors_static.dart`): `"text".red` — extension on String via `QuectoColorsOnStringsStatic`
4. **AnsiPen fluent interface** (`lib/src/quectocolors_ansipen.dart`): `AnsiPen().red().bold()("text")` — compatible with ansicolor package API

### Plain Fast Path

`QuectoPlain` (defined in `quectocolors.dart`) provides zero-scan stylers for known-plain text. Accessed via `.plain` on each class:
- `quectoColors.plain.red("text")` — instance
- `QuectoColorsStatic.plain.red("text")` — static

These skip ESC byte scanning entirely — pure `'$openCode$string$closeCode'` interpolation. ~3x faster than normal stylers on long strings.

### Entry Points

- `lib/quectocolors.dart` — Main export: instance API + AnsiPen + ANSI support detection
- `lib/quectocolors_static.dart` — Static-only API export + String extensions
- `lib/ansipen.dart` — AnsiPen compatibility layer (drop-in for ansicolor package)

### Core Mechanism

`createStyler()` is the central function that builds ANSI styling closures. It:
1. Pre-computes open/close code strings via string interpolation
2. Pre-caches close code unit bytes for fast scanning
3. Pre-warms the StringBuffer to avoid first-call reallocation
4. Returns a closure that scans for ESC bytes using unrolled `codeUnitAt()` comparisons
5. Handles **nested color reinjection** — re-applies the parent style after each nested close code using a do-while loop over a StringBuffer
6. Branches on close code length (4 vs 5 chars) at closure creation time, not per-call

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
- `QuectoPlain` — holds plain (zero-scan) stylers, accessed via `.plain`
- `AnsiPen` — fluent style builder with method chaining (returns `this`)

## Dependencies

- `ansicolor` and `chalkdart` are dependencies used for compatibility and performance comparison testing
- SDK constraint: Dart ^3.8.0

## Branch Info

- Main branch for PRs: `main`
- Development branch: `master`
