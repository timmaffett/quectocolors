import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chalkdart/chalk.dart' as ChalkDart;
import 'package:quectocolors/quectocolors.dart';
import 'package:quectocolors/ansipen.dart';
import 'package:ansicolor/ansicolor.dart' as AnsiColor;
import 'package:quectocolors/quectocolors_static.dart';

import 'chart.dart';
import 'dart:io';

enum TestLevels {
  simple,
  simple_3styles,
  complex,
  largerandom_complex,
}

enum ResultsToPrint {
  none,
  oneAtStart,
  someAtStartAndEnd,
}

const int test = 2;

String centerStrOnTerminal(String title, int width) {
  int len = title.length;
  int leftOver = width-len;
  int indent = 0;
  if(leftOver > 0) {
    indent = leftOver ~/ 2;
  }
  return title.padLeft(indent+len);
}


void main() async {
  if (!stdout.hasTerminal) {
    print('Stdout not attached to a terminal! Exiting...');
    exit(0);
  }

  //print('${stdout.terminalLines} x ${stdout.terminalColumns}');

  //LINUX ONLY//ProcessSignal.sigwinch.watch().listen((_) {
  //LINUX ONLY//  print('${stdout.terminalLines} x ${stdout.terminalColumns}');
  //LINUX ONLY//});


  int consoleWidth = stdout.terminalColumns - 1;

  //print('Determined terminal to be $width columns and $height rows ');
  
  if(consoleWidth<0) {
    consoleWidth = 80;
  }

  //NOT WORK ON WINDOWSfinal width = stdout.terminalColumns;
  final equalBarString = List.generate(consoleWidth, (_) => '=').join();

  print(equalBarString.red);
  print(equalBarString.green);
  print(equalBarString.blue);
  print(equalBarString.yellow);
  print(centerStrOnTerminal('QuectoColors Performance Testing Suite', consoleWidth));
  print('');
  print('');

  runTests( TestLevels.simple, consoleWidth);
  runTests( TestLevels.simple_3styles, consoleWidth );
  runTests( TestLevels.complex, consoleWidth );
  //runTests( TestLevels.largerandom_complex );  // this just shows time factor of .indexOf() on huge buffers, but really isn't representative sample of real world use
  
}


void runTests( TestLevels testMode, int consoleWidth ) {

  if(consoleWidth<80) consoleWidth=80;  // Make the charts minimum of 80 chars wide

  List<String> chartLineAlgorithmName = [];
  List<double> percentList = [];
  List<double> timePerIterationList = [];
  List<QuectoStyler> stylerList = [];

  const ResultsToPrint printSomeResults = ResultsToPrint.oneAtStart;//someAtStartAndEnd;
  const int printSomeNumberOfLinesAtStartAndEnd = 3;

  // The large random test Tests the speed of indexing to find the next ESC sequence and handle nesting - 
  final random = Random();
  final randomBigString = List.generate(200, (_) => String.fromCharCode(random.nextInt(26) + 97)).join(); // Generate a large random string

  print('Running testMode = ${testMode} '.yellowBright );

  print('-----------------------------------------------\n'.magentaBright );
  const int iterations = 100000;


  final stopwatch0 = Stopwatch()..start();

  for (var i = 0; i < iterations; i++) {
    late final String outStr;
    switch(testMode) {
      case TestLevels.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        outStr = QuectoColorsStatic.red( 'Hello '+ QuectoColorsStatic.blue(randomBigString) + QuectoColorsStatic.green(' Here is inner ${QuectoColorsStatic.yellow(innerString2)} and end of green') + testThisStr);   
      case TestLevels.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
        outStr = QuectoColorsStatic.red( 'Hello '+ QuectoColorsStatic.blue(testThisStr) + QuectoColorsStatic.green(' Here is inner ${QuectoColorsStatic.yellow(innerString2)} and end of green') + ' and end of red');
      case TestLevels.simple:
        outStr = QuectoColorsStatic.red( 'Hello ');
      case TestLevels.simple_3styles:
        outStr = QuectoColorsStatic.strikethrough( QuectoColorsStatic.italic( QuectoColorsStatic.red( 'Hello ')));
    }
    if(printSomeResults == ResultsToPrint.none) {
      // do nothing
    } else if(printSomeResults == ResultsToPrint.oneAtStart && i==0) {
      print(outStr);
      //print(QuectoColors.debugOut(outStr));
    } else if (printSomeResults == ResultsToPrint.someAtStartAndEnd && (i<printSomeNumberOfLinesAtStartAndEnd || i>=(iterations-printSomeNumberOfLinesAtStartAndEnd))) {
      print(outStr);
    }
  }
  stopwatch0.stop();

  print('QuectoColorsStatic (accessing Static methods directly) performance test:'.blue);
  print('Iterations: $iterations');
  print('Total time: ${stopwatch0.elapsedMilliseconds} ms');
  print('Average time per iteration: ${stopwatch0.elapsedMilliseconds / iterations} ms');
  final timeQuectoColorsStatic = stopwatch0.elapsedMilliseconds / iterations;


  print('-----------------------------------------------\n'.magentaBright );

  final stopwatch1 = Stopwatch()..start();
QuectoStyler simpleStyle = quectoColors.red;

  for (var i = 0; i < iterations; i++) {
    late final String outStr;
    switch(testMode) {
      case TestLevels.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        outStr = quectoColors.red( 'Hello '+ quectoColors.blue(randomBigString) + quectoColors.green(' Here is inner ${quectoColors.yellow(innerString2)} and end of green') + testThisStr);   
      case TestLevels.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
        outStr = quectoColors.red( 'Hello '+ quectoColors.blue(testThisStr) + quectoColors.green(' Here is inner ${quectoColors.yellow(innerString2)} and end of green') + ' and end of red');
      case TestLevels.simple:
        //outStr = QuectoColors.red( 'Hello ');
        outStr = simpleStyle('Hello ');
      case TestLevels.simple_3styles:
        outStr = quectoColors.strikethrough( quectoColors.italic( quectoColors.red( 'Hello ')));
    }
    if(printSomeResults == ResultsToPrint.none) {
      // do nothing
    } else if(printSomeResults == ResultsToPrint.oneAtStart && i==0) {
      print(outStr);
      //print(QuectoColors.debugOut(outStr));
    } else if (printSomeResults == ResultsToPrint.someAtStartAndEnd && (i<printSomeNumberOfLinesAtStartAndEnd || i>=(iterations-printSomeNumberOfLinesAtStartAndEnd))) {
      print(outStr);
    }
  }
  stopwatch1.stop();

  print('QuectoColors performance test:'.blue);
  print('Iterations: $iterations');
  print('Total time: ${stopwatch1.elapsedMilliseconds} ms');
  print('Average time per iteration: ${stopwatch1.elapsedMilliseconds / iterations} ms');
  final timeQuectoColors = stopwatch1.elapsedMilliseconds / iterations;

  double percent_1div0 = stopwatch1.elapsedMilliseconds/stopwatch0.elapsedMilliseconds;
  double percent_0div1 = stopwatch0.elapsedMilliseconds/stopwatch1.elapsedMilliseconds;

  print('PERCENT diff    QuectoColors Instance/QuectoColorsStatic = ${(percent_1div0*100.0).toStringAsFixed(2)}%  (<100% means faster)  QuectoColorsStatic/quectoColorsInstance =${(percent_0div1*100.0).toStringAsFixed(2)}%'.blueBright);

// AFTER we have static and instance now make the percent chart
  String nameFormatted = AsciiChart.namePaddedToLength('QuectoColorsStatic', 20);
  //percentChart.add( (nameFormatted + AsciiChart.getPercent(100,percent_0div1)).cyanBright );
  chartLineAlgorithmName.add( nameFormatted );
  percentList.add(percent_0div1*100.0);
  timePerIterationList.add(timeQuectoColorsStatic);
  stylerList.add( quectoColors.cyanBright );


nameFormatted = AsciiChart.namePaddedToLength('QuectoColors', 20);
//percentChart.add( (nameFormatted + AsciiChart.getPercent(100,100)).magentaBright );
chartLineAlgorithmName.add( nameFormatted );
percentList.add(100.0); // 100% for QuectoColors, as that is our 'reference' alogorithm
timePerIterationList.add(timeQuectoColors);
stylerList.add( quectoColors.magentaBright );

  print('-----------------------------------------------\n'.magentaBright );
  //Test the built in substring method for comparison.
  final stopwatch2 = Stopwatch()..start();
{
  // make pen outside loop for fastest possible
  AnsiColor.AnsiPen pred = AnsiColor.AnsiPen()..red();
  AnsiColor.AnsiPen pgreen = AnsiColor.AnsiPen()..green();   // AnsiColor compatible notation `..`
  AnsiColor.AnsiPen pblue = AnsiColor.AnsiPen()..blue();
  AnsiColor.AnsiPen pyellow= AnsiColor.AnsiPen()..yellow();
  AnsiColor.AnsiPen p3Styles = AnsiColor.AnsiPen()..red();  // simplified notation
  for (var i = 0; i < iterations; i++) {
    late final String outStr;
    switch(testMode) {
      case TestLevels.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        //shows broken nesting      
        //WRONG  OUTPUT
        outStr =pred( 'Hello '+ pblue(randomBigString) + pgreen(' Here is inner ${pyellow(innerString2)} and end of green') + testThisStr);
      case TestLevels.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
        //shows broken nesting      
        //WRONG  output
        outStr =pred( 'Hello '+ pblue(testThisStr) + pgreen(' Here is inner ${pyellow(innerString2)} and end of green') + ' and end of red');
      case TestLevels.simple:
        //AnsiPen pred = AnsiPen()..red();
        outStr = pred( 'Hello ' );
      case TestLevels.simple_3styles:
        outStr = p3Styles( 'Hello - Can only do red/bold - no third standard');
    }
    if(printSomeResults == ResultsToPrint.none) {
      // do nothing
    } else if(printSomeResults == ResultsToPrint.oneAtStart && i==0) {
      print(outStr);
      //print(QuectoColors.debugOut(outStr));
    } else if (printSomeResults == ResultsToPrint.someAtStartAndEnd && (i<printSomeNumberOfLinesAtStartAndEnd || i>=(iterations-printSomeNumberOfLinesAtStartAndEnd))) {
      print(outStr);
    }
  }
 }
  stopwatch2.stop();
  print('\nBuilt in USING ANSICOLORS performance test:'.green);
  print('Iterations: $iterations');
  print('Total time: ${stopwatch2.elapsedMilliseconds} ms');
  print('Average time per iteration: ${stopwatch2.elapsedMilliseconds / iterations} ms');
  final timeAnsiOrig = stopwatch2.elapsedMilliseconds / iterations;
  double percent_2div1 = stopwatch2.elapsedMilliseconds/stopwatch1.elapsedMilliseconds;

  double percent_1div2 = stopwatch1.elapsedMilliseconds/stopwatch2.elapsedMilliseconds;

  print('PERCENT diff    ansicolors/quectocolors = ${(percent_2div1*100.0).toStringAsFixed(2)}%  (<100% means faster)  quectocolors/ansicolors =${(percent_1div2*100.0).toStringAsFixed(2)}%'.blueBright);

  nameFormatted = AsciiChart.namePaddedToLength('AnsiColors', 20);
  //percentChart.add( (nameFormatted + AsciiChart.getPercent(100,percent_2div1)).greenBright );
  chartLineAlgorithmName.add( nameFormatted );
  percentList.add(percent_2div1*100.0);
  timePerIterationList.add(timeAnsiOrig);
  stylerList.add( quectoColors.greenBright );



  print('-----------------------------------------------\n'.magentaBright );
  //Test the string extensions version
  final stopwatch3 = Stopwatch()..start();

  for (var i = 0; i < iterations; i++) {
    late final String outStr;
    switch(testMode) {
      case TestLevels.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        outStr = ('Hello '+ randomBigString.blue + ' Here is inner ${innerString2.yellow} and end of green'.green + ' and end of red').red;   
      case TestLevels.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
    
        outStr = ('Hello '+ testThisStr.blue + ' Here is inner ${(innerString2.yellow)} and end of green'.green + ' and end of red').red;
      case TestLevels.simple:
        outStr = 'Hello '.red;
      case TestLevels.simple_3styles:
        outStr = 'Hello '.red.italic.strikethrough;
    }
    if(printSomeResults == ResultsToPrint.none) {
      // do nothing
    } else if(printSomeResults == ResultsToPrint.oneAtStart && i==0) {
      print(outStr);
      //print(QuectoColors.debugOut(outStr));
    } else if (printSomeResults == ResultsToPrint.someAtStartAndEnd && (i<printSomeNumberOfLinesAtStartAndEnd || i>=(iterations-printSomeNumberOfLinesAtStartAndEnd))) {
      print(outStr);
    }
  }
  stopwatch3.stop();

  print('\nBuilt in USING STRING EXTENTIONS performance test:'.yellowBright);
  print('Iterations: $iterations');
  print('Total time: ${stopwatch3.elapsedMilliseconds} ms');
  print('Average time per iteration: ${stopwatch3.elapsedMilliseconds / iterations} ms');
  final timeQuectoStrings = stopwatch3.elapsedMilliseconds / iterations; 

  double percent_3div1 = stopwatch3.elapsedMilliseconds/stopwatch1.elapsedMilliseconds;
  double percent_1div3 = stopwatch1.elapsedMilliseconds/stopwatch3.elapsedMilliseconds;

  double percent_3div2 = stopwatch3.elapsedMilliseconds/stopwatch2.elapsedMilliseconds;
  double percent_2div3 = stopwatch2.elapsedMilliseconds/stopwatch3.elapsedMilliseconds;


  print('PERCENT diff    quecto strings/quectocolors = ${(percent_3div1*100.0).toStringAsFixed(2)}%  (<100% means faster)  quectocolors/quecto strings = ${(percent_1div3*100.0).toStringAsFixed(2)}%'.blueBright);
  print('PERCENT diff    quecto strings/ANSICOLORS = ${(percent_3div2*100.0).toStringAsFixed(2)}%  (<100% means faster)   ANSICOLORS/quecto strings = ${(percent_2div3*100.0).toStringAsFixed(2)}%'.cyan);


  nameFormatted =AsciiChart.namePaddedToLength('QuectoStrings', 20);
  //percentChart.add( (nameFormatted + AsciiChart.getPercent(100,percent_3div1)).yellow );
  chartLineAlgorithmName.add( nameFormatted );
  percentList.add(percent_3div1*100.0);
  timePerIterationList.add(timeQuectoStrings);
  stylerList.add( quectoColors.yellow );



  print('\n-----Our AnsiPen compatible version------------------------------------------\n'.magentaBright );
  //Test the built in substring method for comparison.
  final stopwatch4 = Stopwatch()..start();

  // make pen outside loop for fastest possible
  AnsiPen pred = AnsiPen()..red();
  AnsiPen pgreen = AnsiPen()..green();   // AnsiColor compatible notation `..`
  AnsiPen pblue = AnsiPen().blue();
  AnsiPen pyellow= AnsiPen().yellow();
  AnsiPen p3Styles = AnsiPen().red().italic.strikethrough;  // simplified notation
  for (var i = 0; i < iterations; i++) {
    late final String outStr;
    switch(testMode) {
      case TestLevels.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        //shows broken nesting      
        //WRONG  OUTPUT
        outStr =pred( 'Hello '+ pblue(randomBigString) + pgreen(' Here is inner ${pyellow(innerString2)} and end of green') + testThisStr);
      case TestLevels.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
        //shows broken nesting      
        //WRONG  output
        outStr =pred( 'Hello '+ pblue(testThisStr) + pgreen(' Here is inner ${pyellow(innerString2)} and end of green') + ' and end of red');
      case TestLevels.simple:
        //AnsiPen pred = AnsiPen()..red();
        outStr = pred( 'Hello ' );
      case TestLevels.simple_3styles:
        outStr = p3Styles( 'Hello ');
    }
    if(printSomeResults == ResultsToPrint.none) {
      // do nothing
    } else if(printSomeResults == ResultsToPrint.oneAtStart && i==0) {
      print(outStr);
      //print(QuectoColors.debugOut(outStr));
    } else if (printSomeResults == ResultsToPrint.someAtStartAndEnd && (i<printSomeNumberOfLinesAtStartAndEnd || i>=(iterations-printSomeNumberOfLinesAtStartAndEnd))) {
      print(outStr);
    }
  }
  stopwatch4.stop();
  print('\nBuilt in USING ANSICOLORS compatible AnsiPen performance test:'.greenBright);
  print('Iterations: $iterations');
  print('Total time: ${stopwatch4.elapsedMilliseconds} ms');
  print('Average time per iteration: ${stopwatch4.elapsedMilliseconds / iterations} ms');
  final timeQuectoAni = stopwatch4.elapsedMilliseconds / iterations;

  double percent_2div4 = stopwatch2.elapsedMilliseconds/stopwatch4.elapsedMilliseconds;

  double percent_4div2 = stopwatch4.elapsedMilliseconds/stopwatch2.elapsedMilliseconds;

  double percent_4div1 = stopwatch4.elapsedMilliseconds/stopwatch1.elapsedMilliseconds;



  print('PERCENT diff    ansicolors/quectoANSI = ${(percent_2div4*100.0).toStringAsFixed(2)}%  (<100% means faster)  quectoANSI/ansicolors =${(percent_4div2*100.0).toStringAsFixed(2)}%'.blueBright);

  nameFormatted = AsciiChart.namePaddedToLength('QuectoAnsi', 20);
  //percentChart.add( (nameFormatted + AsciiChart.getPercent(100,percent_4div1)).red );
  chartLineAlgorithmName.add( nameFormatted );
  percentList.add(percent_4div1*100.0);
  timePerIterationList.add(timeQuectoAni);
  stylerList.add( quectoColors.red );




 print('\n-----ChalkDart version------------------------------------------\n'.magentaBright );
  //Test the built in substring method for comparison.
  final stopwatch5 = Stopwatch()..start();

  // make pen outside loop for fastest possible
  ChalkDart.Chalk cred = ChalkDart.chalk.red;
  ChalkDart.Chalk cgreen = ChalkDart.chalk.green;   // AnsiColor compatible notation `..`
  ChalkDart.Chalk cblue = ChalkDart.chalk.blue;
  ChalkDart.Chalk cyellow= ChalkDart.chalk.yellow;
  ChalkDart.Chalk c3Styles = ChalkDart.chalk.red.italic.strikethrough;  // simplified notation
  for (var i = 0; i < iterations; i++) {
    late final String outStr;
    switch(testMode) {
      case TestLevels.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        outStr = cred( 'Hello '+ cblue(randomBigString) + cgreen(' Here is inner ${cyellow(innerString2)} and end of green') + testThisStr);
      case TestLevels.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
        outStr =pred( 'Hello '+ cblue(testThisStr) + cgreen(' Here is inner ${cyellow(innerString2)} and end of green') + ' and end of red');
      case TestLevels.simple:
        outStr = cred( 'Hello ' );
      case TestLevels.simple_3styles:
        outStr = c3Styles( 'Hello ');
    }
    if(printSomeResults == ResultsToPrint.none) {
      // do nothing
    } else if(printSomeResults == ResultsToPrint.oneAtStart && i==0) {
      print(outStr);
      //print(QuectoColors.debugOut(outStr));
    } else if (printSomeResults == ResultsToPrint.someAtStartAndEnd && (i<printSomeNumberOfLinesAtStartAndEnd || i>=(iterations-printSomeNumberOfLinesAtStartAndEnd))) {
      print(outStr);
    }
  }
  stopwatch5.stop();
  print('\nBuilt in USING ChalkDart performance test:'.greenBright);
  print('Iterations: $iterations');
  print('Total time: ${stopwatch5.elapsedMilliseconds} ms');
  print('Average time per iteration: ${stopwatch5.elapsedMilliseconds / iterations} ms');
  final timeChalkDart = stopwatch5.elapsedMilliseconds / iterations;

  double percent_2div5 = stopwatch2.elapsedMilliseconds/stopwatch5.elapsedMilliseconds;
  double percent_5div2 = stopwatch5.elapsedMilliseconds/stopwatch2.elapsedMilliseconds;

  print('PERCENT diff    ansicolors/ChalkDart = ${(percent_2div5*100.0).toStringAsFixed(2)}%  (<100% means faster)  ChalkDart/ansicolors =${(percent_5div2*100.0).toStringAsFixed(2)}%'.blueBright);


  double percent_5div1 = stopwatch5.elapsedMilliseconds/stopwatch1.elapsedMilliseconds;
  double percent_1div5 = stopwatch1.elapsedMilliseconds/stopwatch5.elapsedMilliseconds;


  print('PERCENT diff    quectocolors/ChalkDart = ${(percent_5div1*100.0).toStringAsFixed(2)}%  (<100% means faster)  ChalkDart/quectocolors = ${(percent_1div5*100.0).toStringAsFixed(2)}%'.blueBright);

  nameFormatted = AsciiChart.namePaddedToLength('ChalkDart', 20);
  //percentChart.add( (nameFormatted + AsciiChart.getPercent(100,percent_5div1)).blueBright );
  chartLineAlgorithmName.add( nameFormatted );
  percentList.add(percent_5div1*100.0);
  timePerIterationList.add(timeChalkDart);
  stylerList.add( quectoColors.blueBright );

  double findMax(List<double> numbers) => numbers.reduce((a, b) => a > b ? a : b);

  // get max width of any name
  int maxNameLen = 0;
  for(int i=0;i<chartLineAlgorithmName.length;i++) {
    String name =chartLineAlgorithmName[i];
    if(name.length>maxNameLen) maxNameLen = name.length;
  }
  maxNameLen += 2; // 2 spaces of padding

  int roomForChart = consoleWidth-maxNameLen - 10; // 10 characters for numbers and units at end of chart line

  List<String> percentChart = [];
  List<String> timePerIterationChart = [];

  double maxTime = findMax(timePerIterationList) * 1000000.0; // convert milliseconds to nanoseconds
  double unitsPerBlock = maxTime/roomForChart.toDouble(); //  100 block wide chart should fit largest time
  for(int i=0;i<timePerIterationList.length;i++) {
    String name =chartLineAlgorithmName[i];
    timePerIterationChart.add( stylerList[i]( name + AsciiChart.getLineBarGraph( (timePerIterationList[i] * 1000000.0), unitsPerBlock, 'ns') ) );  // convert milliseconds to nanoseconds
  }

  double maxPercent = findMax(percentList);
  //print('Found roomForChart=$roomForChart maxPercent=$maxPercent');
  maxPercent = ((maxPercent/100).floor() + 1.0)* 100.0;  // go to next largest full 100% block 
  //print('After round to next higher 100% =$maxPercent');
  double percentsPerBlock = maxPercent/roomForChart.toDouble(); //  100 block wide chart should fit largest time
  for(int i=0;i<percentList.length;i++) {
    String name =chartLineAlgorithmName[i];
    percentChart.add( stylerList[i]( name + AsciiChart.getPercentLine(percentList[i], percentsPerBlock) ));
      //AsciiChart.getPercent(100,percent_0div1)
  }



  print('\n\n--------------------------CHARTS FOR $testMode---------------------------\n');

  print('$testMode : PERCENT time vs. QuectoColors ');
  for(var line in percentChart) {
    print(line);
  }

  print('\n$testMode : Time Per Iteration');
  for(var line in timePerIterationChart) {
    print(line);
  }

  print('\n\n\n');
}