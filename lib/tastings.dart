import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pontozz/api.dart';
import 'package:pontozz/tasting_products.dart';

import 'globals.dart' as globals;

class Tastings extends StatefulWidget {
  const Tastings({Key? key, required this.client}) : super(key: key);
  final RestClient client;

  @override
  State<Tastings> createState() => _TastingsState();
}

class _TastingsState extends State<Tastings> {

  Future<List> _loadData() async {
    return await widget.client.tastings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text("Kóstolók"),
        centerTitle: true,
        leading: GestureDetector(
        child: Icon(Icons.arrow_back),
          onTap: () {
            Navigator.of(context).pop();
          },
        )),
        body: FutureBuilder(
          future: _loadData(),
          builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
          snapshot.hasData
              ? snapshot.data!.length == 0 ? Text('Jelenleg nincs aktív kóstoló') :
          ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, index) =>  GestureDetector(
              onTap: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TastingProducts(client: widget.client, tasting: snapshot.data![index])),
                  );
                });
              },
              child: Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                title: Text(snapshot.data![index].name, style: TextStyle(color: Colors.white)),
                //subtitle: Text(snapshot.data![index]['body']),
              ),
            ),
          )) : const Center(
            child: CircularProgressIndicator(),
          )
        )
    );
  }
}
