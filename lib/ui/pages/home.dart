import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//TODO List out items from Firestore with image using the state management solution you have integrated
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeProvider>(
      create: (context) => HomeProvider(),
      child: Builder(
        builder: (context) {
          HomeProvider _provider = Provider.of<HomeProvider>(context);
          return Scaffold(
              appBar: AppBar(
                title: Text("Home"),
                leading: Icon(Icons.home),
                backgroundColor: Colors.blueAccent,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/addPage');
                  _provider.refresh();
                },
                child: Icon(Icons.add),
              ),
              body: Container());
        },
      ),
    );
  }
}

class HomeProvider with ChangeNotifier {
  refresh() {
    notifyListeners();
  }
}
