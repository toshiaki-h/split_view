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
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: SplitView(
        initialWeight: 0.7,
        children: [
          SplitView(
            viewMode: SplitViewMode.Horizontal,
            children: [
              Container(
                child: Center(child: Text("View1")),
                color: Colors.red,
              ),
              Container(
                child: Center(child: Text("View2")),
                color: Colors.blue,
              ),
              Container(
                child: Center(child: Text("View3")),
                color: Colors.green,
              ),
            ],
            onWeightChanged: (w) => print("Horizon: $w"),
          ),
          Container(
            child: Center(child: Text("View4")),
            color: Colors.purple,
          ),
          Container(
            child: Center(child: Text("View5")),
            color: Colors.yellow,
          ),
        ],
        viewMode: SplitViewMode.Vertical,
        onWeightChanged: (w) => print("Vertical $w"),
      ),
    );
  }
}
