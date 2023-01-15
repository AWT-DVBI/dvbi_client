import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:xml/xml.dart';
import 'package:dvbi_lib/dvbi_lib.dart';
import 'dart:convert';
import 'package:pretty_json/pretty_json.dart';

Future<void> main() async {
  var progInfoXml = '''<?xml version="1.0" encoding="UTF-8"?>
<TVAMain xmlns="urn:tva:metadata:2019" xmlns:mpeg7="urn:tva:mpeg7:2008" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" publicationTime="2023-01-13T14:36:37Z" publisher="MIT-xperts iSIMS" xml:lang="de" xsi:schemaLocation="urn:tva:metadata:2019 tva_metadata_3-1.xsd">
    <ProgramDescription>
        <ProgramInformationTable>
            <ProgramInformation programId="crid://1.1019.10301/29821">
                <BasicDescription>
                    <Title xml:lang="de" type="main">Tagesschau</Title>
                    <Synopsis length="medium" xml:lang="de">Die Nachrichten der ARD</Synopsis>
                    <Genre href="urn:tva:metadata:cs:ContentCS:2011:3.1"></Genre>
                    <RelatedMaterial>
                        <HowRelated href="urn:tva:metadata:cs:HowRelatedCS:2012:19"></HowRelated>
                        <MediaLocator>
                            <MediaUri contentType="image/jpeg">https://epgimg.ard-poc.de/MjAyMS0wMy0wMg==/603e4a0cc6aaee0008f9ce47_thumb.jpg?t=1616525136813</MediaUri>
                        </MediaLocator>
                    </RelatedMaterial>
                </BasicDescription>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_UNTERTITEL">S:J</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:IMPORT_EVENTID">S:638b10fed4dc9d0008bf826e</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_MEHRKANAL">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_SCHWARZWEISS">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_DESKRIPTION">S:N</OtherIdentifier>
            </ProgramInformation>
            <ProgramInformation programId="crid://1.1019.10301/29822">
                <BasicDescription>
                    <Title xml:lang="de" type="main">Verrückt nach Meer (318)</Title>
                    <Title type="secondary" xml:lang="de">Der Klang von New Orleans</Title>
                    <Synopsis length="medium" xml:lang="de">"Jetzt wird eingespiced!" Für Kapitän und Kreuzfahrtdirektor entwickelt sich ein Ausflug ins legendäre French Quarter von New Orleans zu einer scharfen Angelegenheit. Singer-Songwriter Jonathan Zelter geht in den Sümpfen von Louisiana auf ...</Synopsis>
                    <Genre href="urn:tva:metadata:cs:ContentCS:2011:3.1.3"></Genre>
                    <RelatedMaterial>
                        <HowRelated href="urn:tva:metadata:cs:HowRelatedCS:2012:19"></HowRelated>
                        <MediaLocator>
                            <MediaUri contentType="image/jpeg">https://epgimg.ard-poc.de/MjAyMS0wNS0wMQ==/608ca6ab0b51af0008d817b1_thumb.jpg</MediaUri>
                        </MediaLocator>
                    </RelatedMaterial>
                </BasicDescription>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_UNTERTITEL">S:J</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:IMPORT_EVENTID">S:638b10fed4dc9d0008bf8283</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_MEHRKANAL">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_SCHWARZWEISS">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_DESKRIPTION">S:N</OtherIdentifier>
            </ProgramInformation>
            <ProgramInformation programId="crid://1.1019.10301/29823">
                <BasicDescription>
                    <Title xml:lang="de" type="main">Tagesschau</Title>
                    <Synopsis length="medium" xml:lang="de">Die Nachrichten der ARD</Synopsis>
                    <Genre href="urn:tva:metadata:cs:ContentCS:2011:3.1"></Genre>
                    <RelatedMaterial>
                        <HowRelated href="urn:tva:metadata:cs:HowRelatedCS:2012:19"></HowRelated>
                        <MediaLocator>
                            <MediaUri contentType="image/jpeg">https://epgimg.ard-poc.de/MjAyMS0wMy0wMg==/603e4a0cc6aaee0008f9ce47_thumb.jpg?t=1616525136813</MediaUri>
                        </MediaLocator>
                    </RelatedMaterial>
                </BasicDescription>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_UNTERTITEL">S:J</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:IMPORT_EVENTID">S:638b10fed4dc9d0008bf8299</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_MEHRKANAL">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_SCHWARZWEISS">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_DESKRIPTION">S:N</OtherIdentifier>
            </ProgramInformation>
            <ProgramInformation programId="crid://1.1019.10301/29824">
                <BasicDescription>
                    <Title xml:lang="de" type="main">Brisant</Title>
                    <Title type="secondary" xml:lang="de">Marwa Eldessouky</Title>
                    <Synopsis length="medium" xml:lang="de">Themen:
* Unbekannte überfallen Geldtransporter:
Großeinsatz für die Polizei Saarlouis
* Steigende Pegel und Dauerregen: Anwohner in Sorge vor nächster Flutkatastrophe
* Gefahr auf schneefreien und vereisten Pisten: Wie hoch ist das Risiko, im ...</Synopsis>
                    <RelatedMaterial>
                        <HowRelated href="urn:tva:metadata:cs:HowRelatedCS:2012:19"></HowRelated>
                        <MediaLocator>
                            <MediaUri contentType="image/jpeg">https://epgimg.ard-poc.de/MjAyMC0xMS0xMA==/5faae5d8b8510e0008270ad2_thumb.jpg?t=1617890022061</MediaUri>
                        </MediaLocator>
                    </RelatedMaterial>
                </BasicDescription>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_UNTERTITEL">S:J</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:IMPORT_EVENTID">S:638b10fed4dc9d0008bf82ae</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_MEHRKANAL">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_SCHWARZWEISS">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_DESKRIPTION">S:N</OtherIdentifier>
            </ProgramInformation>
            <ProgramInformation programId="crid://1.1019.10301/29825">
                <BasicDescription>
                    <Title xml:lang="de" type="main">Wer weiß denn sowas? (950)</Title>
                    <Title type="secondary" xml:lang="de">Gäste: Cathy Hummels und Diana zur Löwen</Title>
                    <Synopsis length="medium" xml:lang="de">Die beiden Influencerinnen Cathy Hummels und Diana zur Löwen spielen heute an der Seite der Teamchefs Bernhard Hoëcker und Elton, um die richtige Antwort auf Fachfragen wie diese zu erraten:

Welches Hausmittel sorgt mit einer Wimpernzange für ...</Synopsis>
                    <RelatedMaterial>
                        <HowRelated href="urn:tva:metadata:cs:HowRelatedCS:2012:19"></HowRelated>
                        <MediaLocator>
                            <MediaUri contentType="image/jpeg">https://epgimg.ard-poc.de/MjAyMi0xMi0yMA==/63a112e7d4dc9d0008e4cc61_thumb.jpg</MediaUri>
                        </MediaLocator>
                    </RelatedMaterial>
                </BasicDescription>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_UNTERTITEL">S:J</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:IMPORT_EVENTID">S:638b10fed4dc9d0008bf82c3</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_MEHRKANAL">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_SCHWARZWEISS">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_DESKRIPTION">S:N</OtherIdentifier>
            </ProgramInformation>
            <ProgramInformation programId="crid://1.1019.10301/29826">
                <BasicDescription>
                    <Title xml:lang="de" type="main">Quizduell-Olymp (407)</Title>
                    <Title type="secondary" xml:lang="de">Gäste: Melissa Khalaj und Laura Karasek</Title>
                    <Synopsis length="medium" xml:lang="de">Ihre Karriere begann mit der Castingshow "Popstars". Seit 2022 moderiert Melissa Khalaj "The Voice of Germany". Mit Musik kennt sich die 33-Jährige demnach aus. Ihre Quizpartnerin Laura Karasek ist ein echtes Multitalent: "Gegen zwei weibliche ...</Synopsis>
                    <RelatedMaterial>
                        <HowRelated href="urn:tva:metadata:cs:HowRelatedCS:2012:19"></HowRelated>
                        <MediaLocator>
                            <MediaUri contentType="image/jpeg">https://epgimg.ard-poc.de/MjAyMi0xMi0xMg==/6396857e740c7d00072e485e_thumb.jpg</MediaUri>
                        </MediaLocator>
                    </RelatedMaterial>
                </BasicDescription>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_UNTERTITEL">S:J</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:IMPORT_EVENTID">S:6390a05f06e3c50008508891</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_MEHRKANAL">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_SCHWARZWEISS">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_DESKRIPTION">S:N</OtherIdentifier>
            </ProgramInformation>
            <ProgramInformation programId="crid://1.1019.10301/29827">
                <BasicDescription>
                    <Title xml:lang="de" type="main">Wissen vor acht - Zukunft</Title>
                    <Title type="secondary" xml:lang="de">Der eigene Traum als Video</Title>
                    <Synopsis length="medium" xml:lang="de">Sich den eigenen Traum mal als Video anschauen, wirklich traumhaft oder eher ein Alptraum? Wie Forscher versuchen, Gehirnaktivität beim Träumen zu dekodieren, erfährt man heute in "Wissen vor acht - Zukunft".</Synopsis>
                    <RelatedMaterial>
                        <HowRelated href="urn:tva:metadata:cs:HowRelatedCS:2012:19"></HowRelated>
                        <MediaLocator>
                            <MediaUri contentType="image/jpeg">https://epgimg.ard-poc.de/MjAyMi0xMi0xMg==/63968582740c7d00072e486a_thumb.jpg</MediaUri>
                        </MediaLocator>
                    </RelatedMaterial>
                </BasicDescription>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_UNTERTITEL">S:J</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:IMPORT_EVENTID">S:638b10fed4dc9d0008bf82eb</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_MEHRKANAL">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_SCHWARZWEISS">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_DESKRIPTION">S:J</OtherIdentifier>
            </ProgramInformation>
            <ProgramInformation programId="crid://1.1019.10301/29828">
                <BasicDescription>
                    <Title xml:lang="de" type="main">Wetter vor acht</Title>
                    <Title type="secondary" xml:lang="de">mit Claudia Kleinert</Title>
                    <Synopsis length="medium" xml:lang="de">Wie wird das Wetter? Sonne in Stuttgart, Nebel in Nürnberg, Bremen bewölkt? Hier gibt's die aktuellen Wetterprognosen.</Synopsis>
                    <RelatedMaterial>
                        <HowRelated href="urn:tva:metadata:cs:HowRelatedCS:2012:19"></HowRelated>
                        <MediaLocator>
                            <MediaUri contentType="image/jpeg">https://epgimg.ard-poc.de/MjAyMS0wNS0wMQ==/608ca6ba884b2e0008f38a5e_thumb.jpg</MediaUri>
                        </MediaLocator>
                    </RelatedMaterial>
                </BasicDescription>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_UNTERTITEL">S:J</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:IMPORT_EVENTID">S:638b10fed4dc9d0008bf8300</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_MEHRKANAL">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_SCHWARZWEISS">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_DESKRIPTION">S:N</OtherIdentifier>
            </ProgramInformation>
            <ProgramInformation programId="crid://1.1019.10301/29829">
                <BasicDescription>
                    <Title xml:lang="de" type="main">Wirtschaft vor acht</Title>
                    <Synopsis length="medium" xml:lang="de">...</Synopsis>
                    <Genre href="urn:tva:metadata:cs:ContentCS:2011:3.1.3.3"></Genre>
                </BasicDescription>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_UNTERTITEL">S:J</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:IMPORT_EVENTID">S:638b10fed4dc9d0008bf8315</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_MEHRKANAL">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_SCHWARZWEISS">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_DESKRIPTION">S:N</OtherIdentifier>
            </ProgramInformation>
            <ProgramInformation programId="crid://1.1019.10301/29830">
                <BasicDescription>
                    <Title xml:lang="de" type="main">Tagesschau</Title>
                    <Synopsis length="medium" xml:lang="de">...</Synopsis>
                    <Genre href="urn:tva:metadata:cs:ContentCS:2011:3.1"></Genre>
                    <RelatedMaterial>
                        <HowRelated href="urn:tva:metadata:cs:HowRelatedCS:2012:19"></HowRelated>
                        <MediaLocator>
                            <MediaUri contentType="image/jpeg">https://epgimg.ard-poc.de/MjAyMS0xMC0yOQ==/617b4fc46dff7b00087c429c_thumb.jpg</MediaUri>
                        </MediaLocator>
                    </RelatedMaterial>
                </BasicDescription>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_UNTERTITEL">S:J</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:IMPORT_EVENTID">S:638b10fed4dc9d0008bf832a</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_MEHRKANAL">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_SCHWARZWEISS">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_DESKRIPTION">S:N</OtherIdentifier>
            </ProgramInformation>
            <ProgramInformation programId="crid://1.1019.10301/29831">
                <BasicDescription>
                    <Title xml:lang="de" type="main">2 unter Millionen</Title>
                    <Title type="secondary" xml:lang="de">Fernsehfilm Deutschland 2022</Title>
                    <Synopsis length="medium" xml:lang="de">Auf Glück im Spiel folgt Pech in der Liebe für Oliver Mommsen als Paketbote Henry in "2 unter Millionen": Erst das Beziehungsaus nach 21 Ehejahren - und dann droht der Jackpot-Gewinner aus unbedachtem Egoismus die Chance auf ein neues Glück zu ...</Synopsis>
                    <Genre href="urn:tva:metadata:cs:ContentCS:2011:3.4"></Genre>
                    <ParentalGuidance>
                        <mpeg7:MinimumAge>6</mpeg7:MinimumAge>
                        <mpeg7:Region>DE</mpeg7:Region>
                    </ParentalGuidance>
                    <RelatedMaterial>
                        <HowRelated href="urn:tva:metadata:cs:HowRelatedCS:2012:19"></HowRelated>
                        <MediaLocator>
                            <MediaUri contentType="image/jpeg">https://epgimg.ard-poc.de/MjAyMi0xMi0xMg==/63968583d4dc9d0008d573d7_thumb.jpg</MediaUri>
                        </MediaLocator>
                    </RelatedMaterial>
                </BasicDescription>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_UNTERTITEL">S:J</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:IMPORT_EVENTID">S:638b10fed4dc9d0008bf833f</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_MEHRKANAL">S:J</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_SCHWARZWEISS">S:N</OtherIdentifier>
                <OtherIdentifier organization="MIT-xperts" type="addvalue:ARDPOC_AUDIO_DESKRIPTION">S:J</OtherIdentifier>
            </ProgramInformation>
        </ProgramInformationTable>
        <ProgramLocationTable>
            <Schedule end="2023-02-10T00:45:00Z" serviceIDRef="tag:mitxp.com,2021:1.1019.10301" start="2023-01-12T23:15:00Z">
                <ScheduleEvent>
                    <Program crid="crid://1.1019.10301/29821"></Program>
                    <InstanceDescription>
                        <Title type="epgevent" xml:lang="de">Tagesschau</Title>
                        <OtherIdentifier organization="MIT-xperts" type="eventid">29821</OtherIdentifier>
                    </InstanceDescription>
                    <PublishedStartTime>2023-01-13T15:00:00Z</PublishedStartTime>
                    <PublishedDuration>PT10M</PublishedDuration>
                    <Free value="true"></Free>
                </ScheduleEvent>
                <ScheduleEvent>
                    <Program crid="crid://1.1019.10301/29822"></Program>
                    <InstanceDescription>
                        <Title type="epgevent" xml:lang="de">Verrückt nach Meer (318)</Title>
                        <OtherIdentifier organization="MIT-xperts" type="eventid">29822</OtherIdentifier>
                    </InstanceDescription>
                    <PublishedStartTime>2023-01-13T15:10:00Z</PublishedStartTime>
                    <PublishedDuration>PT50M</PublishedDuration>
                    <Free value="true"></Free>
                </ScheduleEvent>
                <ScheduleEvent>
                    <Program crid="crid://1.1019.10301/29823"></Program>
                    <InstanceDescription>
                        <Title type="epgevent" xml:lang="de">Tagesschau</Title>
                        <OtherIdentifier organization="MIT-xperts" type="eventid">29823</OtherIdentifier>
                    </InstanceDescription>
                    <PublishedStartTime>2023-01-13T16:00:00Z</PublishedStartTime>
                    <PublishedDuration>PT15M</PublishedDuration>
                    <Free value="true"></Free>
                </ScheduleEvent>
                <ScheduleEvent>
                    <Program crid="crid://1.1019.10301/29824"></Program>
                    <InstanceDescription>
                        <Title type="epgevent" xml:lang="de">Brisant</Title>
                        <OtherIdentifier organization="MIT-xperts" type="eventid">29824</OtherIdentifier>
                    </InstanceDescription>
                    <PublishedStartTime>2023-01-13T16:15:00Z</PublishedStartTime>
                    <PublishedDuration>PT45M</PublishedDuration>
                    <Free value="true"></Free>
                </ScheduleEvent>
                <ScheduleEvent>
                    <Program crid="crid://1.1019.10301/29825"></Program>
                    <InstanceDescription>
                        <Title type="epgevent" xml:lang="de">Wer weiß denn sowas? (950)</Title>
                        <OtherIdentifier organization="MIT-xperts" type="eventid">29825</OtherIdentifier>
                    </InstanceDescription>
                    <PublishedStartTime>2023-01-13T17:00:00Z</PublishedStartTime>
                    <PublishedDuration>PT50M</PublishedDuration>
                    <Free value="true"></Free>
                </ScheduleEvent>
                <ScheduleEvent>
                    <Program crid="crid://1.1019.10301/29826"></Program>
                    <InstanceDescription>
                        <Title type="epgevent" xml:lang="de">Quizduell-Olymp (407)</Title>
                        <OtherIdentifier organization="MIT-xperts" type="eventid">29826</OtherIdentifier>
                    </InstanceDescription>
                    <PublishedStartTime>2023-01-13T17:50:00Z</PublishedStartTime>
                    <PublishedDuration>PT55M</PublishedDuration>
                    <Free value="true"></Free>
                </ScheduleEvent>
                <ScheduleEvent>
                    <Program crid="crid://1.1019.10301/29827"></Program>
                    <InstanceDescription>
                        <Title type="epgevent" xml:lang="de">Wissen vor acht - Zukunft</Title>
                        <OtherIdentifier organization="MIT-xperts" type="eventid">29827</OtherIdentifier>
                    </InstanceDescription>
                    <PublishedStartTime>2023-01-13T18:45:00Z</PublishedStartTime>
                    <PublishedDuration>PT5M</PublishedDuration>
                    <Free value="true"></Free>
                </ScheduleEvent>
                <ScheduleEvent>
                    <Program crid="crid://1.1019.10301/29828"></Program>
                    <InstanceDescription>
                        <Title type="epgevent" xml:lang="de">Wetter vor acht</Title>
                        <OtherIdentifier organization="MIT-xperts" type="eventid">29828</OtherIdentifier>
                    </InstanceDescription>
                    <PublishedStartTime>2023-01-13T18:50:00Z</PublishedStartTime>
                    <PublishedDuration>PT5M</PublishedDuration>
                    <Free value="true"></Free>
                </ScheduleEvent>
                <ScheduleEvent>
                    <Program crid="crid://1.1019.10301/29829"></Program>
                    <InstanceDescription>
                        <Title type="epgevent" xml:lang="de">Wirtschaft vor acht</Title>
                        <OtherIdentifier organization="MIT-xperts" type="eventid">29829</OtherIdentifier>
                    </InstanceDescription>
                    <PublishedStartTime>2023-01-13T18:55:00Z</PublishedStartTime>
                    <PublishedDuration>PT5M</PublishedDuration>
                    <Free value="true"></Free>
                </ScheduleEvent>
                <ScheduleEvent>
                    <Program crid="crid://1.1019.10301/29830"></Program>
                    <InstanceDescription>
                        <Title type="epgevent" xml:lang="de">Tagesschau</Title>
                        <OtherIdentifier organization="MIT-xperts" type="eventid">29830</OtherIdentifier>
                    </InstanceDescription>
                    <PublishedStartTime>2023-01-13T19:00:00Z</PublishedStartTime>
                    <PublishedDuration>PT15M</PublishedDuration>
                    <Free value="true"></Free>
                </ScheduleEvent>
                <ScheduleEvent>
                    <Program crid="crid://1.1019.10301/29831"></Program>
                    <InstanceDescription>
                        <Title type="epgevent" xml:lang="de">2 unter Millionen</Title>
                        <OtherIdentifier organization="MIT-xperts" type="eventid">29831</OtherIdentifier>
                    </InstanceDescription>
                    <PublishedStartTime>2023-01-13T19:15:00Z</PublishedStartTime>
                    <PublishedDuration>PT1H30M</PublishedDuration>
                    <Free value="true"></Free>
                </ScheduleEvent>
            </Schedule>
        </ProgramLocationTable>
    </ProgramDescription>
</TVAMain>''';

  final document = XmlDocument.parse(progInfoXml);

  var pst = ProgramScheduleInfoTimestamp.parse(document: document);

  pst.programs
      .forEach((element) => {print(prettyJson(element.toJson(), indent: 2))});

/*
  var pTime = ProgramScheduleInfoTimestamp.parse(data: document);
  
  for (var program in pTime.programs) {
   
   
    var json = program.toJson();

    //prettyJson returns a string
    print(prettyJson(json, indent: 2));
  }
*/
  test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
  });
}

class ProgramScheduleInfoTimestamp {
  //anfrage über bestimmten zeit radius
  //bsp 3 uhr und 21 uhr -> muss immer 6 h unterschied und andere condis in get xml einbauen

  //TODO sort by program starttime
  List<Program> programs = [];

  ProgramScheduleInfoTimestamp({required this.programs});

  factory ProgramScheduleInfoTimestamp.parse({required XmlDocument document}) {
    List<Program> programs = [];

    Iterable<Program> plist = document
        .findAllElements("ProgramInformation")
        .map((e) => Program(
            pid: e.getAttribute("programId")!,
            title: e
                .getElement("BasicDescription")!
                .getElement("Title")!
                .innerText,
            synopsis: e
                .getElement("BasicDescription")!
                .getElement("Synopsis")!
                .innerText,
            mediaUrl: e
                .getElement("BasicDescription")!
                .getElement("RelatedMaterial")
                ?.getElement("MediaLocator")
                ?.getElement("MediaUri")
                ?.innerText,
            startTime: document
                .findAllElements("ScheduleEvent")
                .firstWhere((element) =>
                    element.getElement("Program")!.getAttribute("crid")! ==
                    e.getAttribute("programId")!)
                .getElement("PublishedStartTime")!
                .innerText,
            programDuration: document
                .findAllElements("ScheduleEvent")
                .firstWhere((element) =>
                    element.getElement("Program")!.getAttribute("crid")! ==
                    e.getAttribute("programId")!)
                .getElement("PublishedDuration")!
                .innerText));

    programs = plist.toList();

    return ProgramScheduleInfoTimestamp(programs: programs);
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
  String? mediaUrl;
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

    String? mediaUrl;

    if (dataProg
            .getElement("BasicDescription")!
            .getElement("RelatedMaterial") !=
        null) {
      mediaUrl = dataProg
          .getElement("BasicDescription")!
          .getElement("RelatedMaterial")!
          .getElement("MediaLocator")!
          .getElement("MediaUri")!
          .innerText;
    }

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

  factory Program.parseTimestamps({required XmlDocument timestampData}) {
    //TODO correct parsings

    String pid = timestampData.getAttribute("programId")!;
    String title = timestampData
        .getElement("BasicDescription")!
        .getElement("Title")!
        .innerText;
    String? synopsis = timestampData
        .getElement("BasicDescription")!
        .getElement("Synopsis")!
        .innerText;
    //TODO evtl uri

    String? mediaUrl;

    if (timestampData
            .getElement("BasicDescription")!
            .getElement("RelatedMaterial") !=
        null) {
      mediaUrl = timestampData
          .getElement("BasicDescription")!
          .getElement("RelatedMaterial")!
          .getElement("MediaLocator")!
          .getElement("MediaUri")!
          .innerText;
    }

    String startTime =
        timestampData.getElement("PublishedStartTime")!.innerText;

    String programDuration =
        timestampData.getElement("PublishedDuration")!.innerText;

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
