// ignore_for_file: avoid_print, unused_local_variable

import 'package:dvbi_lib/program_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:dvbi_lib/dvbi.dart';
import 'package:xml/xml.dart';

const String endpointUrl = "https://dvb-i.net/production/services.php/de";

Future<void> main() async {
  /* final dvbi = await DVBI.create(endpointUrl: Uri.parse(endpointUrl));
  var services = dvbi.stream;

  var first = await services.first;

  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(first);
  print(prettyprint);
  print("end");*/

//test optimal xml case

  var detailProgramXml = '''<?xml version="1.0" encoding="UTF-8"?>
<TVAMain xmlns="urn:tva:metadata:2019"
xmlns:mpeg7="urn:tva:mpeg7:2008" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:xsd="http://www.w3.org/2001/XMLSchema" xml:lang="en">
<ProgramDescription>
<ProgramInformationTable xml:lang="en">
<ProgramInformation programId="crid://channel7.co.uk/b01myjsy">
<BasicDescription>
<Title type="main">Bargain Hunt</Title>
<Title type="secondary">01/01/2014</Title>
<Synopsis length="short">The Bargain Hunt teams head to
Staffordshire's County Showground.</Synopsis>
<Synopsis length="medium">The Bargain Hunt teams head to
Staffordshire's County Showground, where both experts face double trouble.</Synopsis>
<Synopsis length="long">The Bargain Hunt teams head to
Staffordshire's County Showground, where both experts face double trouble.
David Harper heads up two Toms for the red team, while twin sisters
Elizabeth and Rachel are guided by Jonathan Pratt for the blue team. Tim
Wonnacott travels to Bath to visit one of the city's greatest architectural
delights.</Synopsis>
<Keyword>FAMILY LIFE</Keyword>
<Keyword>RELATIONSHIPS</Keyword>
<Keyword type="other">Critic's Choice</Keyword>
<Genre href="urn:dvb:metadata:cs:ContentSubject:2019:3" type="main"/>
<ParentalGuidance>
<mpeg7:MinimumAge>15</mpeg7:MinimumAge>
</ParentalGuidance>
<ParentalGuidance>
<mpeg7:ParentalRating
href="urn:fvc:metadata:cs:ContentRatingCS:2014-07:fifteen"/>
<ExplanatoryText length="long">Contains strong language and flash
photography</ExplanatoryText>
</ParentalGuidance>
<CreditsList>
<CreditsItem role="urn:tva:metadata:cs:TVARoleCS:2011:V20">
<OrganizationName>International Studios Limited</OrganizationName>
</CreditsItem>
<CreditsItem role="urn:tva:metadata:cs:TVARoleCS:2011:AD6">
<PersonName>
<mpeg7:GivenName>Jeremy</mpeg7:GivenName>
<mpeg7:FamilyName>Brown</mpeg7:FamilyName>
</PersonName>
</CreditsItem>
<CreditsItem role="urn:mpeg:mpeg7:cs:RoleCS:2001:ACTOR">
<PersonName>
<mpeg7:GivenName>William</mpeg7:GivenName>
<mpeg7:FamilyName>Johnson</mpeg7:FamilyName>
</PersonName>
<Character>
<mpeg7:GivenName>Billy</mpeg7:GivenName>
<mpeg7:FamilyName>Johns</mpeg7:FamilyName>
</Character>
</CreditsItem>
</CreditsList>
<RelatedMaterial>
<HowRelated href="urn:tva:metadata:cs:HowRelatedCS:2012:19"></HowRelated>
<MediaLocator>
<MediaUri contentType="image/jpeg">https://epgimg.ard-poc.de/MjAyMS0wMy0wMg==/603e4a0cc6aaee0008f9ce47_thumb.jpg?t=1616525136813</MediaUri>
</MediaLocator>
</RelatedMaterial>
</BasicDescription>
</ProgramInformation>
</ProgramInformationTable>
<ProgramLocationTable xml:lang="en">
<OnDemandProgram serviceIDRef="https://channel7.co.uk/service_a_app">
<Program crid="crid://channel7.co.uk/b01myjsy"/>
<ProgramURL contentType="application/vnd.dvb.ait+xml">
https://channel7.co.uk/ait.aitx?pid=b01myjsy</ProgramURL>
<AuxiliaryURL contentType="application/vnd.dvb.ait+xml">
https://channel7.co.uk/ait.aitx?template</AuxiliaryURL>
<InstanceDescription>
<Genre
href="urn:fvc:metadata:cs:MediaAvailabilityCS:2014-07:media_available" type="other"/>
<Genre
href="urn:fvc:metadata:cs:FEPGAvailabilityCS:2014-10:fepg_unavailable" type="other"/>
<CaptionLanguage closed="true">en</CaptionLanguage>
<AVAttributes>
<VideoAttributes>
<HorizontalSize>576</HorizontalSize>
<VerticalSize>512</VerticalSize>
<AspectRatio>16:9</AspectRatio>
</VideoAttributes>
</AVAttributes>
</InstanceDescription>
<PublishedDuration>PT1H</PublishedDuration>
<StartOfAvailability>2013-09-25T12:03:09Z</StartOfAvailability>
<EndOfAvailability>2013-10-02T09:59:00Z</EndOfAvailability>
<DeliveryMode>streaming</DeliveryMode>
<Free value="true"/>
</OnDemandProgram>
</ProgramLocationTable></ProgramDescription>
</TVAMain>''';

  final document = XmlDocument.parse(detailProgramXml);

  final data = document
      .getElement("TVAMain")!
      .getElement("ProgramDescription")!
      .getElement("ProgramInformationTable")!
      .getElement("ProgramInformation")!;

  ProgramInfo prog = ProgramInfo(
      programId: "TestprogramId",
      mainTitle: "TestmainTitle",
      secondaryTitle: "TsecondaryTitle",
      synopsisMedium: "TsynopsisMedium",
      synopsisShort: "TsynopsisShort",
      genre: null,
      imageUrl: null,
      publishedStartTime: DateTime.parse("2013-09-25T12:03:09Z"),
      publishedDuration: 2.0);

  var mytest = DetailedProgramInfo.parse(data: document, programInfo: prog);

  print(mytest.toJson());
}
