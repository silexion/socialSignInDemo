import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pontozz/api.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pontozz/full_screen_image.dart';
import 'package:pontozz/product_rating_view.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:toggle_switch/toggle_switch.dart';
import 'constants.dart' as Constants;
import 'events.dart';
import 'globals.dart' as globals;

class ProductAddWidget extends StatefulWidget {
  const ProductAddWidget({Key? key, required this.client}) : super(key: key);
  final RestClient client;

  @override
  State<ProductAddWidget> createState() => _ProductAddWidgetState();
}

class _ProductAddWidgetState extends State<ProductAddWidget> {

  XFile? image;
  Product data = Product(ratings: {}, ratingInfo: {'1':'0'}, criterias: []);
  late Future<List<Category>> categories;

  final ImagePicker picker = ImagePicker();
  Map<int, String> criteriaOptions = new Map();

  List<bool> selectedYesNoOptions = <bool>[true, false];

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);

    setState(() {
      image = img;
    });
  }

  Future<XFile> getImageXFileByUrl(String url) async {
    var file = await DefaultCacheManager().getSingleFile(url);
    XFile result = XFile(file.path);
    return result;
  }

  Future<Widget> buildRatingViews() async
  {
    List<Widget> list = [];
    List<Criteria> criterias = data.category == null ? [] : [...data.category!.criterias];
    data.criterias = criterias ;
    criterias.add(Criteria(id: 0, name: 'Összbenyomás'));

    for(var i = 0; i < criterias.length; i++){
      list.add(SizedBox(height: 15));
      list.add(Text(criterias[i].name.toString().toUpperCase(),));
      list.add(RatingBar.builder(
        unratedColor: Colors.black,
        initialRating: data.ratings.containsKey(criterias[i].id.toString()) ? data.ratings[criterias[i].id.toString()]!.toDouble() : 0.0,
        minRating: 1,
        itemCount: 5,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Color(0xFFd2ac67),
        ),
        onRatingUpdate: (rating) {
          data.ratings[criterias[i].id!.toString()] = rating.toInt();

          if(criterias[i].id != 0) {
            setState(() {
              switch (rating.toInt()) {
                case 1:
                  criteriaOptions[criterias[i].id!] = criterias[i].option1!;
                  break;
                case 2:
                  criteriaOptions[criterias[i].id!] = criterias[i].option2!;
                  break;
                case 3:
                  criteriaOptions[criterias[i].id!] = criterias[i].option3!;
                  break;
                case 4:
                  criteriaOptions[criterias[i].id!] = criterias[i].option4!;
                  break;
                case 5:
                  criteriaOptions[criterias[i].id!] = criterias[i].option5!;
                  break;
              }
            });
          }
        },
      ));
      list.add(Text(criteriaOptions[criterias[i].id!] != null ? criteriaOptions[criterias[i].id!].toString() : "",
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: TextStyle(color: Color(0xFFd2ac67))));
    }
    return new Column(children: list);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      categories = getCategories();
    });
  }

  void mediaSelectDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Kép feltöltése', style: TextStyle(fontSize: 18)),
            content: Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    style: ButtonStyle(minimumSize: MaterialStateProperty.all(Size(200, 50))),
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery);
                    },
                    icon: Icon(Icons.image),
                    label: Text('Galériából'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ButtonStyle(minimumSize: MaterialStateProperty.all(Size(200, 50))),
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.camera);
                    },
                    icon: Icon(Icons.camera),
                    label: Text('Kamerával'),
                  ),
                ],
              ),
            ),
          );
        });
  }

  final nameController = TextEditingController();
  final manufacturerController = TextEditingController();
  final countryController = TextEditingController();
  final reviewController = TextEditingController();
  final descriptionController = TextEditingController();
  final barcodeController = TextEditingController();
  var readOnly = false;
  List<String> names = [];

  final _formKey = GlobalKey<FormState>();

  void showProduct(Product product) {
    setState(() {
      data.id = product.id;
      data.ratings = product.ratings;
      data.ratingInfo = product.ratingInfo;
      data.image = product.image;
      data.category = product.category as Category;
      data.category_id = product.category!.id;
      data.review = product.review;

      if(globals.role != 'admin') readOnly = true;
    });

    getImageXFileByUrl(Constants.IMAGE_URL + "thumbs/" + product.image.toString()).then((value) {
      setState(() {
        image = value;
      });
    });

    barcodeController.text = product.barcode!;
    nameController.text = product.name!;

    if(product.manufacturer != null)
      manufacturerController.text = product.manufacturer!;

    if(product.country != null)
      countryController.text = product.country!;

    if(product.description != null)
      reviewController.text = product.description!;
  }

  @override
  Widget build(BuildContext context) {
    //Navigator.pop(context);
    return Scaffold(
        appBar: AppBar(
            title: Text("Termék értékelése"),
            centerTitle: true,
            leading: GestureDetector(
              child: Icon(Icons.arrow_back),
              onTap: () {
                Navigator.of(context).pop();
              },
            )),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                /*for (var criteria in data.category!.criterias) {
                  if (!data.ratings.containsKey(criteria.id.toString())) {
                    Fluttertoast.showToast(
                        msg: "Nem adtad meg az összes értékelést.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                    return;
                  }
                }*/

                if (image == null) {
                  Fluttertoast.showToast(
                      msg: "Válaszd ki a képet.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                  return;
                }

                data.name = nameController.text.toString();
                data.manufacturer = manufacturerController.text.toString();
                data.description = reviewController.text.toString();
                data.country = countryController.text.toString();
                data.barcode = barcodeController.text.toString();

                SimpleFontelicoProgressDialog _dialog = SimpleFontelicoProgressDialog(context: context);

                if(globals.role == "user" && data.id != null) {

                  Navigator.of(context).pop();
                  Future.delayed(Duration.zero, () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) =>
                            ProductRatingView(
                              data: data, client: widget.client, pageController: null, updateProduct: (Product p) {  },
                            )
                        ));
                  });
                } else {
                  _dialog.show(message: 'A feltöltés folyamatban...', backgroundColor: Colors.black26);
                  Future<ProductResponse> saveFuture = /*data.id != null && globals.role == "user" ?
                  widget.client.sendRating(
                      data
                  ) : */
                  widget.client.saveProduct(
                      data.id,
                      data.name!,
                      data.barcode!,
                      data.manufacturer!,
                      data.description!,
                      //data.review,
                      data.country!,
                      data.ratings,
                      data.ratingInfo,
                      data.category_id!,
                      File(image!.path)
                  );

                  saveFuture.then((value) async {
                    _dialog.hide();
                    if(value.success) {
                      await showDialog<void>(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext ctx) {
                          return AlertDialog(
                            content: Text('A termék sikeresen beküldve. Értékeled most?'),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('Igen'),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  Future.delayed(Duration.zero, () {
                                    Navigator.push(ctx,
                                        MaterialPageRoute(builder: (context) =>
                                            ProductRatingView(
                                              data: value.product!, client: widget.client, pageController: null, updateProduct: (Product p) {  },
                                            )
                                        ));
                                  });

                                },
                              ),
                              ElevatedButton(
                                child: const Text('Nem'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                      /*Fluttertoast.showToast(
                          msg: value.message,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.teal,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );*/
                      Navigator.of(context).pop();
                    } else {
                      Fluttertoast.showToast(
                          msg: value.message,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.deepOrange,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  });
                  }
              }
            },
            child: Text(globals.role == "user" && data.id != null ? 'Értékelem' : 'Küldés'),
          ),
        ),
        body: SingleChildScrollView(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
                key: _formKey,
                child:
                Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: TextFormField(
                            controller: barcodeController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Vonalkód',
                            ),
                            // The validator receives the text that the user has entered.
                            /*validator: (value) {
              if (value == null || value.isEmpty || value.length < 5) {
                return 'Legalább 5 karakter hosszú lehet';
              }
              return null;
            },*/
                          )),
                          IconButton(icon: Icon(Icons.camera, size: 30), onPressed: () async  {
                            /*Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BarcodeScanner()),
                            );*/
                            Map barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                "#000000",
                "Mégse",
                true,
                ScanMode.DEFAULT );

                           /* var res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SimpleBarcodeScannerPage(),
                                ));
                            setState(() {
                              if (res is String) {
                                String barcode = res;*/



                                var barcode = barcodeScanRes["data"].toString();
                                var type = barcodeScanRes["type"].toString();

                                barcodeController.text = barcode;
                                if (barcode.length > 0) {
                                  widget.client.getProductByBarcode(barcode)
                                      .then((product) {
                                    showProduct(product);
                                  }, onError: (error, stackTrace) {
                                    setState(() {
                                      countryController.text =
                                          globals.countryFromBArcode(
                                              barcode, "type");
                                    });
                                  });
                                }
                            //});
                          })
                        ]
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Kép', style: Theme.of(context).textTheme.labelMedium),
                        image != null
                            ? GestureDetector(
                            onTap: readOnly ? () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                    return FullScreenImage(
                                      imageUrl: Constants.IMAGE_URL + data.image.toString(),
                                      tag: "generate_a_unique_tag", key: null,
                                    );
                                  }));
                            } : mediaSelectDialog, // Image tapped
                            child:
                            ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: kIsWeb ? Image.network(
                                  image!.path,
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                ) : Image.file(
                                  File(image!.path),
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                ))
                        )
                            : ElevatedButton(
                          onPressed: () {
                            mediaSelectDialog();
                          },
                          child: Text('Feltöltés'),
                        ),
                      ],),
                    SizedBox(height: 10),
                    IgnorePointer(
                      //ignoring: readOnly,
                      ignoring: false,
                      child:
                      TypeAheadFormField(
                        textFieldConfiguration: TextFieldConfiguration(
                          maxLength: 100,
                          style: TextStyle(color: Color(0xFFd2ac67)),
                          controller: nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Megnevezés',
                          ),
                        ),
                        minCharsForSuggestions: 2,
                        noItemsFoundBuilder: (value) {
                          return Text("", style: TextStyle(height: 0),);
                        },
                        suggestionsCallback: (pattern) async {
                          if(pattern != "")
                            return await widget.client.productSearch(pattern);
                          else return [];
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion.toString()),
                            //subtitle: Text('\$${suggestion['price']}'),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          var name = suggestion.toString();
                          nameController.text = name;
                          widget.client.getProductByName(name).then((product) {
                            if (name != "") {
                              showProduct(product);
                            }
                          });
                        },
                      ),
                      /*TextFormField(
            controller: nameController,
            readOnly: readOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Megnevezés',
            ),
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 5) {
                return 'Legalább 5 karakter hosszú lehet';
              }
              return null;
            },
        )*/
                    ),
                    SizedBox(height: 10),
                    DropdownButtonHideUnderline(
                      child: FutureBuilder<List<Category>>(
                        future: categories,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return new IgnorePointer(
                                ignoring: readOnly,
                                child: DropdownButtonFormField2(
                                  //buttonPadding: EdgeInsets.only(left: 14, right: 14),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  validator: (value) => value == null ? 'kötelező megadni' : null,
                                  isExpanded: true,
                                  buttonHeight: 50,
                                  hint: Row(
                                    children: const [
                                      Expanded(
                                        child: Text(
                                          'Kategória',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  value: data.category,
                                  icon: Icon(Icons.arrow_drop_down),
                                  iconSize: 30,
                                  style: TextStyle(color: Colors.black),
                                  onChanged: (newValue) {
                                    setState(() {
                                      data.category = (newValue as Category?);
                                      data.category_id = (newValue)!.id;
                                    });
                                  },
                                  items: snapshot.data
                                      ?.map<DropdownMenuItem<Category>>((Category value) {
                                    return DropdownMenuItem<Category>(
                                      value: value,
                                      child: Text(value.name!, style: TextStyle(
                                        color: Color(0xFFd2ac67),
                                        fontSize: 16,
                                      ),),
                                    );
                                  }).toList(),
                                ));
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          return TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Kategória',
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    TypeAheadFormField(
                      enabled: !readOnly,
                      textFieldConfiguration: TextFieldConfiguration(
                        style: TextStyle(color: Color(0xFFd2ac67)),
                        scrollPadding: const EdgeInsets.only(bottom: 300),
                        controller: manufacturerController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Gyártó',
                        ),
                      ),
                      minCharsForSuggestions: 2,
                      suggestionsCallback: (pattern) async {
                        if(pattern != "")
                          return await widget.client.manufacturerSearch(pattern);
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
                        manufacturerController.text = name;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      style: TextStyle(color: Color(0xFFd2ac67)),
                      readOnly: readOnly,
                      controller: countryController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Ország',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      maxLines: 2,
                      controller: descriptionController,
                      style: TextStyle(color: Color(0xFFd2ac67)),
                      readOnly: readOnly,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Leírás',
                      ),
                    ),
                    SizedBox(height: 10),
                   /* Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child:
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text("Vennéd?", style: Theme.of(context).textTheme.labelMedium),
                          ToggleSwitch(
                            cornerRadius: 20.0,
                            activeFgColor: Color(0xFFd2ac67),
                            activeBgColor: [Colors.black45],
                            inactiveBgColor: Colors.black45,
                            initialLabelIndex: data.ratingInfo['1'] == '1' ? 0 : 1,
                            totalSwitches: 2,
                            labels: ['Igen', 'Nem'],
                            onToggle: (index) {
                              data.ratingInfo['1'] = index == 0 ? "1" : "0";
                            },
                          ),
                        ]
                        )
                    ),*/
                   /* FutureBuilder<Widget>(
                      future: buildRatingViews(),
                      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                        }
                        return snapshot.hasData
                            ? Container(
                          child: snapshot.data,
                        ) : Container();
                      },
                    ),*/
                  ],
                )))));
  }

  Future<List<Category>> getCategories() async {
    return await widget.client.getCategories();
  }
}
