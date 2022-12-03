// ignore_for_file: avoid_print

library dvbi_lib;

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:io';

class ServiceListManager {
  //field

  String endpointUrl = "https://dvb-i.net/production/services.php/de";

  //functions of servicelistmanager class

  Future<http.Response> fetchServiceList() {
    return http.get(Uri.parse(endpointUrl));
  }

  Future<XmlDocument> getServiceListXml() async {
    var response = await fetchServiceList();

    if (response.statusCode == 200) {
      final serviceList = XmlDocument.parse(response.body.toString());

      return serviceList;
    } else {
      print("sth went wrong code: ${response.statusCode}");

      return XmlDocument.parse(response.body.toString());
    }
  }

  Future<void> showChannels() async {
    final document = await getServiceListXml();
    final serviceNames = document.findAllElements('ServiceName');
    //channel list as string
    serviceNames.map((node) => node.text).forEach((element) => print(element));
    print(serviceNames.length);
    print("Done");
  }

  Future<String> getArdLiveStream() async {
    print("get ardvmpd streams");
    final document = await getServiceListXml();
    // ignore: unused_local_variable
    var res = document.findAllElements("Service");

    //res.forEach((node) => print(node.getElement("ProviderName")));
    //res.forEach((node) => print(node.getElement("ServiceInstance")));

    return "https://livesim.dashif.org/livesim/mup_30/testpic_2s/Manifest.mpd"; //change to res
  }

  Future<void> testerFun() async {
    print("testerFun");
    final document = await getServiceListXml();
    // ignore: unused_local_variable
    var res = document.findAllElements("Service");

    //ServiceName
    /*
    res.map((e) => e.getElement("ServiceName")).forEach((e) => print(e?.text));
    res.map((e) => e.getElement("ServiceName").text);
    */
    //mdpUri
    /*
    res
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

  ///  transform xml to List of Serviceobjects
  Future<Iterable<ServiceObject>> transformXMLToServiceObjList() async {
    print("get ServiceObjects");
    final document = await getServiceListXml();
    var res = document.findAllElements("Service").map((e) => ServiceObject(
        "serviceName", "mpdURI", "channelBannerURI", PlayListObject()));
    return res;
  }
}

class PlayListObject {}

/// class that contains meta information about each service form a servicelist
class ServiceObject {
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
