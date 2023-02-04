import 'package:xml/xml.dart';

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

    //TODO staging over production as production returns wrong values at the moment
    if (scheduleInfoEndpoint.contains("production")) {
      scheduleInfoEndpoint =
          scheduleInfoEndpoint.replaceAll("production", "staging");
    }

    String? programInfoEndpoint =
        data.getElement("ProgramInfoEndpoint")?.getElement("URI")!.innerText;
    //TODO staging over production as production returns wrong values at the moment
    if (programInfoEndpoint != null) {
      if (programInfoEndpoint.contains("production")) {
        programInfoEndpoint =
            programInfoEndpoint.replaceAll("production", "staging");
      }
    }
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
