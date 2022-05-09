import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'masked_input_formator.dart';

class CustomTextInput extends StatefulWidget {
  final hintTextString;
  final TextEditingController textEditController;
  final InputType inputType;
  final bool enableBorder;
  final Color? themeColor;
  final double? cornerRadius;
  final int? maxLength;
  final Widget? prefixIcon;
  final Color? textColor;
  final String? errorMessage;
  final String? labelText;
  final String textInit;
  final String? rePasswordText;
  CustomTextInput(
      {Key? key,
      required this.hintTextString,
      required this.textEditController,
      required this.inputType,
      this.enableBorder = false,
      this.themeColor,
      this.cornerRadius,
      this.maxLength,
      this.prefixIcon,
      this.textColor,
      this.errorMessage,
      this.labelText,
      required this.textInit,
      this.rePasswordText = ""})
      : super(key: key);

  // ignore: prefer_typing_uninitialized_variables

  @override
  _CustomTextInputState createState() => _CustomTextInputState();
}

// input text state
class _CustomTextInputState extends State<CustomTextInput> {
  bool _isValidate = true;
  String validationMessage = '';
  bool visibility = true;
  int oldTextSize = 0;
  String textInput = "";
  @override
  initState() {
    super.initState();
    print("1");
  }

  // build method for UI rendering
  @override
  Widget build(BuildContext context) {
    print("render");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: TextField(
        controller: widget.textEditController,
        decoration: InputDecoration(
          hintText: widget.hintTextString as String,
          errorText: _isValidate ? null : validationMessage,
          counterText: '',
          border: getBorder(),
          enabledBorder: widget.enableBorder ? getBorder() : InputBorder.none,
          focusedBorder: widget.enableBorder ? getBorder() : InputBorder.none,
          labelText: widget.labelText ?? widget.hintTextString as String,
          labelStyle: getTextStyle(),
          prefixIcon: widget.prefixIcon ?? getPrefixIcon(),
          suffixIcon: getSuffixIcon(),
        ),
        onChanged: checkValidation,
        keyboardType: getInputType(),
        obscureText:
            widget.inputType != InputType.Password ? false : !visibility,
        maxLength: widget.inputType == InputType.PaymentCard
            ? 19
            : widget.maxLength ?? getMaxLength(),
        style: TextStyle(
          color: widget.textColor ?? Colors.black,
        ),
        inputFormatters: [getFormatter()],
      ),
    );
  }

  //get border of textinput filed
  OutlineInputBorder getBorder() {
    return OutlineInputBorder(
      borderRadius:
          BorderRadius.all(Radius.circular(widget.cornerRadius ?? 12.0)),
      borderSide: BorderSide(
          width: 2, color: widget.themeColor ?? Theme.of(context).primaryColor),
      gapPadding: 2,
    );
  }

  // formatter on basis of textinput type
  TextInputFormatter getFormatter() {
    if (widget.inputType == InputType.PaymentCard)
      return MaskedTextInputFormatter(
        mask: 'xxxx xxxx xxxx xxxx',
        separator: ' ',
      );
    else
      return TextInputFormatter.withFunction((oldValue, newValue) => newValue);
  }

  // text style for textinput
  TextStyle getTextStyle() {
    return TextStyle(
        color: widget.themeColor ?? Theme.of(context).primaryColor);
  }

  // input validations
  void checkValidation(String textFieldValue) {
    switch (widget.inputType) {
      case InputType.Default:
        _isValidate = textFieldValue.length >= 6;
        validationMessage =
            widget.errorMessage ?? 'Tên đăng nhập phải dài hơn 6 kí tự';
        break;
      case InputType.Email:
        _isValidate = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(textFieldValue);
        validationMessage = widget.errorMessage ?? 'Hãy nhập email của bạn';
        break;
      case InputType.Number:
        _isValidate = textFieldValue.length == widget.maxLength;
        validationMessage =
            widget.errorMessage ?? 'Contact Number is not valid';

        break;
      case InputType.Password:
        _isValidate = textFieldValue.length >= 6;
        validationMessage =
            widget.errorMessage ?? 'Mật khẩu phải dài hơn 6 kí tự';

        break;
      case InputType.rePassword:
        _isValidate = textFieldValue == widget.rePasswordText;
        validationMessage =
            widget.errorMessage ?? 'Mật khẩu nhập lại không chính xác';
        break;
      case InputType.PaymentCard:
        _isValidate = textFieldValue.length == 19;
        validationMessage = widget.errorMessage ?? 'Card number is not correct';
        break;
      default:
    }
    oldTextSize = textFieldValue.length;
    if (textInput != textFieldValue) {
      setState(() {
        textInput = textFieldValue;
      });
    }
  }

  // return input type for setting keyboard
  TextInputType getInputType() {
    switch (widget.inputType) {
      case InputType.Default:
        return TextInputType.text;
        break;

      case InputType.Email:
        return TextInputType.emailAddress;
        break;

      case InputType.Number:
        return TextInputType.number;
        break;

      case InputType.PaymentCard:
        return TextInputType.number;
        break;

      default:
        return TextInputType.text;
        break;
    }
  }

  // get max length of text
  int getMaxLength() {
    switch (widget.inputType) {
      case InputType.Default:
        return 36;
        break;

      case InputType.Email:
        return 50;
        break;

      case InputType.Number:
        return 10;
        break;

      case InputType.Password:
        return 24;
        break;

      case InputType.PaymentCard:
        return 19;
        break;

      default:
        return 36;
        break;
    }
  }

  // get prefix Icon
  Icon getPrefixIcon() {
    switch (widget.inputType) {
      case InputType.Default:
        return Icon(
          Icons.person,
          color: widget.themeColor ?? Theme.of(context).primaryColor,
        );
        break;

      case InputType.Email:
        return Icon(
          Icons.email,
          color: widget.themeColor ?? Theme.of(context).primaryColor,
        );
        break;

      case InputType.Number:
        return Icon(
          Icons.phone,
          color: widget.themeColor ?? Theme.of(context).primaryColor,
        );
        break;

      case InputType.Password:
        return Icon(
          Icons.lock,
          color: widget.themeColor ?? Theme.of(context).primaryColor,
        );
        break;

      case InputType.PaymentCard:
        return Icon(
          Icons.credit_card,
          color: widget.themeColor ?? Theme.of(context).primaryColor,
        );
        break;

      default:
        return Icon(
          Icons.person,
          color: widget.themeColor ?? Theme.of(context).primaryColor,
        );
        break;
    }
  }

  // get suffix icon
  Widget getSuffixIcon() {
    if (widget.inputType == InputType.Password) {
      return IconButton(
        onPressed: () {
          visibility = !visibility;
          setState(() {});
        },
        icon: Icon(
          visibility ? Icons.visibility : Icons.visibility_off,
          color: widget.themeColor ?? Theme.of(context).primaryColor,
        ),
      );
    } else {
      return const Opacity(opacity: 0, child: Icon(Icons.phone));
    }
  }
}

//input types
enum InputType { Default, Email, Number, Password, PaymentCard, rePassword }
