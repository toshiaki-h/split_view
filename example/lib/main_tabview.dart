import 'package:flutter/material.dart';
import 'package:split_view/split_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<int> items = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 10; i++) {
      items.add(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            tabs: [
              Tab(text: "Tab1"),
              Tab(text: "Tab2"),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            SplitView(
              key: PageStorageKey(0),
              initialWeight: 0.7,
              view1: SplitView(
                key: PageStorageKey(1),
                viewMode: SplitViewMode.Horizontal,
                view1: Container(
                  child: Center(child: Text("View1")),
                  color: Colors.red,
                ),
                view2: Container(
                  child: Center(child: Text("View2")),
                  color: Colors.blue,
                ),
                onWeightChanged: (w) => print("Horizon: $w"),
              ),
              view2: Container(
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text("Item ${items[index]}"),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: items.length),
                color: Colors.green,
              ),
              viewMode: SplitViewMode.Vertical,
              onWeightChanged: (w) => print("Vertical $w"),
            ),
            Container(
              child: Center(
                child: Text("Tab2 content"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
