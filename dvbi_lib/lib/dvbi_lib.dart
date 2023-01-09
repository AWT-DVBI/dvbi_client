// ignore_for_file: avoid_print

library dvbi_lib;

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:logging/logging.dart';
import 'package:collection/collection.dart';

final Logger _log = Logger("dvbi_lib");

class DVBIException implements Exception {
  String cause;
  DVBIException(this.cause);
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

/**
 * for now_next = true programinfo xml-parser
 * more info see dvbi docs - 6.5.3 Now/Next Filtered Schedule Request
 * req query -> <ScheduleInfoEndpoint>?sid=<service_id>&now_next=true
 * <service_id> -> from serviceList UniqueIdentifier or the ContentGuideServiceRef where CGS precendence over Uid
 */
class ProgramScheduleInfo_nownext {
  Program current; //member of now
  Program next; //member 0f next

  ProgramScheduleInfo_nownext({required this.current, required this.next});

  factory ProgramScheduleInfo_nownext.parse({required XmlDocument data}) {
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
    return ProgramScheduleInfo_nownext(current: current, next: next);
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

  Map<String, dynamic> toJson() => {
        'programid': pid,
        'title': title,
        'synopsis': synopsis,
        'mediaUrl': mediaUrl,
        'startTime': startTime,
        'programDuration': programDuration
      };
}

class ContentGuideSourceElem {
  final Uri scheduleInfoEndpoint;
  final Uri? programInfoEndpoint;
  final String providerName;
  final String cgsid;

  ContentGuideSourceElem(
      {required this.scheduleInfoEndpoint,
      required this.programInfoEndpoint,
      required this.providerName,
      required this.cgsid});

  factory ContentGuideSourceElem.parse({required XmlElement data}) {
    String scheduleInfoEndpoint =
        data.getElement("ScheduleInfoEndpoint")!.getElement("URI")!.innerText;
    String? programInfoEndpoint =
        data.getElement("ProgramInfoEndpoint")?.getElement("URI")!.innerText;
    String providerName = data.getElement("ProviderName")!.innerText;
    String cgsid = data.getAttribute("CGSID")!;

    return ContentGuideSourceElem(
        cgsid: cgsid,
        providerName: providerName,
        programInfoEndpoint:
            programInfoEndpoint != null ? Uri.parse(programInfoEndpoint) : null,
        scheduleInfoEndpoint: Uri.parse(scheduleInfoEndpoint));
  }

  Map<String, dynamic> toJson() => {
        'scheduleInfoEndpoint': scheduleInfoEndpoint.toString(),
        'programInfoEndpoint': programInfoEndpoint?.toString(),
        'providerName': providerName,
        'cgsid': cgsid
      };
}

enum HowRelatedEnum {
  logo,
  application,
}

class RelatedMaterialElem {
  static const Map<String?, HowRelatedEnum> howRelatedMap = {
    "urn:dvb:metadata:cs:HowRelatedCS:2020:1001.2": HowRelatedEnum.logo,
    "urn:dvb:metadata:cs:LinkedApplicationCS:2019:1.1":
        HowRelatedEnum.application,
  };

  final HowRelatedEnum? howRelated;
  final XmlElement xml;

  RelatedMaterialElem({required this.howRelated, required this.xml});

  Uri getLogo({int? width}) {
    if (howRelated == HowRelatedEnum.logo) {
      //TODO: tva suffix not in standard
      String uriText =
          xml.getElement("MediaLocator")!.getElement("tva:MediaUri")!.innerText;
      Uri uri = Uri.parse(uriText);

      if (width != null) {
        uri.replace(queryParameters: {"width": width});
      }

      return uri;
    }

    throw DVBIException("Called getLogo on unrelated Element: $howRelated");
  }

  factory RelatedMaterialElem.parse({required XmlElement data}) {
    String? href = data.getElement("HowRelated")?.getAttribute("href");

    HowRelatedEnum? howRelated = howRelatedMap[href];

    return RelatedMaterialElem(howRelated: howRelated, xml: data);
  }
}

class ServiceElem {
  final String serviceName;
  final String uniqueIdentifier;
  final String providerName;
  final ContentGuideSourceElem? contentGuideSourceElem;
  final Uri? dashmpd;
  final Uri? logo;

  ProgramScheduleInfo_nownext? programinfo;

  ServiceElem(
      {required this.serviceName,
      required this.uniqueIdentifier,
      required this.providerName,
      required this.contentGuideSourceElem,
      required this.dashmpd,
      required this.logo});

  Map<String, dynamic> toJson() => {
        'serviceName': serviceName,
        'uniqueIdentifier': uniqueIdentifier,
        'providerName': providerName,
        'contentGuideSourceElem': contentGuideSourceElem,
        'dashmpd': dashmpd?.toString(),
        'logo': logo?.toString()
      };

  //constructor short way
  factory ServiceElem.parse(
      {required XmlElement data,
      required List<XmlElement>? contentGuideSourceList}) {
    String serviceName = data.getElement("ServiceName")!.innerText;
    String uniqueIdentifier = data.getElement("UniqueIdentifier")!.innerText;
    String providerName = data.getElement("ProviderName")!.innerText;

    // Get serviceInstace elements ordered by priority
    List<XmlElement> serviceInstances;
    {
      serviceInstances = data.findAllElements("ServiceInstance").toList();

      // Sort ServiceInstance elements by priority
      serviceInstances.sort((a, b) {
        int res = int.parse(a.getAttribute("priority")!) -
            int.parse(b.getAttribute("priority")!);
        return res;
      });
    }

    // Parse dashmpd
    Uri? dashmpd;
    {
      XmlElement? dashDeliveryParameters = serviceInstances
          .firstWhereOrNull(
              (element) => element.getElement("DASHDeliveryParameters") != null)
          ?.firstElementChild;

      XmlElement? uriBasedLocation =
          dashDeliveryParameters?.getElement("UriBasedLocation");

      bool correctType =
          uriBasedLocation?.getAttribute("contentType").toString() ==
              "application/dash+xml";

      if (correctType) {
        String? uri = uriBasedLocation?.getElement("URI")!.innerText;
        dashmpd = uri != null ? Uri.parse(uri) : null;
      } else {
        _log.fine("==== Unsupported dash type ====");
        _log.fine("uriBasedLocation: \n ${uriBasedLocation?.toXmlString()}");

        _log.fine(
            "dashDeliveryParameters: \n ${dashDeliveryParameters?.toXmlString()}");
      }
    }

    // Parse ContentGuideSource
    ContentGuideSourceElem? contentGuideSourceObj;
    {
      XmlElement? contentGuideSource = data.getElement("ContentGuideSource");

      if (contentGuideSource == null && contentGuideSourceList != null) {
        String? ref = data.getElement("ContentGuideSourceRef")?.innerText;
        for (final elem in contentGuideSourceList) {
          if (ref == null) {
            break;
          }

          if (elem.getAttribute("CGSID") == ref) {
            contentGuideSource = elem;
          }
        }
      }

      contentGuideSourceObj = contentGuideSource != null
          ? ContentGuideSourceElem.parse(data: contentGuideSource)
          : null;
    }

    List<RelatedMaterialElem> relatedMaterial = [];
    {
      for (XmlElement rd in data.findAllElements("RelatedMaterial")) {
        relatedMaterial.add(RelatedMaterialElem.parse(data: rd));
      }
    }

    // Parse logo
    Uri? logo;
    {
      logo = relatedMaterial
          .firstWhere((element) => element.howRelated == HowRelatedEnum.logo)
          .getLogo();
    }

    return ServiceElem(
        serviceName: serviceName,
        uniqueIdentifier: uniqueIdentifier,
        providerName: providerName,
        contentGuideSourceElem: contentGuideSourceObj,
        dashmpd: dashmpd,
        logo: logo);
  }
}

class DVBI {
  final Uri endpointUrl;
  final http.Client httpClient;

  DVBI({required this.endpointUrl}) : httpClient = http.Client();

  void close() {
    httpClient.close();
  }

  Stream<ServiceElem> get stream async* {
    final String data;

    if (endpointUrl.isScheme("HTTP") || endpointUrl.isScheme("HTTPS")) {
      var res = await http.get(endpointUrl);

      if (res.statusCode != 200) {
        throw DVBIException(
            "Status code invalid. Code: ${res.statusCode} Reason: ${res.reasonPhrase}");
      }
      data = res.body;
    } else {
      var res = File.fromUri(endpointUrl);

      data = await res.readAsString();
    }

    final serviceList = XmlDocument.parse(data).getElement("ServiceList")!;

    final services = serviceList.findAllElements("Service");
    final List<XmlElement>? contentGuideSourceList = serviceList
        .getElement("ContentGuideSourceList")
        ?.childElements
        .toList();

    for (var serviceData in services) {
      yield ServiceElem.parse(
          contentGuideSourceList: contentGuideSourceList, data: serviceData);
    }
  }

  /**
   * req for programscheduleInfo
   */
  Stream<ProgramScheduleInfo_nownext> programScheduleInfoNowNext(
      String scheduleInfoEndpoint, String sid) async* {
    final String xmlData;

    if (Uri.parse(scheduleInfoEndpoint).isScheme("HTTP") ||
        Uri.parse(scheduleInfoEndpoint).isScheme("HTTPS")) {
      // String endpoint =scheduleInfoEndpoint + '?' + sid + '&' + 'now_next=true';
      String endpoint = '$scheduleInfoEndpoint?sid=$sid&now_next=true';

      print(endpoint + " in" + "pSI function");

      var res = await http.get(Uri.parse(endpoint));

      if (res.statusCode != 200) {
        throw DVBIException(
            "Status code invalid. Code: ${res.statusCode} Reason: ${res.reasonPhrase}");
      }
      xmlData = res.body;
    } else {
      print("in else?");
      var res = File.fromUri(endpointUrl);

      xmlData = await res.readAsString();
    }

    final scheduleData = XmlDocument.parse(xmlData);

    //return as stream
    yield ProgramScheduleInfo_nownext.parse(data: scheduleData);
  }

  //delete proginfoxml because http request will be in future methode
  Stream<ProgramInfo> getProgramInfo(endpointpi, pid) async* {
    //

    final String xmlData;

    if (Uri.parse(endpointpi).isScheme("HTTP") ||
        Uri.parse(endpointpi).isScheme("HTTPS")) {
      // String endpoint =scheduleInfoEndpoint + '?' + sid + '&' + 'now_next=true';
      String endpoint = '$endpointpi?pid=$pid';

      print(endpoint + " in" + "pSI function");

      var res = await http.get(Uri.parse(endpoint));

      if (res.statusCode != 200) {
        throw DVBIException(
            "Status code invalid. Code: ${res.statusCode} Reason: ${res.reasonPhrase}");
      }
      xmlData = res.body;
    } else {
      print("in else?");
      var res = File.fromUri(endpointUrl);

      xmlData = await res.readAsString();
    }

    final programInfo = XmlDocument.parse(xmlData);

    //return as stream
    yield ProgramInfo.parse(data: programInfo);
  }
}
