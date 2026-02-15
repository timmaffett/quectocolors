import 'package:flutter_test/flutter_test.dart';

import 'package:quectocolors/quectocolors.dart';

void main() {
  // flutter test runs without a terminal, so ansiColorDisabled defaults to true.
  // Force it off before any static final stylers are lazily initialized.
  ansiColorDisabled = false;

  // Helper to make escape codes visible in test output
  String esc(String s) => s.replaceAll('\x1B[', 'ESC[');

  group('Basic colors (smoke test)', () {
    test('red wraps with correct codes', () {
      final result = QuectoColors.red('Hello');
      expect(result, '\x1B[31mHello\x1B[39m');
    });

    test('bold wraps with correct codes', () {
      final result = QuectoColors.bold('Hello');
      expect(result, '\x1B[1mHello\x1B[22m');
    });
  });

  group('256-color xterm palette', () {
    test('ansi256 foreground produces correct escape code', () {
      final styler = QuectoColors.ansi256(196);
      final result = styler('Hello');
      expect(result, '\x1B[38;5;196mHello\x1B[39m');
    });

    test('bgAnsi256 background produces correct escape code', () {
      final styler = QuectoColors.bgAnsi256(21);
      final result = styler('Hello');
      expect(result, '\x1B[48;5;21mHello\x1B[49m');
    });

    test('underlineAnsi256 produces correct escape code', () {
      final styler = QuectoColors.underlineAnsi256(82);
      final result = styler('Hello');
      expect(result, '\x1B[58;5;82mHello\x1B[59m');
    });

    test('ansi256 code 0 (black)', () {
      final result = QuectoColors.ansi256(0)('test');
      expect(result, '\x1B[38;5;0mtest\x1B[39m');
    });

    test('ansi256 code 255 (max)', () {
      final result = QuectoColors.ansi256(255)('test');
      expect(result, '\x1B[38;5;255mtest\x1B[39m');
    });
  });

  group('16M true color (RGB)', () {
    test('rgb foreground produces correct escape code', () {
      final styler = QuectoColors.rgb(255, 128, 0);
      final result = styler('Hello');
      expect(result, '\x1B[38;2;255;128;0mHello\x1B[39m');
    });

    test('bgRgb background produces correct escape code', () {
      final styler = QuectoColors.bgRgb(0, 0, 255);
      final result = styler('Hello');
      expect(result, '\x1B[48;2;0;0;255mHello\x1B[49m');
    });

    test('underlineRgb produces correct escape code', () {
      final styler = QuectoColors.underlineRgb(128, 64, 32);
      final result = styler('Hello');
      expect(result, '\x1B[58;2;128;64;32mHello\x1B[59m');
    });

    test('rgb with all zeros (black)', () {
      final result = QuectoColors.rgb(0, 0, 0)('test');
      expect(result, '\x1B[38;2;0;0;0mtest\x1B[39m');
    });

    test('rgb with all 255 (white)', () {
      final result = QuectoColors.rgb(255, 255, 255)('test');
      expect(result, '\x1B[38;2;255;255;255mtest\x1B[39m');
    });
  });

  group('Nesting with extended colors', () {
    test('basic color inside 256-color restores 256-color', () {
      // ansi256(196) wraps text; inside we have blue text that closes with \x1B[39m
      // The 256-color styler should detect the \x1B[39m close and re-inject its open code
      final outerStyler = QuectoColors.ansi256(196);
      final innerText = QuectoColors.blue('inner');
      // innerText = \x1B[34minner\x1B[39m
      final result = outerStyler('before $innerText after');
      // Should detect \x1B[39m inside and re-inject \x1B[38;5;196m
      expect(result, contains('\x1B[38;5;196m'));
      // The close code of blue (\x1B[39m) should be followed by the 256-color reopen
      expect(result, contains('\x1B[38;5;196m after'));
      // Should end with the 256-color close
      expect(result, endsWith('\x1B[39m'));
    });

    test('256-color inside basic color restores basic color', () {
      // red wraps text; inside we have ansi256(21) text that closes with \x1B[39m
      final innerText = QuectoColors.ansi256(21)('inner');
      // innerText = \x1B[38;5;21minner\x1B[39m
      final result = QuectoColors.red('before $innerText after');
      // red should detect \x1B[39m from inner close and re-inject \x1B[31m
      expect(result, contains('\x1B[31m after'));
      expect(result, endsWith('\x1B[39m'));
    });

    test('multiple nested close codes in extended color', () {
      final outer = QuectoColors.ansi256(196);
      final inner1 = QuectoColors.blue('a');
      final inner2 = QuectoColors.green('b');
      final result = outer('$inner1$inner2');
      // Should have the open code re-injected after each inner close
      // Count occurrences of the 256-color open code
      final openCode = '\x1B[38;5;196m';
      final count = openCode.allMatches(result).length;
      // Initial open + after inner1 close + after inner2 close = 3
      expect(count, 3, reason: 'Expected 3 occurrences of 256-color open code: ${esc(result)}');
    });

    test('bg 256-color nesting with bg basic color', () {
      final outer = QuectoColors.bgAnsi256(21);
      final inner = QuectoColors.bgRed('inner');
      // inner closes with \x1B[49m, outer should detect it
      final result = outer('before $inner after');
      expect(result, contains('\x1B[48;5;21m after'));
    });
  });

  group('rgbToAnsi256 conversion', () {
    test('black maps to 16', () {
      expect(QuectoColors.rgbToAnsi256(0, 0, 0), 16);
    });

    test('white maps to 231', () {
      expect(QuectoColors.rgbToAnsi256(255, 255, 255), 231);
    });

    test('pure red maps to 196', () {
      expect(QuectoColors.rgbToAnsi256(255, 0, 0), 196);
    });

    test('pure green maps to 46', () {
      expect(QuectoColors.rgbToAnsi256(0, 255, 0), 46);
    });

    test('pure blue maps to 21', () {
      expect(QuectoColors.rgbToAnsi256(0, 0, 255), 21);
    });

    test('mid-gray enters grayscale ramp', () {
      final result = QuectoColors.rgbToAnsi256(128, 128, 128);
      // Should be in grayscale range 232-255
      expect(result, greaterThanOrEqualTo(232));
      expect(result, lessThanOrEqualTo(255));
    });

    test('near-black gray uses grayscale ramp', () {
      final result = QuectoColors.rgbToAnsi256(8, 8, 8);
      expect(result, greaterThanOrEqualTo(232));
    });

    test('near-white gray uses grayscale ramp', () {
      final result = QuectoColors.rgbToAnsi256(248, 248, 248);
      expect(result, greaterThanOrEqualTo(232));
      expect(result, lessThanOrEqualTo(255));
    });
  });

  group('QuectoPlain extended colors', () {
    test('ansi256 plain produces correct code', () {
      final styler = QuectoPlain.ansi256(196);
      final result = styler('Hello');
      expect(result, '\x1B[38;5;196mHello\x1B[39m');
    });

    test('bgAnsi256 plain produces correct code', () {
      final result = QuectoPlain.bgAnsi256(21)('Hello');
      expect(result, '\x1B[48;5;21mHello\x1B[49m');
    });

    test('rgb plain produces correct code', () {
      final result = QuectoPlain.rgb(255, 0, 128)('Hello');
      expect(result, '\x1B[38;2;255;0;128mHello\x1B[39m');
    });

    test('bgRgb plain produces correct code', () {
      final result = QuectoPlain.bgRgb(10, 20, 30)('Hello');
      expect(result, '\x1B[48;2;10;20;30mHello\x1B[49m');
    });

    test('underlineAnsi256 plain produces correct code', () {
      final result = QuectoPlain.underlineAnsi256(82)('Hello');
      expect(result, '\x1B[58;5;82mHello\x1B[59m');
    });

    test('underlineRgb plain produces correct code', () {
      final result = QuectoPlain.underlineRgb(1, 2, 3)('Hello');
      expect(result, '\x1B[58;2;1;2;3mHello\x1B[59m');
    });

    test('plain does not handle nesting (by design)', () {
      // QuectoPlain skips scanning — nesting is not re-injected
      final outer = QuectoPlain.ansi256(196);
      final inner = QuectoColors.blue('inner');
      final result = outer('before $inner after');
      // Should just wrap the entire string, NOT re-inject after inner close
      expect(result, '\x1B[38;5;196mbefore $inner after\x1B[39m');
    });
  });

  group('String extension methods', () {
    test('ansi256 extension', () {
      final result = 'Hello'.ansi256(196);
      expect(result, '\x1B[38;5;196mHello\x1B[39m');
    });

    test('bgAnsi256 extension', () {
      final result = 'Hello'.bgAnsi256(21);
      expect(result, '\x1B[48;5;21mHello\x1B[49m');
    });

    test('underlineAnsi256 extension', () {
      final result = 'Hello'.underlineAnsi256(82);
      expect(result, '\x1B[58;5;82mHello\x1B[59m');
    });

    test('rgb extension', () {
      final result = 'Hello'.rgb(255, 128, 0);
      expect(result, '\x1B[38;2;255;128;0mHello\x1B[39m');
    });

    test('bgRgb extension', () {
      final result = 'Hello'.bgRgb(0, 0, 255);
      expect(result, '\x1B[48;2;0;0;255mHello\x1B[49m');
    });

    test('underlineRgb extension', () {
      final result = 'Hello'.underlineRgb(128, 64, 32);
      expect(result, '\x1B[58;2;128;64;32mHello\x1B[59m');
    });

    test('chaining with basic styles', () {
      final result = 'Hello'.ansi256(196);
      // Further chain with bold
      final bolded = result.bold;
      expect(bolded, startsWith('\x1B[1m'));
      expect(bolded, endsWith('\x1B[22m'));
      expect(bolded, contains('\x1B[38;5;196m'));
    });
  });

  group('AnsiPen extended methods', () {
    test('ansi256Fg applies foreground', () {
      final pen = AnsiPen()..ansi256Fg(196);
      final result = pen('Hello');
      expect(result, '\x1B[38;5;196mHello\x1B[39m');
    });

    test('ansi256Bg applies background', () {
      final pen = AnsiPen()..ansi256Bg(21);
      final result = pen('Hello');
      expect(result, '\x1B[48;5;21mHello\x1B[49m');
    });

    test('underlineAnsi256 on pen', () {
      final pen = AnsiPen()..underlineAnsi256(82);
      final result = pen('Hello');
      expect(result, '\x1B[58;5;82mHello\x1B[59m');
    });

    test('rgbFg applies foreground RGB', () {
      final pen = AnsiPen()..rgbFg(255, 128, 0);
      final result = pen('Hello');
      expect(result, '\x1B[38;2;255;128;0mHello\x1B[39m');
    });

    test('rgbBg applies background RGB', () {
      final pen = AnsiPen()..rgbBg(0, 0, 255);
      final result = pen('Hello');
      expect(result, '\x1B[48;2;0;0;255mHello\x1B[49m');
    });

    test('underlineRgb on pen', () {
      final pen = AnsiPen()..underlineRgb(128, 64, 32);
      final result = pen('Hello');
      expect(result, '\x1B[58;2;128;64;32mHello\x1B[59m');
    });

    test('chaining extended with basic styles', () {
      final pen = AnsiPen()..ansi256Fg(196)..bold;
      final result = pen('Hello');
      // bold wraps around ansi256Fg (stack applies inner-to-outer)
      expect(result, contains('\x1B[38;5;196m'));
      expect(result, contains('\x1B[1m'));
    });

    test('method chaining returns this', () {
      final pen = AnsiPen();
      final returned = pen.ansi256Fg(196);
      expect(identical(returned, pen), isTrue);
    });
  });

  group('ansiColorDisabled passthrough', () {
    // We can't easily toggle ansiColorDisabled in tests because the stylers
    // are created at class load time. But createExtendedStyler creates new
    // closures per call, so we can test the disabled path by checking behavior
    // when ansiColorDisabled is set.
    //
    // Note: Since the basic static finals are already created, we only test
    // the extended methods here which create closures on demand.

    test('extended stylers respect ansiColorDisabled at creation time', () {
      // Save current state
      final wasDisabled = ansiColorDisabled;
      try {
        ansiColorDisabled = true;
        final styler = QuectoColors.ansi256(196);
        expect(styler('Hello'), 'Hello');

        final rgbStyler = QuectoColors.rgb(255, 0, 0);
        expect(rgbStyler('Hello'), 'Hello');

        final bgStyler = QuectoColors.bgAnsi256(21);
        expect(bgStyler('Hello'), 'Hello');

        final bgRgbStyler = QuectoColors.bgRgb(0, 0, 255);
        expect(bgRgbStyler('Hello'), 'Hello');
      } finally {
        ansiColorDisabled = wasDisabled;
      }
    });

    test('plain extended stylers respect ansiColorDisabled', () {
      final wasDisabled = ansiColorDisabled;
      try {
        ansiColorDisabled = true;
        final styler = QuectoPlain.ansi256(196);
        expect(styler('Hello'), 'Hello');

        final rgbStyler = QuectoPlain.rgb(255, 0, 0);
        expect(rgbStyler('Hello'), 'Hello');
      } finally {
        ansiColorDisabled = wasDisabled;
      }
    });
  });

  group('Edge cases', () {
    test('empty string with extended styler', () {
      final result = QuectoColors.ansi256(196)('');
      expect(result, '\x1B[38;5;196m\x1B[39m');
    });

    test('single character with extended styler', () {
      final result = QuectoColors.ansi256(196)('X');
      expect(result, '\x1B[38;5;196mX\x1B[39m');
    });

    test('string shorter than close code length', () {
      final result = QuectoColors.ansi256(196)('Hi');
      expect(result, '\x1B[38;5;196mHi\x1B[39m');
    });

    test('extended styler cached and reused produces consistent results', () {
      final styler = QuectoColors.ansi256(196);
      final r1 = styler('Hello');
      final r2 = styler('World');
      expect(r1, '\x1B[38;5;196mHello\x1B[39m');
      expect(r2, '\x1B[38;5;196mWorld\x1B[39m');
    });
  });
}
