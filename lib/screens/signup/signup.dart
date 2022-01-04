import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/common/routes.dart';
import 'package:wean_app/widgets/appBars.dart';
import 'package:wean_app/widgets/buttons.dart';
import 'package:wean_app/widgets/decorations.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _fnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  FocusScopeNode _focusScopeNode = FocusScopeNode();
  bool _terms = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: appBarWithCenterText(context, 'Register'),
          ),
          body: SafeArea(
              child: Container(
            margin: const EdgeInsets.all(6),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: FocusScope(
                  node: _focusScopeNode,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextFormField(
                          controller: _fnameController,
                          autofocus: true,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              border: normalBorder,
                              enabledBorder: normalBorder,
                              focusedBorder: focusBorder,
                              prefixIcon: Icon(
                                Icons.person,
                                color: AppTheme.primaryColor,
                              ),
                              hintText: "Enter your name",
                              hintStyle: AppTheme.body2.copyWith(
                                color: AppTheme.greyText,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              border: normalBorder,
                              enabledBorder: normalBorder,
                              focusedBorder: focusBorder,
                              prefixIcon: Icon(
                                Icons.email,
                                color: AppTheme.primaryColor,
                              ),
                              hintText: "Enter your email",
                              hintStyle: AppTheme.body2.copyWith(
                                color: AppTheme.greyText,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        margin: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "I accept all terms and conditions",
                                style: AppTheme.body1
                                    .copyWith(color: AppTheme.black),
                              ),
                              flex: 3,
                            ),
                            Container(
                              child: Transform.scale(
                                scale: 1.25,
                                child: Switch(
                                  value: _terms,
                                  activeColor: AppTheme.primaryColor,
                                  inactiveTrackColor: AppTheme.disableColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _terms = value;
                                    });
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CustomFlatButton(
                          fn: () {
                            Navigator.of(context).pushReplacementNamed(home);
                          },
                          text: "JOIN NOW"),
                    ],
                  ),
                ),
              ),
            ),
          )),
        ));
  }
}
