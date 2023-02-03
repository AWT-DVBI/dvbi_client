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
        detailProgramInfos.add(DetailedProgramInfo.parse(data: data));
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
      required this.imageUrl,
      required this.publishedStartTime,
      required this.publishedDuration});

  factory DetailedProgramInfo.parse({required XmlDocument data}) {
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

        //TODO maybe if condi not engough as could be also null
        synopsisLong = synopsisMedium = synopsis
            .firstWhere((element) => element.getAttribute("length") == "Long")
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

    //TODO
    ParentalGuidance? minAge;

    Uri? imageUrl;
    {
      XmlElement? relatedMaterialElem =
          data.getElement("BasicDescription")!.getElement("RelatedMaterial");

      if (relatedMaterialElem != null) {
        final howRelated = RelatedMaterialElem.parse(data: relatedMaterialElem);
        imageUrl = howRelated.getLogo();
      }
    }

    DateTime? publishedStartTime =
        DateTime.tryParse(data.getElement("PublishedStartTime")!.innerText);

    //TODO how to get double of already used data
    double publishedDuration = 0;

    return DetailedProgramInfo(
        programId: programId,
        mainTitle: mainTitle,
        secondaryTitle: secondaryTitle,
        synopsisShort: synopsisShort,
        synopsisMedium: synopsisMedium,
        synopsisLong: synopsisLong,
        genre: genre,
        minAge: minAge,
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

///The minimum age rating or guidance/watershed indicators and optional text. ParentalGuidance Element
class ParentalGuidance {
  late int minimumAge;

  String? explanatoryText;
}

///A maximum of 40 CreditsItem elements shall be present within a CreditsList element.
class CreditItems {
  ///The name of an organization referenced in a CreditsItem. This element shall only be supplied if PersonName is not present.
  String? organisationName;

  ///The name of the person referenced in a CreditsItem. GivenName is mandatory element. This element shall only be supplied if PersonName is not present.
  String? personName;
}
