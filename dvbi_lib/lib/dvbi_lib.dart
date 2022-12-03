// ignore_for_file: avoid_print

library dvbi_lib;

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

const String endpointUrl = "https://dvb-i.net/production/services.php/de";

class DVBIException implements Exception {
  String cause;
  DVBIException(this.cause);
}

class PlayListObject {}

/// class that contains meta information about each service form a servicelist

class ContentGuideSourceElem {
  final Uri scheduleInfoEndpoint;
  final Uri? programInfoEndpoint;
  final String providerName;
  final String cgsid;

  ContentGuideSourceElem(
      {required this.scheduleInfoEndpoint,
      required this.programInfoEndpoint,
      required this.providerName,
      required this.cgsid});

  factory ContentGuideSourceElem.parse({required XmlElement d}) {
    String scheduleInfoEndpoint =
        d.getElement("ScheduleInfoEndpoint")!.getElement("URI")!.innerText;
    String? programInfoEndpoint =
        d.getElement("ProgramInfoEndpoint")?.getElement("URI")!.innerText;
    String providerName = d.getElement("ProviderName")!.innerText;
    String cgsid = d.getAttribute("CGSID")!;

    return ContentGuideSourceElem(
        cgsid: cgsid,
        providerName: providerName,
        programInfoEndpoint:
            programInfoEndpoint != null ? Uri.parse(programInfoEndpoint) : null,
        scheduleInfoEndpoint: Uri.parse(scheduleInfoEndpoint));
  }

  Map<String, dynamic> toJson() => {
        'scheduleInfoEndpoint': scheduleInfoEndpoint.toString(),
        'programInfoEndpoint': programInfoEndpoint.toString(),
        'providerName': providerName,
        'cgsid': cgsid
      };
}

class ServiceElem {
  final String serviceName;
  final String uniqueIdentifier;
  final String providerName;
  final ContentGuideSourceElem? contentGuideSourceElem;

  PlayListObject? playListObject;

  ServiceElem(
      {required this.serviceName,
      required this.uniqueIdentifier,
      required this.providerName,
      required this.contentGuideSourceElem});

  Map<String, dynamic> toJson() => {
        'serviceName': serviceName,
        'uniqueIdentifier': uniqueIdentifier,
        'providerName': providerName,
        'contentGuideSourceElem': contentGuideSourceElem,
      };

  //constructor short way
  factory ServiceElem.parse(
      {required XmlElement? d,
      required List<XmlElement>? contentGuideSourceList}) {
    if (d == null) {
      throw DVBIException("Service object received null as data");
    }

    String serviceName = d.getElement("ServiceName")!.innerText;
    String uniqueIdentifier = d.getElement("UniqueIdentifier")!.innerText;
    String providerName = d.getElement("ProviderName")!.innerText;

    XmlElement? contentGuideSource = d.getElement("ContentGuideSource");

    if (contentGuideSource == null && contentGuideSourceList != null) {
      String ref = d.getElement("ContentGuideSourceRef")!.innerText;
      for (final elem in contentGuideSourceList) {
        if (elem.getAttribute("CGSID") == ref) {
          contentGuideSource = elem;
        }
      }
    }

    return ServiceElem(
        serviceName: serviceName,
        uniqueIdentifier: uniqueIdentifier,
        providerName: providerName,
        contentGuideSourceElem: contentGuideSource != null
            ? ContentGuideSourceElem.parse(d: contentGuideSource)
            : null);
  }
}

class DVBI {
  final String endpointUrl;
  final http.Client httpClient;

  DVBI({required this.endpointUrl}) : httpClient = http.Client();

  Future<http.Response> getHttp(String endpointUrl) {
    return http.get(Uri.parse(endpointUrl));
  }

  Stream<ServiceElem> getServiceStream() async* {
    print(endpointUrl);
    final response = await getHttp(endpointUrl);

    if (response.statusCode == 200) {
      final document =
          XmlDocument.parse(response.body).getElement("ServiceList")!;

      final serviceList = document.findAllElements("Service");
      final List<XmlElement>? contentGuideSourceList =
          document.getElement("ContentGuideSourceList")?.childElements.toList();

      for (var sd in serviceList) {
        yield ServiceElem.parse(
            contentGuideSourceList: contentGuideSourceList, d: sd);
      }
    } else {
      throw DVBIException(
          "Status code invalid. Code: ${response.statusCode} Reason: ${response.reasonPhrase}");
    }
  }
}
