import 'package:busca_imagens_movidas_repetidas/ui/gif_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
const request = "API_URL";

Future<void> main() async {
  await dotenv.load(fileName: "dotenv.env");

  runApp(MaterialApp(
    title: "Busca gifes",
    theme: ThemeData(hintColor: Colors.white),
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {

  String _search = "";
  int _offset = 0;
  Future<Map> _getGifs() async{
    http.Response response;
    if(_search == ""){
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/trending?api_key=" + dotenv.env['API_KEY']! + "&limit=25&offset=$_offset&rating=G"));
    } else{
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/search?api_key="+ dotenv.env['API_KEY']! + "&q=$_search&limit=25&offset=$_offset&rating=G&lang=en"));
    }
    return json.decode(response.body);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Image.network('https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body:
        Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(15.0),
                child: TextField(
                  onSubmitted: (text) {
                    setState(() {
                      _search = text;
                      _offset = 0;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "O que quer pesquisar?",
                    labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 3, color: Colors.white)
                      ),
                      border: OutlineInputBorder()
                  ),
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                  textAlign: TextAlign.center,
                ),
            ),
            Expanded(
                child: FutureBuilder(
                  future: _getGifs(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState){
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Container(
                          width: 200.0,
                          height: 200.0,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 5.0,
                          )
                        );
                      default:
                        if (snapshot.hasError) return Container();
                        else
                          return _createGifTable(context, snapshot);
                    }
                  },
                )
            )
          ],
        ),
    );
  }
  Widget _createGifTable(context, snapshot){
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0
        ),
       itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index){
          if (_search == null || index < snapshot.data["data"].length){
          return (GestureDetector(
            child: Image.network(
                snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300.0,
                fit: BoxFit.cover,
               ),
                onTap: () {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))
                  );
                },
                onLongPress: () {
                  Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"], subject: "See this new gif I found");
                },
            )
          );
          }
          else return (Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.white, size: 70.0,),
                  Text("Carregar mais...",
                    style: TextStyle(color: Colors.white, fontSize: 22.0),
                  )
                ],
              ),
              onTap: (){
                setState(() {
                  _offset += 25;
                });
              },
            ),
          ));
      },
    );
  }
  int _getCount(List data){
    if (_search == null) return data.length;
    else return data.length + 1;
  }
}
