import 'dart:convert';

import 'package:app1/auth/screen/AgainPassword.dart';
import 'package:app1/auth/screen/LoginScreen.dart';
import 'package:app1/main.dart';

import 'package:app1/model/forgot_user.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/widgets/app_button.dart';
import 'package:app1/widgets/dismit_keybord.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rounded_loading_button/rounded_loading_button.dart';

class VerifyCode extends StatefulWidget {
  const VerifyCode({Key? key, this.userCreate, this.userForgot})
      : super(key: key);
  final UserCreateModel? userCreate;
  final UserForgotModel? userForgot;

  @override
  _VerifyCode createState() => _VerifyCode();
}

class _VerifyCode extends State<VerifyCode> {
  final TextEditingController _1Controller = TextEditingController();
  final TextEditingController _2Controller = TextEditingController();

  final TextEditingController _3Controller = TextEditingController();

  final TextEditingController _4Controller = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  var urlRegisterConfirm = Uri.parse(SERVER_IP + '/auth/registerConfirm');
  var urlForgotConfirm = Uri.parse(SERVER_IP + '/auth/forgotPasswordConfirm');

  Future<String> registerConfirmFunction(
      UserCreateModel user, String token) async {
    http.Response response;
    response = await http.post(urlRegisterConfirm,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "userName": user.userName,
          "password": user.password,
          "email": user.email,
          "createdAt": user.createdAt,
          "sex": user.sex,
          "addressTinh": user.addressTinh,
          "addressDetails": user.addressDetails,
          "birthDate": user.birthDate,
          "token": token,
          "realName": user.realName,
          "avatarImg": user.avatarImg,
          "coverImg": user.coverImg,
        }));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body).toString();
    } else {
      return "error";
    }
  }

  Future<String> forgotConfirmFunction(
      UserForgotModel user, String token) async {
    http.Response response;
    response = await http.post(urlForgotConfirm,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(
            {"userName": user.userName, "email": user.email, "token": token}));

    return json.decode(response.body).toString();
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                ),
                Text(
                  "M?? OTP",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "M?? OTP ???? ???????c g???i trong email c???a b???n !",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  "Vui l??ng nh???p v??o d?????i ????y ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _textFieldOTP(
                              first: true,
                              last: false,
                              controller: _1Controller),
                          _textFieldOTP(
                              first: false,
                              last: false,
                              controller: _2Controller),
                          _textFieldOTP(
                              first: false,
                              last: false,
                              controller: _3Controller),
                          _textFieldOTP(
                              first: false,
                              last: true,
                              controller: _4Controller),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: (_1Controller.text.length >= 1 == true &&
                          _2Controller.text.length >= 1 == true &&
                          _4Controller.text.length >= 1 == true &&
                          _3Controller.text.length >= 1 == true)
                      ? RoundedLoadingButton(
                          child: Text("G???i"),
                          controller: _btnController,
                          onPressed: () async {
                            //
                            String token = _1Controller.text +
                                _2Controller.text +
                                _3Controller.text +
                                _4Controller.text;
                            print("token ???? nh??p---  " + token);
                            if (widget.userCreate != null) {
                              print("----register ch???y-------------");
                              print(widget.userCreate!.realName);
                              String a = await registerConfirmFunction(
                                  widget.userCreate!, token);
                              _btnController.success();
                              _btnController.reset();
                              if (a == "done") {
                                //dang kis thanh cong
                                print("dangki thanh cong");
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => LoginScreen()));
                              } else {
                                print("Dang ki that bai");
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.error,
                                  text: "T???o m???i th???t b???i !",
                                );
                              }
                            }
                            if (widget.userForgot != null) {
                              print("----forgotch???y-------------");

                              String a = await forgotConfirmFunction(
                                  widget.userForgot!, token);
                              _btnController.reset();

                              if (a == "done") {
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.success,
                                  text: "T???o m???i th??nh c??ng !",
                                );
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => AgainForgotScreen(
                                              userName:
                                                  widget.userForgot!.userName,
                                              email: widget.userForgot!.email,
                                              token: token,
                                            )));
                              }
                            }
                          })
                      : AppBTnStyle(
                          label: "G???i",
                          onTap: null,
                          color: Color.fromRGBO(255, 255, 255, 0.4),
                        ),
                ),
                SizedBox(
                  height: 18,
                ),
                Text(
                  "b???n ch??a th???y m?? code",
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      color: Colors.blue),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "G???i l???i m?? OTP",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue),
                ),
              ],
            ),
          )),
    );
  }

  Widget _textFieldOTP({required bool first, last, controller}) {
    return Container(
      height: 85,
      child: AspectRatio(
        aspectRatio: 0.7,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          onChanged: (value) {
            if (value.length == 1 && last == false) {
              FocusScope.of(context).nextFocus();
              setState(() {});
            }
            if (value.length == 0 && first == false) {
              FocusScope.of(context).previousFocus();
              setState(() {});
            }
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.normal, color: Colors.blue),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            counter: Offstage(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
