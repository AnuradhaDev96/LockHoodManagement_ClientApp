import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../models/reservation/reservation.dart';
import '../../config/app_colors.dart';
import '../../services/reservation_service.dart';

class RoomForReservationItemBuilder extends StatefulWidget {
  const RoomForReservationItemBuilder({Key? key, required this.roomForReservationModel}) : super(key: key);
  final RoomForReservationModel roomForReservationModel;

  @override
  State<RoomForReservationItemBuilder> createState() => _RoomForReservationItemBuilderState();
}

class _RoomForReservationItemBuilderState extends State<RoomForReservationItemBuilder> {
  late RoomForReservationModel _roomForReservationModel;
  final TextEditingController _roomNameController = TextEditingController();
  late final List<int> _roomCountSelectList;
  late final ReservationService _reservationService;

  // guest count list changes according to the room count selected by user (2 persons per room)
  late List<int> _dynamicGuestCountList;

  @override
  void initState() {
    _roomForReservationModel = widget.roomForReservationModel;
    _reservationService = GetIt.I<ReservationService>();
    if (_roomForReservationModel.availableRoomCount == 0 || _roomForReservationModel.availableRoomCount == null) {
      _roomCountSelectList = <int>[];
    } else {
      _roomCountSelectList = <int>[];
      for (int i=1; i <= _roomForReservationModel.availableRoomCount!; i++) {
        _roomCountSelectList.add(i);
      }
    }

    if (_roomForReservationModel.noOfGuests == 0 || _roomForReservationModel.noOfGuests == null) {
      _dynamicGuestCountList = <int>[];
    } else {
      _dynamicGuestCountList = <int>[];
      for (int i=1; i <= _roomForReservationModel.roomCountForOrder! * 2; i++) {
        _dynamicGuestCountList.add(i);
      }
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void reAssignDynamicGuestCountList() {
    // setState(() {
      _dynamicGuestCountList.clear();
      for (int i=1; i <= _roomForReservationModel.roomCountForOrder! * 2; i++) {
        _dynamicGuestCountList.add(i);
      }
    // });
  }

  void calculateSubTotal() {
    _roomForReservationModel.subTotal = _reservationService.calculateSubTotalForSelectedRoom(_roomForReservationModel);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      color: AppColors.lightGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _roomForReservationModel.roomName!,
                  style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5.0),
                Text(
                  "Rate: LKR ${_roomForReservationModel.rateInLkr}",
                  style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    "Customize choices:",
                    style: TextStyle(color: AppColors.indigoMaroon, fontSize: 14.0),
                ),
                const SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Room count',
                          style: TextStyle(fontSize: 12.0),
                        ),
                        SizedBox(
                          // width: 100.0,
                          height: 35.0,
                          child: DropdownButton(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(12.0),
                            icon: const Icon(
                              Icons.bedroom_parent_outlined,
                              size: 15.0,
                            ),
                            dropdownColor: AppColors.goldYellow,
                            value: _roomForReservationModel.roomCountForOrder,
                            isExpanded: false,
                            hint: const Text(
                                'Room count',
                                style: TextStyle(fontSize: 12.0,),
                            ),
                            items: _roomCountSelectList.map((int value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                value.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12.0),
                              ),
                            )).toList(),
                            onChanged: (selectedValue){
                              setState(() {
                                _roomForReservationModel.roomCountForOrder = selectedValue as int?;
                                reAssignDynamicGuestCountList();
                                calculateSubTotal();
                                print(_roomForReservationModel.roomCountForOrder);
                              });
                            },
                          )
                        ),
                      ],
                    ),
                    const SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total guests',
                          style: TextStyle(fontSize: 12.0),
                        ),
                        SizedBox(
                          // width: 100.0,
                            height: 35.0,
                            child: DropdownButton(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(12.0),
                              icon: const Icon(
                                Icons.family_restroom_rounded,
                                size: 15.0,
                              ),
                              dropdownColor: AppColors.goldYellow,
                              value: _roomForReservationModel.noOfGuests,
                              isExpanded: false,
                              hint: const Text(
                                'Select no of guests',
                                style: TextStyle(fontSize: 12.0,),
                              ),
                              items: _dynamicGuestCountList.map((int value) => DropdownMenuItem<int>(
                                value: value,
                                child: Text(
                                  value.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12.0),
                                ),
                              )).toList(),
                              onChanged: (selectedValue){
                                setState(() {
                                  _roomForReservationModel.noOfGuests = selectedValue as int?;
                                  print(_roomForReservationModel.noOfGuests);
                                });
                              },
                            )
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            const Text(
              "*No of guests changes based on no of rooms selected.",
              style: TextStyle(fontSize: 8.0, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10.0),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Sub total:  LKR ",
                    style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "${_roomForReservationModel.subTotal}",
                    style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
                  ),
                ]
              ),
            )
          ],
        ),
      ),
    );
  }
}