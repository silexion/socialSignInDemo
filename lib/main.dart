
import 'dart:io';
import 'dart:ui';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/svg.dart';
import 'package:magic_text/magic_text.dart';
import 'package:pontozz/tastings.dart';

import 'globals.dart' as globals;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:pontozz/api.dart';
import 'package:pontozz/product_add.dart';
import 'package:pontozz/product_rating_view.dart';
import 'package:pontozz/search.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' hide ButtonStyle;
import 'package:preload_page_view/preload_page_view.dart';
import 'package:transparent_image/transparent_image.dart';
import 'constants.dart' as Constants;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

late SharedPreferences prefs;

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'profile'
  ],
);

void main() async {
  if (kIsWeb) {
    // initialiaze the facebook javascript SDK
    await FacebookAuth.i.webInitialize(
      appId: "1398168583987782",
      cookie: true,
      xfbml: true,
      version: "v13.0",
    );
  }

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

class MyApp extends StatelessWidget {
  //final plugin = FacebookLogin(debug: true);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Pontozz!',
      theme: ThemeData.dark(
        useMaterial3: true,

        /* colorSchemeSeed: Colors.indigo,

        //primarySwatch: Colors.indigo,
        hintColor: Colors.grey,
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(color: Colors.grey),
            ),
        ),
        toggleButtonsTheme: ToggleButtonsThemeData(focusColor: Colors.grey),
        textTheme: TextTheme(
          titleMedium: const TextStyle(
            color: Colors.white, // <-- TextFormField input color
          ),
            bodyMedium: TextStyle(color: Colors.white),
            bodySmall: TextStyle(color: Colors.white),
            displayMedium: TextStyle(color: Colors.white),
            labelMedium: TextStyle(color: Colors.white),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.black*/
      ).copyWith(
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            titleTextStyle: TextStyle(
                color: Color(0xFFd2ac67),
                fontFamily: 'Boxed',
                fontSize: 20.0
            )
        ),
        textTheme: ThemeData.dark().textTheme.copyWith(
          labelMedium: ThemeData.dark().textTheme.labelMedium?.copyWith(
              color: Color(0xffa8a8a8),
              fontSize: 16
          ),
          titleMedium: ThemeData.dark().textTheme.titleMedium?.copyWith(
            color: Color(0xFFd2ac67), // <-- TextFormField input color
          ),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: ThemeData.dark().textTheme.headlineSmall?.copyWith(
            color: Color(0xFFd2ac67), // <-- TextFormField input color
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
            focusedBorder: const OutlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
              borderSide: const BorderSide(color: Colors.grey, width: 2.0),
            ),
            contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8)
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          //style: ElevatedButton.styleFrom(onPrimary: Colors.white)
          //this themedata controls the
          style: ButtonStyle(
            //for some reason the MarterialStateProperty must be called to explicitly define types for buttons
            //ie: "MaterialStateProperty.all<Color>(const Color(0xFF50D2C2))" just allows "const Color(0xFF50D2C2)" to be used

            foregroundColor: MaterialStateProperty.all<Color>(Color(0xFFd2ac67)), //actual text color
            textStyle: MaterialStateProperty.all<TextStyle>(const TextStyle(
              //this determines the text style of the text displayed on buttons
              fontSize: 14,
              color: Color(0xFFd2ac67), //color not used
            ),),
            enableFeedback: true,
            //minimumSize: ,
          ),
        ),
      ),
      home: MyHomePage(title: ''/*, plugin: plugin*/),
    );
  }
}

class MyHomePage extends StatefulWidget {
  //final FacebookLogin plugin;

  MyHomePage({Key? key, required this.title/*, required this.plugin*/}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Item extends StatefulWidget {
  Product item;
  Tasting? tasting;
  RestClient client;
  final Function(int i) prevItem;
  final Function(int i) nextItem;
  List<Product> items;

  Item({required this.items, required this.item, required this.client, required this.prevItem, required this.nextItem, this.tasting});

  @override
  State<StatefulWidget> createState() {
    return ItemState();
  }
}

class ItemState extends State<Item> {

  late var pageNum = widget.items.indexOf(widget.item);
  late var pageController = PreloadPageController(initialPage: widget.items.indexOf(widget.item));

  updateItem(Product item) {
    setState(() {
      print('update'+pageNum.toString());
      widget.items[pageNum] = item;
      //print(item.ratings[0]);
    });

    //var i = widget.items.indexOf(item) + 1;
    //widget.nextItem(i);
  }

  prevItem(int p) {
    pageNum--;
    var i = widget.items.indexOf(widget.item) - 1;
    widget.item = widget.items[i];
    print('prev' +i.toString());
    pageController.jumpToPage(i);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(
                horizontal: 8.0, vertical: 4.0),
            child: Material(
                color: Colors.white.withOpacity(0.0),
                child : InkWell(
                    splashColor: Colors.black12,
                    radius: 100,
                    borderRadius: BorderRadius.circular(8),
                    // When the user taps the button, show a snackbar.
                    onTap: () {
                      if(widget.tasting != null && widget.tasting!.status == 0) return;

                      pageNum = widget.items.indexOf(widget.item);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) =>
                              PreloadPageView.builder(
                                itemCount: widget.items.length,
                                itemBuilder: (BuildContext context, int position) {
                                  var item = widget.items[position];
                                  if(widget.tasting != null)
                                    item.tasting_id = widget.tasting!.id;
                                  print('position');
                                  print(item.tasting_id);
                                  return ProductRatingView(
                                      data: item, pageController: pageController, client: widget.client, updateProduct: (item){updateItem(item);}, prevProduct: widget.prevItem);
                                },
                                onPageChanged: (int position) {
                                  setState(() {
                                    pageNum = position;
                                  });
                                  print('page'+position.toString());
                                },
                                preloadPagesCount: 3,
                                controller: pageController,
                              )));
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                          children: <Widget>[
                            ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: FadeInImage.memoryNetwork(
                                    fadeInDuration: Duration(milliseconds: 300),
                                    placeholder: kTransparentImage,
                                    image: Constants.IMAGE_URL + "thumbs/" + widget.item.image.toString(),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover
                                )),
                            Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  /*Text(widget.item.name.toString() ,
                            maxLines: 3,
                            softWrap: true,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)
                          )*/

                                  MagicText(widget.item.name.toString(),
                                    breakWordCharacter: '-',
                                    minFontSize: 12,
                                    maxFontSize: 16,
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16), smartSizeMode: true, asyncMode: true,
                                  ),

                                  Row(
                                      children: <Widget>[
                                        widget.item.ratings['0'] != null ? RatingBarIndicator(
                                          rating: widget.item.ratings['0'] != null ? widget.item.ratings['0']!.toDouble() : 0,
                                          itemBuilder: (context, index) => Icon(
                                            Icons.star,
                                            color: Color(0xFFd2ac67),
                                          ),
                                          itemCount: 5,
                                          itemSize: 20.0,
                                        ) : Text("M??g nem ??rt??kelted", style: TextStyle(
                                            color: Colors.grey)),
                                      ]),
                                  Text(widget.tasting!= null && widget.tasting!.status == 1 ? "" : widget.item.overall.toString())
                                ]
                                )),
                            //Text(event.value['date'] + ", " + event.value['location'])
                          ]),
                    )

                )))
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  //static final FacebookLogin facebookSignIn = new FacebookLogin();
  late GoogleSignInAccount? _currentUser;
  String? token;
  String provider = "";
  var signedIn = false;
  late Future<List>? _future = null;
  late RestClient client;
  ScrollController _controller = ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
  String? _sdkVersion;
  //FacebookAccessToken? _token;
  //FacebookUserProfile? _profile;
  String? _email;

  late List<Product> loaded;

  void apiLogin() {
    if(provider == "facebook") {
      apiToken(token);
    } else {
      _currentUser?.authentication.then((value) {
        print("Custom Log:" + value.accessToken.toString());
        //_login("google", value.accessToken.toString());
        var dio = Dio();
        final client = RestClient(dio);

        print('signedIn');
        print(signedIn);
        print('token');
        print(token);

        if (token == null || token == 'null') {
          setState(() {
            signedIn = false;
          });
        }
        apiToken(value.accessToken.toString());
      });
    }
  }

  void apiToken(socialToken) {
    if(!signedIn) {
      print('----------------TOKEN-------------------');
      print(socialToken);
      print(provider);
      client.login(socialToken, provider).then((value) {
        print(value);
        SharedPreferences.getInstance().then((prefValue) =>
            setState(() {
              prefValue.setString("token", value.accessToken);
              prefValue.setString("role", value.role);
              globals.role = value.role;
              prefValue.setBool("signedIn", true);
            })
        );

        setState(() {
          token = value.accessToken;
          signedIn = true;

          var dio = Dio();
          print('API TOKEN');
          print(token);
          dio.options.headers["Authorization"] = "Bearer "+token!;
          print(dio.options.headers["Authorization"]);
          client = RestClient(dio);

          _future = loadData();
        });
      }, onError: (err) {
        print('err');
        print(err);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (_controller.offset >= _controller.position.maxScrollExtent &&
          !_controller.position.outOfRange) {
        setState(() {//you can do anything here
        });
      }
      if (_controller.offset <= _controller.position.minScrollExtent &&
          !_controller.position.outOfRange) {
        setState(() {//you can do anything here
        });
      }
    });
    print("CHANGE");
    SharedPreferences.getInstance().then((prefValue) {

      if(prefValue.containsKey("signedIn")) {
        setState(() {
          signedIn = prefValue.getBool("signedIn")!;
          print(signedIn.toString());
        });
      }

      if(prefValue.containsKey("role")) {
        setState(() {
          globals.role = prefValue.getString("role")!;
          print(globals.role);
        });
      }

      if(prefValue.containsKey("provider")) {
        setState(() {
          provider = prefValue.getString("provider")!;
        });
      }

      token = prefValue.getString("token").toString();

      print('token: ' + token.toString());
      print('prodiver: ' + provider.toString());

      if(token == null || provider == "") {
        setState(() {
          signedIn = false;
          FlutterNativeSplash.remove();
        });
        //apiLogin();
      }

      eventBus.on<UpdateItemEvent>().listen((event) {
        print('event.index');
        print(event.index);
        setState(() {
          loaded[event.index] = event.item;
        });
      });

      signInSilent();
    });

    HttpOverrides.global = MyHttpOverrides();

    _googleSignIn.onCurrentUserChanged.listen((account) {
      print('USER_CHANGED');
      print(account);
      _currentUser = account;
      if(account != null) {
        setState(() {
          provider = "google";
          apiLogin();
          _future = loadData();
          signedIn = true;
          FlutterNativeSplash.remove();
        });
      } else {
        setState(() {
          signedIn = false;
          provider = "";
          FlutterNativeSplash.remove();
        });
      }

      SharedPreferences.getInstance().then((prefs) {
        prefs.setString("provider", provider);
      });
    });

    setState(() {
      SharedPreferences.getInstance().then((prefValue) {
        token = prefValue.getString("token").toString();

        var dio = Dio();
        dio.options.headers["Authorization"] = "Bearer "+token!;
        client = RestClient(dio);
        _future = loadData();
      });
    });
  }


  void signInSilent() async {
    if(provider == "google") {
      _googleSignIn.signInSilently().then((value) {

        if (value == null) {
          setState(() {
            signedIn = false;
          });
        }

        setState(() {
          FlutterNativeSplash.remove();
        });
      });
    } else {
      FlutterNativeSplash.remove();
    }
  }

  Future<List> loadData() async {
    return await client.getProducts();
  }

  void _login(String provider, String token) async {
    var dio = Dio();
    Map data = Map();
    data["access_token"] = token;
    data["provider"] = provider;
    try {
      Response response = await dio.post("https://pontozz.nextstep.hu/api/login",
          data: data, onSendProgress: (count, total) {
            print("Count:" + count.toString());
          });
      print(response.data);
    } on DioError catch (e) {
      print(e.response);
    }
  }

  Future<Null> _loginFBPressed() async {

    final LoginResult result = await FacebookAuth.instance.login(); // by default we request the email and the public profile

    if (result.status == LoginStatus.success) {
      // you are logged
      final AccessToken accessToken = result.accessToken!;
      setState(() {
        provider = "facebook";
        this.token = accessToken.token;
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString("provider", provider);
        });
      });
      apiLogin();
    } else {
      print(result.status);
      print(result.message);
    }

    await _updateLoginInfo();
  }

  Future<void> _handleSignOut() {
    setState(() {
      token = null;
      signedIn = false;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool("signedIn", false);
        prefs.remove('token');
      });
    });

    print("LOGOUT");
    client.logout();

    if(provider == "google")
      return _googleSignIn.signOut();
    else
      return FacebookAuth.instance.logOut();
  }

  Future<void> _updateLoginInfo() async {
    final userData = await FacebookAuth.instance.getUserData();

    setState(() {
      _email = userData["email"];
    });
  }


  nextItem(int i) {

  }

  prevItem(int i) {

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Pontozz!"),
      ),
      drawer: !signedIn ? null:Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text('Bejelentkezve'),
            ),
            ListTile(
              title: const Text('Term??k ??rt??kel??se'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductAddWidget(client: client)),
                );
              },
            ),
            ListTile(
              title: const Text('Keres??s'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchWidget(client: client)),
                );
              },
            ),
            ListTile(
              title: const Text('K??stol??k'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Tastings(client: client)),
                );
              },
            ),
            ListTile(
              title: const Text('Kijelentkez??s'),
              onTap: _handleSignOut,
            )
          ],
        ),
      ),
      body: signedIn ? FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container(height: 100, alignment: Alignment.topCenter, child: LinearProgressIndicator());
          } else {
            print(snapshot);
            if (snapshot.hasData) {
              loaded = snapshot.data;

              return ListView.builder(
                  physics: ClampingScrollPhysics(),
                  itemCount: loaded.length,
                  controller: _controller,
                  itemBuilder: (context, int i) {
                    return new Item(items: loaded, item: loaded[i], client: client, nextItem: (i){nextItem(i);}, prevItem: (i){prevItem(i);}, tasting: null) ;
                  }
              );
            }
            return Container();
          }
        },
      ) : Container(color: Color(0xFF231f20), child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Image.asset('assets/kvaterka2.png', height: 150),
          SizedBox(height: 50),
          //TextButton(child: const Text('Logout'), onPressed: () => _googleSignIn.signOut()),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: MaterialButton(
              color: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              padding: EdgeInsets.all(20.0),
              onPressed: () => _handleGoogleSignIn(),
              elevation: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/google.svg", color: Colors.white, height: 20,),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text("Bejelentkez??s Google fi??kkal"),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: MaterialButton(
              color: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              padding: EdgeInsets.all(20.0),
              onPressed: () => _loginFBPressed(),
              elevation: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.facebook, color: Colors.white),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text("Bejelentkez??s Facebook fi??kkal"),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: MaterialButton(
              color: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              padding: EdgeInsets.all(20.0),
              onPressed: () => _handleAppleSignIn(),
              elevation: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.apple, color: Colors.white),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text("Bejelentkez??s Apple fi??kkal"),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20)
        ],
      )),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      _googleSignIn.isSignedIn().then((value) async {
        if(value) _googleSignIn.signOut();
        await _googleSignIn.signIn();
      });

    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleAppleSignIn() async {
    try {
      final AuthorizationResult result = await TheAppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      switch (result.status) {
        case AuthorizationStatus.authorized:

          setState(() {
            provider = "apple";
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString("provider", provider);
            });
          });
          apiLogin();
          break;
        case AuthorizationStatus.error:
          print("Sign in failed: ${result.error!.localizedDescription}");
          break;

        case AuthorizationStatus.cancelled:
          print('User cancelled');
          break;
      }
      /*final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId:
          'com.parkmobil.pontozz.auth',
          redirectUri:
          Uri.parse(
            'https://pontozz.nextstep.hu',
          ),
        ),
      );*/

    } catch (error) {
      print(error);
    }
  }
}
