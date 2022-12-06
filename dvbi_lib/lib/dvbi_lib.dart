library dvbi_lib;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:xml/xml_events.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class ServiceListManager {
  //field
  //functions of servicelistmanager class

  Future<String> readEndpoint() async {
    print("object in readendpoint");
    var filePath = p.join(Directory.current.path, 'endpointurl.txt');
    print(filePath);
    File file = File(filePath);
    var fileContent = await file.readAsString();

    return fileContent;
  }

  Future<Stream<List<XmlEvent>>> getXmlStream() async {
    String endpoint = await readEndpoint();
    final url = Uri.parse(endpoint);
    final request = await HttpClient().getUrl(url);
    final response = await request.close();
    return response.transform(utf8.decoder).toXmlEvents();
  }

  Future<void> showChannelStream() async {
    var mystream = await getXmlStream();
    print("in showchannelstream");

    await mystream
        .selectSubtreeEvents((e) => e.name == "Service")
        .toXmlNodes()
        .flatten()
        .forEach((e) => print(e.getElement("ServiceName")?.innerText));

    /*mystream
        .selectSubtreeEvents(((event) => event.name == "Service"))
        .toXmlNodes()
        .flatten()
        .toList();*/
  }

  //old
  Future<http.Response> fetchServiceList() async {
    String endpoint = await readEndpoint();
    print("object");
    print(endpoint);
    return await http.get(Uri.parse(endpoint));
  }

  //old
  Future<XmlDocument> getServiceListXml() async {
    var response = await fetchServiceList();

    if (response.statusCode == 200) {
      final serviceList = XmlDocument.parse(response.body.toString());

      return serviceList;

      print("Done");
    } else {
      print("sth went wrong code: " + response.statusCode.toString());

      return XmlDocument.parse(response.body.toString());
    }
  }

  //old
  Future<void> showChannels() async {
    final document = await getServiceListXml();
    final serviceNames = document.findAllElements('ServiceName');
    //channel list as string
    serviceNames.map((node) => node.text).forEach((element) => print(element));
    print(serviceNames.length);
    print("Done");
  }

  //old
  Future<void> testerFun() async {
    print("testerFun");
    final document = await getServiceListXml();
    var res = document.findAllElements("Service");

    //ServiceName
    /*
    res.map((e) => e.getElement("ServiceName")).forEach((e) => print(e?.text));
    res.map((e) => e.getElement("ServiceName").text);
    */
    //mdpUri
    /*
        .map((e) => e
            .getElement("ServiceInstance")
            ?.getElement("DASHDeliveryParameters")
            ?.getElement("UriBasedLocation")
            ?.getElement("URI")
            ?.text)
        .forEach((element) => print(element));
      */
    //channelBannerUri

    /*
    res
        .map((e) => e
            .getElement("RelatedMaterial")
            ?.getElement("MediaLocator")
            ?.getElement("tva:MediaUri")
            ?.text)
        .forEach((element) => print(element));
    */

    //Playlistobj
  }

  //old
  /**
   *  transform xml to List of Serviceobjects 
   */
  Future<Iterable<ServiceObject>> transformXMLToServiceObjList() async {
    print("get ServiceObjects");
    final document = await getServiceListXml();
    var res = document.findAllElements("Service").map((e) => ServiceObject(
        "serviceName", "mpdURI", "channelBannerURI", PlayListObject()));
    return res;
  }
}

class PlayListObject {
//fetch program later

}

/**
 * class that contains meta information about each service form a servicelist 
 */
class ServiceObject {
  //getter
  String serviceName = "";
  String mpdURI = "";
  String channelBannerURI = "";

  PlayListObject playListObject;

//constructor short way
  ServiceObject(this.serviceName, this.mpdURI, this.channelBannerURI,
      this.playListObject);
}



/*
ServiceObject
•	Uri -> mpd stream
•	Servicename(channelname)
•	contentUrl -> playlistObject (what is running on different channels)
Uri -> channel banner

 */
