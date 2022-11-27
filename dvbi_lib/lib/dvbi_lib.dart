library dvbi_lib;

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

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

      print("Done");
    } else {
      print("sth went wrong code: " + response.statusCode.toString());

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
    var res = document.findAllElements("Service");

    //res.forEach((node) => print(node.getElement("ProviderName")));
    res.forEach((node) => print(node.getElement("ServiceInstance")));

    return "https://mcdn.daserste.de/daserste/dash/manifest.mpd"; //change to res
  }
}
