import 'perftest_harness.dart';

class AsciiChart {
  static String unicode1_8thBlocks = '▏▏▍▌▋▊	▉█';
  static String unicodeLowerBlocks = '▄	▅';

  static String tick = '█'; //'▇';
 // static String tick2 = '░';//	▒
  static String smallTick = '▏';

  static int calls=0;

  /// Assumes percent is 0-100.0 scale (it can be 400%, etc, but 100 based
  static String getPercentLine( double percent, double percentPerChar ) {
    calls++;
    //double percentPerChar = 100.0 / totalWidth.toDouble();

    if(percentPerChar<1.0) {
      percentPerChar = 1.0;
    }

    //int blocks = ((percent / percentPerChar) + 0.5).round();

    StringBuffer sb = StringBuffer();
    double where = 0.0;
    while(where<percent) {
      //alternate rows//sb.write((calls%2==0) ? tick2 : tick);
      sb.write(tick);
      where += percentPerChar;
    }
    sb.write(' ${percent.toStringAsFixed(1)}%');
    return sb.toString();
  }

  static String getLineBarGraph( double totalValue, double unitsPerBlock, String unitsPerBlockString ) {
    StringBuffer sb = StringBuffer();
    double where = 0;
    while(where<totalValue) {
      sb.write(tick);
      where+=unitsPerBlock;
    }
    sb.write(' ${totalValue.toStringAsFixed(1)} $unitsPerBlockString');
    return sb.toString();
  }


  static String namePaddedToLength( String name, int pad ) {
    if(name.length>pad) {
      return name.substring(0,pad);  // take first `pad` chars
    } else {
      return name.padRight(pad);
    }
  }


/*

Block Elements[1]
Official Unicode Consortium code chart (PDF)
       	0	1	2	3	4	5	6	7	8	9	A	B	C	D	E	F
U+258x	▀	▁	▂	▃	▄	▅	▆	▇	█	▉	▊	▋	▌	▍	▎	▏
U+259x	▐	░	▒	▓	▔	▕	▖	▗	▘	▙	▚	▛	▜	▝	▞	▟

*/

}

/*
▉▉▉▉▉▉▉
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▒▒▒▒▒▒▒▒▒▒▒▒

█████████████████████   full block
▌▌   half block
▎▎▎  quater block
	▊	▊	▊	▊ three quarters block [ NO different scale ]

█████▌                // fulls with half on the end..

▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
▇▇▇▇
▍▍▍▍
████
▇▇▇▇▍
████▍  small full with half 

   // TICK
TICK = "▇"
SM_TICK = "▏"
*/