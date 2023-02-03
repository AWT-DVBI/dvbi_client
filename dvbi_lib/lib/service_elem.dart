// ignore_for_file: unused_import

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
  ScheduleInfo? _scheduleInfo;

  Future<ScheduleInfo?> scheduleInfo({int? days}) async {
    if (_scheduleInfo == null &&
        contentGuideSourceElem?.scheduleInfoEndpoint != null) {
      Uri endpoint = contentGuideSourceElem!.scheduleInfoEndpoint;

      // Get the datetime now (closest value to one of allowedList) and next 6h

      final n6 = DateTime.now();
      //allowed hours for api request(0:00, 3:00, 6:00, 9:00, 12:00, 15:00, 18:00, 21:00)
      final allowedHours = [0, 3, 6, 9, 12, 15, 18, 21];
      final currentHour = n6.hour;

      final startTime6 = DateTime(n6.year, n6.month, n6.day,
          findClosestValue(allowedHours, currentHour));

      final endUnixtime6 = startTime6.add(Duration(hours: 6));

      endpoint = endpoint.replace(queryParameters: {
        "sid": contentGuideServiceRef ?? uniqueIdentifier,
        "start_unixtime": startTime6.millisecondsSinceEpoch.toString(),
        "end_unixtime": endUnixtime6.microsecondsSinceEpoch.toString()
      });

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

/**
 * find closest value to specific target in an array
 */
int findClosestValue(array, int target) {
  int closest = 100;
  int closestVal = 0;

  for (int x in array) {
    var difference = (x - target).abs();

    if (difference < closest) {
      closest = difference;
      closestVal = x;
    }
  }

  return closestVal;
}
