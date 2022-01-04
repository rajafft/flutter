import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:wean_app/common/screenConfig.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wean_app/translations/locale_keys.g.dart';

class BidWidget extends StatefulWidget {
  final DocumentReference<Object?> chatReference;

  BidWidget({Key? key, required this.chatReference}) : super(key: key);

  @override
  _BidWidgetState createState() => _BidWidgetState();
}

class _BidWidgetState extends State<BidWidget> {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isCurrentBidFetched = false;
  late double minimumBid;
  late double current_bid;
  int incDecValue = 0;

  bool isBiding = false;

  @override
  void initState() {
    super.initState();
    fetchCurrentBid();
  }

  void fetchCurrentBid() async {
    DocumentSnapshot snapshot = await widget.chatReference.get();
    if (snapshot.exists && snapshot.data() != null) {
      DocumentSnapshot productSnapshot = await ((snapshot.data()
              as Map)['productReference'] as DocumentReference)
          .get();
      if (productSnapshot.exists && productSnapshot.data() != null) {
        minimumBid = (productSnapshot.data() as Map)['current_bid'];
        if (minimumBid >= 0 && minimumBid <= 100) {
          incDecValue = 1;
        } else if (minimumBid >= 100 && minimumBid <= 1000) {
          incDecValue = 5;
        } else if (minimumBid > 1000 && minimumBid < 100000) {
          incDecValue = 50;
        } else if (minimumBid > 100000 && minimumBid < 10000000) {
          incDecValue = 500;
        } else {
          incDecValue = 5000;
        }
        current_bid = minimumBid + incDecValue;
        isCurrentBidFetched = true;
        setState(() {});
      }
    }
  }

  void increament() {
    current_bid = current_bid + incDecValue;
    setState(() {});
  }

  void decreament() {
    double minimumValue = minimumBid + incDecValue;
    if (current_bid > minimumValue) {
      current_bid = current_bid - incDecValue;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.screenHeight * .2,
      color: Colors.white,
      margin: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 68.0),
      child: isCurrentBidFetched
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove,
                        color: Theme.of(context).accentColor,
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
                      iconSize: 32.0,
                      color: Theme.of(context).primaryColor,
                      onPressed: () => decreament(),
                    ),
                    Text(
                      '$current_bid' + ' ' + LocaleKeys.SAR.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xffF5BC50),
                        fontSize: 25.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).accentColor,
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
                      iconSize: 32.0,
                      color: Theme.of(context).primaryColor,
                      onPressed: () => increament(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                !isBiding
                    ? InkWell(
                        onTap: () => submitBid(),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Color(0xffF5BC50)),
                          child: Text(LocaleKeys.bid_now.tr()),
                        ),
                      )
                    : Container(
                        child: CircularProgressIndicator(),
                      )
              ],
            )
          : Center(
              child: Container(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }

  void submitBid() async {
    setState(() {
      isBiding = true;
    });
    DocumentSnapshot snapshot = await widget.chatReference.get();
    if (snapshot.exists && snapshot.data() != null) {
      DocumentSnapshot productSnapshot = await ((snapshot.data()
              as Map)['productReference'] as DocumentReference)
          .get();
      Map<String, dynamic> updateMap = new Map();
      updateMap.putIfAbsent('current_bid', () => current_bid);
      updateMap.putIfAbsent('last_bid_updated_by', () => auth.currentUser!.uid);
      productSnapshot.reference.update(updateMap);
    }
    setState(() {
      isBiding = false;
    });
    Navigator.pop(context);
  }
}
