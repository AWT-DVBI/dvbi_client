// ignore_for_file: avoid_print

library dvbi_lib;

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class DVBIException implements Exception {
  String cause;
  DVBIException(this.cause);
}

class PlayListObject {}

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

  factory ContentGuideSourceElem.parse({required XmlElement data}) {
    String scheduleInfoEndpoint =
        data.getElement("ScheduleInfoEndpoint")!.getElement("URI")!.innerText;
    String? programInfoEndpoint =
        data.getElement("ProgramInfoEndpoint")?.getElement("URI")!.innerText;
    String providerName = data.getElement("ProviderName")!.innerText;
    String cgsid = data.getAttribute("CGSID")!;

    return ContentGuideSourceElem(
        cgsid: cgsid,
        providerName: providerName,
        programInfoEndpoint:
            programInfoEndpoint != null ? Uri.parse(programInfoEndpoint) : null,
        scheduleInfoEndpoint: Uri.parse(scheduleInfoEndpoint));
  }

  Map<String, dynamic> toJson() => {
        'scheduleInfoEndpoint': scheduleInfoEndpoint.toString(),
        'programInfoEndpoint': programInfoEndpoint?.toString(),
        'providerName': providerName,
        'cgsid': cgsid
      };
}

enum HowRelatedEnum {
  logo,
  application,
}

class RelatedMaterialElem {
  static const Map<String?, HowRelatedEnum> howRelatedMap = {
    "urn:dvb:metadata:cs:HowRelatedCS:2020:1001.2": HowRelatedEnum.logo,
    "urn:dvb:metadata:cs:LinkedApplicationCS:2019:1.1":
        HowRelatedEnum.application,
  };

  final HowRelatedEnum? howRelated;
  final XmlElement xml;

  RelatedMaterialElem({required this.howRelated, required this.xml});

  Uri getLogo({int? width}) {
    if (howRelated == HowRelatedEnum.logo) {
      String uriText =
          xml.getElement("MediaLocator")!.getElement("MediaUri")!.innerText;
      Uri uri = Uri.parse(uriText);

      if (width != null) {
        uri.replace(queryParameters: {"width": width});
      }

      return uri;
    }

    throw DVBIException("Called getLogo on unrelated Element: $howRelated");
  }

  factory RelatedMaterialElem.parse({required XmlElement data}) {
    String? href = data.getElement("HowRelated")?.getAttribute("href");

    HowRelatedEnum? howRelated = howRelatedMap[href];

    return RelatedMaterialElem(howRelated: howRelated, xml: data);
  }
}

class ServiceElem {
  final String serviceName;
  final String uniqueIdentifier;
  final String providerName;
  final ContentGuideSourceElem? contentGuideSourceElem;
  final Uri? dashmpd;
  final Uri? logo;

  PlayListObject? playListObject;

  ServiceElem(
      {required this.serviceName,
      required this.uniqueIdentifier,
      required this.providerName,
      required this.contentGuideSourceElem,
      required this.dashmpd,
      required this.logo});

  Map<String, dynamic> toJson() => {
        'serviceName': serviceName,
        'uniqueIdentifier': uniqueIdentifier,
        'providerName': providerName,
        'contentGuideSourceElem': contentGuideSourceElem,
        'dashmpd': dashmpd?.toString(),
        'logo': logo?.toString()
      };

  //constructor short way
  factory ServiceElem.parse(
      {required XmlElement data,
      required List<XmlElement>? contentGuideSourceList}) {
    String serviceName = data.getElement("ServiceName")!.innerText;
    String uniqueIdentifier = data.getElement("UniqueIdentifier")!.innerText;
    String providerName = data.getElement("ProviderName")!.innerText;

    // Get serviceInstace elements ordered by priority
    List<XmlElement> serviceInstances;
    {
      serviceInstances = data.findAllElements("ServiceInstance").toList();

      // Sort ServiceInstance elements by priority
      serviceInstances.sort((a, b) {
        int res = int.parse(a.getAttribute("priority")!) -
            int.parse(b.getAttribute("priority")!);
        return res;
      });
    }

    // Parse dashmpd
    Uri? dashmpd;
    {
      XmlElement? dashDeliveryParameters = serviceInstances.firstWhere(
          (element) => element.getElement("DASHDeliveryParameters") != null);

      XmlElement? uriBasedLocation =
          dashDeliveryParameters.getElement("UriBasedLocation");

      bool correctType =
          uriBasedLocation?.getAttribute("contentType").toString() ==
              "application/dash+xml";

      if (correctType) {
        String? uri = uriBasedLocation?.getElement("URI")!.innerText;
        dashmpd = uri != null ? Uri.parse(uri) : null;
      }
    }

    // Parse ContentGuideSource
    ContentGuideSourceElem? contentGuideSourceObj;
    {
      XmlElement? contentGuideSource = data.getElement("ContentGuideSource");

      if (contentGuideSource == null && contentGuideSourceList != null) {
        String ref = data.getElement("ContentGuideSourceRef")!.innerText;
        for (final elem in contentGuideSourceList) {
          if (elem.getAttribute("CGSID") == ref) {
            contentGuideSource = elem;
          }
        }
      }

      contentGuideSourceObj = contentGuideSource != null
          ? ContentGuideSourceElem.parse(data: contentGuideSource)
          : null;
    }

    List<RelatedMaterialElem> relatedMaterial = List.empty();
    {
      for (XmlElement rd in data.findAllElements("RelatedMaterial")) {
        relatedMaterial.add(RelatedMaterialElem.parse(data: rd));
      }
    }

    // Parse logo
    Uri? logo;
    {
      logo = relatedMaterial
          .firstWhere((element) => element.howRelated == HowRelatedEnum.logo)
          .getLogo();
    }

    return ServiceElem(
        serviceName: serviceName,
        uniqueIdentifier: uniqueIdentifier,
        providerName: providerName,
        contentGuideSourceElem: contentGuideSourceObj,
        dashmpd: dashmpd,
        logo: logo);
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
      final serviceList =
          XmlDocument.parse(response.body).getElement("ServiceList")!;

      final services = serviceList.findAllElements("Service");
      final List<XmlElement>? contentGuideSourceList = serviceList
          .getElement("ContentGuideSourceList")
          ?.childElements
          .toList();

      for (var serviceData in services) {
        yield ServiceElem.parse(
            contentGuideSourceList: contentGuideSourceList, data: serviceData);
      }
    } else {
      throw DVBIException(
          "Status code invalid. Code: ${response.statusCode} Reason: ${response.reasonPhrase}");
    }
  }
}
