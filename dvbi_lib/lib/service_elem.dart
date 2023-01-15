import 'package:xml/xml.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'content_guide_source.dart';

import 'related_material.dart';

final Logger _log = Logger("service_elem");

class ServiceElem {
  final String serviceName;
  final String uniqueIdentifier;
  final String providerName;
  final ContentGuideSourceElem? contentGuideSourceElem;
  final Uri? dashmpd;
  final Uri? logo;

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
        serviceName: serviceName,
        uniqueIdentifier: uniqueIdentifier,
        providerName: providerName,
        contentGuideSourceElem: contentGuideSourceObj,
        dashmpd: dashmpd,
        logo: logo);
  }
}
