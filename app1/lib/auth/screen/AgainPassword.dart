import 'dart:convert';

import 'package:app1/main.dart';

import 'package:app1/model/forgot_user.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../../ui.dart';
import '../../widgets/text_input_style.dart';

import '../../widgets/dismit_keybord.dart';
import '../../widgets/app_button.dart';
import '../../widgets/background.dart';
import 'package:http/http.dart' as http;

import 'LoginScreen.dart';
import 'RegisterScreen.dart';

class AgainForgotScreen extends StatefulWidget {
  const AgainForgotScreen(
      {Key? key,
      required this.userName,
      required this.email,
      required this.token})
      : super(key: key);
  final String userName;
  final String email;
  final String token;
  @override
  _AgainForgotScreenState createState() => _AgainForgotScreenState();
}

class _AgainForgotScreenState extends State<AgainForgotScreen> {
  late FocusNode? myFocusNode;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  bool _isValidate = true;
  String validationMessage = "";
  bool _visibility = true;
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    OutlineInputBorder getBorder() {
      return OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(48.0)),
        borderSide: BorderSide(width: 2, color: Theme.of(context).primaryColor),
        gapPadding: 2,
      );
    }

    var urlRegisterConfirm = Uri.parse(SERVER_IP + '/auth/forgotNewPassword');

    Future<String> forgotPwConfirmFunction(
        String userName, String password, String token, String email) async {
      http.Response response;
      response = await http.post(urlRegisterConfirm,
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            "userName": userName,
            "email": email,
            "token": token,
            "password": password
          }));

      return json.decode(response.body).toString();
    }

    Size size = MediaQuery.of(context).size;
    String initText = "";
    // _passwordController.text = "hihi";
    var currentFocus;
    return Scaffold(
      body: DismissKeyboard(
        child: Background(
            Column: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100, bottom: 60),
                child: Text(
                  "Nhập mật khẩu mới",
                  style: AppStyles.h2,
                ),
              ),

              CustomTextInput(
                textEditController: _passwordController,
                hintTextString: 'Mật khẩu',
                inputType: InputType.Password,
                enableBorder: true,
                themeColor: Theme.of(context).primaryColor,
                cornerRadius: 48.0,
                maxLength: 24,
                prefixIcon:
                    Icon(Icons.lock, color: Theme.of(context).primaryColor),
                textColor: Colors.black,
                textInit: initText,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: TextField(
                    controller: _rePasswordController,
                    decoration: InputDecoration(
                      hintText: "Nhập lại mật khẩu",
                      errorText: _isValidate ? null : validationMessage,
                      counterText: '',
                      border: getBorder(),
                      enabledBorder: getBorder(),
                      focusedBorder: getBorder(),
                      labelText: "Nhập lại mật khẩu",
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Theme.of(context).primaryColor,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _visibility = !_visibility;
                          setState(() {});
                        },
                        icon: Icon(
                          _visibility ? Icons.visibility : Icons.visibility_off,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    obscureText: !_visibility,
                    onChanged: (String textInput) {
                      setState(() {
                        _isValidate = textInput == _passwordController.text;
                        validationMessage = 'Mật khẩu nhập lại không chính xác';
                      });
                    }),
              ),
              //...............Button ..gửi  nhập lại mk mới.............................
              (_passwordController.text.length >= 6 == true &&
                      _passwordController.text == _rePasswordController.text)
                  ? RoundedLoadingButton(
                      child: Text("Gửi"),
                      controller: _btnController,
                      onPressed: () async {
                        print(widget.userName);
                        if (widget.token != userProvider.jwtP) {
                          String a = await forgotPwConfirmFunction(
                            widget.userName,
                            _passwordController.text,
                            widget.token,
                            widget.email,
                          );
                          _btnController.success();
                          _btnController.reset();
                          if (a == "done") {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => LoginScreen()));
                          } else {}
                        } else {
                          var r = await PutApi(
                              widget.token,
                              {
                                "userName": widget.userName,
                                "email": widget.email,
                                "token": widget.token,
                                "password": _passwordController.text
                              },
                              "/user/updatePassword");
                          if (r == "done") {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => LoginScreen()));
                          }
                        }
                      })
                  : AppBTnStyle(
                      onTap: null,
                      color: Color.fromRGBO(255, 255, 255, 0.4),
                      label: "Gửi",
                    ),
              //.......................button đã có tài khoản.......................
            ],
          ),
        )),
      ),
    );
  }
}

Future PutApi(String jwt, data, String pathApi) async {
  http.Response response;
  print("----post---------" + pathApi);
  response = await http.put(Uri.parse(SERVER_IP + pathApi),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'cookie': "jwt=" + jwt
      },
      body: jsonEncode(data));

  if (response.statusCode == 200 || response.statusCode == 201) {
    print("-----kêt quả post--------");
    print(json.decode(response.body).toString());
    return json.decode(response.body);
  } else {
    print("---------------put lỗi---------");
    return "error";
  }
}
