import 'dart:collection';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:dvbi_lib/content_guide_source.dart';
import 'package:xml/xml.dart';
import 'related_material.dart';
import 'package:logging/logging.dart';

import 'package:dvbi_lib/dvbi.dart';

final Logger _log = Logger("program_info");

enum Genre { contentCS, formatCS, contentSubject }

class ProgramInfo {
  static const Map<String?, Genre> genreMap = {
    "urn:tva:metadata:cs:ContentCS:2011": Genre.contentCS,
    "urn:dvb:metadata:cs:ContentSubject:2019": Genre.contentSubject,
    "urn:tva:metadata:cs:FormatCS:2011": Genre.formatCS
  };

  String programId;
  String mainTitle;
  String? secondaryTitle;
  String synopsisMedium;
  String? synopsisShort;

  Genre? genre;
  Uri? imageUrl;

  //from 6.10.7 ScheduleEvent
  DateTime? publishedStartTime;
  double publishedDuration;

  ProgramInfo(
      {required this.programId,
      required this.mainTitle,
      required this.secondaryTitle,
      required this.synopsisMedium,
      required this.synopsisShort,
      required this.genre,
      required this.imageUrl,
      required this.publishedStartTime,
      required this.publishedDuration});

  factory ProgramInfo.parse(
      {required XmlElement data, required XmlElement scheduleEvent}) {
    String programId = data.getAttribute("programId")!;

    //print("in my parse");

    String mainTitle;
    String? secondaryTitle;
    {
      List<XmlElement> titles =
          data.getElement("BasicDescription")!.findElements("Title").toList();

      mainTitle = titles[0].innerText;
      if (titles.length > 1) {
        secondaryTitle = titles[1].innerText;
      }
    }

    String? synopsisShort;
    String synopsisMedium;
    {
      List<XmlElement> synopsis = data
          .getElement("BasicDescription")!
          .findElements("Synopsis")
          .toList();

      synopsisMedium = synopsis
          .firstWhere((element) => element.getAttribute("length") == "medium")
          .innerText;

      if (synopsis.length > 1) {
        secondaryTitle = synopsisMedium = synopsis
            .firstWhere((element) => element.getAttribute("length") == "short")
            .innerText;
      }
    }

    String? genreStr = data
        .getElement("BasicDescription")!
        .getElement("Genre")
        ?.getAttribute("href");
    Genre? genre;

    if (genreStr != null) {
      for (final g in genreMap.keys) {
        if (genreStr.startsWith(g!)) {
          genre = genreMap[g];
        }
      }
    }

    Uri? imageUrl;
    {
      XmlElement? relatedMaterialElem =
          data.getElement("BasicDescription")!.getElement("RelatedMaterial");

      if (relatedMaterialElem != null) {
        final howRelated = RelatedMaterialElem.parse(data: relatedMaterialElem);
        imageUrl = howRelated.getLogo();
      }
    }

    DateTime? publishedStartTime = DateTime.tryParse(
        scheduleEvent.getElement("PublishedStartTime")!.innerText);

    double publishedDuration =
        parseTime(scheduleEvent.getElement("PublishedDuration")!.innerText);

    return ProgramInfo(
        programId: programId,
        mainTitle: mainTitle,
        secondaryTitle: secondaryTitle,
        synopsisShort: synopsisShort,
        synopsisMedium: synopsisMedium,
        genre: genre,
        imageUrl: imageUrl,
        publishedStartTime: publishedStartTime,
        publishedDuration: publishedDuration);
  }

  Map<String, dynamic> toJson() => {
        'programId': programId,
        'mainTitle': mainTitle,
        'secondaryTitle': secondaryTitle,
        'synopsisShort': synopsisShort,
        'synopsisMedium': synopsisMedium,
        'genre': genre?.toString(),
        'imageUrl': imageUrl?.toString(),
        'publishedStartTime': publishedStartTime?.toString(),
        'publishedDuration': publishedDuration
      };
}

//alternative remove PT und dann in Gui anzeigen 2H20M
double parseTime(String time) {
  RegExp onlyNumbers = RegExp(r'[^0-9]');

  if (time.contains('H') && time.contains('M')) {
    //return i.e. [PT2, 30M]
    var x = time.split("H");

    var aStr = x[0].replaceAll(onlyNumbers, ''); // '23'
    var adouble = double.parse(aStr);
    var a2Str = x[1].replaceAll(onlyNumbers, ''); // '23'
    var a2double = double.parse(a2Str) / 60;

    return adouble + a2double;
  } else if (time.contains('H') && !time.contains('M')) {
    var aStr = time.replaceAll(onlyNumbers, ''); // '23'
    var adouble = double.parse(aStr);

    return adouble;
  } else if (time.contains('M') && !time.contains('H')) {
    var aStr = time.replaceAll(onlyNumbers, ''); // '23'
    var adouble = double.parse(aStr);

    return adouble / 60;
  } else {
    print("case not found");
    return 0;
  }
}

class ScheduleInfo {
  final List<ProgramInfo> programInfoTable;
  final ContentGuideSourceElem contentGuideSourceElem;
  List<DetailedProgramInfo>? _detailProgramInfos;
  ScheduleInfo(
      {required this.programInfoTable, required this.contentGuideSourceElem});

  factory ScheduleInfo.parse(
      {required XmlDocument data,
      required ContentGuideSourceElem contentGuideSourceElem}) {
    ContentGuideSourceElem elem = contentGuideSourceElem;
    List<ProgramInfo> programs = [];

    final programInfoData = data
        .getElement("TVAMain")!
        .getElement("ProgramDescription")!
        .getElement("ProgramInformationTable")!
        .findAllElements("ProgramInformation");

    //TODO in hashmap
    final programScheduleData = data.findAllElements("ScheduleEvent");
    final map = HashMap<String, XmlElement>.fromIterable(programScheduleData,
        key: (e) => e.getElement("Program")!.getAttribute("crid")!,
        value: (e) => e);

    if (programInfoData.isEmpty || programScheduleData.isEmpty) {
    } else {
      Iterable<ProgramInfo> plist = data
          .findAllElements("ProgramInformation")
          .map((e) => ProgramInfo.parse(
              data: e, scheduleEvent: map[e.getAttribute("programId")]!));

      programs = plist.toList();
    }

    return ScheduleInfo(
        programInfoTable: programs, contentGuideSourceElem: elem);
  }

  Map<String, dynamic> toJson() => {"programInfoTable": programInfoTable};

  ///get for a programlist a detailed programList
  Future<List<DetailedProgramInfo>?> detailProgramInfos() async {
    List<DetailedProgramInfo> detailProgramInfos = [];
    print("in detailProgramInfos ");
    if (_detailProgramInfos == null &&
        contentGuideSourceElem.programInfoEndpoint != null) {
      Uri endpoint = contentGuideSourceElem.programInfoEndpoint!;

      for (ProgramInfo prog in programInfoTable) {
        endpoint = endpoint.replace(queryParameters: {
          "pid": prog.programId,
        });

        var res = await http.get(endpoint);
        _log.fine("programinfo http request: ${res.request}");

        if (res.statusCode != 200) {
          throw DVBIException(
              "Status code invalid. Code: ${res.statusCode} Reason: ${res.reasonPhrase}");
        }
        String xmlData = res.body;
        var data = XmlDocument.parse(xmlData);
        detailProgramInfos
            .add(DetailedProgramInfo.parse(data: data, programInfo: prog));
      }
    }

    return detailProgramInfos;
  }
}

///class that represents detailed meta data of a specific program
class DetailedProgramInfo {
  static const Map<String?, Genre> genreMap = {
    "urn:tva:metadata:cs:ContentCS:2011": Genre.contentCS,
    "urn:dvb:metadata:cs:ContentSubject:2019": Genre.contentSubject,
    "urn:tva:metadata:cs:FormatCS:2011": Genre.formatCS
  };

  ///crid id
  String programId;

  ///main title of the program
  String mainTitle;

  ///optional secondary title of the program
  String? secondaryTitle;

  ///Descriptive text about the entity. medium is mandatory
  String synopsisMedium;

  ///short Descriptive text about the entity. short is mandatory
  String? synopsisShort;

  ///long descriptive test is optional
  String? synopsisLong;

  ///a list of keywords associated to a programme. optional
  List<String> keywords = [];

  ///The genre or classification for the programme. optional
  Genre? genre;

  ///age describtion of the program
  ParentalGuidance? minAge;

  ///The list of credits for the specified programme.
  List<CreditItems>? creditItemlist;

  Uri? imageUrl;

  //from 6.10.7 ScheduleEvent take data from the program id
  DateTime? publishedStartTime;
  double publishedDuration;

  DetailedProgramInfo(
      {required this.programId,
      required this.mainTitle,
      required this.secondaryTitle,
      required this.synopsisMedium,
      required this.synopsisShort,
      required this.synopsisLong,
      required this.genre,
      required this.minAge,
      required this.keywords,
      required this.creditItemlist,
      required this.imageUrl,
      required this.publishedStartTime,
      required this.publishedDuration});

  factory DetailedProgramInfo.parse(
      {required XmlDocument data, required ProgramInfo programInfo}) {
    final programInfoData = data
        .getElement("TVAMain")!
        .getElement("ProgramDescription")!
        .getElement("ProgramInformationTable")!
        .getElement("ProgramInformation")!;

    String programId = programInfoData.getAttribute("programId")!;

    //print("in my parse");

    String mainTitle;
    String? secondaryTitle;
    {
      List<XmlElement> titles = programInfoData
          .getElement("BasicDescription")!
          .findElements("Title")
          .toList();

      mainTitle = titles[0].innerText;
      if (titles.length > 1) {
        secondaryTitle = titles[1].innerText;
      }
    }

    String? synopsisLong;
    String? synopsisShort;
    String synopsisMedium;
    {
      List<XmlElement> synopsis = programInfoData
          .getElement("BasicDescription")!
          .findElements("Synopsis")
          .toList();

      synopsisMedium = synopsis
          .firstWhere((element) => element.getAttribute("length") == "medium")
          .innerText;

      if (synopsis.length > 1) {
        if (synopsis
            .any((element) => element.getAttribute("length") == "short")) {
          synopsisShort = synopsis
              .firstWhere(
                  (element) => element.getAttribute("length") == "short")
              .innerText;
        }
        if (synopsis
            .any((element) => element.getAttribute("length") == "long")) {
          synopsisLong = synopsis
              .firstWhere((element) => element.getAttribute("length") == "long")
              .innerText;
        }
      }
    }

    String? genreStr = programInfoData
        .getElement("BasicDescription")!
        .getElement("Genre")
        ?.getAttribute("href");
    Genre? genre;

    if (genreStr != null) {
      for (final g in genreMap.keys) {
        if (genreStr.startsWith(g!)) {
          genre = genreMap[g];
        }
      }
    }

    //TODO elplanatorytext not mandatory
    ParentalGuidance? parentalGuidance;
    if (programInfoData.findElements("ParentalGuidance").isNotEmpty) {
      parentalGuidance = ParentalGuidance(
          int.parse(programInfoData
              .findElements("ParentalGuidance")
              .firstWhere((element) => element.name == "mpeg7:MinimumAge")
              .innerText),
          programInfoData
              .findElements("ParentalGuidance")
              .firstWhere((element) => element.name == "ExplanatoryText")
              .innerText);
    }

    List<CreditItems>? creditItemlist;
    if (programInfoData.findElements("CreditsList>").isNotEmpty) {
      creditItemlist = [];
      creditItemlist.add(CreditItems.parse(
          programInfoData.findElements("CreditsList").toList()));
    }

    List<String> keywords = [];
    if (programInfoData.findElements("Keywords").isNotEmpty) {
      //if keywords are present
      List<XmlElement> xmlKeywords =
          programInfoData.findElements("Keywords").toList();

      for (XmlElement keyword in xmlKeywords) {
        keywords.add(keyword.innerText);
      }
    }

    Uri? imageUrl;
    {
      XmlElement? relatedMaterialElem = programInfoData
          .getElement("BasicDescription")!
          .getElement("RelatedMaterial");

      if (relatedMaterialElem != null) {
        final howRelated = RelatedMaterialElem.parse(data: relatedMaterialElem);
        imageUrl = howRelated.getLogo();
      }
    }

    //TODO werte übergeben von schon vorhanden object oder einfach nicht neu machen
    DateTime? publishedStartTime = programInfo.publishedStartTime;

    //TODO how to get double of already used data
    double publishedDuration = programInfo.publishedDuration;

    return DetailedProgramInfo(
        programId: programId,
        mainTitle: mainTitle,
        secondaryTitle: secondaryTitle,
        synopsisShort: synopsisShort,
        synopsisMedium: synopsisMedium,
        synopsisLong: synopsisLong,
        genre: genre,
        minAge: parentalGuidance,
        creditItemlist: creditItemlist,
        keywords: keywords,
        imageUrl: imageUrl,
        publishedStartTime: publishedStartTime,
        publishedDuration: publishedDuration);
  }

  Map<String, dynamic> toJson() => {
        'programId': programId,
        'mainTitle': mainTitle,
        'secondaryTitle': secondaryTitle,
        'synopsisShort': synopsisShort?.toString(),
        'synopsisMedium': synopsisMedium,
        'synopsisLong': synopsisLong?.toString(),
        'genre': genre?.toString(),
        'imageUrl': imageUrl?.toString(),
        'publishedStartTime': publishedStartTime?.toString(),
        'publishedDuration': publishedDuration
      };
}

///The minimum age rating or guidance/watershed indicators and optional text. ParentalGuidance Element
class ParentalGuidance {
  late int minimumAge;
  String? explanatoryText;

  ParentalGuidance(this.minimumAge, this.explanatoryText);

  factory ParentalGuidance.parse(int age, String? text) {
    return ParentalGuidance(age, text);
  }
}

///A maximum of 40 CreditsItem elements shall be present within a CreditsList element.
class CreditItems {
  ///The name of an organization referenced in a CreditsItem. This element shall only be supplied if PersonName is not present.
  String? organisationName;

  ///The name of the person referenced in a CreditsItem. GivenName is mandatory element. This element shall only be supplied if PersonName is not present.
  String? personName;

  CreditItems(this.organisationName, this.personName);

  factory CreditItems.parse(List<XmlElement> data) {
    String? organisationName = data
        .firstWhere((element) =>
            element.getAttribute("role") ==
            "urn:tva:metadata:cs:TVARoleCS:2011:V20")
        .getElement("OrganizationName")
        ?.innerText;

    //TODO create list for all actors-> parse whole roles and person names 6.10.14 CreditsItem Element
    String? personName = data
        .firstWhere((element) =>
            element.getAttribute("role") ==
            "urn:mpeg:mpeg7:cs:RoleCS:2001:ACTOR")
        .getElement("PersonName")
        ?.getElement("mpeg7:FamilyName")
        ?.innerText;

    return CreditItems(organisationName, personName);
  }
}
