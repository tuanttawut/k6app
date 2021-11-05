import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k6_app/models/chat_models.dart';
import 'package:k6_app/models/seller_model.dart';
import 'package:k6_app/models/user_models.dart';
import 'package:k6_app/utility/my_constant.dart';

class ChatPage extends StatefulWidget {
  ChatPage({required this.userModel, required this.sellerModel});
  final UserModel userModel;
  final SellerModel sellerModel;
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  SellerModel? sellerModel;
  UserModel? userModel;
  String? idUser, idSeller, message;
  bool? check;
  final df = new DateFormat('dd/MM H:mm น.');
  String? date(DateTime tm) {
    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);
    Duration oneWeek = new Duration(days: 7);
    String? month;
    switch (tm.month) {
      case 1:
        month = "มกราคม";
        break;
      case 2:
        month = "กุมภาพันธ์";
        break;
      case 3:
        month = "มีนาคม";
        break;
      case 4:
        month = "เมษายน";
        break;
      case 5:
        month = "พฤษภาคม";
        break;
      case 6:
        month = "มิถุนายน";
        break;
      case 7:
        month = "กรกฏาคม";
        break;
      case 8:
        month = "สิงหาคม";
        break;
      case 9:
        month = "กันยายน";
        break;
      case 10:
        month = "ตุลาคม";
        break;
      case 11:
        month = "พฤศจิกายน";
        break;
      case 12:
        month = "ธันวาคม";
        break;
    }

    Duration difference = today.difference(tm);

    if (difference.compareTo(oneDay) < 1) {
      return "วันนี้";
    } else if (difference.compareTo(twoDay) < 1) {
      return "เมื่อวานนี้";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return "จันทร์";
        case 2:
          return "อังคาร";
        case 3:
          return "พุธ";
        case 4:
          return "พฤหัสบดี";
        case 5:
          return "ศุกร์";
        case 6:
          return "เสาร์";
        case 7:
          return "อาทิตย์";
      }
    } else if (tm.year == today.year) {
      return '${tm.day} $month ';
    } else {
      return '${tm.day} $month ${tm.year}';
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      userModel = widget.userModel;
      sellerModel = widget.sellerModel;
      readChat();
    });
  }

  List<ChatModel> chatlist = [];
  Future<Null> readChat() async {
    idSeller = sellerModel!.idSeller;
    idUser = userModel!.idUser;
    String url =
        '${MyConstant().domain}/api/getChatuserseller.php?isAdd=true&id_user=$idUser&id_seller=$idSeller';
    Response response = await Dio().get(url);
    var result = json.decode(response.data);
    if (result != null) {
      for (var map in result) {
        ChatModel chatlists = ChatModel.fromMap(map);
        setState(() {
          chatlist.add(chatlists);
        });
      }
    } else {
      setState(() {
        check = false;
      });
    }
  }

  var _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(),
        body: check == false
            ? showNotMessage()
            : Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.builder(
                        itemCount: chatlist.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(
                            chatlist[index].message,
                            style: TextStyle(fontSize: 16),
                            textAlign: chatlist[index].status == 'user'
                                ? TextAlign.right
                                : TextAlign.left,
                          ),
                          subtitle: Text(
                            date(DateTime.parse(chatlist[index].regdate))
                                .toString(),
                            textAlign: chatlist[index].status == 'user'
                                ? TextAlign.right
                                : TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                  ),
                  chatInputField(),
                ],
              ));
  }

  Widget showNotMessage() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        chatInputField(),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          BackButton(),
          SizedBox(width: 20 * 0.75),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sellerModel!.firstname,
                style: TextStyle(fontSize: 16),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget chatInputField() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20 / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 6),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            SizedBox(width: 20),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20 * 0.75,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                      onChanged: (value) => message,
                      textInputAction: TextInputAction.done,
                      controller: _controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: "ส่งข้อความ ...",
                        border: InputBorder.none,
                        filled: true,
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}