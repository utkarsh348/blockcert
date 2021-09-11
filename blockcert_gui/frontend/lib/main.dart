import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter/foundation.dart';

final bool enableInteractiveSelection = true;
void main() {
  runApp(strt());
}

class Keys {
  String? pubkey;
  String? privkey;
  Keys(this.pubkey, this.privkey);

  Keys.fromJson(Map<String, dynamic> json)
      : pubkey = json["PublicKey"],
        privkey = json["PrivateKey"];
}

class strt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
  return MaterialApp(
        home: Scaffold(
          body: Text("Welcome to\nBlockcert"),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => addCert())
                        );
              },
              splashColor: Colors.black87,
              child: const Icon(Icons.add),
              focusColor: Colors.black87,
              hoverColor: Colors.blueGrey,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              color: Colors.black87,
              child: IconTheme(
                data: IconThemeData(
                    color: Theme.of(context).colorScheme.onPrimary),
                child: Row(children: <Widget>[
                  //const Spacer(),
                  //const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.approval_outlined),
                    tooltip: 'Check certificate',
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => verify())
                        );
                    },
                    icon: const Icon(Icons.linear_scale_rounded),
                    tooltip: 'Keygen',
                  )
                ]
              ),
            ),
          )
        )
      );
  }
}


class verify extends StatefulWidget {
  const verify({ Key? key }) : super(key: key);

  @override
  _verifyState createState() => _verifyState();
}

class _verifyState extends State<verify> {
  Future<List<Keys>> keys() async {
    var url = "http://localhost:8080/keygen";
    var response = await http.get(Uri.parse(url));


    List<Keys> keylist = [];
        if (response.statusCode == 200) {
          // Map<String, dynamic> keylist = new Map<String, dynamic>.from(convert.jsonDecode(response.body));
          keylist.add(Keys.fromJson(convert.jsonDecode(response.body)));
        }
        return keylist;
  }
  FutureBuilder<List<Keys>> fkey(){
    var futureKey = keys();
    return FutureBuilder<List<Keys>>(
      future: futureKey,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      var keysgens = "Public: "+snapshot.data[0].pubkey+"\n\n"+"Private: "+snapshot.data[0].privkey;
      return Text(keysgens);
    } else if (snapshot.hasError) {
      return Text('${snapshot.error}');
    }
    return const CircularProgressIndicator();
    },
  );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text("Verification"), 
        ),
        body: fkey()  
    );
  }
}



class addCert extends StatefulWidget {
  const addCert({ Key? key }) : super(key: key);

  @override
  _addCertState createState() => _addCertState();
}

class _addCertState extends State<addCert> {

  createPost(String title, String key) async {
    debugPrint(key);
    var url = 'http://localhost:8080/new_cert';
    var req = http.MultipartRequest('POST', Uri.parse(url));

    req.files.add(
    http.MultipartFile.fromBytes(
      'picture',
      File(title).readAsBytesSync(),
      filename: title.split("/").last
    )
  );
  req.fields['PrivateKey'] = key;
  var res = await req.send();
}

  
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  Future<Text>? _futureres;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Data Example'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: (_futureres == null) ? buildColumn() : buildFutureBuilder(),
        ),
      );
  }
  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: _controller1,
          decoration: const InputDecoration(hintText: 'Enter File Name'),
        ),
        TextField(
          controller: _controller2,
          decoration: const InputDecoration(hintText: 'Enter private key'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              createPost(_controller1.text,_controller2.text);
            });
              
            
          },
          child: const Text('Create Data'),
        ),
      ],
    );
  }

  FutureBuilder<Text> buildFutureBuilder() {
    return FutureBuilder<Text>(
      future: _futureres,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.toString());
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}




