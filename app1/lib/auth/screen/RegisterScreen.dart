import 'dart:convert';

import 'package:app1/auth/screen/VerifyCodeScreen.dart';
import 'package:app1/main.dart';
import 'package:app1/model/user_model.dart';
import 'package:cool_alert/cool_alert.dart';

import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../../widgets/text_input_style.dart';
import 'package:http/http.dart' as http;
import '../../widgets/dismit_keybord.dart';
import '../../widgets/app_button.dart';
import '../../widgets/background.dart';
import '../../ui.dart';
import 'LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late FocusNode? myFocusNode;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  var urlRegister = Uri.parse(SERVER_IP + '/auth/register');
  Future<UserCreateModel> registerFunction(
      String userName, String password, String email) async {
    http.Response response;
    response = await http.post(urlRegister,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(
            {"userName": userName, "password": password, "email": email}));

    print("da lay thanh cong");
    var a = json.decode(response.body);
    print(json.decode(response.body)["token"]);
    if (a["userName"] == null) {
      return new UserCreateModel(
        friend: [],
        friendConfirm: [],
        friendRequest: [],
        avatarImg: [],
        coverImg: [],
        hadMessageList: [],
      );
    }
    UserCreateModel b = new UserCreateModel(
      friendConfirm: [],
      friendRequest: [],
      avatarImg: [],
      coverImg: [],
      hadMessageList: [],
      friend: [],
      userName: a["userName"],
      password: a["password"],
      email: a["email"],
      token: a["token"].toString(),
    );

    return b;
  }

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
    OutlineInputBorder getBorder() {
      return OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(48.0)),
        borderSide: BorderSide(width: 2, color: Theme.of(context).primaryColor),
        gapPadding: 2,
      );
    }

    Size size = MediaQuery.of(context).size;

    String initText = "";
    // _passwordController.text = "hihi";
    var currentFocus;
    return Scaffold(
      appBar: AppBar(
        title: Text("Đăng ký"),
        backgroundColor: Color.fromRGBO(200, 100, 400, 0.2),
      ),
      body: DismissKeyboard(
        child: Background(
            Column: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 60),
                child: Text(
                  "Đăng ký",
                  style: AppStyles.h2,
                ),
              ),
              CustomTextInput(
                textEditController: _userNameController,
                hintTextString: 'Tên người dùng',
                inputType: InputType.Default,
                enableBorder: true,
                themeColor: Theme.of(context).primaryColor,
                cornerRadius: 48.0,
                maxLength: 24,
                prefixIcon:
                    Icon(Icons.person, color: Theme.of(context).primaryColor),
                textColor: Colors.black,
                textInit: initText,
              ),
              CustomTextInput(
                textEditController: _emailController,
                hintTextString: 'Email',
                inputType: InputType.Email,
                enableBorder: true,
                themeColor: Theme.of(context).primaryColor,
                cornerRadius: 48.0,
                maxLength: 24,
                prefixIcon:
                    Icon(Icons.person, color: Theme.of(context).primaryColor),
                textColor: Colors.black,
                textInit: initText,
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
              //...............Button ..gửi đăng kí.............................
              (_userNameController.text.length >= 6 == true &&
                      _passwordController.text.length >= 6 == true &&
                      _passwordController.text == _rePasswordController.text &&
                      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(_emailController.text))
                  ? RoundedLoadingButton(
                      child: Text("Đăng Ký"),
                      controller: _btnController,
                      onPressed: () async {
                        String userName = _userNameController.text;
                        String password = _passwordController.text;
                        String email = _emailController.text;

                        UserCreateModel result =
                            await registerFunction(userName, password, email);
                        print("name" + result.token);
                        _btnController.success();
                        _btnController.reset();
                        UserCreateModel user = new UserCreateModel(
                            friend: [],
                            friendConfirm: [],
                            friendRequest: [],
                            avatarImg: ["avatarNull.jpg"],
                            coverImg: ["coverNull.jpg"],
                            hadMessageList: [],
                            realName: "user",
                            sex: '',
                            createdAt: DateTime.now().toString(),
                            addressTinh: "",
                            addressDetails: "",
                            birthDate: '',
                            userName: result.userName,
                            token: result.token,
                            password: result.password,
                            email: result.email);
                        print("name 2 " + user.token);
                        _btnController.reset();

                        if (user.userName == "") {
                          print("sai roi");
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            text: "Tạo mới thất bại !",
                          );
                          //bắn ra 1 cái thông báo là người dùng hoặc email đã tồn tại
                        } else {
                          print("ok");
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.success,
                            text: "Tạo mới thành công !",
                          );
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => VerifyCode(
                                        userCreate: user,
                                      )));
                        }
                      })
                  : AppBTnStyle(
                      onTap: null,
                      color: Color.fromRGBO(255, 255, 255, 0.4),
                      label: "Đăng ký",
                    ),
              Divider(height: 40, color: Colors.black),
              //.......................button đã có tài khoản.......................
              TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => LoginScreen()));
                  },
                  child: RichText(
                      text: TextSpan(
                          text: "bạn đã có tài khoản     ",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          children: [
                        TextSpan(
                          text: "ĐĂNG NHẬP",
                          style: TextStyle(color: Colors.orangeAccent),
                        )
                      ]))),
            ],
          ),
        )),
      ),
    );
  }
}
