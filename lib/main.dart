import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      initialRoute: MyHomePage.id,
      routes: {
        MyHomePage.id: (context) => MyHomePage(),
        Registration.id: (context) => Registration(),
        Login.id: (context) => Login(),
        Chat.id: (context) => Chat(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  static const String id = "HomeScreen";
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  width: 30,
                  child: Image.asset("lib/assets/logo.png"),
                ) 
              ),
              Text(
                "Maya Chat",
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            ]
          ),
          SizedBox(
                height: 50,
              ),
              CustomButton(
                text: "Log In",
                callback: (){
                  Navigator.of(context).pushNamed(Login.id);
                },
              ),
              CustomButton(
                text: "Register",
                callback: (){
                  Navigator.of(context).pushNamed(Registration.id);
                },
              )
        ]
      )
    );
  }
}

class CustomButton extends StatelessWidget{
  final VoidCallback callback;
  final String text;

  const CustomButton({Key key, this.callback, this.text}) : super(key : key);
  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.blueGrey,
        elevation: 6.0,
        borderRadius: BorderRadius.circular(30),
        child: MaterialButton(
          onPressed: callback,
          minWidth: 200.0,
          height: 45,
          child: Text(text),
        ),
      ),
    );
  }
}

class Registration extends StatefulWidget {
  static const String id = "Registration";

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  String email;
  String password;

  final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> registerUser() async{
    AuthResult result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password
    );
    FirebaseUser user = result.user;
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => Chat(
          user: user
        ),
      )
    );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maya Chat"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Hero(
              tag: "logo", 
              child: Container(
                width: 100,
                child: Image.asset("lib/assets/logo.png")
              )
            )
          ),
          SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => email = value,
              decoration: InputDecoration(
                hintText: "Enter Your Email",
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 95),
            child: TextField(
              autocorrect: false,
              obscureText: true,
              onChanged: (value) => password = value,
               decoration: InputDecoration(
                hintText: "Enter Your Password",
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
            child: CustomButton(
              text: "Register",
              callback: () async{
                await registerUser();
              },
            ),
          )
        ],
      ),
    );
  }
}

class Login extends StatefulWidget {
  static const String id = "Login";
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email;
  String password;

  final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> loginUser() async{
    AuthResult result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
    FirebaseUser user = result.user;
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => Chat(user: user),
      )
    );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maya Chat"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Hero(
              tag: "logo", 
              child: Container(
                width: 100,
                child: Image.asset("lib/assets/logo.png")
              )
            )
          ),
          SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => email = value,
              decoration: InputDecoration(
                hintText: "Enter Your Email",
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 95),
            child: TextField(
              autocorrect: false,
              obscureText: true,
              onChanged: (value) => password = value,
               decoration: InputDecoration(
                hintText: "Enter Your Password",
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
            child: CustomButton(
              text: "Log In",
              callback: () async{
                await loginUser();
              },
            ),
          )
        ],
      ),
    );
  }
}

class Chat extends StatefulWidget {
  static const String id = "Chat";
  final FirebaseUser user;

  const Chat({Key key, this.user}) : super(key : key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

Future<void> callback() async{
  if(messageController.text.length > 0){
    await
    _firestore.collection('messages').add(
      {
        'text': messageController.text,
        'from': widget.user.email,
      }
    );
    messageController.clear();
    scrollController.animateTo(
      scrollController.position.maxScrollExtent, 
      curve: Curves.easeOut,
      duration: Duration(milliseconds: 300),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Hero(
          tag: 'logo',
          child: Container(
            height: 40,
            child: 
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("lib/assets/logo.png"),
            ),
          )
        ),
        title: Text("Maya Chat"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close), 
            onPressed: () {
              _auth.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('messages').snapshots(),
                  builder: (context, snapshot){
                    if(!snapshot.hasData) 
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                    List<DocumentSnapshot> docs = snapshot.data.documents;

                    List<Widget> messages = docs.map(
                      (docs) => Message(
                        from: docs.data['from'],
                        text: docs.data['text'],
                        // owner: widget.user.email = docs.data['from'],
                      )
                    ).toList();

                    return ListView(
                      controller: scrollController,
                      children: <Widget>[
                        ...messages,
                      ],
                    );
                  }
                ),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        onSubmitted: (value) => callback(),
                        decoration: InputDecoration(
                        hintText: "Enter your Message...",
                        border: const OutlineInputBorder(),
                        ),
                        controller: messageController,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SendButton(
                      text: "Send",
                      callback: callback,
                    ),
                  )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SendButton({Key key, this.text, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.orange,
      onPressed: callback,
      child: Text(text)
    );
  }
}

class Message extends StatelessWidget {
  final String from;
  final String text;

  final bool owner = true;

  const Message({Key key, this.from, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: owner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            from,
          ),
          Material(
            color: owner ? Colors.blueGrey : Colors.red,
            borderRadius: BorderRadius.circular(10),
            elevation: 6,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 10, horizontal: 15
              ),
              child: Text(
                text,
              ),
            ),
          )
        ],
      ),
    );
  }
}