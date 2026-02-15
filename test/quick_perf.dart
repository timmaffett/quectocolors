import 'package:quectocolors/quectocolors.dart';
import 'package:ansicolor/ansicolor.dart' as AnsiColor;
import 'dart:math';

// Quick A/B test: compare QuectoColors vs AnsiColor, no terminal required.

const int iterations = 500000;

final String randomString = String.fromCharCodes(
  List.generate(200, (i) => 97 + Random(42).nextInt(26)),
);

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
  print(
    '${label.padRight(55)} ${sw.elapsedMilliseconds.toString().padLeft(6)}ms  ${ns.toString().padLeft(6)}ns/iter',
  );
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

  bench('QuectoColors  red("Hello ")', () => QuectoColors.red('Hello '));
  bench('AnsiColor     red("Hello ")', () => acRed('Hello '));

  print('\n=== SIMPLE 3-STYLES: strikethrough(italic(red(...))) ===\n');

  bench(
    'QuectoColors  strikethrough(italic(red(...)))',
    () => QuectoColors.strikethrough(
      QuectoColors.italic(QuectoColors.red('Hello ')),
    ),
  );

  print('\n=== COMPLEX: nested colors (200-char random strings) ===\n');

  final string = randomString;

  bench(
    'QuectoColors  nested',
    () => QuectoColors.red(
      'Hello ' +
          QuectoColors.blue(string) +
          QuectoColors.green(
            'Here is ' + QuectoColors.yellow(string) + ' end',
          ) +
          ' end of red',
    ),
  );

  bench(
    'AnsiColor     (no nesting support)',
    () => acRed(
      'Hello ' +
          acBlue(string) +
          acGreen('Here is ' + acYellow(string) + ' end') +
          ' end of red',
    ),
  );

  bench(
    'String ext    (.red etc)',
    () =>
        ('Hello ' +
                string.blue +
                ('Here is ' + string.yellow + ' end').green +
                ' end of red')
            .red,
  );

  print('\n=== PLAIN FAST PATH: single color, known-plain text ===\n');

  bench('QuectoPlain   red("Hello ")', () => QuectoPlain.red('Hello '));
  bench(
    'QuectoColors  (normal) red("Hello ")',
    () => QuectoColors.red('Hello '),
  );
  bench('AnsiColor     (no nesting)  red("Hello ")', () => acRed('Hello '));

  print('\n=== PLAIN FAST PATH: 200-char random string ===\n');

  bench('QuectoPlain   red(200-char)', () => QuectoPlain.red(string));
  bench('QuectoColors  (normal) red(200-char)', () => QuectoColors.red(string));
  bench('AnsiColor     (no nesting)  red(200-char)', () => acRed(string));

  // Verify correctness
  print('\n=== CORRECTNESS CHECK ===');
  final nested = QuectoColors.red('A${QuectoColors.blue("B")}C');
  print('QuectoColors: ${nested.replaceAll('\x1B[', 'ESC[')}');
  final acNested = acRed('A${acBlue("B")}C');
  print('AnsiColor:    ${acNested.replaceAll('\x1B[', 'ESC[')}');
  // Plain path check
  final plainResult = QuectoPlain.red('Hello');
  print('Plain:        ${plainResult.replaceAll('\x1B[', 'ESC[')}');
}
