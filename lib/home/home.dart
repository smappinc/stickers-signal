import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_app/util/constants.dart';
import 'package:web_app/util/my_fab.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List stickers = new List<Map>();
  bool isLoading = true;
  String _outputText = '';

  @override
  void initState() {
    // Set the flag as true
    super.initState();
    getAllStickers();
    initOneSignal();
  }

  Future<void> initOneSignal() async {
    OneSignal.shared.init("e35eafa7-2b43-491b-9b50-82e87676a0cc", iOSSettings: {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.inAppLaunchUrl: false
    });
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    await OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);
  }

  Future<void> getAllStickers() async {
    final status = await AppTrackingTransparency.requestTrackingAuthorization();
    String url = "https://smappinc.github.io/data/stickerapi.json";
    var response = await get(url);
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      stickers = jsonDecode(response.body);
    } else {
      Constants.showDialog('Cannot connect to server');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text(
          "Home",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [],
      ),
      body: Container(
          margin: EdgeInsets.symmetric(vertical: 5.0),
          child: (isLoading)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: stickers.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return stickerCell(stickers[index]);
                  })),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: MyFab(),
      ),
    );
  }

  Widget stickerCell(Map sticker) {
    return GestureDetector(
      child: Container(
          height: 170,
          padding: EdgeInsets.all(10.0),
          margin: EdgeInsets.only(top: 15, left: 15, right: 15),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 100,
                margin: EdgeInsets.only(left: 20, right: 20),
                //color: Colors.red,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        width: 60,
                        height: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: CachedNetworkImage(
                              imageUrl: sticker['imageurl'], fit: BoxFit.cover),
                        )),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          sticker['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                width: double.infinity,
                padding:
                    EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue[900],
                ),
                child: Center(
                    child: Text(
                  'Add Sticker Pack to Signal',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
              ),
            ],
          )),
      onTap: () async {
        launch(sticker['url']);
      },
    );
  }

  Widget homeDrawer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Ezrevize"),
            accountEmail: Text("support.ezrevize@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                  ? Colors.white
                  : Colors.white,
              child: Text(
                'EZ',
                style: TextStyle(fontSize: 40.0, color: Colors.blue),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.account_circle_rounded,
              color: Colors.blue,
              size: 30.0,
            ),
            title: Text(
              'Login',
              style: TextStyle(color: Colors.blue),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.account_circle_rounded,
              color: Colors.blue,
              size: 30.0,
            ),
            title: Text(
              'My Profile',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
