/*
   This writes the code for the X11 color table entry points for chalkdart.dart
*/
/*
  @author: tim maffett
*/
import 'dart:io';
import 'package:args/args.dart';

const String outputStringExtensionClassFile = 'lib/src/quectocolors_css.g.dart';

bool htmlSpansInsteadOfInlineSvg = false;

void main(List<String> arguments) {
  print(
    'make_css_x11_methods - writing out QuectoColors CSS/X11 string extension class from CSS/X11 RGB list',
  );
  print('  Use --help for options');
  exitCode = 0; // presume success
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print help text and exit.',
    )
    ..addFlag(
      'htmlSpansInsteadOfInlineSvg',
      abbr: 'm',
      negatable: false,
      help:
          'Write example color using HTML span instead of Markdown image w/inline SVGs.  Warning VSCode will strip html from Markdown docs.',
    )
    ..addOption(
      'out',
      abbr: 'o',
      help:
          'specify output file to write to instead of `$outputStringExtensionClassFile`',
    );

  ArgResults argResults;

  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    printUsage(parser);
    exit(0);
  }

  if (argResults.wasParsed('help')) {
    printUsage(parser);
    exit(0);
  }

  final bool dumpToOutFile =
      argResults.wasParsed('out') && argResults['out'].isNotEmpty;
  final String stringOutputFileName = dumpToOutFile
      ? argResults['out']
      : outputStringExtensionClassFile;

  htmlSpansInsteadOfInlineSvg = argResults.wasParsed(
    'htmlSpansInsteadOfInlineSvg',
  );

  List<String> out = [];

  out = dumpQuectoColorCSSExtensionMethods();
  // and add the string extension methods for all the CSS/X11 colors
  out = dumpStringExtensionColorMethods(out);

  print('Writing QuectColor string extensions to `$stringOutputFileName`');

  File(stringOutputFileName).writeAsStringSync(out.join('\n').toString());

  exit(0);
}

List<String> dumpQuectoColorCSSExtensionMethods() {
  List<String> out = [];

  // Determine cache size (3 entries per color: fg + bg + underline)
  final keyList = colorKeywords.keys.toList();
  int cacheSize = keyList.length * 3;

  out.add(
    '''// Copyright (c) 2020-2026, tim maffett.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// BEGIN GENERATED CODE - DO NOT MODIFY BY HAND - generating code => /tool/makeX11EntryPoints.dart''',
  );

  out.add('''
import 'quectocolors.dart';

/// This extension class adds proper methods to QuectoColors for all of the
/// standard X11/CSS/SVG color names for use by QuectoColors.
extension QuectoColorsX11 on QuectoColors {
  static final List<QuectoStyler?> _cache = List<QuectoStyler?>.filled($cacheSize, null);
''');

  int cacheIdx = 0;
  for (int i = 0; i < keyList.length; i++) {
    final colorKeyword = keyList[i];
    final hexColorValue = colorKeywords[colorKeyword] ?? 0;
    num red = (hexColorValue >> 16) & 0xFF;
    num green = (hexColorValue >> 8) & 0xFF;
    num blue = hexColorValue & 0xFF;

    String colorHexStr = hexColorValue
        .toRadixString(16)
        .padLeft(6, '0')
        .toUpperCase();
    String entryPoint = colorKeyword;
    String onEntryPoint =
        'on${colorKeyword[0].toUpperCase()}${colorKeyword.substring(1)}';

    String cssColorCode = colorKeyword.toLowerCase();
    String colorSource = 'X11/CSS';
    if (cssColorCode == 'rebeccapurple' || cssColorCode == 'lightgoldenrod') {
      colorSource = 'X11';
      cssColorCode = 'rgb($red, $green, $blue)'; // these are X11 names
    } else if (cssColorCode == 'lightgoldenrodyellow') {
      colorSource = 'CSS';
    }
    cssColorCode = cssColorCode.replaceAll('x11', '');
    //String svgColor = cssColorCode;//"rgb%50$red,$green,$blue%51";
    String svgColor = "rgb%28$red,$green,$blue%29"; //cssColorCode;//
    String inlineSvgCode = !htmlSpansInsteadOfInlineSvg
        ? "![$cssColorCode](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='$svgColor'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32)"
        : "";
    String inlineSpanCode = htmlSpansInsteadOfInlineSvg
        ? "<span style='background-color: $cssColorCode;border: black solid 2px;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>"
        : "";

    outWithIndent(
      out,
      "/// set foreground color to $colorSource color $colorKeyword $inlineSvgCode$inlineSpanCode (0x$colorHexStr)/rgb($red, $green, $blue)",
    );
    outWithIndent(
      out,
      'static QuectoStyler get $entryPoint => _cache[$cacheIdx] ??= QuectoColors.rgb($red, $green, $blue);',
    );
    cacheIdx++;
    outWithIndent(out, '');
    outWithIndent(
      out,
      "/// set background color to $colorSource color $colorKeyword $inlineSvgCode$inlineSpanCode (0x$colorHexStr)/rgb($red, $green, $blue)",
    );
    outWithIndent(
      out,
      'static QuectoStyler get $onEntryPoint => _cache[$cacheIdx] ??= QuectoColors.bgRgb($red, $green, $blue);',
    );
    cacheIdx++;
    outWithIndent(out, '');
    outWithIndent(
      out,
      "/// set underline color to $colorSource color $colorKeyword $inlineSvgCode$inlineSpanCode (0x$colorHexStr)/rgb($red, $green, $blue)",
    );
    outWithIndent(
      out,
      'static QuectoStyler get ${onEntryPoint}Underline => _cache[$cacheIdx] ??= QuectoColors.underlineRgb($red, $green, $blue);',
    );
    cacheIdx++;
  }
  out.add('}');

  out.add('');
  out.add(
    '''// END GENERATED CODE - DO NOT MODIFY BY HAND - generating code => /examples/makeX11EntryPoints.dart
''',
  );

  return out;
}

List<String> dumpStringExtensionColorMethods(List<String> out) {
  out.add(
    '''// Copyright (c) 2020-2026, tim maffett.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// BEGIN GENERATED CODE - DO NOT MODIFY BY HAND - generating code => /tool/makeX11EntryPoints.dart''',
  );

  out.add('''

/// This extension class adds proper methods for all of the
/// standard CSS/X11/SVG color names for use by QuectoColors.
extension QuectoColorsCSSStrings on String {''');
  final keyList = colorKeywords.keys.toList();
  for (int i = 0; i < keyList.length; i++) {
    final colorKeyword = keyList[i];
    final hexColorValue = colorKeywords[colorKeyword] ?? 0;

    num red = (hexColorValue >> 16) & 0xFF;
    num green = (hexColorValue >> 8) & 0xFF;
    num blue = hexColorValue & 0xFF;

    String colorHexStr = hexColorValue
        .toRadixString(16)
        .padLeft(6, '0')
        .toUpperCase();
    String entryPoint = colorKeyword;
    String onEntryPoint =
        'on${colorKeyword[0].toUpperCase()}${colorKeyword.substring(1)}';

    String cssColorCode = colorKeyword.toLowerCase();
    String colorSource = 'CSS/X11';
    if (cssColorCode == 'rebeccapurple' || cssColorCode == 'lightgoldenrod') {
      colorSource = 'X11';
      cssColorCode = 'rgb($red, $green, $blue)'; // these are X11 names
    } else if (cssColorCode == 'lightgoldenrodyellow') {
      colorSource = 'CSS';
    }
    cssColorCode = cssColorCode.replaceAll('x11', '');
    String svgColor = "rgb%28$red,$green,$blue%29"; //cssColorCode;//
    String inlineSvgCode = !htmlSpansInsteadOfInlineSvg
        ? "![$cssColorCode](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='$svgColor'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32)"
        : "";
    String inlineSpanCode = htmlSpansInsteadOfInlineSvg
        ? "<span style='background-color: $cssColorCode;border: black solid 2px;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>"
        : "";

    outWithIndent(
      out,
      "/// set foreground color to $colorSource color $colorKeyword $inlineSvgCode$inlineSpanCode (0x$colorHexStr)/rgb($red, $green, $blue)",
    );
    outWithIndent(
      out,
      'String get $entryPoint => QuectoColorsX11.$entryPoint(this);',
    );
    outWithIndent(out, '');
    outWithIndent(
      out,
      "/// set background color to $colorSource color $colorKeyword $inlineSvgCode$inlineSpanCode (0x$colorHexStr)/rgb($red, $green, $blue)",
    );
    outWithIndent(
      out,
      'String get $onEntryPoint => QuectoColorsX11.$onEntryPoint(this);',
    );
    outWithIndent(out, '');
    outWithIndent(
      out,
      "/// set underline color to $colorSource color $colorKeyword $inlineSvgCode$inlineSpanCode (0x$colorHexStr)/rgb($red, $green, $blue)",
    );
    outWithIndent(
      out,
      'String get ${onEntryPoint}Underline => QuectoColorsX11.${onEntryPoint}Underline(this);',
    );

    if (i < (keyList.length - 1)) outWithIndent(out, '');
  }
  out.add('}');

  out.add('');
  out.add(
    '''// END GENERATED CODE - DO NOT MODIFY BY HAND - generating code => /tool/makeX11EntryPoints.dart
''',
  );

  return out;
}

void outWithIndent(List<String> out, String line) {
  if (line.isEmpty) {
    out.add('');
  } else {
    out.add('  $line');
  }
}

final Map<String, int> colorKeywords = <String, int>{
  'aliceBlue': 0xF0F8FF,
  'antiqueWhite': 0xFAEBD7,
  'aqua': 0x00FFFF,
  'aquamarine': 0x7FFFD4,
  'azure': 0xF0FFFF,
  'beige': 0xF5F5DC,
  'bisque': 0xFFE4C4,
  'blackX11': 0x000000,
  'blanchedAlmond': 0xFFEBCD,
  'blueX11': 0x0000FF,
  'blueViolet': 0x8A2BE2,
  'brown': 0xA52A2A,
  'burlywood': 0xDEB887,
  'cadetBlue': 0x5F9EA0,
  'chartreuse': 0x7FFF00,
  'chocolate': 0xD2691E,
  'coral': 0xFF7F50,
  'cornflowerBlue': 0x6495ED,
  'cornsilk': 0xFFF8DC,
  'crimson': 0xDC143C,
  'cyanX11': 0x00FFFF,
  'darkBlue': 0x00008B,
  'darkCyan': 0x008B8B,
  'darkGoldenrod': 0xB8860B,
  'darkGray': 0xA9A9A9,
  'darkGreen': 0x006400,
  'darkGrey': 0xA9A9A9,
  'darkKhaki': 0xBDB76B,
  'darkMagenta': 0x8B008B,
  'darkOliveGreen': 0x556B2F,
  'darkOrange': 0xFF8C00,
  'darkOrchid': 0x9932CC,
  'darkRed': 0x8B0000,
  'darkSalmon': 0xE9967A,
  'darkSeaGreen': 0x8FBC8F,
  'darkSlateBlue': 0x483D8B,
  'darkSlateGray': 0x2F4F4F,
  'darkSlateGrey': 0x2F4F4F,
  'darkTurquoise': 0x00CED1,
  'darkViolet': 0x9400D3,
  'deepPink': 0xFF1493,
  'deepSkyBlue': 0x00BFFF,
  'dimGray': 0x696969,
  'dimGrey': 0x696969,
  'dodgerBlue': 0x1E90FF,
  'fireBrick': 0xB22222,
  'floralWhite': 0xFFFAF0,
  'forestGreen': 0x228B22,
  'fuchsia': 0xFF00FF,
  'gainsboro': 0xDCDCDC,
  'ghostWhite': 0xF8F8FF,
  'gold': 0xFFD700,
  'goldenrod': 0xDAA520,
  'grayX11': 0x808080,
  'greenX11': 0x008000,
  'greenYellow': 0xADFF2F,
  'greyX11': 0x808080,
  'honeydew': 0xF0FFF0,
  'hotPink': 0xFF69B4,
  'indianRed': 0xCD5C5C,
  'indigo': 0x4B0082,
  'ivory': 0xFFFFF0,
  'khaki': 0xF0E68C,
  'lavender': 0xE6E6FA,
  'lavenderBlush': 0xFFF0F5,
  'lawnGreen': 0x7CFC00,
  'lemonChiffon': 0xFFFACD,
  'lightBlue': 0xADD8E6,
  'lightCoral': 0xF08080,
  'lightCyan': 0xE0FFFF,
  'lightGoldenrodYellow': 0xFAFAD2, // CSS colorname
  'lightGoldenrod': 0xFAFAD2, // X11 name
  'lightGray': 0xD3D3D3,
  'lightGreen': 0x90EE90,
  'lightGrey': 0xD3D3D3,
  'lightPink': 0xFFB6C1,
  'lightSalmon': 0xFFA07A,
  'lightSeaGreen': 0x20B2AA,
  'lightSkyBlue': 0x87CEFA,
  'lightSlateGray': 0x778899,
  'lightSlateGrey': 0x778899,
  'lightSteelBlue': 0xB0C4DE,
  'lightYellow': 0xFFFFE0,
  'lime': 0x00FF00,
  'limeGreen': 0x32CD32,
  'linen': 0xFAF0E6,
  'magentaX11': 0xFF00FF,
  'maroon': 0x800000,
  'mediumAquamarine': 0x66CDAA,
  'mediumBlue': 0x0000CD,
  'mediumOrchid': 0xBA55D3,
  'mediumPurple': 0x9370DB,
  'mediumSeaGreen': 0x3CB371,
  'mediumSlateBlue': 0x7B68EE,
  'mediumSpringGreen': 0x00FA9A,
  'mediumTurquoise': 0x48D1CC,
  'mediumVioletRed': 0xC71585,
  'midnightBlue': 0x191970,
  'mintCream': 0xF5FFFA,
  'mistyRose': 0xFFE4E1,
  'moccasin': 0xFFE4B5,
  'navajoWhite': 0xFFDEAD,
  'navy': 0x000080,
  'oldLace': 0xFDF5E6,
  'olive': 0x808000,
  'oliveDrab': 0x6B8E23,
  'orange': 0xFFA500,
  'orangeRed': 0xFF4500,
  'orchid': 0xDA70D6,
  'paleGoldenrod': 0xEEE8AA,
  'paleGreen': 0x98FB98,
  'paleTurquoise': 0xAFEEEE,
  'paleVioletRed': 0xDB7093,
  'papayaWhip': 0xFFEFD5,
  'peachPuff': 0xFFDAB9,
  'peru': 0xCD853F,
  'pink': 0xFFC0CB,
  'plum': 0xDDA0DD,
  'powderBlue': 0xB0E0E6,
  'purple': 0x800080,
  'rebeccaPurple': 0x663399,
  'redX11': 0xFF0000,
  'rosyBrown': 0xBC8F8F,
  'royalBlue': 0x4169E1,
  'saddleBrown': 0x8B4513,
  'salmon': 0xFA8072,
  'sandyBrown': 0xF4A460,
  'seaGreen': 0x2E8B57,
  'seashell': 0xFFF5EE,
  'sienna': 0xA0522D,
  'silver': 0xC0C0C0,
  'skyBlue': 0x87CEEB,
  'slateBlue': 0x6A5ACD,
  'slateGray': 0x708090,
  'slateGrey': 0x708090,
  'snow': 0xFFFAFA,
  'springGreen': 0x00FF7F,
  'steelBlue': 0x4682B4,
  'tan': 0xD2B48C,
  'teal': 0x008080,
  'thistle': 0xD8BFD8,
  'tomato': 0xFF6347,
  'turquoise': 0x40E0D0,
  'violet': 0xEE82EE,
  'wheat': 0xF5DEB3,
  'whiteX11': 0xFFFFFF,
  'whiteSmoke': 0xF5F5F5,
  'yellowX11': 0xFFFF00,
  'yellowGreen': 0x9ACD32,
};

void printUsage(ArgParser parser) {
  print('''Usage: make_css_x11_methods.dart
${parser.usage}
''');
}
