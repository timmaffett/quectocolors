# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

QuectoColors is a high-performance Dart/Flutter package for ANSI terminal color styling. It provides multiple API styles for applying colors, text effects, and background colors to terminal output. Performance is a primary design goal.

## Build and Test Commands

```bash
dart pub get                          # Install dependencies
dart analyze                          # Run linter (uses flutter_lints)
flutter test                          # Run unit tests
dart run test/perftest.dart           # Run performance benchmarks
dart run test/perftest_harness.dart   # Run enhanced performance benchmarks
```

## Architecture

### Multiple API Styles

The package exposes four ways to apply ANSI styling, each with different performance characteristics:

1. **Instance methods** (`lib/src/quectocolors.dart`): `quectoColors.red("text")` — global `QuectoColors` instance with closures for each style
2. **Static methods** (`lib/src/quectocolors_static.dart`): `QuectoColorsStatic.red("text")` — static finals, better performance when compiled
3. **String extensions** (in `quectocolors_static.dart`): `"text".red` — extension on String via `QuectoColorsOnStringsStatic`
4. **AnsiPen fluent interface** (`lib/src/quectocolors_ansipen.dart`): `AnsiPen().red().bold()("text")` — compatible with ansicolor package API

### Entry Points

- `lib/quectocolors.dart` — Main export: instance API + AnsiPen + ANSI support detection
- `lib/quectocolors_static.dart` — Static-only API export
- `lib/ansipen.dart` — AnsiPen compatibility layer (drop-in for ansicolor package)

### Core Mechanism

`createStyler()` is the central function that builds ANSI styling closures. It wraps text with open/close escape sequences and handles **nested color reinjection** — when styled text contains inner escape sequences, it re-applies the current style after each nested sequence using a do-while loop over a StringBuffer.

### Platform Detection

ANSI support detection uses Dart conditional imports (`lib/supports_ansi_color.dart`):
- `src/supports_ansi_io.dart` — checks `stdout.supportsAnsiEscapes`
- `src/supports_ansi_web.dart` — assumes true for browsers
- `src/supports_ansi.dart` — default fallback (true)

Global toggle: `ansiColorDisabled` disables all color output.

### Performance Testing

The `test/` directory contains benchmark infrastructure comparing QuectoColors against `ansicolor` and `chalkdart` packages across test levels (simple, 3-style, complex, large random complex). Results are visualized with ASCII bar charts (`test/chart.dart`).

## Key Types

- `QuectoStyler = String Function(String)` — typedef for all styling functions
- `AnsiPen` — fluent style builder with method chaining (returns `this`)

## Dependencies

- `ansicolor` and `chalkdart` are dependencies used for compatibility and performance comparison testing
- SDK constraint: Dart ^3.8.0-149.0.dev

## Branch Info

- Main branch for PRs: `main`
- Development branch: `master`
