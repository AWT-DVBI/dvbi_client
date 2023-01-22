// ignore_for_file: avoid_print, unused_import, unused_element

library dvbi_lib;

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:logging/logging.dart';

import 'program_info.dart';
import 'service_elem.dart';

final Logger _log = Logger("dvbi");

class DVBIException implements Exception {
  String cause;
  DVBIException(this.cause);
}

class DVBI {
  final String data;
  final http.Client httpClient;

  DVBI({required this.data}) : httpClient = http.Client();

  static Future<DVBI> create({required Uri endpointUrl}) async {
    String data;
    if (endpointUrl.isScheme("HTTP") || endpointUrl.isScheme("HTTPS")) {
      var res = await http.get(endpointUrl);

      if (res.statusCode != 200) {
        throw DVBIException(
            "Status code invalid. Code: ${res.statusCode} Reason: ${res.reasonPhrase}");
      }
      data = res.body;
    } else {
      var res = File.fromUri(endpointUrl);

      data = await res.readAsString();
    }

    return DVBI(data: data);
  }

  void close() {
    httpClient.close();
  }

  List<ServiceElem> get serviceElems {
    final serviceList = XmlDocument.parse(data).getElement("ServiceList")!;
    final services = serviceList.findAllElements("Service");
    final List<XmlElement>? contentGuideSourceList = serviceList
        .getElement("ContentGuideSourceList")
        ?.childElements
        .toList();
    return services
        .map((serviceData) => ServiceElem.parse(
            httpClient: httpClient,
            data: serviceData,
            contentGuideSourceList: contentGuideSourceList))
        .toList();
  }

  Stream<ServiceElem> get stream async* {
    final serviceList = XmlDocument.parse(data).getElement("ServiceList")!;

    final services = serviceList.findAllElements("Service");
    final List<XmlElement>? contentGuideSourceList = serviceList
        .getElement("ContentGuideSourceList")
        ?.childElements
        .toList();

    for (var serviceData in services) {
      yield ServiceElem.parse(
          httpClient: httpClient,
          contentGuideSourceList: contentGuideSourceList,
          data: serviceData);
    }
  }
}
