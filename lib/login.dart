import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'config/app.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';


GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
  ],
);

class Login extends StatefulWidget {
  const Login({ Key key }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  bool isLogin = false;
  String nama = "";

  @override
  initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() { 
      print("completed");
      setState(() {
      });
    });

    this.checkLogin();
  }

  Future<void> checkLogin() async{
    var checkUser = await FirebaseAuth.instance.currentUser;
    if(checkUser!=null){
      setState(() {
        isLogin = true;
        nama = checkUser.displayName;
      });
    }
  }

  Future<void> _handleLogout()async{
    await _googleSignIn.signOut();
    setState(() {
      isLogin = false;
      nama = "";
    });
  }

  Future<void> _handleSignIn() async {
    try {
      final userGoogle = await _googleSignIn.signIn();
      if(userGoogle==null){
        return;
      }

      setState(() {
        isLogin = true;
        nama = userGoogle.displayName;
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> doLogin() async{
    var urlApi = Uri.https(Config().urlApi, '/public/api/login');

    http.post(
      urlApi,
      body: {
        'user_name': username.text,
        'user_password': password.text,
      }
    ).then((http.Response response) {
      if(response.statusCode==401){
        // logout(context);
      }else{
        Map<String, dynamic> result = json.decode(response.body);
        if (result['status'] == 'success') {
          this.saveToken(result['api_key']);
        } else {
          Toast.show("Username dan Password salah", context, duration: 10000);
        }
      }
    });
  }

  Future<void> saveToken(token) async{
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString('token', token);
    // Navigator.pushReplacement(context,
    //     MaterialPageRoute(builder: (BuildContext context) {
    //   return Home();
    // }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.red[400],
        title: Text("Sign in", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 8, right: 8, bottom: 15),
                child: 
                (isLogin) ? 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Hai, "+nama, style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold,) ,),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Logout", style: TextStyle(color: Colors.white),),
                          ],
                        ),
                        onPressed: () {
                          this._handleLogout();
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red[600]),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )
                          )
                        )
                      ),
                    )
                  ],
                )
                
                : 
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Login with Google", style: TextStyle(color: Colors.white),),
                          ],
                        ),
                        onPressed: () {
                          this._handleSignIn();
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red[600]),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )
                          )
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Align(alignment: Alignment.center ,child: Text("Atau", style: TextStyle(color: Colors.grey[700]),)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text("Username", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),),
                    ),
                    TextField(
                      controller: username,
                      decoration: InputDecoration(
                        hintText : 'Username',
                        filled: true,
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        prefixIcon: Icon(Icons.people)
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text("Password", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),),
                    ),
                    TextField(
                      obscureText: true,
                      controller: password,
                      decoration: InputDecoration(
                        hintText : 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        prefixIcon: Icon(Icons.lock)
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: ElevatedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Log In", style: TextStyle(color: Colors.white),),
                          ],
                        ),
                        onPressed: () {
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red[300]),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )
                          )
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}