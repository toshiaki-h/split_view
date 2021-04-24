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
        leading: SplitView(
          viewMode: SplitViewMode.Horizontal,
          leading: Container(
            child: Center(child: Text("View1")),
            color: Colors.red,
          ),
          trailing: Container(
            child: Center(child: Text("View2")),
            color: Colors.blue,
          ),
          onWeightChanged: (w) => print("Horizon: $w"),
        ),
        trailing: Container(
          child: Center(
            child: Text("View3"),
          ),
          color: Colors.green,
        ),
        viewMode: SplitViewMode.Vertical,
        onWeightChanged: (w) => print("Vertical $w"),
      ),
    );
  }
}
