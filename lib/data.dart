import 'package:flutter/material.dart';
import 'dart:convert';

class data extends StatefulWidget {
  @override
  _dataState createState() => _dataState();
}

class _dataState extends State<data> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: FutureBuilder(
          future: DefaultAssetBundle.of(context).loadString('data/data.json'),
          builder: (context, snapshot) {
            var mydata = json.decode(snapshot.data.toString());
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Card(
                    child: Column(
                  children: [
                    GestureDetector(
                        onTap: () {
                          setState(() {});
                          print('pressed');
                        },
                        child: Text(mydata[index]['number'])),
                    Text(mydata[index]['date']),
                    Text(mydata[index]['month']),
                    Text(mydata[index]['year']),
                  ],
                ));
              },
              itemCount: mydata == null ? 0 : mydata.length,
            );
          },
        ),
      ),
    );
  }
}
