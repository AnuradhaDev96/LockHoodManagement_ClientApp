import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/app_colors.dart';
import '../../../config/language_settings.dart';
import '../../../models/authentication/system_user.dart';
import '../../../models/change_notifiers/administrative_units_change_notifer.dart';
import '../../../models/membership/membership_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/membership_service.dart';
import '../../../utils/general_dialog_utils.dart';
import 'create_new_member_dialog.dart';

class MembershipListPage extends StatelessWidget {
  MembershipListPage({Key? key,}) : super(key: key);

  final MembershipService _membershipService = GetIt.I<MembershipService>();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  final ValueNotifier<List<String>> _allocatedPermissionsListNotifier = ValueNotifier<List<String>>(<String>[]);


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.I<AuthService>().permissionsListForUser(),
      builder: (BuildContext context, AsyncSnapshot<SystemUser?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return const SizedBox(width: 0, height: 0);
        } else if (snapshot.hasData) {
          _allocatedPermissionsListNotifier.value = List<String>.from(snapshot.data!.authPermissions ?? <String>[]);
          return Consumer<AdministrativeUnitsChangeNotifier>(
              builder: (BuildContext context, AdministrativeUnitsChangeNotifier pageViewNotifier, child) {
                if (pageViewNotifier.paramDivisionalSecretariat == null ||
                    pageViewNotifier.paramGramaNiladariDivision == null) {
                  return Column(
                    children: [
                      const Text(";dlaYksl fodaYhla' kej; fmr msgqjg hkak'"), //???????????????????????? ??????????????????. ???????????? ????????? ?????????????????? ????????????.
                      const SizedBox(height: 5.0),
                      ElevatedButton(
                        onPressed: () {
                          pageViewNotifier.jumpToPreviousPage();
                        },
                        child: const Text(
                          "wdmiq", //????????????
                          style: TextStyle(color: AppColors.white, fontSize: 14.0),
                        ),
                      ),
                    ],
                  );
                }

                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            pageViewNotifier.paramDivisionalSecretariat!.sinhalaValue,
                            style: const TextStyle(
                                fontFamily: SettingsSinhala.unicodeSinhalaFontFamily, color: AppColors.nppPurpleLight),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.appBarColor,
                            size: 14.0,
                          ),
                          Text(
                            pageViewNotifier.paramGramaNiladariDivision!.sinhalaValue,
                            style: const TextStyle(
                                fontFamily: SettingsSinhala.unicodeSinhalaFontFamily, color: AppColors.nppPurpleLight),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, top: 5.0),
                          child: Text(
                            'idud??lhska l<uKdlrKh', //????????????????????????????????? ???????????????????????????
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, top: 5.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ValueListenableBuilder<List<String>>(
                                valueListenable: _allocatedPermissionsListNotifier,
                                builder: (context, snapshot, child) {
                                  bool doHavePrivilegeToCustomizeMembers =
                                      snapshot.contains(pageViewNotifier.paramDivisionalSecretariat!.id);
                                  return doHavePrivilegeToCustomizeMembers
                                      ? IconButton(
                                          onPressed: () => _createNewMembershipRecord(
                                              context,
                                              pageViewNotifier.paramDivisionalSecretariat!.id,
                                              pageViewNotifier.paramGramaNiladariDivision!.id),
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                            size: 32.0,
                                          ),
                                          splashRadius: 6.0,
                                          color: AppColors.darkPurple,
                                          tooltip: "kj idu??lfhla", //?????? ??????????????????????????????
                                        )
                                      : const SizedBox(width: 0, height: 0);
                                },
                              ),
                            const SizedBox(width: 8.0),
                              RawMaterialButton(
                                // onPressed: _createNewDivisionalSecretariatRecord,
                                  onPressed: () => _navigateToAdministrativeUnitsPage(context),
                                  fillColor: AppColors.darkPurple,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                  child: const Icon(
                                    Icons.keyboard_backspace_outlined, size: 25.0, color: AppColors.white,)
                                // splashRadius: 10.0,

                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    Container(color: AppColors.darkPurple, height: 2.0,),
                    const SizedBox(height: 8.0),
                    StreamBuilder(
                      stream: _membershipService.getDivisionalSecretariatsStream(
                          pageViewNotifier.paramDivisionalSecretariat!.id,
                          pageViewNotifier.paramGramaNiladariDivision!.id),
                      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
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
                          return const Text("idud??lhska lsisfjla fkdue;"); //????????????????????????????????? ???????????????????????? ???????????????
                        } else if (snapshot.hasData) {
                          if (snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text("idud??lhska lsisfjla fkdue;")); //????????????????????????????????? ???????????????????????? ???????????????
                          }
                          return Scrollbar(
                              controller: _verticalScrollController,
                              scrollbarOrientation: ScrollbarOrientation.right,
                              thumbVisibility: true,
                              trackVisibility: true,
                              child: SingleChildScrollView(
                                  controller: _verticalScrollController,
                                  scrollDirection: Axis.vertical,
                                  physics: const ClampingScrollPhysics(),
                                  child: Scrollbar(
                                    controller: _horizontalScrollController,
                                    scrollbarOrientation: ScrollbarOrientation.top,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: _horizontalScrollController,
                                        child: DataTable(
                                          headingTextStyle: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: SettingsSinhala.unicodeSinhalaFontFamily,
                                            color: AppColors.black,
                                          ),
                                          dataTextStyle: const TextStyle(
                                            fontSize: 12.0,
                                            fontFamily: SettingsSinhala.unicodeSinhalaFontFamily,
                                            color: AppColors.black,
                                          ),
                                          headingRowColor: MaterialStateProperty.all(AppColors.silverPurple),
                                          border: const TableBorder(
                                            verticalInside: BorderSide(width: 0.5, color: AppColors.nppPurpleLight),
                                            bottom: BorderSide(width: 0.5, color: AppColors.grayForPrimary),
                                          ),
                                          columns: const [
                                            DataColumn(label: Text('??????.??????.????????????')),
                                            DataColumn(label: Text('???????????????????????? ??????')),
                                            DataColumn(label: Text('??????????????????')),
                                            DataColumn(label: Text('????????????????????? ????????????')),
                                            DataColumn(label: Text('????????????????????????')),
                                            DataColumn(label: Text('?????????????????? ???????????? 1')),
                                            DataColumn(label: Text('?????????????????? ???????????? 2')),
                                            DataColumn(label: Text('?????????????????????')),
                                            DataColumn(
                                              label: Text(
                                                'FB Username',
                                                style: TextStyle(fontFamily: SettingsSinhala.engFontFamily),
                                              ),
                                            ),
                                            DataColumn(label: Text('????????????????????? ???????????? ??????????????? ???????????????????????????')),
                                            DataColumn(label: Text('????????????????????????????????? ???????????? ??????????????? ????????????????????????')),
                                            DataColumn(label: Text('????????? ??????????????? ????????????')),
                                            DataColumn(label: Text('????????????????????? ????????????')),
                                          ],
                                          rows: snapshot.data!.docs.map((data) => _membershipItemBuilder(context, data))
                                              .toList(),
                                        )
                                    ),
                                  )
                              )
                          );
                        }
                        return const Text("idud??lhska lsisfjla fkdue;"); //????????????????????????????????? ???????????????????????? ???????????????
                      },
                    )
                  ],
                );
              }
          );
        }
        return const SizedBox(width: 0, height: 0);
      }
    );
  }

  DataRow _membershipItemBuilder(BuildContext context, DocumentSnapshot data) {
    final membership = MembershipModel.fromSnapshot(data);

    return DataRow(cells: [
      DataCell(Text(membership.nicNumber)),
      DataCell(Text(membership.fullName)),
      DataCell(Text(membership.address ?? "-")),
      DataCell(Text(membership.electoralSeat ?? "-")),
      DataCell(Text(membership.kottashaya ?? "-")),
      DataCell(Text(membership.firstTelephoneNo ?? "-")),
      DataCell(Text(membership.secondTelephoneNo ?? "-")),
      DataCell(Text(membership.job ?? "-")),
      DataCell(
        (membership.fbUserName != null)
            ? RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                        children: [
                      TextSpan(
                        text: membership.fbUserName,
                        style: const TextStyle(
                          fontFamily: SettingsSinhala.engFontFamily,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () => _launchFbUrlOfUser(membership.fbUserName!)
                      ),
                    ],
                    ),
                  ],
                ),
              )
            : const Text("-"),
      ),
      DataCell(Text(membership.preferredFieldToJoin ?? "-")),
      DataCell(Text(membership.preferredRegionToOperate ?? "-")),
      DataCell(Text(membership.houseNumber ?? "-")),
      DataCell(
        Text(membership.dateInTheForm != null ? DateFormat.yMd().format(membership.dateInTheForm!) : "-"),
      ),
    ]);
  }

  void _navigateToAdministrativeUnitsPage(BuildContext context) {
    Provider.of<AdministrativeUnitsChangeNotifier>(context, listen: false).jumpToPreviousPage();
  }

  void _createNewMembershipRecord(
      BuildContext context, String divisionalSecretariatId, String gramaNiladariDivisionId) async {
    bool isProcessSuccessful = await GeneralDialogUtils().showCustomGeneralDialog(
      context: context,
      child: CreateNewMemberDialog(
          divisionalSecretariatId: divisionalSecretariatId, gramaNiladariDivisionId: gramaNiladariDivisionId),
      title: "idud??lfhla tl;= ls??u", //????????????????????????????????? ???????????? ???????????????
    );
  }

  void _launchFbUrlOfUser(String username) async {
    String url = "https://fb.com/$username";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print("URL is not available");
    }
  }
}
