import 'package:dvbi_client/app/app.dart';
import 'package:dvbi_lib/program_info.dart';
import 'package:flutter/material.dart';
import 'package:dvbi_lib/dvbi.dart';
import 'package:dvbi_lib/service_elem.dart';

class ContentGuidePage extends StatelessWidget {
  const ContentGuidePage({Key? key, this.title = 'ContentGuidePage', this.dvbi})
      : super(key: key);

  static const routeName = "contentGuidePage";

  final String title;
  final DVBI? dvbi;

  @override
  Widget build(BuildContext context) {
    var serviceElems = dvbi!.serviceElems;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(58, 66, 86, 1.0),
          centerTitle: true,
          title: const Text("Content Guide Page"),
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              tooltip: 'Browse Channels',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                   return IPTVPlayer(dvbi: dvbi);
                }));
              },
              alignment: Alignment.center,
            ),
          ],
          foregroundColor: Colors.blueGrey,
        ),
        body:
        ListView.builder(
          itemCount: serviceElems.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) {
                return IPTVPlayer(dvbi: dvbi, startingChannel: index);
              }));},
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                flex: 2,
                child:
                  Column(
                    children: [
                    Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                      width: 50,
                      height: 50,
                        margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(serviceElems[index].logo.toString()),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceElems[index].serviceName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
                  ),
                  ),
                  Expanded(flex: 8, child:
                  Column(
                    children: [
                      FutureProgramInfoWidget(serviceElement: serviceElems[index], scheduleInfo: serviceElems[index].scheduleInfo(), index: index)
                    ],
                  ),
                  )
            ],
            )
            );
          },
        ),
    );
  }
}

class FutureProgramInfoWidget extends StatelessWidget {
  final ServiceElem serviceElement;
  final Future<ScheduleInfo?> scheduleInfo;
  final int index;

  const FutureProgramInfoWidget({
    required this.serviceElement,
    required this.scheduleInfo,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
     return FutureBuilder<ScheduleInfo?>(
       future: scheduleInfo,
       builder: (BuildContext context, AsyncSnapshot<ScheduleInfo?> snapshot) {
         if (snapshot.hasData) {
           if(snapshot.data != null) {
             return ProgramInfoWidget(serviceElement: serviceElement,
                 scheduleInfo: snapshot.data!,
                 index: index);
           }
           else{
             return Row(
               children: const [
                 Text("Channel has no schedule Info")
               ],
             ) ;
           }
         }
         else if (snapshot.hasError) {
           return Row( children: [
             Text("${snapshot.error}")
           ]
         );
         }
         // By default, show a loading spinner
         return Row(children: const [CircularProgressIndicator()]);
       },
     );
  }
}


class ProgramInfoWidget extends StatelessWidget {

  final ServiceElem serviceElement;
  final ScheduleInfo scheduleInfo;
  final int index;

  const ProgramInfoWidget({
    required this.serviceElement,
    required this.scheduleInfo,
    required this.index,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var programInfo;
    if(scheduleInfo.programInfoTable.isNotEmpty){
      programInfo = scheduleInfo.programInfoTable[0];
    }
    else{
      programInfo = ProgramInfo(programId: 'NA', mainTitle: 'NA', secondaryTitle: 'NA', synopsisMedium: '', synopsisShort: '', genre: null, imageUrl: null, publishedStartTime: null, publishedDuration: 0.0);
    }
    return
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
                child:
             Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.all(10),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(programInfo.imageUrl.toString()),
                  fit: BoxFit.cover,
                ),
              ),
            )
            ),
            Flexible(
              fit: FlexFit.loose,
                child:
                Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      programInfo.mainTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                        programInfo.synopsisMedium,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.normal
                        )
                    )
                  ],
                ),
                ),
              ),
          ],
        );
  }

}
