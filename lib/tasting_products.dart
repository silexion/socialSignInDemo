import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pontozz/api.dart';
import 'package:pontozz/main.dart';

import 'globals.dart' as globals;

class TastingProducts extends StatefulWidget {
  const TastingProducts({Key? key, required this.client, required this.tasting}) : super(key: key);
  
  final RestClient client;
  final Tasting tasting;

  @override
  State<TastingProducts> createState() => _TastingProductsState();
}

class _TastingProductsState extends State<TastingProducts> {

  late List<Product> loaded;
  late Future<List> _future;
  ScrollController _controller = ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);

  nextItem(int i) {

  }

  prevItem(int i) {

  }

  Future<List> loadData() async {
    return await widget.client.tastingProducts(widget.tasting.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text(widget.tasting.name),
        centerTitle: true,
        leading: GestureDetector(
          child: Icon(Icons.arrow_back),
          onTap: () {
            Navigator.of(context).pop();
          },
        )),
        body: FutureBuilder(
          future: loadData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container(height: 100, alignment: Alignment.topCenter, child: LinearProgressIndicator());
            } else {
              print(snapshot);
              if (snapshot.hasData) {
                loaded = snapshot.data;

                return ListView.builder(
                    key: Key("Your Key"),
                    physics: ClampingScrollPhysics(),
                    itemCount: loaded.length,
                    controller: _controller,
                    itemBuilder: (context, int i) {
                      var item = loaded[i];
                      //if(widget.tasting != null)
                        //item.tasting_id = widget.tasting!.id;

                      return new Item(items: loaded, item: item, client: widget.client, nextItem: (i){nextItem(i);}, prevItem: (i){prevItem(i);}, tasting: widget.tasting) ;
                    }
                );
              }
              return Container();
            }
          },
        )
    );
  }
}
