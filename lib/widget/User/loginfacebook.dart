import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:http/http.dart' as http;
import 'package:k6_app/utility/my_constant.dart';
import 'package:k6_app/utility/my_style.dart';
import 'package:k6_app/utility/normal_dialog.dart';

class LoginFacebook extends StatefulWidget {
  @override
  _LoginFacebookState createState() => _LoginFacebookState();
}

class _LoginFacebookState extends State<LoginFacebook> {
  String name, password, email, phone, typeuser, imageavatar;

  bool isLoggedIn = false;

  var profileData;

  var facebookLogin = FacebookLogin();

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;

      name = profileData['name'];
      email = profileData['email'];
      imageavatar = profileData['picture']['data']['url'];

      checkUser();
    });
  }

  Future<Null> registerThread() async {
    String url =
        '${MyConstant().domain}/k6app/addUser.php?isAdd=true&name=$name&email=$email&password=$password&phone=$phone&typeuser=$typeuser&imageavatar=$imageavatar';

    try {
      Response response = await Dio().get(url);
      print('res = $response');

      if (response.toString() == 'true') {
        normalDialog(
            context, 'เข้าใช้สำเร็จด้วยชื่อ :\n${profileData['name']} ');
      } else {
        normalDialog(context, 'ไม่สามารถ สมัครได้ กรุณาลองอีกครั้ง');
      }
    } catch (e) {}
  }

  Future<Null> checkUser() async {
    String url =
        '${MyConstant().domain}/k6app/getUserWhereUser.php?isAdd=true&email=$email';
    try {
      Response response = await Dio().get(url);

      if (response.toString() == 'true') {
        print('YESSSSSSSSSSSSSSSSSSSSSSSS');
      } else {
        showAddFBDialog();
      }
    } catch (e) {}
  }

  Future<Null> showAddFBDialog() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) => SimpleDialog(
              title: ListTile(
                title: Text('ลงชื่อเข้าใช้ด้วย Facebook',
                    style: MyStyle().mainH2Title),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage('$imageavatar'),
                    radius: 70,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'ชื่อ : $name',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'อีเมล : $email',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                buildPhoneField(),
                ListTile(
                  title: Text('เลือกชนิดของสมาชิก: '),
                ),
                RadioListTile(
                  value: 'user',
                  groupValue: typeuser,
                  onChanged: (value) {
                    setState(() {
                      typeuser = value;
                    });
                  },
                  title: Text('สมาชิกทั่วไป'),
                ),
                RadioListTile(
                  value: 'seller',
                  groupValue: typeuser,
                  onChanged: (value) {
                    setState(() {
                      typeuser = value;
                    });
                  },
                  title: Text('ผู้ขาย'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        print('เก็บข้อมูล : $name,$email, $phone, $typeuser');

                        if (phone == null ||
                            phone.isEmpty ||
                            phone.length < 10) {
                          normalDialog(context, 'โปรด กรอกเบอร์โทรศัพท์');
                        } else if (typeuser == null) {
                          normalDialog(context, 'โปรด เลือกชนิดของผู้สมัคร');
                        } else {
                          registerThread();
                        }
                      },
                      child: Text('ยืนยัน'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('ยกเลิก'),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  TextFormField buildPhoneField() {
    return TextFormField(
      onChanged: (value) => phone = value.trim(),
      validator: (value) {
        if (value.length < 10)
          return 'โปรดกรอกเบอร์โทร 10 หลัก';
        else
          return null;
      },
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'เบอร์โทรศัพท์',
        icon: Icon(Icons.phone_android),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignInButtonBuilder(
      backgroundColor: Colors.indigo,
      text: 'ล็อกอินด้วย Facebook',
      icon: Icons.facebook,
      onPressed: () => initiateFacebookLogin(),
    );
  }

  void initiateFacebookLogin() async {
    var facebookLoginResult =
        await facebookLogin.logIn(['email', 'public_profile']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        onLoginStatusChanged(false);
        print('การล็อกอินเออเร่อ');
        break;
      case FacebookLoginStatus.cancelledByUser:
        onLoginStatusChanged(false);
        print('การล็อกอินถูกยกเลิกโดยผู้ใช้');
        break;
      case FacebookLoginStatus.loggedIn:
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${facebookLoginResult.accessToken.token}');

        var profile = json.decode(graphResponse.body);
        print(profile.toString());

        onLoginStatusChanged(true, profileData: profile);

        break;
    }
    _logout() async {
      await facebookLogin.logOut();
      onLoginStatusChanged(false);
      print("Logged out");
    }
  }
}