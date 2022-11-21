library dvbi_lib;

import 'package:xml/xml.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class XmlParser {
  //field
  var myXml = '''<?xml version = "1.0"?> 
   <bookshelf> 
      <book> 
         <title lang = "english">Growing a Language</title> 
         <price>29.99</price> 
      </book> 
      
      <book> 
         <title lang = "english">Learning XML</title> 
         <price>39.95</price> 
      </book> 
      <price>132.00</price> 
   </bookshelf>''';

  // function
  void xmlHandler() {
    final doc = XmlDocument.parse(myXml);

    print("testrun");
    final prices = doc.findAllElements('price');
    prices.map((node) => node.text).forEach(print);
  }
}
