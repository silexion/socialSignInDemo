
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pontozz/api.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pontozz/events.dart';
import 'package:pontozz/full_screen_image.dart';
import 'package:pontozz/main.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'constants.dart' as Constants;
import 'api.dart' as Api;
import 'package:fluttertoast/fluttertoast.dart';
import 'events.dart';

class ProductRatingView extends StatefulWidget {
  const ProductRatingView({Key? key, required this.data, this.pageController, required this.client, required this.updateProduct,  this.prevProduct}) : super(key: key);

  final Product data;
  final RestClient client;
  final PreloadPageController? pageController;
  final Function(Product p) updateProduct;
  final Function(int i)? prevProduct;

  @override
  State<StatefulWidget> createState() {

    return ProductRatingViewState();
  }
}



class ProductRatingViewState extends State<ProductRatingView> {
  Map<int, String> criteriaOptions = new Map();
  final reviewController = TextEditingController();

  Widget getRatingViews(List<Criteria> criterias)
  {
    List<Widget> list = [];
    for(var i = 0; i < criterias.length; i++){
      list.add(SizedBox(height: 10));
      list.add(Text(criterias[i].name.toString().toUpperCase(),));
      list.add(RatingBar.builder(
        initialRating: widget.data.ratings.containsKey(criterias[i].id.toString()) ? widget.data.ratings[criterias[i].id.toString()]!.toDouble() : 0.0,
        minRating: 1,
        itemCount: 5,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),

        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Color(0xFFd2ac67),
        ),
        onRatingUpdate: (rating) {
          widget.data.ratings[criterias[i].id!.toString()] = rating.toInt();

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
      if (widget.data.review != null)
        reviewController.text = widget.data.review.toString();
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
        title: Text(widget.data.name.toString()),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) {
                    return FullScreenImage(
                      imageUrl: Constants.IMAGE_URL + widget.data.image.toString(),
                      tag: "generate_a_unique_tag", key: null,
                    );
                  }));
            },
            icon: Icon(Icons.image),
          ),
        ],
        leading: GestureDetector(
        child: Icon(Icons.arrow_back),
            onTap: () {
            Navigator.of(context).pop();
        },
    )),
    body: SingleChildScrollView(
    child: Stack(
    children: <Widget>[
      Container(alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(Constants.IMAGE_URL + widget.data.image.toString()),
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.8), BlendMode.modulate),
            fit: BoxFit.cover,
          ),
        ),
        child:
    Column(children: [
    Padding(
    padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
        child: Container(
          width: double.infinity,
          child:Card(
    color: Color.fromARGB(180, 0, 0, 0),
      child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(children: [
            Row(children: [
              Visibility(child: Text(widget.data.manufacturer.toString()), visible: widget.data.manufacturer != null),
              Visibility(child: Text(", "), visible: widget.data.manufacturer != null && widget.data.country != null),
              Visibility(child: Text(widget.data.country.toString()), visible: widget.data.country != null)
            ],),
            Visibility(child: Align(alignment: Alignment.topLeft, child: Text(widget.data.description.toString())), visible: widget.data.description != null)
          ],)
      )))),
        Padding(
            padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
            child: Container(
              width: double.infinity,
              child: Card(
              color: Color.fromARGB(180, 0, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getRatingViews(widget.data.category != null ? widget.data.category!.criterias! : widget.data.criterias!),
                  SizedBox(height: 15),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child:
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("Vennéd?"),
                        ToggleSwitch(
                          cornerRadius: 20.0,
                          activeFgColor: Color(0xFFd2ac67),
                          activeBgColor: [Colors.black45],
                          inactiveBgColor: Colors.black45,
                          initialLabelIndex: widget.data.ratingInfo['1'] == '1' ? 0 : 1,
                          totalSwitches: 2,
                          labels: ['Igen', 'Nem'],
                          onToggle: (index) {
                            widget.data.ratingInfo['1'] = index == 0 ? "1" : "0";
                          },
                        ),
                        ]
                      )
                  ),
                  SizedBox(height: 10),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child:
                    TextFormField(
                      maxLines: 2,
                      controller: reviewController,
                      style: TextStyle(color: Color(0xFFd2ac67)),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Vélemény',
                      ),
                  )),
                  SizedBox(height: 15),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child:
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      widget.pageController != null ?
                        ElevatedButton.icon(style: ElevatedButton.styleFrom(padding: EdgeInsets.fromLTRB(25, 10, 25, 10)),
                          label: Text('Előző'),
                          icon: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 30.0,
                          ),
                          onPressed: () {
                            widget.pageController?.previousPage(duration: Duration(milliseconds: 300), curve: Curves.ease);

                            //widget.prevProduct(1);
                          }) :
                      ElevatedButton(style: ElevatedButton.styleFrom(padding: EdgeInsets.fromLTRB(25, 10, 25, 10)),
                          child: Text('Mégse'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                      ElevatedButton.icon(style: ElevatedButton.styleFrom(surfaceTintColor: Colors.indigoAccent, padding: EdgeInsets.fromLTRB(25, 10, 25, 10)),
                        label: Text('Küldés'),
                        icon: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        onPressed: () {
                          for(var criteria in widget.data.category!.criterias) {
                            if(!widget.data.ratings.containsKey(criteria.id.toString())) {
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
                          }

                          widget.data.review = reviewController.text.toString();
                          widget.client.sendRating(widget.data).then((value) {
                            //Navigator.of(context).pop();
                            setState(() {
                              if (widget.pageController != null) {
                                eventBus.fire(UpdateItemEvent(widget.data,
                                    widget.pageController!.page!.toInt()));
                                widget.pageController?.nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.ease);
                              } else {
                                widget.data.overall = value.overall;
                                eventBus.fire(UpdateItemEvent(widget.data, 0));
                                Navigator.of(context).pop();
                              }
                            });

                          });
                        })
                    ],)
                  ),

                  SizedBox(height: 15)
          ]
      )))),
      ],
    ))])));
  }
}

