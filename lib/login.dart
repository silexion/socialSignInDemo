import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'profile'
  ],
);

Future<void> _handleSignIn() async {
  try {
    await _googleSignIn.signIn();
  } catch (error) {
    print(error);
  }
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(
              "https://www.xda-developers.com/files/2018/02/Flutter-Framework-Feature-Image-Red.png"),
          minRadius: MediaQuery.of(context).size.width / 4,
        ),
        SizedBox(
          height: 280,
        ),
        //TextButton(child: const Text('Logout'), onPressed: () => _googleSignIn.signOut()),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            padding: EdgeInsets.all(10.0),
            onPressed: () => _handleSignIn(),
            color: Colors.white,
            elevation: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://storage.googleapis.com/gd-wagtail-prod-assets/original_images/evolving_google_identity_videoposter_006.jpg"),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text("Login with Google"),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            padding: EdgeInsets.all(10.0),
            //onPressed: () => _loginFB(),
            color: Colors.white,
            elevation: 5,
            onPressed: () {  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://i.pinimg.com/originals/1b/99/43/1b9943ad6de248c23a430fa07b0ec5bd.png"),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text("Login with Facebook"),
                ),
              ],
            ),
          ),
        ),
      ],
    ),);
  }
}
