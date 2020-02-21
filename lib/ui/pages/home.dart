import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  List<Widget> _loading = [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(child: CircularProgressIndicator()),
    ),
  ];
  double _screenHeight, _screenWidth = 0;
  bool _init = false;
  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider<HomeProvider>(
      create: (context) => HomeProvider(),
      child: Builder(
        builder: (context) {
          HomeProvider _provider = Provider.of<HomeProvider>(context);
          if (_init == false) {
            _init = true;
            _provider.setChildren = _loading;
            Future.delayed(Duration(seconds: 1)).then((_) {
              setItems(_provider);
            });
          }
          return Scaffold(
              appBar: AppBar(
                title: Text("Home"),
                leading: Icon(Icons.home),
                backgroundColor: Colors.blueAccent,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/addPage');
                  _provider.setChildren = _loading;
                  Future.delayed(Duration(seconds: 1)).then((_) {
                    setItems(_provider);
                  });
                },
                child: Icon(Icons.add),
              ),
              body: ListView(
                  // children: _provider.children,
                  children: _provider.children));
        },
      ),
    );
  }

  //single item widget
  Padding item(
      {@required String title, @required String description, String imageUrl}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: _screenWidth * 0.025, vertical: _screenHeight * 0.025),
      child: Container(
        height: _screenHeight / 5,
        width: _screenWidth * 0.95,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: Offset(2, 2),
                  color: Colors.grey),
            ],
            borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.all(5),
        child: Row(
          children: <Widget>[
            //for image title and image
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: _screenHeight / 7,
                  width: _screenWidth * .5,
                  decoration: BoxDecoration(
                      image: DecorationImage(image: NetworkImage(imageUrl))),
                )
              ],
            ),
            Container(
              height: 50,
              width: 5,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [BoxShadow()]),
            ),
            //for description
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(5),
                child: Text(description,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12)),
              ),
              // color: Colors.blue,
            )
          ],
        ),
      ),
    );
  }

  //fetch items and assign to list
  setItems(HomeProvider _provider) {
    Firestore.instance.collection('Items').getDocuments().then((snapshots) {
      List<Widget> _tempList = List<Widget>();
      for (var each in snapshots.documents) {
        _tempList.add(item(
            title: each.data['title'],
            description: each.data['description'],
            imageUrl: each.data['image_url']));
      }
      _provider.setChildren = _tempList;
      _provider.refresh();
    });
  }
}

class HomeProvider with ChangeNotifier {
  List<Widget> _children = [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(child: CircularProgressIndicator()),
    ),
  ];
  get children => _children;
  set setChildren(List<Widget> children) {
    this._children = children;
  }

  refresh() {
    notifyListeners();
  }
}
