import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/models/productModel.dart';
import 'package:wean_app/models/yardItemModel.dart';
import 'package:wean_app/services/firebaseServices.dart';
import 'package:wean_app/translations/locale_keys.g.dart';
import 'package:wean_app/widgets/listviews.dart';
import 'package:wean_app/widgets/textViews.dart';
import 'package:easy_localization/easy_localization.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ProductModel> products = [];

  FirebaseDBServices dbServices = FirebaseDBServices();

  late String ownerId;

  @override
  void initState() {
    loadHistory();
    super.initState();
  }

  loadHistory() async {
    ownerId = FirebaseAuth.instance.currentUser!.uid;
    await dbServices.loadItemsByUserId(ownerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: Stack(
          // clipBehavior: Clip.none,
          children: [
            Container(
              height: 100,
              color: AppTheme.primaryStartColor,
              child: Center(
                child: TextAppName(),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 80,
                bottom: kBottomNavigationBarHeight,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Container(
                    color: Colors.white,
                    child: StreamBuilder<QuerySnapshot?>(
                      stream: dbServices.itemDataStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text(LocaleKeys.error_loading_item.tr()));
                        }
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.connectionState == ConnectionState.none) {
                          return Center(
                            child: SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          );
                        }
                        if (snapshot.data == null ||
                            snapshot.data!.docs.isEmpty) {
                          return Center(child: Text(LocaleKeys.no_data_found.tr()));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(0),
                          itemBuilder: (context, index) {
                            // print("data ${snapshot.data!.docs.length}");
                            var jsonData = snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                            String? indexId = snapshot.data!.docs[index].id;
                            YardItem product = YardItem.fromJson(jsonData);
                            return ListYardItems(
                              item: product,
                              isHistory: true,
                              indexID: indexId,
                            );
                          },
                          itemCount: snapshot.data?.docs.length,
                        );
                      },
                    )),
              ),
            ),
          ],
        ));
  }
}
