import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chalkdart/chalk.dart' as ChalkDart;
import 'package:quectocolors/quectocolors.dart';
import 'package:quectocolors/ansipen.dart';
import 'package:ansicolor/ansicolor.dart' as AnsiColor;
import 'package:quectocolors/quectocolors_static.dart';
import 'package:quectocolors/src/quectocolors_alt.dart';

import 'chart.dart';
import 'dart:io';

enum TestVersion {
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


  int terminalWidth = stdout.terminalColumns - 1;

  //print('Determined terminal to be $width columns and $height rows ');
  
  if(terminalWidth<0) {
    terminalWidth = 80;
  }

  //NOT WORK ON WINDOWSfinal width = stdout.terminalColumns;
  final equalBarString = List.generate(terminalWidth, (_) => '=').join();

  print(equalBarString.red);
  print(equalBarString.green);
  print(equalBarString.blue);
  print(equalBarString.yellow);
  print(centerStrOnTerminal('QuectoColors Performance Testing Suite', terminalWidth));
  print('');
  print('');

  runTestSet( testVersion:TestVersion.simple, terminalWidth:terminalWidth);
  runTestSet( testVersion:TestVersion.simple_3styles, terminalWidth:terminalWidth );
  runTestSet( testVersion:TestVersion.complex, terminalWidth:terminalWidth );
  //runTestSet(  testMode:TestLevels.largerandom_complex, terminalWidth:terminalWidth );  // this just shows time factor of .indexOf() on huge buffers, but really isn't representative sample of real world use
  
}

typedef TestHarnessPerformanceTargetFunction = Stopwatch Function(int iterations, TestVersion testMode );

class SetOfPerformanceTests {
  ///static const int nanoSecondsIn1Millisecond = 1000000;
  static const int nanoSecondsIn1Microsecond = 1000;
  static const int defaultIterations = 100000;
  static const int maxDisplayAlgorithmNameLen = 25; // max length of algorithm name to display in chart
  final TestVersion testVersion;
  final int terminalWidth;
  final int iterations;
  final ResultsToPrint printSomeResults;
  final int printSomeNumberOfLinesAtStartAndEnd;

  SetOfPerformanceTests( {required this.testVersion, this.terminalWidth = 80, this.iterations=defaultIterations, this.printSomeResults = ResultsToPrint.oneAtStart, this.printSomeNumberOfLinesAtStartAndEnd=1} );

  int totalAlgorithmCount = 0;
  List<String> chartLineAlgorithmNameList = [];
  List<String> algorithmDescriptionList = [];
  List<double> percentList = [];
  List<QuectoStyler> stylerList = [];
  List<int> elapsedMillisecondsList = [];
  List<int> elapsedMicrosecondsList = [];
  List<double> averageTimePerIterationInNanosecondsList = [];

  double findMax(List<double> numbers) => numbers.reduce((a, b) => a > b ? a : b);

  int runPerformanceTestOnTestFunction( {required String algorithmName, required String algorithmDescription, required QuectoStyler colorForAlgorithm, required TestHarnessPerformanceTargetFunction testFunction }) {
    print('Starting $iterations iterations of $algorithmName ($algorithmDescription) -------------------'.magentaBright );


    final stopwatch = testFunction( iterations, testVersion );
    

    print('$algorithmName Complete-----------------------------------------------\n'.magentaBright );
    totalAlgorithmCount++;

    chartLineAlgorithmNameList.add( AsciiChart.namePaddedToLength(algorithmName, maxDisplayAlgorithmNameLen));
    algorithmDescriptionList.add(algorithmDescription);
    stylerList.add(colorForAlgorithm);
    elapsedMillisecondsList.add(stopwatch.elapsedMilliseconds);
    elapsedMicrosecondsList.add(stopwatch.elapsedMicroseconds);
    averageTimePerIterationInNanosecondsList.add( (stopwatch.elapsedMicroseconds.toDouble() / iterations.toDouble()) * nanoSecondsIn1Microsecond ); // convert to Nanoseconds per iteration

    return (totalAlgorithmCount-1); // Return INDEX of where we put this algorithm
}


  void printReportForSet(int setIndex) {
    print('-----------------------------------------------\n'.magentaBright );

    print('${chartLineAlgorithmNameList[setIndex]} (${algorithmDescriptionList[setIndex]}) performance test:'.blue);
    //print('Iterations: $iterations');
    print('  Total time for $iterations iterations: ${elapsedMillisecondsList[setIndex]} ms');
    print('  Average time per iteration: ${averageTimePerIterationInNanosecondsList[setIndex]} ms');

    //print('-----------------------------------------------\n'.magentaBright );

  }

  void summarizeResults({required int referenceIndexFor100Percent}) {
    assert(chartLineAlgorithmNameList.length == totalAlgorithmCount, 'Error: chartLineAlgorithmNameList.length=${chartLineAlgorithmNameList.length} != totalAlgorithmCount=$totalAlgorithmCount');
    assert(algorithmDescriptionList.length == totalAlgorithmCount, 'Error: algorithmDescriptionList.length=${algorithmDescriptionList.length} != totalAlgorithmCount=$totalAlgorithmCount');
    assert(percentList.length == totalAlgorithmCount, 'Error: percentList.length=${percentList.length} != totalAlgorithmCount=$totalAlgorithmCount');
    assert(stylerList.length == totalAlgorithmCount, 'Error: stylerList.length=${stylerList.length} != totalAlgorithmCount=$totalAlgorithmCount');
    assert(elapsedMillisecondsList.length == totalAlgorithmCount, 'Error: elapsedMillisecondsList.length=${elapsedMillisecondsList.length} != totalAlgorithmCount=$totalAlgorithmCount');
    assert(averageTimePerIterationInNanosecondsList.length == totalAlgorithmCount, 'Error: averageTimePerIterationList.length=${averageTimePerIterationInNanosecondsList.length} != totalAlgorithmCount=$totalAlgorithmCount');

    if(referenceIndexFor100Percent<0 || referenceIndexFor100Percent>=totalAlgorithmCount) {
      throw('Error: referenceIndexFor100Percent=$referenceIndexFor100Percent is out of range 0-$totalAlgorithmCount');
    }

    // And now create the percent list based on the reference algorithm 
    double reference100Percent = elapsedMillisecondsList[referenceIndexFor100Percent].toDouble();
    for(int i=0;i<totalAlgorithmCount;i++) {
      percentList.add((elapsedMillisecondsList[i].toDouble()/reference100Percent) * 100.0);
    }

    // get max width of any name
    int maxNameLen = 0;
    for(int i=0;i<totalAlgorithmCount;i++) {
      String name =chartLineAlgorithmNameList[i];
      if(name.length>maxNameLen) maxNameLen = name.length;
    }
    maxNameLen += 2; // 2 spaces of padding

    int roomForChart = terminalWidth-maxNameLen - 10; // 10 characters for numbers and units at end of chart line

    List<String> percentChart = [];
    List<String> timePerIterationChart = [];

    double maxTime = findMax(averageTimePerIterationInNanosecondsList);
    double unitsPerBlock = maxTime/roomForChart.toDouble(); //  100 block wide chart should fit largest time
    for(int i=0;i<totalAlgorithmCount;i++) {
      String name =chartLineAlgorithmNameList[i];
      timePerIterationChart.add( stylerList[i]( name + AsciiChart.getLineBarGraph(averageTimePerIterationInNanosecondsList[i], unitsPerBlock, 'ns') ) );
    }

    double maxPercent = findMax(percentList);
    //print('Found roomForChart=$roomForChart maxPercent=$maxPercent');
    maxPercent = ((maxPercent/100).floor() + 1.0)* 100.0;  // go to next largest full 100% block 
    //print('After round to next higher 100% =$maxPercent');
    double percentsPerBlock = maxPercent/roomForChart.toDouble(); //  100 block wide chart should fit largest time
    for(int i=0;i<totalAlgorithmCount;i++) {
      String name =chartLineAlgorithmNameList[i];
      percentChart.add( stylerList[i]( name + AsciiChart.getPercentLine(percentList[i], percentsPerBlock) ));
        //AsciiChart.getPercent(100,percent_0div1)
    }



    print('\n\n--------------------------CHARTS FOR $testVersion---------------------------\n');

    print('$testVersion : PERCENT time vs. QuectoColors ');
    for(var line in percentChart) {
      print(line);
    }

    print('\n$testVersion : Time Per Iteration');
    for(var line in timePerIterationChart) {
      print(line);
    }

    print('\n\n\n');
  }
}


late final randomBigString; // Generate a large random string
bool randomStringMade = false;

const int defaultIterations = 100000;
const int iterations = defaultIterations;
const ResultsToPrint printSomeResults = ResultsToPrint.oneAtStart;//someAtStartAndEnd;
const int printSomeNumberOfLinesAtStartAndEnd = 3;


void runTestSet( {required TestVersion testVersion, required int terminalWidth}) {  

  if(!randomStringMade) {
    // The large random test Tests the speed of indexing to find the next ESC sequence and handle nesting - 
    final random = Random();
    randomBigString = List.generate(200, (_) => String.fromCharCode(random.nextInt(26) + 97)).join(); // Generate a large random string
    randomStringMade = true;
  }
  if(terminalWidth<80) terminalWidth=80;  // Make the charts minimum of 80 chars wide

  
  print('Running All Performance Runs $iterations iterations of testVersion = ${testVersion} '.yellowBright );

  SetOfPerformanceTests perfSet = SetOfPerformanceTests(testVersion: testVersion, terminalWidth: terminalWidth, iterations: iterations, printSomeResults: printSomeResults, printSomeNumberOfLinesAtStartAndEnd: printSomeNumberOfLinesAtStartAndEnd );
  
  perfSet.runPerformanceTestOnTestFunction(algorithmName: 'QuectoColorsStatic', algorithmDescription: 'accessing Static methods directly',
                                          colorForAlgorithm: QuectoColorsStatic.cyanBright, testFunction: testQuectoColorsStatic );
  
  int referenceAlgIndex = perfSet.runPerformanceTestOnTestFunction(algorithmName: 'QuectoColors', algorithmDescription: 'quectoColors instance methods version',
                                          colorForAlgorithm: QuectoColorsStatic.magentaBright, testFunction: testQuectoColors );

  perfSet.runPerformanceTestOnTestFunction(algorithmName: 'QuectoColorsAlt', algorithmDescription: 'quectoColors ALTERNATE instance methods version',
                                          colorForAlgorithm: QuectoColorsStatic.gray, testFunction: testQuectoColorsAlt );


  perfSet.runPerformanceTestOnTestFunction(algorithmName: 'AnsiColors Package', algorithmDescription: 'original AnsiColors package - does not support nesting or complex styles',
                                          colorForAlgorithm: QuectoColorsStatic.greenBright, testFunction: testOriginalAnsi );
  perfSet.runPerformanceTestOnTestFunction(algorithmName: 'QuClrs String Extensions', algorithmDescription: 'QuectoColors style functions directly accessed off any String variable',
                                          colorForAlgorithm: QuectoColorsStatic.yellow, testFunction: testQuectoStringExtensions );
  perfSet.runPerformanceTestOnTestFunction(algorithmName: 'QuClrs AnsiPen Compatible', algorithmDescription: 'QuectoColors only requiring import change to "quectocolors/ansipen.dart"',
                                          colorForAlgorithm: QuectoColorsStatic.red, testFunction: testAnsiPenCompatibleQuectoColors );
  perfSet.runPerformanceTestOnTestFunction(algorithmName: 'ChalkDart Package', algorithmDescription: 'Using ChalkDart package',
                                          colorForAlgorithm: QuectoColorsStatic.blueBright, testFunction: testChalkDart );

  perfSet.summarizeResults(referenceIndexFor100Percent:referenceAlgIndex);
 
  print('\n\n\n');
}





Stopwatch testQuectoColorsStatic(int iterations, TestVersion testMode ) {
  String outStr;

  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    switch(testMode) {
      case TestVersion.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        outStr = QuectoColorsStatic.red( 'Hello '+ QuectoColorsStatic.blue(randomBigString) + QuectoColorsStatic.green(' Here is inner ${QuectoColorsStatic.yellow(innerString2)} and end of green') + testThisStr);   
      case TestVersion.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
        outStr = QuectoColorsStatic.red( 'Hello '+ QuectoColorsStatic.blue(testThisStr) + QuectoColorsStatic.green(' Here is inner ${QuectoColorsStatic.yellow(innerString2)} and end of green') + ' and end of red');
      case TestVersion.simple:
        outStr = QuectoColorsStatic.red( 'Hello ');
      case TestVersion.simple_3styles:
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
  stopwatch.stop();

  return stopwatch;
}

Stopwatch testQuectoColors(int iterations, TestVersion testMode ) {
  final stopwatch1 = Stopwatch()..start();
  QuectoStyler simpleStyle = quectoColors.red;

  for (var i = 0; i < iterations; i++) {
    late final String outStr;
    switch(testMode) {
      case TestVersion.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        outStr = quectoColors.red( 'Hello '+ quectoColors.blue(randomBigString) + quectoColors.green(' Here is inner ${quectoColors.yellow(innerString2)} and end of green') + testThisStr);   
      case TestVersion.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
        outStr = quectoColors.red( 'Hello '+ quectoColors.blue(testThisStr) + quectoColors.green(' Here is inner ${quectoColors.yellow(innerString2)} and end of green') + ' and end of red');
      case TestVersion.simple:
        //outStr = QuectoColors.red( 'Hello ');
        outStr = simpleStyle('Hello ');
      case TestVersion.simple_3styles:
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
  return stopwatch1;
}

Stopwatch testOriginalAnsi(int iterations, TestVersion testMode ) {
  String outStr;
  final stopwatch2 = Stopwatch()..start();

  // make pen outside loop for fastest possible
  AnsiColor.AnsiPen pred = AnsiColor.AnsiPen()..red();
  AnsiColor.AnsiPen pgreen = AnsiColor.AnsiPen()..green();   // AnsiColor compatible notation `..`
  AnsiColor.AnsiPen pblue = AnsiColor.AnsiPen()..blue();
  AnsiColor.AnsiPen pyellow= AnsiColor.AnsiPen()..yellow();
  AnsiColor.AnsiPen p3Styles = AnsiColor.AnsiPen()..red();  // simplified notation
  for (var i = 0; i < iterations; i++) {
    switch(testMode) {
      case TestVersion.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        //shows broken nesting      
        //WRONG  OUTPUT
        outStr =pred( 'Hello '+ pblue(randomBigString) + pgreen(' Here is inner ${pyellow(innerString2)} and end of green') + testThisStr);
      case TestVersion.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
        //shows broken nesting      
        //WRONG  output
        outStr =pred( 'Hello '+ pblue(testThisStr) + pgreen(' Here is inner ${pyellow(innerString2)} and end of green') + ' and end of red');
      case TestVersion.simple:
        //AnsiPen pred = AnsiPen()..red();
        outStr = pred( 'Hello ' );
      case TestVersion.simple_3styles:
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
  stopwatch2.stop();
  return stopwatch2;
}

Stopwatch testQuectoStringExtensions(int iterations, TestVersion testMode) {
    //Test the string extensions version
  final stopwatch3 = Stopwatch()..start();

  for (var i = 0; i < iterations; i++) {
    late final String outStr;
    switch(testMode) {
      case TestVersion.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        outStr = ('Hello '+ randomBigString.blue + ' Here is inner ${innerString2.yellow} and end of green'.green + ' and end of red').red;   
      case TestVersion.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
    
        outStr = ('Hello '+ testThisStr.blue + ' Here is inner ${(innerString2.yellow)} and end of green'.green + ' and end of red').red;
      case TestVersion.simple:
        outStr = 'Hello '.red;
      case TestVersion.simple_3styles:
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
  return stopwatch3;
}

Stopwatch testAnsiPenCompatibleQuectoColors(int iterations, TestVersion testMode) {
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
      case TestVersion.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        //shows broken nesting      
        //WRONG  OUTPUT
        outStr =pred( 'Hello '+ pblue(randomBigString) + pgreen(' Here is inner ${pyellow(innerString2)} and end of green') + testThisStr);
      case TestVersion.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
        //shows broken nesting      
        //WRONG  output
        outStr =pred( 'Hello '+ pblue(testThisStr) + pgreen(' Here is inner ${pyellow(innerString2)} and end of green') + ' and end of red');
      case TestVersion.simple:
        //AnsiPen pred = AnsiPen()..red();
        outStr = pred( 'Hello ' );
      case TestVersion.simple_3styles:
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
  return stopwatch4;
}

Stopwatch testChalkDart(int iterations, TestVersion testMode) {
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
      case TestVersion.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        outStr = cred( 'Hello '+ cblue(randomBigString) + cgreen(' Here is inner ${cyellow(innerString2)} and end of green') + testThisStr);
      case TestVersion.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
        outStr = cred( 'Hello '+ cblue(testThisStr) + cgreen(' Here is inner ${cyellow(innerString2)} and end of green') + ' and end of red');
      case TestVersion.simple:
        outStr = cred( 'Hello ' );
      case TestVersion.simple_3styles:
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
  return stopwatch5;
}



Stopwatch testQuectoColorsAlt(int iterations, TestVersion testMode ) {
  final stopwatch6 = Stopwatch()..start();
  QuectoStyler simpleStyle =  quectoColorsAlt.red;

  for (var i = 0; i < iterations; i++) {
    late final String outStr;
    switch(testMode) {
      case TestVersion.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        outStr = quectoColorsAlt.red( 'Hello '+ quectoColorsAlt.blue(randomBigString) + quectoColorsAlt.green(' Here is inner ${quectoColorsAlt.yellow(innerString2)} and end of green') + testThisStr);   
      case TestVersion.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
        outStr = quectoColorsAlt.red( 'Hello '+ quectoColorsAlt.blue(testThisStr) + quectoColorsAlt.green(' Here is inner ${quectoColorsAlt.yellow(innerString2)} and end of green') + ' and end of red');
      case TestVersion.simple:
        //outStr = quectoColorsAlt.red( 'Hello ');
        outStr = simpleStyle('Hello ');
      case TestVersion.simple_3styles:
        outStr = quectoColorsAlt.strikethrough( quectoColorsAlt.italic( quectoColorsAlt.red( 'Hello ')));
    }
    if(printSomeResults == ResultsToPrint.none) {
      // do nothing
    } else if(printSomeResults == ResultsToPrint.oneAtStart && i==0) {
      print(outStr);
      //print(quectoColorsAlt.debugOut(outStr));
    } else if (printSomeResults == ResultsToPrint.someAtStartAndEnd && (i<printSomeNumberOfLinesAtStartAndEnd || i>=(iterations-printSomeNumberOfLinesAtStartAndEnd))) {
      print(outStr);
    }
  }
  stopwatch6.stop();
  return stopwatch6;
}