import 'package:quectocolors/quectocolors.dart';
import 'package:quectocolors/quectocolors_static.dart';
import 'package:quectocolors/src/quectocolors_alt.dart';
import 'package:ansicolor/ansicolor.dart' as AnsiColor;
import 'dart:math';

// Quick A/B test: compare QuectoColors (with new codeUnitAt scan)
// against original AnsiColor, no terminal required.
// QuectoColorsAlt still uses the OLD indexOf code — serves as baseline.

const int iterations = 500000;

final String randomString = String.fromCharCodes(
    List.generate(200, (i) => 97 + Random(42).nextInt(26)));

void bench(String label, String Function() fn) {
  // Warmup
  String result = '';
  for (int i = 0; i < 1000; i++) result = fn();

  final sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    result = fn();
  }
  sw.stop();

  final ns = (sw.elapsedMicroseconds * 1000) ~/ iterations;
  print('${label.padRight(55)} ${sw.elapsedMilliseconds.toString().padLeft(6)}ms  ${ns.toString().padLeft(6)}ns/iter');
}

void main() {
  ansiColorDisabled = false;
  AnsiColor.ansiColorDisabled = false;

  // Set up AnsiColor pens
  final acRed = AnsiColor.AnsiPen()..red();
  final acBlue = AnsiColor.AnsiPen()..blue();
  final acGreen = AnsiColor.AnsiPen()..green();
  final acYellow = AnsiColor.AnsiPen()..yellow();

  print('=== SIMPLE: single color on short string ===');
  print('Iterations: $iterations\n');

  bench('QuectoColors  (NEW codeUnitAt)  red("Hello ")',
      () => quectoColors.red('Hello '));
  bench('QuectoStatic  (NEW codeUnitAt)  red("Hello ")',
      () => QuectoColorsStatic.red('Hello '));
  bench('QuectoAlt     (OLD indexOf)     red("Hello ")',
      () => quectoColorsAlt.red('Hello '));
  bench('AnsiColor                       red("Hello ")',
      () => acRed('Hello '));

  print('\n=== SIMPLE 3-STYLES: strikethrough(italic(red(...))) ===\n');

  bench('QuectoColors  (NEW codeUnitAt)',
      () => quectoColors.strikethrough(quectoColors.italic(quectoColors.red('Hello '))));
  bench('QuectoStatic  (NEW codeUnitAt)',
      () => QuectoColorsStatic.strikethrough(QuectoColorsStatic.italic(QuectoColorsStatic.red('Hello '))));
  bench('QuectoAlt     (OLD indexOf)',
      () => quectoColorsAlt.strikethrough(quectoColorsAlt.italic(quectoColorsAlt.red('Hello '))));

  print('\n=== COMPLEX: nested colors (200-char random strings) ===\n');

  final string = randomString;

  bench('QuectoColors  (NEW codeUnitAt)', () =>
      quectoColors.red('Hello ' +
          quectoColors.blue(string) +
          quectoColors.green('Here is ' +
              quectoColors.yellow(string) +
              ' end') +
          ' end of red'));

  bench('QuectoStatic  (NEW codeUnitAt)', () =>
      QuectoColorsStatic.red('Hello ' +
          QuectoColorsStatic.blue(string) +
          QuectoColorsStatic.green('Here is ' +
              QuectoColorsStatic.yellow(string) +
              ' end') +
          ' end of red'));

  bench('QuectoAlt     (OLD indexOf)', () =>
      quectoColorsAlt.red('Hello ' +
          quectoColorsAlt.blue(string) +
          quectoColorsAlt.green('Here is ' +
              quectoColorsAlt.yellow(string) +
              ' end') +
          ' end of red'));

  bench('AnsiColor     (no nesting support)', () =>
      acRed('Hello ' +
          acBlue(string) +
          acGreen('Here is ' +
              acYellow(string) +
              ' end') +
          ' end of red'));

  bench('String ext    (NEW via QuectoStatic)', () =>
      ('Hello ' +
          string.blue +
          ('Here is ' + string.yellow + ' end').green +
          ' end of red').red);

  print('\n=== PLAIN FAST PATH: single color, known-plain text ===\n');

  bench('QuectoColors  plain.red("Hello ")',
      () => quectoColors.plain.red('Hello '));
  bench('QuectoStatic  plain.red("Hello ")',
      () => QuectoColorsStatic.plain.red('Hello '));
  bench('QuectoColors  (normal) red("Hello ")',
      () => quectoColors.red('Hello '));
  bench('AnsiColor     (no nesting)  red("Hello ")',
      () => acRed('Hello '));

  print('\n=== PLAIN FAST PATH: 200-char random string ===\n');

  bench('QuectoColors  plain.red(200-char)',
      () => quectoColors.plain.red(string));
  bench('QuectoStatic  plain.red(200-char)',
      () => QuectoColorsStatic.plain.red(string));
  bench('QuectoColors  (normal) red(200-char)',
      () => quectoColors.red(string));
  bench('AnsiColor     (no nesting)  red(200-char)',
      () => acRed(string));

  // Verify correctness
  print('\n=== CORRECTNESS CHECK ===');
  final nested = quectoColors.red('A${quectoColors.blue("B")}C');
  print('QuectoColors: ${nested.replaceAll('\x1B[', 'ESC[')}');
  final acNested = acRed('A${acBlue("B")}C');
  print('AnsiColor:    ${acNested.replaceAll('\x1B[', 'ESC[')}');
  // Plain path check
  final plainResult = quectoColors.plain.red('Hello');
  print('Plain:        ${plainResult.replaceAll('\x1B[', 'ESC[')}');
}
