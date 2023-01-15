import 'dart:io';

import 'package:xml/xml.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'content_guide_source.dart';
import 'program_info.dart';
import 'dvbi.dart';
import 'package:http/http.dart' as http;
import 'related_material.dart';

final Logger _log = Logger("service_elem");

class ServiceElem {
  final String serviceName;
  final String uniqueIdentifier;
  final String providerName;
  final String? contentGuideServiceRef;
  final ContentGuideSourceElem? contentGuideSourceElem;
  final Uri? dashmpd;
  final Uri? logo;
  final http.Client httpClient;
  ProgramInfo? _programInfo;
  ScheduleInfo? _scheduleInfo;

  /// req for programscheduleInfo
  Future<ScheduleInfo?> get scheduleInfo async {
    if (_scheduleInfo == null &&
        contentGuideSourceElem?.scheduleInfoEndpoint != null) {
      Uri endpoint = contentGuideSourceElem!.scheduleInfoEndpoint;

      final n = DateTime.now();

      // Get unixtime of today at 0 o'clock
      final startTime = DateTime(n.year, n.month, n.day);

      final endUnixtime = startTime.add(const Duration(days: 7));

      endpoint = endpoint.replace(queryParameters: {
        "sid": contentGuideServiceRef ?? uniqueIdentifier,
        "start_unixtime": startTime.millisecondsSinceEpoch.toString(),
        "end_unixtime": endUnixtime.microsecondsSinceEpoch.toString()
      });
      //_log.fine("scheduleInfo http request: $endpoint");
      var res = await http.get(endpoint);
      _log.fine("scheduleInfo http request: ${res.request}");

      if (res.statusCode != 200) {
        throw DVBIException(
            "Status code invalid. Code: ${res.statusCode} Reason: ${res.reasonPhrase}");
      }
      String xmlData = res.body;
      var data = XmlDocument.parse(xmlData);

      _scheduleInfo = ScheduleInfo.parse(data: data);
    }

    return _scheduleInfo;
  }

  //TODO: Return result type
  Future<ProgramInfo> get programInfo async {
    if (_programInfo == null) {
      Uri endpoint = contentGuideSourceElem!.programInfoEndpoint!;
      //endpoint.replace(queryParameters: {"pid": width});
      var res = await http.get(endpoint);
      _log.fine("programInfo http request: ${res.request}");
      if (res.statusCode != 200) {
        throw DVBIException(
            "Status code invalid. Code: ${res.statusCode} Reason: ${res.reasonPhrase}");
      }
      String xmlData = res.body;
      var data = XmlDocument.parse(xmlData);

      _programInfo = ProgramInfo.parse(data: data);
    }

    return _programInfo!;
  }

  ServiceElem(
      {required this.serviceName,
      required this.uniqueIdentifier,
      required this.providerName,
      required this.contentGuideSourceElem,
      required this.httpClient,
      required this.dashmpd,
      required this.contentGuideServiceRef,
      required this.logo});

  Map<String, dynamic> toJson() => {
        'serviceName': serviceName,
        'uniqueIdentifier': uniqueIdentifier,
        'providerName': providerName,
        'contentGuideSourceElem': contentGuideSourceElem,
        'contentGuideServiceRef': contentGuideServiceRef,
        'dashmpd': dashmpd?.toString(),
        'logo': logo?.toString(),
        'scheduleInfo': _scheduleInfo
      };

  //constructor short way
  factory ServiceElem.parse(
      {required XmlElement data,
      required http.Client httpClient,
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
      XmlElement? dashDeliveryParameters = serviceInstances
          .firstWhereOrNull(
              (element) => element.getElement("DASHDeliveryParameters") != null)
          ?.firstElementChild;

      XmlElement? uriBasedLocation =
          dashDeliveryParameters?.getElement("UriBasedLocation");

      bool correctType =
          uriBasedLocation?.getAttribute("contentType").toString() ==
              "application/dash+xml";

      if (correctType) {
        String? uri = uriBasedLocation?.getElement("URI")!.innerText;
        dashmpd = uri != null ? Uri.parse(uri) : null;
      } else {
        _log.fine("==== Unsupported dash type ====");
        _log.fine("uriBasedLocation: \n ${uriBasedLocation?.toXmlString()}");

        _log.fine(
            "dashDeliveryParameters: \n ${dashDeliveryParameters?.toXmlString()}");
      }
    }

    // Parse ContentGuideServiceRef
    String? contentGuideServiceRef;
    {
      XmlElement? elem = data.getElement("ContentGuideServiceRef");

      contentGuideServiceRef = elem?.innerText;
    }

    // Parse ContentGuideSource
    ContentGuideSourceElem? contentGuideSourceObj;
    {
      XmlElement? contentGuideSource = data.getElement("ContentGuideSource");

      if (contentGuideSource == null && contentGuideSourceList != null) {
        String? ref = data.getElement("ContentGuideSourceRef")?.innerText;
        for (final elem in contentGuideSourceList) {
          if (ref == null) {
            break;
          }

          if (elem.getAttribute("CGSID") == ref) {
            contentGuideSource = elem;
          }
        }
      }

      contentGuideSourceObj = contentGuideSource != null
          ? ContentGuideSourceElem.parse(data: contentGuideSource)
          : null;
    }

    List<RelatedMaterialElem> relatedMaterial = [];
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
        contentGuideServiceRef: contentGuideServiceRef,
        serviceName: serviceName,
        uniqueIdentifier: uniqueIdentifier,
        httpClient: httpClient,
        providerName: providerName,
        contentGuideSourceElem: contentGuideSourceObj,
        dashmpd: dashmpd,
        logo: logo);
  }
}
