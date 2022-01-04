import 'package:flutter/material.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/screenConfig.dart';

class CustomFlatButton extends StatefulWidget {
  Function fn;
  String text;

  CustomFlatButton({required this.fn, required this.text});

  @override
  _CustomFlatButtonState createState() => _CustomFlatButtonState();
}

class _CustomFlatButtonState extends State<CustomFlatButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(6),
      width: SizeConfig.screenWidth,
      child: ElevatedButton(
          style: AppTheme.flatButtonStyle,
          onPressed: (){
            widget.fn();
          },
          child: Text(
            widget.text,
            style: AppTheme.textTheme.button,
          )),
    );
  }
}

class CustomButton extends StatefulWidget {
  Function fn;
  String text;
  double? width;

  CustomButton({required this.fn, required this.text, this.width});

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      margin: const EdgeInsets.all(6),
      width: widget.width!=null? widget.width:SizeConfig.screenWidth-200,
      child: ElevatedButton(
          style: AppTheme.flatButtonStyle,
          onPressed: (){
            widget.fn();
          },
          child: Text(
            widget.text,
            style: AppTheme.textTheme.button,
          )),
    );
  }
}
