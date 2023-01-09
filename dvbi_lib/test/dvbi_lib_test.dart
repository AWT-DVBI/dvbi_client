import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:xml/xml.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'dart:convert';
import 'package:pretty_json/pretty_json.dart';

Future<void> main() async {
  var progInfoXml = '''<?xml version="1.0" encoding="UTF-8"?>
<TVAMain xmlns="urn:tva:metadata:2019" xmlns:mpeg7="urn:tva:mpeg7:2008" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" publicationTime="2022-09-08T06:05:17Z" publisher="MIT-xperts iSIMS" xml:lang="de" xsi:schemaLocation="urn:tva:metadata:2019 tva_metadata_3-1.xsd">
    <ProgramDescription>
        <ProgramInformationTable>
            <ProgramInformation programId="crid://1.1019.10301/25107">
                <BasicDescription>
                    <Title xml:lang="de" type="main">Die Briefe meiner Mutter</Title>
                    <Title type="secondary" xml:lang="de">Fernsehfilm Deutschland 2014</Title>
                    <Synopsis length="medium" xml:lang="de">Einen Tag vor ihrem 18. Geburtstag findet Laura Hellmer durch Zufall heraus, dass ihre Mutter Katharina, eine renommierte Politjournalistin, sie jahrelang belogen hat: Lauras Vater war kein spanischer Kriegsfotograf, der vor ihrer Geburt starb, ...</Synopsis>
                    <Synopsis length="long" xml:lang="de">Einen Tag vor ihrem 18. Geburtstag findet Laura Hellmer durch Zufall heraus, dass ihre Mutter Katharina, eine renommierte Politjournalistin, sie jahrelang belogen hat: Lauras Vater war kein spanischer Kriegsfotograf, der vor ihrer Geburt starb, sondern lebt und befindet sich vermutlich in Chile. Kurzerhand macht sich Laura auf nach Südamerika, um ihren wahren Vater zu finden. Während sie sich in Santiago auf die Spuren ihrer Mutter begibt, die einst über die Opfer der Pinochet-Diktatur berichtete, reist Katharina ihrer Tochter hinterher.</Synopsis>
                    <Genre href="urn:tva:metadata:cs:ContentCS:2011:3.4"></Genre>
                    <RelatedMaterial>
                        <HowRelated href="urn:tva:metadata:cs:HowRelatedCS:2012:19"></HowRelated>
                        <MediaLocator>
                            <MediaUri contentType="image/jpeg">https://epgimg.ard-poc.de/MjAyMi0wMS0yMw==/61ecb000d65384000872687b_thumb.jpg</MediaUri>
                        </MediaLocator>
                    </RelatedMaterial>
                </BasicDescription>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_UNTERTITEL">S:J</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:IMPORT_EVENTID">S:62e25140828e8e00085c9ec5</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_MEHRKANAL">S:J</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_SCHWARZWEISS">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_DESKRIPTION">S:J</OtherIdentifier>
            </ProgramInformation>
        </ProgramInformationTable>
        <ProgramLocationTable>
      
    </ProgramLocationTable>
    </ProgramDescription>
</TVAMain>''';

//get now_next info parser
/*  final document = XmlDocument.parse(myxml);

  //TODO check if first and last can be same if only one element
  Iterable<XmlElement> scheduleArr = document
      .getElement("TVAMain")!
      .getElement("ProgramDescription")!
      .getElement("ProgramLocationTable")!
      .getElement("Schedule")!
      .childElements;

  XmlElement current = scheduleArr.first;
  XmlElement next = scheduleArr.last;

  //second node

  print("----");
  var mypsi = ProgramScheduleInfo.parse(data: document);
  
  var json1 = mypsi.current.toJson();
  var json2 = mypsi.next.toJson();

  //prettyJson returns a string
  print(prettyJson(json1, indent: 2));
  print(prettyJson(json2, indent: 2));
  
  */

  final document = XmlDocument.parse(progInfoXml);

  var mypi = ProgramInfo.parse(data: document);

  var json = mypi.toJson();

  //prettyJson returns a string
  print(prettyJson(json, indent: 2));

  /* print("testAttribute");
  print(mypsi.current.pid);
  print(mypsi.current.title);
  print(mypsi.current.mediaUrl);
  print(mypsi.current.startTime);
  print(mypsi.current.programDuration);
  print(mypsi.current.synopsis);

  print("----");
  print("testAttribute");
  print(mypsi.next.pid);
  print(mypsi.next.title);
  print(mypsi.next.mediaUrl);
  print(mypsi.next.startTime);
  print(mypsi.next.programDuration);
  print(mypsi.next.synopsis);
*/

  test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });
}

//delete proginfoxml because http request will be in future methode
ProgramInfo getProgramInfo(endpoint, pid, progInfoXml) {
  //

  return ProgramInfo.parse(data: progInfoXml);
}

/**
   * detailed information about specific program
   */
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

    String sysnopsisLong = synposisis.last.innerText;

    String genre = data
        .getElement("TVAMain")!
        .getElement("ProgramDescription")!
        .getElement("ProgramInformationTable")!
        .getElement("ProgramInformation")!
        .getElement("BasicDescription")!
        .getElement("Genre")!
        .getAttribute("href")!;

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

/**
 * for now_next = true programinfo xml-parser
 * more info see dvbi docs - 6.5.3 Now/Next Filtered Schedule Request
 */
class ProgramScheduleInfo {
  ProgramSchedule current; //member of now
  ProgramSchedule next; //member 0f next

  ProgramScheduleInfo({required this.current, required this.next});

  factory ProgramScheduleInfo.parse({required XmlDocument data}) {
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

    ProgramSchedule current = ProgramSchedule.parse(
        dataProg: dataProgCurrent, dataSchedule: dataScheduleCurrent);
    ProgramSchedule next = ProgramSchedule.parse(
        dataProg: dataProgNext, dataSchedule: dataScheduleNext);
    return ProgramScheduleInfo(current: current, next: next);
  }
}

// prgrammschedule
class ProgramSchedule {
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

  ProgramSchedule(
      {required this.pid,
      required this.title,
      required this.synopsis,
      required this.mediaUrl,
      required this.startTime,
      required this.programDuration});

  /**
   * xmlElemet start at level ProgramInformation=dataprog & dataschedule=programlocationtable/ScheduleEvent
   */
  factory ProgramSchedule.parse(
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

    return ProgramSchedule(
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
