import 'dart:developer';

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

  ProgramInfo(
      {required this.programId,
      required this.mainTitle,
      required this.secondaryTitle,
      required this.synopsisMedium,
      required this.synopsisShort,
      required this.genre,
      required this.imageUrl});

  factory ProgramInfo.parse({required XmlElement data}) {
    String programId = data.getAttribute("programId")!;

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

    return ProgramInfo(
        programId: programId,
        mainTitle: mainTitle,
        secondaryTitle: secondaryTitle,
        synopsisShort: synopsisShort,
        synopsisMedium: synopsisMedium,
        genre: genre,
        imageUrl: imageUrl);
  }

  Map<String, dynamic> toJson() => {
        'programId': programId,
        'mainTitle': mainTitle,
        'secondaryTitle': secondaryTitle,
        'synopsisShort': synopsisShort,
        'synopsisMedium': synopsisMedium,
        'genre': genre?.toString(),
        'imageUrl': imageUrl?.toString()
      };
}

class MyProgramInfo {
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
  String publishedStartTime;
  String publishedDuration;

  MyProgramInfo(
      {required this.programId,
      required this.mainTitle,
      required this.secondaryTitle,
      required this.synopsisMedium,
      required this.synopsisShort,
      required this.genre,
      required this.imageUrl,
      required this.publishedStartTime,
      required this.publishedDuration});

  factory MyProgramInfo.parse(
      {required XmlElement data, required XmlElement scheduleEvent}) {
    String programId = data.getAttribute("programId")!;

    print("in my parse");

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

    String publishedStartTime =
        scheduleEvent.getElement("PublishedStartTime")!.innerText;

    String publishedDuration =
        scheduleEvent.getElement("PublishedDuration")!.innerText;

    print(publishedDuration);

    return MyProgramInfo(
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
        'imageUrl': imageUrl?.toString()
      };
}
/*
class ScheduleInfo {
  final List<ProgramInfo> programInfoTable;

  ScheduleInfo({required this.programInfoTable});

  factory ScheduleInfo.parse({required XmlDocument data}) {
    // Parse ProgramInformation Table
    List<ProgramInfo> programInfoTable = [];
    {
      final programInfoData = data
          .getElement("TVAMain")!
          .getElement("ProgramDescription")!
          .getElement("ProgramInformationTable")!
          .findAllElements("ProgramInformation");

      for (final pi in programInfoData) {
        ProgramInfo info = ProgramInfo.parse(data: pi);
        programInfoTable.add(info);
      }
    }

/*debugg 
    if (data.findAllElements("ProgramInformationTable").isEmpty) {
      print("No ProgramInformationTable event");
    }
*/

    if (data.findAllElements("ProgramInformation").isEmpty) {
      print("No ProgramInformation event");
    }

    if (data.findAllElements("Schedule").isEmpty) {
      print("No Schedule");
    }

    return ScheduleInfo(programInfoTable: programInfoTable);
  }

  Map<String, dynamic> toJson() => {"programInfoTable": programInfoTable};
}
*/

class MyScheduleInfo {
  final List<MyProgramInfo> programInfoTable;

  MyScheduleInfo({required this.programInfoTable});

  factory MyScheduleInfo.parse({required XmlDocument data}) {
    List<MyProgramInfo> programs = [];

    final programInfoData = data
        .getElement("TVAMain")!
        .getElement("ProgramDescription")!
        .getElement("ProgramInformationTable")!
        .findAllElements("ProgramInformation");

    final programScheduleData = data.findAllElements("ScheduleEvent");

    if (programInfoData.isEmpty || programScheduleData.isEmpty) {
      print("progInfo is empty");
    } else {
      Iterable<MyProgramInfo> plist = data
          .findAllElements("ProgramInformation")
          .map((e) => MyProgramInfo.parse(
              data: e,
              scheduleEvent: programScheduleData.firstWhere((element) =>
                  element.getElement("Program")!.getAttribute("crid")! ==
                  e.getAttribute("programId")!)));

      programs = plist.toList();
      /*Iterable<ProgramInfo> plist = data
          .findAllElements("ProgramInformation")
          .map((e) => ProgramInfo.parse(data: e));

      programs = plist.toList();
      */
    }

    return MyScheduleInfo(programInfoTable: programs);
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
