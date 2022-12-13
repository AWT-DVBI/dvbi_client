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

  final document = XmlDocument.parse(myxml);

  //print(document.toString());

  XmlElement? e1 = document.getElement("TVAMain");

  print(e1
      ?.getElement("ProgramDescription")
      ?.getElement("ProgramInformationTable")
      ?.getElement("ProgramInformation")
      ?.getElement("BasicDescription")
      ?.getElement("Title")
      ?.innerText);

  test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });
}

class ProgramScheduleInfo {
  Program current; //member of now
  Program next; //member 0f next

  ProgramScheduleInfo({required this.current, required this.next});

  factory ProgramScheduleInfo.parse({required XmlDocument data}) {
    //TODO
    XmlElement dataProg = data.getElement("name")!;
    XmlElement dataSchedule = data.getElement("name")!;

    //TODO
    Program current =
        Program.parse(dataProg: dataProg, dataSchedule: dataSchedule);
    Program next =
        Program.parse(dataProg: dataProg, dataSchedule: dataSchedule);
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
  String endTime;
  // PublishedDuration
  String programDuration;

  Program(
      {required this.pid,
      required this.title,
      required this.synopsis,
      required this.mediaUrl,
      required this.startTime,
      required this.endTime,
      required this.programDuration});

  /**
   * xmlElemet start at level ProgramInformation=dataprog & dataschedule=programlocationtable
   */
  factory Program.parse(
      {required XmlElement dataProg, required XmlElement dataSchedule}) {
    String pid =
        dataProg.getElement("ProgramInformation")!.getAttribute("programId")!;
    String title = dataProg
        .getElement("ProgramInformation")!
        .getElement("BasicDescription")!
        .getElement("Title")!
        .innerText;
    String? synopsis = dataProg
        .getElement("ProgramInformation")!
        .getElement("BasicDescription")!
        .getElement("Synopsis")!
        .innerText;
    //todo evtl uri
    String mediaUrl = dataProg
        .getElement("ProgramInformation")!
        .getElement("BasicDescription")!
        .getElement("Title")!
        .innerText;

    String startTime = dataSchedule.getAttribute("start")!;
    String endTime = dataSchedule.getAttribute("end")!;

    //toDo
    String programDuration = dataSchedule.getElement("end")!.innerText;

    return Program(
        pid: pid,
        title: title,
        synopsis: synopsis,
        mediaUrl: mediaUrl,
        startTime: startTime,
        endTime: endTime,
        programDuration: programDuration);
  }
}
