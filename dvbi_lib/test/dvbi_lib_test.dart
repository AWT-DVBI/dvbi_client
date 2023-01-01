import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:xml/xml.dart';
import 'package:dvbi_lib/dvbi_lib.dart';

Future<void> main() async {
  print("hello");

  var myxml = '''<?xml version="1.0"?>
<TVAMain xmlns="urn:tva:metadata:2019" xmlns:mpeg7="urn:tva:mpeg7:2008" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xml:lang="de">
    <ProgramDescription>
        <ProgramInformationTable xml:lang="de">
            <ProgramInformation programId="crid://zdf.de/metadata/broadcast_item/83791/">
                <BasicDescription>
                    <Title type="main" xml:lang="de">
                        <![CDATA[Mythos Concorde]]>
                    </Title>
                    <Synopsis length="medium" xml:lang="de">
                        <![CDATA[Keine Beschreibung verfügbar]]>
                    </Synopsis>
                    <RelatedMaterial>
                        <HowRelated href="urn:tva:metadata:cs:HowRelatedCS:2012:19"/>
                        <MediaLocator>
                            <MediaUri contentType="image/png">https://int-dvbi.zdf.de/contentguide/image/4213.png</MediaUri>
                        </MediaLocator>
                    </RelatedMaterial>
                </BasicDescription>
                <MemberOf crid="crid://dvb.org/metadata/schedules/now-next/now" index="1"/>
            </ProgramInformation>
            <ProgramInformation programId="crid://zdf.de/metadata/broadcast_item/83792/">
                <BasicDescription>
                    <Title type="main" xml:lang="de">
                        <![CDATA[Mythos Concorde]]>
                    </Title>
                    <Synopsis length="medium" xml:lang="de">
                        <![CDATA[Die Concorde gilt noch heute als technisches Meisterwerk. Obwohl ihr Betrieb sich bald als unrentabel erweist, fliegt sie jahrzehntelang. Bis ein tragischer Unfall alles verändert.]]>
                    </Synopsis>
                    <RelatedMaterial>
                        <HowRelated href="urn:tva:metadata:cs:HowRelatedCS:2012:19"/>
                        <MediaLocator>
                            <MediaUri contentType="image/png">https://int-dvbi.zdf.de/contentguide/image/4214.png</MediaUri>
                        </MediaLocator>
                    </RelatedMaterial>
                </BasicDescription>
                <MemberOf crid="crid://dvb.org/metadata/schedules/now-next/later" index="1"/>
            </ProgramInformation>
        </ProgramInformationTable>
        <GroupInformationTable>
            <GroupInformation groupId="crid://dvb.org/metadata/schedules/now-next/now" numOfItems="1" ordered="true">
                <GroupType value="otherCollection" xsi:type="ProgramGroupTypeType"/>
                <BasicDescription/>
            </GroupInformation>
            <GroupInformation groupId="crid://dvb.org/metadata/schedules/now-next/later" numOfItems="1" ordered="true">
                <GroupType value="otherCollection" xsi:type="ProgramGroupTypeType"/>
                <BasicDescription/>
            </GroupInformation>
        </GroupInformationTable>
        <ProgramLocationTable>
            <Schedule serviceIDRef="tag:zdf.de,2020:zdfinfo" start="2022-12-12T17:45:00Z" end="2022-12-12T19:15:00Z">
                <ScheduleEvent>
                    <Program crid="crid://zdf.de/metadata/broadcast_item/83791/"/>
                    <PublishedStartTime>2022-12-12T17:45:00Z</PublishedStartTime>
                    <PublishedDuration>PT45M</PublishedDuration>
                </ScheduleEvent>
                <ScheduleEvent>
                    <Program crid="crid://zdf.de/metadata/broadcast_item/83792/"/>
                    <PublishedStartTime>2022-12-12T18:30:00Z</PublishedStartTime>
                    <PublishedDuration>PT45M</PublishedDuration>
                </ScheduleEvent>
            </Schedule>
        </ProgramLocationTable>
    </ProgramDescription>
</TVAMain>''';

//get now_next info parser
  final document = XmlDocument.parse(myxml);

  //TODO check if first and last can be same if only one element
  Iterable<XmlElement> scheduleArr = document
      .getElement("TVAMain")!
      .getElement("ProgramDescription")!
      .getElement("ProgramLocationTable")!
      .getElement("Schedule")!
      .childElements;

  print(scheduleArr.length);

  XmlElement current = scheduleArr.first;
  XmlElement next = scheduleArr.last;

  print(current.getElement("PublishedStartTime"));
  print(next.getElement("PublishedStartTime"));

  print("Test1 ende");
  //second node

  print("----");
  var mypsi = ProgramScheduleInfo.parse(data: document);
  print("testAttribute");
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

  test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });
}

/**
 * for now_next = true programinfo xml-parser
 */
class ProgramScheduleInfo {
  Program current; //member of now
  Program next; //member 0f next

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

    Program current = Program.parse(
        dataProg: dataProgCurrent, dataSchedule: dataScheduleCurrent);
    Program next =
        Program.parse(dataProg: dataProgNext, dataSchedule: dataScheduleNext);
    return ProgramScheduleInfo(current: current, next: next);
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

  /**
   * xmlElemet start at level ProgramInformation=dataprog & dataschedule=programlocationtable/ScheduleEvent
   */
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
}
