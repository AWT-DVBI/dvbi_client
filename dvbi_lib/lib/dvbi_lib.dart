library dvbi_lib;

import 'dart:convert';
import 'dart:io';
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml_events.dart';

class XMLParser {
  String url = "https://dvb-i.net/production/services.php/de";

  Future<List<xml.XmlNode>> getServicesFromXML () async {
    // produces a request object
    var request = await HttpClient().getUrl(Uri.parse(url));
    // sends the request
    var response = await request.close();
    // transforms and prints the response
    return await response
      .transform(utf8.decoder)
      .toXmlEvents()
      .selectSubtreeEvents(((event) => event.name =="Service"))
      .toXmlNodes()
      .flatten()
      .toList();
    }

}

Future<void> main() async {
  XMLParser parser = XMLParser();
  List<xml.XmlNode> services = await parser.getServicesFromXML();
  print(services.length);

}
