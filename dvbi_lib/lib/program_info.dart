import 'package:xml/xml.dart';

class ProgramInfo {
  String programId;
  String mainTitle;
  String secTitle;

  String synopsisMedium;
  String synopsisLong;
  String genre;
  String imageUrl;

  ProgramInfo(
      {required this.programId,
      required this.mainTitle,
      required this.secTitle,
      required this.synopsisMedium,
      required this.synopsisLong,
      required this.genre,
      required this.imageUrl});

  factory ProgramInfo.parse({required XmlDocument data}) {
    String programId = data
        .getElement("TVAMain")!
        .getElement("ProgramDescription")!
        .getElement("ProgramInformationTable")!
        .getElement("ProgramInformation")!
        .getAttribute("programId")!;

    Iterable<XmlElement> titles = data
        .getElement("TVAMain")!
        .getElement("ProgramDescription")!
        .getElement("ProgramInformationTable")!
        .getElement("ProgramInformation")!
        .getElement("BasicDescription")!
        .findElements("Title");

    String mainTitle = titles.first.innerText;

    String secTitle = titles.last.innerText;

    Iterable<XmlElement> synposisis = data
        .getElement("TVAMain")!
        .getElement("ProgramDescription")!
        .getElement("ProgramInformationTable")!
        .getElement("ProgramInformation")!
        .getElement("BasicDescription")!
        .findElements("Synopsis");

    String synposisMedium = synposisis.first.innerText;

    //TODO is optional S.115
    String sysnopsisLong = synposisis.last.innerText;

    //TODO genre is optional -> check
    String genre = "";
    if (data.findAllElements("Genre").isNotEmpty) {
      genre = data
          .getElement("TVAMain")!
          .getElement("ProgramDescription")!
          .getElement("ProgramInformationTable")!
          .getElement("ProgramInformation")!
          .getElement("BasicDescription")!
          .getElement("Genre")!
          .getAttribute("href")!;
    }
    String imageUrl = data
        .getElement("TVAMain")!
        .getElement("ProgramDescription")!
        .getElement("ProgramInformationTable")!
        .getElement("ProgramInformation")!
        .getElement("BasicDescription")!
        .getElement("RelatedMaterial")!
        .getElement("MediaLocator")!
        .getElement("MediaUri")!
        .innerText;

    return ProgramInfo(
        programId: programId,
        mainTitle: mainTitle,
        secTitle: secTitle,
        synopsisLong: sysnopsisLong,
        synopsisMedium: synposisMedium,
        genre: genre,
        imageUrl: imageUrl);
  }

  Map<String, dynamic> toJson() => {
        'programId': programId,
        'mainTitle': mainTitle,
        'secTitle': secTitle,
        'synopsisLong': synopsisLong,
        'synopsisMedium': synopsisMedium,
        'genre': genre,
        'imageUrl': imageUrl
      };
}

class ScheduleInfo {
  final XmlDocument data;

  ScheduleInfo({required this.data});

  factory ScheduleInfo.parse({required XmlDocument data}) {
    return ScheduleInfo(data: data);
  }

  Map<String, dynamic> toJson() => {};
}

class ScheduleInfoNowNext {
  Program current; //member of now
  Program next; //member 0f next

  ScheduleInfoNowNext({required this.current, required this.next});

  factory ScheduleInfoNowNext.parse({required XmlDocument data}) {
    //TODO check if now & next are present-> if first and last can be same

    Iterable<XmlElement> programArr = data
        .getElement("TVAMain")!
        .getElement("ProgramDescription")!
        .getElement("ProgramInformationTable")!
        .childElements; //ProgramInformation

    XmlElement dataProgCurrent = programArr.first;
    XmlElement dataProgNext = programArr.last;

    Iterable<XmlElement> scheduleArr = data
        .getElement("TVAMain")!
        .getElement("ProgramDescription")!
        .getElement("ProgramLocationTable")!
        .getElement("Schedule")!
        .childElements; //ScheduleEvent

    XmlElement dataScheduleCurrent = scheduleArr.first;
    XmlElement dataScheduleNext = scheduleArr.last;

    Program current = Program.parse(
        dataProg: dataProgCurrent, dataSchedule: dataScheduleCurrent);
    Program next =
        Program.parse(dataProg: dataProgNext, dataSchedule: dataScheduleNext);
    return ScheduleInfoNowNext(current: current, next: next);
  }
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
