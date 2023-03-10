import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:matara_division_system/src/models/administrative_units/grama_niladari_divisions.dart';
import 'package:provider/provider.dart';
import '../../../models/administrative_units/divisional_secretariats.dart';
import '../../../models/change_notifiers/administrative_units_change_notifer.dart';

import '../../../config/app_colors.dart';
import '../../../config/language_settings.dart';
import '../../../services/administrative_units_service.dart';
import '../../../utils/common_utils.dart';
import '../../../utils/general_dialog_utils.dart';
import '../../../utils/message_utils.dart';
import 'create_divisional_secretariat_dialog.dart';
import 'create_grama_niladari_division_dialog.dart';

class AdministrativeDivisionsList extends StatefulWidget {
  const AdministrativeDivisionsList({Key? key}) : super(key: key);

  @override
  State<AdministrativeDivisionsList> createState() => _AdministrativeDivisionsListState();
}

class _AdministrativeDivisionsListState extends State<AdministrativeDivisionsList> {
  late final AdministrativeUnitsService _administrativeUnitsService;
  List<bool> _expansionPanelExpandStatus = <bool>[];
  @override
  void initState() {
    _administrativeUnitsService = GetIt.I<AdministrativeUnitsService>();
    super.initState();
  }

  @override
  void dispose() {
    print("disposed when opeening dialog");
    super.dispose();
  }
  // final ValueNotifier<List<bool>> _expansionPanelExpandStatus = ValueNotifier<List<bool>>(<bool>[]);
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        (CommonUtils.isMobileUI(context))
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 15.0),
                      child: RichText(
                        text: const TextSpan(
                            style: TextStyle(
                              color: AppColors.black,
                            ),
                            children: [
                              TextSpan(
                                  text: "m%dfoaYsh f,al?? ld??hd, ji?? ", //?????????????????????????????? ??????????????? ????????????????????? ????????????
                                  style: TextStyle(fontFamily: 'DL-Paras', fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: "| Divisional Secretariats",
                                  style: TextStyle(fontFamily: SettingsSinhala.engFontFamily)),
                            ]),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, top: 15.0),
                        child: RawMaterialButton(
                            onPressed: _createNewDivisionalSecretariatRecord,
                            // iconSize: 15.0,
                            // color: AppColors.nppPurple,
                            // padding: const EdgeInsets.all(5.0),
                            fillColor: AppColors.darkPurple,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                            child: const Icon(
                              Icons.add,
                              size: 25.0,
                              color: AppColors.white,
                            )
                            // splashRadius: 10.0,

                            ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 15.0),
                      child: RichText(
                        text: const TextSpan(
                            style: TextStyle(
                              color: AppColors.black,
                            ),
                            children: [
                              TextSpan(
                                  text: "m%dfoaYsh f,al?? ld??hd, ji?? ", //?????????????????????????????? ??????????????? ????????????????????? ????????????
                                  style: TextStyle(fontFamily: 'DL-Paras', fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: "| Divisional Secretariats",
                                  style: TextStyle(fontFamily: SettingsSinhala.engFontFamily)),
                            ]),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 15.0),
                    child: RawMaterialButton(
                        onPressed: _createNewDivisionalSecretariatRecord,
                        // iconSize: 15.0,
                        // color: AppColors.nppPurple,
                        // padding: const EdgeInsets.all(5.0),
                        fillColor: AppColors.darkPurple,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                        child: const Icon(
                          Icons.add,
                          size: 25.0,
                          color: AppColors.white,
                        )
                        // splashRadius: 10.0,

                        ),
                  ),
                ],
              ),
        const SizedBox(height: 5.0),
        Container(color: AppColors.darkPurple,height: 2.0,),
        const SizedBox(height: 8.0),
        StreamBuilder(
          stream: _administrativeUnitsService.getDivisionalSecretariatsStream(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        color: AppColors.darkPurple,
                      ),
                    )),
              );
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const Text("o;a; lsisjla fkdue;"); //???????????? ????????????????????? ???????????????
            } else if (snapshot.hasData) {
              if (snapshot.data!.docs.isEmpty) {
                return const Text("o;a; lsisjla fkdue;"); //???????????? ????????????????????? ???????????????
              }

              print("### length of divsecStream: ${snapshot.data!.docs.length}");
              var panels = <ExpansionPanel>[];
              //
              if (_expansionPanelExpandStatus.isEmpty) {
                for (int index = 0; index < snapshot.data!.docs.length; index++) {
                  _expansionPanelExpandStatus.add(false);
                }
              } else {
                if (snapshot.data!.docs.length != _expansionPanelExpandStatus.length) {
                  _expansionPanelExpandStatus.clear();
                  for (int index = 0; index < snapshot.data!.docs.length; index++) {
                    _expansionPanelExpandStatus.add(false);
                  }
                }
              }

              // DivisionalSecretariats.fromSnapshot
              snapshot.data!.docs.sort((a,b) {
                String div1 = DivisionalSecretariats.fromSnapshot(a).id;
                String div2 = DivisionalSecretariats.fromSnapshot(b).id;
                return div1.compareTo(div2);
              });
              for (int index = 0; index < snapshot.data!.docs.length; index++) {
                panels.add(_divSecretariatItemBuilder(context, snapshot.data!.docs[index], index));
              }


              return ExpansionPanelList(
                // shrinkWrap: true,
                expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 5.0),
                dividerColor: AppColors.darkPurple,
                animationDuration: const Duration(milliseconds: 1200),
                expansionCallback: (int panelIndex, bool isExpanded) {
                  setState(() {
                  _expansionPanelExpandStatus[panelIndex] = !_expansionPanelExpandStatus[panelIndex];

                  });
                  // _administrativeUnitsChangeNotifier.setValueByIndex(
                  //     panelIndex, !_administrativeUnitsChangeNotifier.expansionPanelExpandStatusList[panelIndex]);
                },
                // elevation: 5.0,
                // children: snapshot.data!.docs.map((data) =>
                //     _divSecretariatItemBuilder(context, data, snapshot.data!.docs.indexOf(data),)).toList(),
                children: panels,


              );
            }
            return const Text("o;a; lsisjla fkdue;");

          },
        ),
      ],
    );
  }

  ExpansionPanel _divSecretariatItemBuilder(BuildContext context, DocumentSnapshot data, int index) {
    print("##index of sent data: $index");
    final divisionalSecretariat = DivisionalSecretariats.fromSnapshot(data);
    return ExpansionPanel(
        canTapOnHeader: true,
        backgroundColor: AppColors.lightGray,
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ListTile(
            // tileColor: AppColors.nppPurpleDark,
            // dense: false,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topRight: Radius.circular(15.0), topLeft: Radius.circular(15.0))
            ),
            title: Text(
              divisionalSecretariat.sinhalaValue,
              style: const TextStyle(
                fontFamily: SettingsSinhala.unicodeSinhalaFontFamily,
                color: AppColors.darkPurple,
              ),
            ),
            trailing: SizedBox(
              width: 80,
              height: 30,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _createNewGramaNiladariDivisionRecord(divisionalSecretariat),
                    icon: const Icon(
                      Icons.add_circle_outline,
                    ),
                    splashRadius: 25.0,
                    color: AppColors.darkPurple,
                    // hoverColor: AppColors.appBarColor,
                  ),
                  IconButton(
                    onPressed: () => _deleteSelectedDivisionalSecretariat(divisionalSecretariat),
                    icon: const Icon(
                      Icons.delete_outline,
                    ),
                    splashRadius: 25.0,
                    color: AppColors.darkPurple,
                  ),

                ],
              ),
            ),
          );
        },
        isExpanded: _expansionPanelExpandStatus[index],
        body: DivisionalSecretariatExpansionPanelContent(divisionalSecretariat: divisionalSecretariat),
    );
  }

  void _createNewDivisionalSecretariatRecord() async {
    bool isProcessSuccessful = await GeneralDialogUtils().showCustomGeneralDialog(
      context: context,
      child: CreateDivisionalSecretariatDialog(),
      title: "m%dfoaYsh f,al?? ld??hd,hla tl;= ls??u",//?????????????????????????????? ??????????????? ?????????????????????????????? ???????????? ???????????????
    );
    // if (isProcessSuccessful == null) {
    //   return;
    // } else if (isProcessSuccessful) {
    //   showSaveResultMessage(true, "m%dfoaYsh f,al?? ld??hd,hla tl;= lrk ,??'");
    // } else {
    //   showSaveResultMessage(false, "m%dfoaYsh f,al?? ld??hd,hla tl;= lrk ,??'");//?????????????????????????????? ??????????????? ?????????????????????????????? ???????????? ????????? ?????????.
    // }
  }

  //#region delete divisional secretariat
  void _deleteSelectedDivisionalSecretariat(DivisionalSecretariats division) {
    _administrativeUnitsService.deleteDivisionalSecretariatRecord(division).then(
          (value) {
        if (value) {
          //?????????????????????????????? ??????????????? ???????????????????????? ???????????? ??????????????? ????????????????????????.
          _showResultMessage(context, true, "m%dfoaYsh f,al?? ld??hd,h bj;a ls??u id??:lhs'");
        } else {
          //????????? ????????????????????? ?????????????????????????????? ??????????????? ?????????????????????????????? ?????????.
          _showResultMessage(context, false, "fuu fla;fhka m%dfoaYsh f,al?? ld??hd,hla ke;'");
        }
      },
      onError: (e) {
        //???????????????????????? ??????????????????. ???????????? ??????????????? ???????????????.
        _showResultMessage(context, false, ";dlaYksl fodaYhla' kej; W;aiy lrkak'");
      },
    );
  }

  void _showResultMessage(BuildContext context, bool statusOfRequest, String message) {
    statusOfRequest
        ? MessageUtils.showSuccessInFlushBar(context, message, appearFromTop: false,
        duration: 4)
        : MessageUtils.showErrorInFlushBar(context, message, appearFromTop: false, duration: 4);
  }
  //#end region delete divisional secretariat

  //#region add grama niladari division
  void _createNewGramaNiladariDivisionRecord(DivisionalSecretariats division) async {
    bool isProcessSuccessful = await GeneralDialogUtils().showCustomGeneralDialog(
      context: context,
      child: CreateGramaNiladariDivisionDialog(divisionalSecretariatId: division.id,),
      title: ".%du ks,Od?? jiula tl;= ls??u",//?????????????????? ????????????????????? ??????????????? ???????????? ???????????????
    );
  }
  //#end region add grama niladari division

}

class DivisionalSecretariatExpansionPanelContent extends StatelessWidget {
  DivisionalSecretariatExpansionPanelContent({Key? key, required this.divisionalSecretariat}) : super(key: key);
  // final String divisionalSecretariatId;
  final DivisionalSecretariats divisionalSecretariat;
  final AdministrativeUnitsService _administrativeUnitsService = GetIt.I<AdministrativeUnitsService>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder(
            stream: _administrativeUnitsService.getGramaNiladiriDivisionsStream(divisionalSecretariat.id),
            // (BuildContext context, AsyncSnapshot<List<GramaNiladariDivisions>> snapshot)
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 100,
                      height: 10,
                      child: LinearProgressIndicator(
                        // strokeWidth: 5,
                        backgroundColor: AppColors.silverPurple,
                        color: AppColors.darkPurple,
                        minHeight: null,
                      ),
                    ),
                  ),
                );
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                return const Text("o;a; lsisjla fkdue;"); //???????????? ????????????????????? ???????????????
              } else if (snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  return const Text("o;a; lsisjla fkdue;"); //???????????? ????????????????????? ???????????????
                }

                return ListView(
                  // padding: const EdgeInsets.fromLTRB(10.0, 8.0, 8.0, 10.0),
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((division) => _gramaNiladariDivItemBuilder(context, division)).toList(),
                );
              }

              return const Text("o;a; lsisjla fkdue;"); //???????????? ????????????????????? ???????????????
            },
        ),
      ],
    );
  }

  // Widget _gramaNiladariDivItemBuilder(BuildContext context, GramaNiladariDivisions division) {
  Widget _gramaNiladariDivItemBuilder(BuildContext context, DocumentSnapshot data) {
    final division = GramaNiladariDivisions.fromSnapshot(data);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      padding: const EdgeInsets.fromLTRB(25.0, 8.0, 10.0, 8.0),
      decoration: const BoxDecoration(
        // color: Colors.amber,
        gradient: LinearGradient(colors: [AppColors.nppPurpleLight, Colors.white], stops: [0.02, 0.02]),
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        // border: Border(
        //   left: BorderSide(
        //     color: AppColors.nppPurple,
        //     width: 10.0,
        //   ),
        // )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            division.sinhalaValue,
            style: const TextStyle(
              fontFamily: SettingsSinhala.unicodeSinhalaFontFamily,
              color: AppColors.appBarColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _navigateToMembershipPage(context, division),
                icon: const Icon(
                  Icons.people_alt_outlined,
                ),
                splashRadius: 20.0,
                color: AppColors.nppPurpleLight,
                tooltip: "idud??lhska",
              ),
              IconButton(
                onPressed: () => _deleteSelectedGramaNiladariDivision(context, divisionalSecretariat.id, division),
                icon: const Icon(
                  Icons.delete_outline,
                ),
                splashRadius: 20.0,
                color: AppColors.nppPurpleLight,
              ),
            ],
          )
        ],
      ),
    );
  }


  //#region: add new grama niladari division
  void _deleteSelectedGramaNiladariDivision(BuildContext context, String divisionalSecretariatId, GramaNiladariDivisions division) {
    _administrativeUnitsService.deleteGramaNiladariDivisionRecord(divisionalSecretariatId, division).then(
          (value) {
        if (value) {
          //?????????????????? ????????????????????? ????????? ???????????? ??????????????? ????????????????????????.
          showDeleteResultMessage(context, true, ".%du ks,Od?? jiu bj;a ls??u id??:lhs'");
        } else {
          //????????? ????????????????????? ?????????????????????????????? ??????????????? ?????????????????????????????? ?????????.
          showDeleteResultMessage(context, false, "fuu fla;fhka .%du ks,Od?? jiula ke;'");
        }
      },
      onError: (e) {
        //???????????????????????? ??????????????????. ???????????? ??????????????? ???????????????.
        showDeleteResultMessage(context, false, ";dlaYksl fodaYhla' kej; W;aiy lrkak'");
      },
    );
  }

  void showDeleteResultMessage(BuildContext context, bool statusOfRequest, String message) {
    statusOfRequest
        ? MessageUtils.showSuccessInFlushBar(context, message, appearFromTop: false,
        duration: 4)
        : MessageUtils.showErrorInFlushBar(context, message, appearFromTop: false, duration: 4);
  }

  //#end region: add new grama niladari division

  // void _selectAccessRequestToCreateUser(BuildContext context, RequestAccessModel requestAccessModel) {
  //   Provider.of<AccessRequestsPageViewNotifier>(context, listen: false).setSelectedRequestAccess(requestAccessModel);
  //   Provider.of<AccessRequestsPageViewNotifier>(context, listen: false).jumpToNextPage();
  // }
  void _navigateToMembershipPage(BuildContext context, GramaNiladariDivisions gramaNiladariDivision) {
    Provider.of<AdministrativeUnitsChangeNotifier>(context, listen: false)
        .setSelectedAdministrativeUnits(divisionalSecretariat, gramaNiladariDivision);
    Provider.of<AdministrativeUnitsChangeNotifier>(context, listen: false).jumpToNextPage();
  }
}

