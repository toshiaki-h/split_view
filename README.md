# Splitter view plugin

A splitter view for flutter.

## Usage
To use this plugin, add split_view as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Example
```dart
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SplitView(
        initialWeight: 0.7,
        minHeightSidebar: 300,
        maxHeightSidebar: 400,
        view1: SplitView(
          viewMode: SplitViewMode.Horizontal,
          minWidthSidebar: 300,
          maxWidthSidebar: 400,
          view1: Container(
            child: Center(child: Text("View1")),
            color: Colors.red,
          ),
          view2: Container(
            child: Center(child: Text("View2")),
            color: Colors.blue,
          ),
        ),
        view2: Container(
          child: Center(
            child: Text("View3"),
          ),
          color: Colors.green,
        ),
        viewMode: SplitViewMode.Vertical,
      ),
    );
  }
}
```

## ToDo
- Add tests.
- Aim to enhance documents.
- and more...