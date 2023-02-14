import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pontozz/api.dart';
import 'package:pontozz/full_screen_image.dart';
import 'package:pontozz/product_rating_view.dart';
import 'package:pontozz/review_item.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'constants.dart' as Constants;
import 'globals.dart' as globals;

class SearchWidget extends StatefulWidget {
  const SearchWidget({Key? key, required this.client}) : super(key: key);
  final RestClient client;

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {

  final barcodeController = TextEditingController();
  Product? product;
  static const _pageSize = 20;

  final PagingController<int, Review> _pagingController =
  PagingController(firstPageKey: 0);
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchReviewsPage(pageKey);
    });
    _dialog = SimpleFontelicoProgressDialog(context: context);
    super.initState();
  }

  Future<void> _fetchReviewsPage(int pageKey) async {
    try {
      final newItems = await widget.client.getReviews(pageKey, _pageSize, product!.id!);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }


  Future<Widget> buildProductView() async
  {
    List<Widget> list = [];

    List<Widget> params = [];

    if(product != null) {


      if(product!.category != null) {
        params.add(Text(product!.category!.name!));
      }

      if(product!.manufacturer != null) {
        params.add(Text(product!.manufacturer!));
      }

      if(product!.country != null) {
        params.add(Text(product!.country!));
      }

      params.add(Row(children: [
        RatingBarIndicator(
            rating: product!.overall != null ? double.parse(product!.overall!) : 0,
            itemCount: 5,
            itemSize: 20.0,
            itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Color(0xFFd2ac67),
            )
        ),
        Text(product!.overall != null ? product!.overall! : "")
      ])
      );


      list.add(Text(product!.name!, style: Theme.of(context).textTheme.headlineSmall,));
      list.add(SizedBox(height: 10));
      list.add(Row(children: [
        Column(children: params, crossAxisAlignment: CrossAxisAlignment.start),
        Spacer(),
        GestureDetector(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              Constants.IMAGE_URL + 'thumbs/' + product!.image!.toString(),
              fit: BoxFit.cover,
              width: 80,
              height: 80,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            )
          ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) {
                    return FullScreenImage(
                      imageUrl: Constants.IMAGE_URL + product!.image.toString(),
                      tag: product!.image.toString(), key: null,
                    );
                  })
              );
            }
        )
      ],));

      list.add(SizedBox(height: 20));
      list.add(Text("Vélemények"));
      list.add(SizedBox(height: 10));
      list.add(PagedListView<int, Review>.separated(
        
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Review>(
          itemBuilder: (context, item, index) => ReviewItem(review: item),
          //itemBuilder: (context, item, index) => Text(item.review!, style: TextStyle(fontStyle: FontStyle.italic)),
            noItemsFoundIndicatorBuilder: (_) => Text('Még nincs vélemény'),
        ), separatorBuilder: (context, index) => const Divider()));
    }

    return  Align( alignment: Alignment.topLeft, child: Column(children: list, crossAxisAlignment: CrossAxisAlignment.start));
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
        title: Text("Keresés"),
        centerTitle: true,
        leading: GestureDetector(
          child: Icon(Icons.arrow_back),
          onTap: () {
            Navigator.of(context).pop();
          },
        )
      ),
      body: SingleChildScrollView(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(children: [
          Form(
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  style: TextStyle(color: Color(0xFFd2ac67)),
                  controller: barcodeController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Keresés...',
                  ),
                ),
                minCharsForSuggestions: 2,
                suggestionsCallback: (pattern) async {
                  if(pattern != "")
                    return await widget.client.productSearch(pattern);
                  else return [];
                },
                noItemsFoundBuilder: (value) {
                  return Text("", style: TextStyle(height: 0),);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion.toString()),
                    //subtitle: Text('\$${suggestion['price']}'),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  var name = suggestion.toString();
                  barcodeController.text = "";
                  _dialog.show(message: 'Betöltés...', backgroundColor: Colors.black26);

                  widget.client.getProductByName(name).then((product) {
                    if (name != "") {
                      setState(() {
                        this.product = product;
                        _pagingController.refresh();
                        _dialog.hide();
                      });
                    }
                  });
                },
              ),
            ),
            IconButton(icon: Icon(Icons.camera, size: 30), onPressed: () async {
              /*Map barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                  "#000000",
                  "Mégse",
                  true,
                  ScanMode.DEFAULT);*/
              String barcode = await FlutterBarcodeScanner.scanBarcode(
                  "#000000",
                  "Mégse",
                  true,
                  ScanMode.DEFAULT );
  
              //var barcode = barcodeScanRes["data"].toString();
              barcodeController.text = "";
              if(barcode.length > 0) {

                _dialog.show(message: 'Betöltés...', backgroundColor: Colors.black26);

                widget.client.getProductByBarcode(barcode).then((product) {
                  setState(() {
                    this.product = product;
                    _dialog.hide();
                  });
                }, onError: (error, stackTrace) {
                  setState(() {
                    _dialog.hide();
                    //countryController.text = globals.countryFromBArcode(barcode, type);
                  });
                }) ;
              }
            })
            ]
           )
      ),
          SizedBox(height: 20),
          FutureBuilder<Widget>(
            future: buildProductView(),
            builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
              }
              return snapshot.hasData
                  ? Container(
                child: snapshot.data,
              ) : Container();
            },
          ),
      ])
    )
    ),
    );
  }
}
