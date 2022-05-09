import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:app1/auth/screen/LoginScreen.dart';
import 'package:app1/Screen/MainScreen.dart';
import 'package:app1/chat-app/screens_chat/CameraView.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/user/screen/Profile.dart';
import 'package:app1/main.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:app1/widgets/app_button.dart';
import 'package:app1/widgets/app_button_icon.dart';
import 'package:app1/widgets/dismit_keybord.dart';
import 'package:app1/widgets/text_input_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../ui.dart';

class SettingUser extends StatefulWidget {
  const SettingUser({Key? key}) : super(key: key);

  @override
  _SettingUser createState() => _SettingUser();
}

class _SettingUser extends State<SettingUser> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  List<String> listHobbies = [
    "Acapella",
    'Aikido',
    'BMX',
    'Ba môn phối hợp',
    'Bay khinh khí cầu',
    'Beatbox',
    'Bi-a lỗ & bi-a',
    'Bowling',
    'Bóng bàn',
    'Bóng bầu dục',
    'Bóng chuyền',
    'Bóng chuyền bãi biển',
    'Bóng chày',
    'Bóng rổ',
    'Bóng đá',
    'Bơi lội',
    'Bơi thuyền',
    'Bắn cung',
    'Bắn súng',
    'Ca hát',
    'Câu cá'
        'Chiêm tinh học',
    "Chà DJ",
    "Chơi đàn ghi-ta",
    "Chơi đàn violin",
    'Nghe nhạc',
    'Trò chơi điện tử'
  ];
  List<String> listTinhThanhPho = [
    'An Giang',
    'Bà rịa – Vũng tàu',
    'Bắc Giang',
    'Bắc Kạn',
    'Bạc Liêu',
    'Bắc Ninh',
    'Bến Tre',
    'Bình Định',
    'Bình Dương',
    'Bình Phước',
    'Bình Thuận',
    'Cà Mau',
    'Cần Thơ',
    'Cao Bằng',
    'Đà Nẵng',
    'Đắk Lắk',
    'Đắk Nông',
    'Điện Biên',
    'Đồng Nai',
    'Đồng Tháp',
    'Gia Lai',
    'Hà Giang',
    'Hà Nam',
    'Hà Nội',
    'Hà Tĩnh',
    'Hải Dương',
    'Hải Phòng',
    'Hậu Giang',
    'Hòa Bình',
    'Hưng Yên',
    'Khánh Hòa',
    'Kiên Giang',
    'Kon Tum',
    'Lai Châu',
    'Lâm Đồng',
    'Lạng Sơn',
    'Lào Cai',
    'Long An',
    'Nam Định',
    'Nghệ An',
    'Ninh Bình',
    'Ninh Thuận',
    'Phú Thọ',
    'Phú Yên',
    'Quảng Bình',
    'Quảng Nam',
    'Quảng Ngãi',
    'Quảng Ninh',
    'Quảng Trị',
    'Sóc Trăng',
    'Sơn La',
    'Tây Ninh',
    'Thái Bình',
    'Thái Nguyên',
    'Thanh Hóa',
    'Thừa Thiên Huế',
    'Tiền Giang',
    'Thành phố Hồ Chí Minh',
    'Trà Vinh',
    'Tuyên Quang',
    'Vĩnh Long',
    'Vĩnh Phúc',
    'Yên Bái',
  ];
  //List<String> listHuyenPhuong = ['Bắc Từ Liêm','Nam Từ Liêm','Thanh Oai'];
  //List<String> listXaPhuong = ['Mỹ Đình 1','Mỹ Đình 2','Mỹ Đình 3'];
  final TextEditingController _inputNameController = TextEditingController();
  final TextEditingController _inputNameSchoolController =
      TextEditingController();
  final TextEditingController _inputHistoryController = TextEditingController();
  var valueChooseTinh = 'Hà Nội';
  var valueChooseHobbies;
  late DateTime _dateBirth;
  late String dateBirth;
  late bool valueCheckSexBoy;
  late bool valueCheckSexGirl;
  late bool valueCheckSexOther;
  FocusNode focusNode = FocusNode();
  int popTime = 0;
  late UserModel _userProfile;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    valueCheckSexBoy = false;
    valueCheckSexGirl = false;
    valueCheckSexOther = false;
    dateBirth = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final RoundedLoadingButtonController _btnLogoutController =
        RoundedLoadingButtonController();
    String pathAvatar = userProvider.userP.avatarImg != null &&
            userProvider.userP.avatarImg.length != 0
        ? SERVER_IP +
            "/upload/" +
            userProvider
                .userP.avatarImg[userProvider.userP.avatarImg.length - 1]
        : SERVER_IP + "/upload/avatarNull.jpg";
    String pathCover = userProvider.userP.coverImg != null &&
            userProvider.userP.coverImg.length != 0
        ? SERVER_IP +
            "/upload/" +
            userProvider.userP.coverImg[userProvider.userP.coverImg.length - 1]
        : SERVER_IP + "/upload/avatarNull.jpg";
    void onImageSend(String path, String event, String jwt) async {
      print("image.............${path}");
      var request = http.MultipartRequest(
          "POST", Uri.parse(SERVER_IP + "/file/img/upload"));
      request.fields["eventChangeImgUser"] = event;
      request.files.add(await http.MultipartFile.fromPath("img", path));
      request.headers.addAll(
          {"Content-type": "multipart/form-data", "cookie": "jwt=" + jwt});

      http.StreamedResponse response = await request.send();

      var httpResponse = await http.Response.fromStream(response);
      print(httpResponse.statusCode);
      if (httpResponse.statusCode == 201 || httpResponse.statusCode == 200) {
        var data = json.decode(httpResponse.body).toString();

        if (data == "error" || data == "not jwt") {
          print(data);
        } else {
          print(data);
          UserModel user = userProvider.userP;
          if (event == "avatar") {
            List avatar = user.avatarImg;
            avatar.add(data);
            user.avatarImg = avatar;
          }
          if (event == "cover") {
            List cover = user.coverImg;
            cover.add(data);
            user.coverImg = cover;
          }
          userProvider.userLogin(user, userProvider.jwtP);
          for (var i = 0; i < popTime; i++) {
            if (mounted) Navigator.pop(context);
          }
          if (mounted)
            setState(() {
              popTime = 0;
            });
        }
      } else {
        print("er");
      }
    }

    return DismissKeyboard(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: AppBar(
                backgroundColor: Color.fromRGBO(200, 100, 400, 0.2),
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Chỉnh sửa trang cá nhân"),
                ),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 22, right: 12),
                  child: InkWell(
                      onTap: () async {
                        print("oki");
                        focusNode.unfocus();
                        if (!focusNode.hasFocus) {
                          Navigator.of(context).pop(true);
                        }

                        //
                      },
                      child: Icon(Icons.arrow_back, size: 24)),
                ),
                leadingWidth: 60,
                titleSpacing: 0,
              ),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ///ảnh đại diện

                    ///Tiểu sử
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tiểu sử ",
                          style: AppStyles.h3,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _inputHistoryController,
                        autofocus: false,
                        decoration: InputDecoration(hintText: "..."),
                      ),
                    ),

                    ///họ, tên
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Họ và tên ",
                          style: AppStyles.h3,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                      child: TextField(
                        controller: _inputNameController,
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: "VD: Nguyễn Văn A",
                        ),
                      ),
                    ),

                    ///Quê quán

                    Row(
                      children: [
                        Icon(Icons.home_outlined),
                        Text(
                          " Sống tại   ",
                          style: AppStyles.h3,
                          textAlign: TextAlign.left,
                        ),
                        DropdownButton(
                          dropdownColor: Colors.white,
                          value: valueChooseTinh,
                          onChanged: (value) {
                            setState(() {
                              valueChooseTinh = value as String;
                            });
                          },
                          items: listTinhThanhPho.map((valueTinh) {
                            return DropdownMenuItem(
                              value: valueTinh,
                              child: Text(
                                valueTinh,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800),
                                textAlign: TextAlign.left,
                              ),
                            ); //DropdownMenuItem
                          }).toList(),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                      child: Divider(
                        height: 1,
                        color: Colors.black87,
                      ),
                    ),

                    ///Trường học
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Trường học ",
                          style: AppStyles.h3,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                      child: TextField(
                        controller: _inputNameSchoolController,
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: "THPT ...",
                        ),
                      ),
                    ),

                    /// sở thích
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sở thích ",
                          style: AppStyles.h3,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.face_unlock_rounded),
                        ),
                        DropdownButton(
                          dropdownColor: Colors.white,
                          value: valueChooseHobbies,
                          onChanged: (value) {
                            setState(() {
                              valueChooseHobbies = value as String;
                            });
                          },
                          items: listHobbies.map((valueHobbie) {
                            return DropdownMenuItem(
                              value: valueHobbie,
                              child: Text(
                                valueHobbie,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800),
                                textAlign: TextAlign.left,
                              ),
                            ); //DropdownMenuItem
                          }).toList(),
                        ),
                      ],
                    ),

                    // ............ Ngày sinh
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            "Ngày sinh",
                            style: AppStyles.h3,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        RaisedButton(
                            child: Text("Chọn"),
                            onPressed: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1975),
                                lastDate: DateTime.now(),
                              ).then((date) {
                                setState(() {
                                  _dateBirth = date as DateTime;
                                  dateBirth =
                                      _dateBirth.toString().substring(0, 10);
                                });
                              });
                            }), //Chọn ngày sinh
                        Text(
                          "\t\t\t\t" + dateBirth,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),

                    //..............Giới tính
                    Row(
                      children: [
                        Text(
                          "Giới tính",
                          style: AppStyles.h3,
                          textAlign: TextAlign.left,
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: valueCheckSexBoy,
                                  onChanged: (valueSex) {
                                    setState(() {
                                      valueCheckSexBoy = valueSex as bool;
                                    });
                                    valueCheckSexGirl = false;
                                    valueCheckSexOther = false;
                                  },
                                ),
                                Text(
                                  "Nam",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ), // gt Nam

                            Row(
                              children: [
                                Checkbox(
                                  value: valueCheckSexGirl,
                                  onChanged: (valueSex) {
                                    setState(() {
                                      valueCheckSexGirl = valueSex as bool;
                                    });
                                    valueCheckSexBoy = false;
                                    valueCheckSexOther = false;
                                  },
                                ),
                                Text(
                                  "Nữ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ), // gt Nữ

                            Row(
                              children: [
                                Checkbox(
                                  value: valueCheckSexOther,
                                  onChanged: (valueSex) {
                                    setState(() {
                                      valueCheckSexOther = valueSex as bool;
                                    });
                                    valueCheckSexGirl = false;
                                    valueCheckSexBoy = false;
                                  },
                                ),
                                Text(
                                  "Khác",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ), // gt khác
                          ],
                        ),
                      ],
                    ), // Giới tính

                    //..............Nút Lưu
                    SizedBox(
                      height: 20,
                    ),
                    RoundedLoadingButton(
                      controller: _btnController,
                      child: Text("Lưu cài đặt"),
                      onPressed: () async {
                        String sex;
                        String selectTinh = valueChooseTinh;
                        print("Họ, Tên  ---  " + _inputNameController.text);
                        print("Tỉnh đã chọn là ---  " + selectTinh);
                        //  print("Huyện đã chọn là ---  " + selectTinh);
                        //  print("Xã đã chọn là ---  " + selectTinh);
                        print("Ngày sinh  ---  " + dateBirth);
                        if (valueCheckSexBoy) {
                          sex = "Nam";
                          print("Giới tính  --- Nam ");
                        } else if (valueCheckSexGirl) {
                          print("Giới tính  --- Nữ ");
                          sex = "Nữ";
                        } else {
                          sex = "Other";
                          print("Giới tính  ---  Khác ");
                        }
                        print(
                            "Tiểu sử là  ---  " + _inputHistoryController.text);
                        print("Sở thích là  ---  " + valueChooseHobbies);

                        log('Đã lưu cài đặt');
                        var result = await PostApi(
                            userProvider.jwtP,
                            {
                              "realName": _inputNameController.text,
                              "sex": sex,
                              "addressTinh": selectTinh,
                              "addressDetails": "",
                              "birthDate": dateBirth
                            },
                            "/user/setting");
                        print("kết quả là ---------");
                        if (result == "not jwt") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => LoginScreen()));
                        }
                        if (result == "done") {
                          userProvider.userP.realName =
                              _inputNameController.text;
                          userProvider.userP.sex = sex;
                          userProvider.userP.addressTinh = selectTinh;
                          userProvider.userP.addressDetails = "";
                          userProvider.userP.birthDate = dateBirth;
                          _btnController.success();
                          if (_inputNameController.text != "user") {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => MainScreen(
                                        UserId: userProvider.userP.id)));
                          }
                        }
                        print(result);
                      },
                    )
                  ], //nút lưu
                ),
              ),
            )));
  }
}

Future PostApi(String jwt, data, String pathApi) async {
  http.Response response;
  print("----post---------" + pathApi);
  response = await http.post(Uri.parse(SERVER_IP + pathApi),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'cookie': "jwt=" + jwt
      },
      body: jsonEncode(data));

  if (response.statusCode == 200 || response.statusCode == 201) {
    // print("-----kêt quả post--------");
    // print(json.decode(response.body).toString());
    return json.decode(response.body);
  } else {
    print("---------------post lỗi---------");
    return "error";
  }
}
