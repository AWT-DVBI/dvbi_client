// ignore_for_file: unused_import, unused_element

import 'dart:developer';
import 'dart:collection';
import 'package:xml/xml.dart';
import 'related_material.dart';
import 'package:logging/logging.dart';

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

  ScheduleInfo({required this.programInfoTable});

  factory ScheduleInfo.parse({required XmlDocument data}) {
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

    return ScheduleInfo(programInfoTable: programs);
  }

  Map<String, dynamic> toJson() => {"programInfoTable": programInfoTable};
}

// prgramminfo
class Program {
  //ProgramInformation programId i.e.="crid://zdf.de/metadata/broadcast_item/83791/"
  String pid;
  String title;
  //program description Synopsis
  String synopsis;
  //pictureUrl-MediaUri
  String mediaUrl;
  //schedule PublishedStartTime-- erkennen über id
  String startTime;

  // PublishedDuration
  String programDuration;

  Program(
      {required this.pid,
      required this.title,
      required this.synopsis,
      required this.mediaUrl,
      required this.startTime,
      required this.programDuration});

  /// xmlElemet start at level ProgramInformation=dataprog & dataschedule=programlocationtable/ScheduleEvent
  factory Program.parse(
      {required XmlElement dataProg, required XmlElement dataSchedule}) {
    String pid = dataProg.getAttribute("programId")!;
    String title =
        dataProg.getElement("BasicDescription")!.getElement("Title")!.innerText;
    String? synopsis = dataProg
        .getElement("BasicDescription")!
        .getElement("Synopsis")!
        .innerText;
    //TODO evtl uri
    String mediaUrl = dataProg
        .getElement("BasicDescription")!
        .getElement("RelatedMaterial")!
        .getElement("MediaLocator")!
        .getElement("MediaUri")!
        .innerText;

    String startTime = dataSchedule.getElement("PublishedStartTime")!.innerText;

    String programDuration =
        dataSchedule.getElement("PublishedDuration")!.innerText;

    return Program(
        pid: pid,
        title: title,
        synopsis: synopsis,
        mediaUrl: mediaUrl,
        startTime: startTime,
        programDuration: programDuration);
  }

  Map<String, dynamic> toJson() => {
        'programid': pid,
        'title': title,
        'synopsis': synopsis,
        'mediaUrl': mediaUrl,
        'startTime': startTime,
        'programDuration': programDuration
      };
}
