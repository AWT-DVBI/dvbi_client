import 'package:xml/xml.dart';
import 'dvbi.dart';

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
      //TODO: tva suffix not in standard
      String uriText =
          xml.getElement("MediaLocator")!.getElement("tva:MediaUri")!.innerText;
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
