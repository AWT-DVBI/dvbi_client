import 'package:xml/xml.dart';
import 'dvbi.dart';
import 'package:logging/logging.dart';

final Logger _log = Logger("program_info");

enum HowRelatedEnum {
  logo,
  application,
  defaultImage,
  sixteenByNineColour,
  squareColour,
  sixteenByNineWhite,
  squareWhite,
  sixteenByNineColourLight,
  squareColourLight,
  sixteenByNineColourDark,
  squareColourDark,
}

class RelatedMaterialElem {
  static const Map<String?, HowRelatedEnum> howRelatedMap = {
    "urn:dvb:metadata:cs:HowRelatedCS:2020:1001.2": HowRelatedEnum.logo,
    "urn:dvb:metadata:cs:LinkedApplicationCS:2019:1.1":
        HowRelatedEnum.application,
    "urn:tva:metadata:cs:HowRelatedCS:2012:19": HowRelatedEnum.defaultImage,
    "urn:fvc:metadata:cs:ImageVariantCS:2017-02:16x9_colour":
        HowRelatedEnum.sixteenByNineColour,
    "urn:fvc:metadata:cs:ImageVariantCS:2017-02:square_colour":
        HowRelatedEnum.squareColour,
    "urn:fvc:metadata:cs:ImageVariantCS:2017-02:16x9_white":
        HowRelatedEnum.sixteenByNineWhite,
    "urn:fvc:metadata:cs:ImageVariantCS:2017-02:square_white":
        HowRelatedEnum.squareWhite,
    "urn:fvc:metadata:cs:ImageVariantCS:2017-02:16x9_colour_light":
        HowRelatedEnum.sixteenByNineColourLight,
    "urn:fvc:metadata:cs:ImageVariantCS:2017-02:square_colour_light":
        HowRelatedEnum.squareColourLight,
    "urn:fvc:metadata:cs:ImageVariantCS:2017-02:16x9_colour_dark":
        HowRelatedEnum.sixteenByNineColourDark,
    "urn:fvc:metadata:cs:ImageVariantCS:2017-02:square_colour_dark":
        HowRelatedEnum.squareColourDark
  };

  bool _isImage() {
    switch (howRelated) {
      case HowRelatedEnum.sixteenByNineColour:
      case HowRelatedEnum.squareColour:
      case HowRelatedEnum.logo:
      case HowRelatedEnum.defaultImage:
      case HowRelatedEnum.sixteenByNineColourDark:
      case HowRelatedEnum.sixteenByNineColourLight:
      case HowRelatedEnum.sixteenByNineWhite:
      case HowRelatedEnum.squareColourDark:
      case HowRelatedEnum.squareColourLight:
      case HowRelatedEnum.squareWhite:
        return true;
      default:
        return false;
    }
  }

  final HowRelatedEnum? howRelated;
  final XmlElement xml;

  RelatedMaterialElem({required this.howRelated, required this.xml});

  Uri getLogo({int? width}) {
    if (_isImage()) {
      String? maybeUri =
          xml.getElement("MediaLocator")!.getElement("MediaUri")?.innerText;

      String uriText = maybeUri ??
          xml.getElement("MediaLocator")!.getElement("tva:MediaUri")!.innerText;
      Uri uri = Uri.parse(uriText);

      if (width != null) {
        uri = uri.replace(queryParameters: {"width": width});
      }

      return uri;
    }
    _log.severe(
        "Called getLogo on $howRelated Element but expected logo. XML: ${xml.toXmlString()}");
    throw DVBIException(
        "Called getLogo on $howRelated Element but expected logo");
  }

  factory RelatedMaterialElem.parse({required XmlElement data}) {
    String? href = data.getElement("HowRelated")?.getAttribute("href");

    HowRelatedEnum? howRelated = howRelatedMap[href];

    return RelatedMaterialElem(howRelated: howRelated, xml: data);
  }
}
