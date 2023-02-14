
import 'dart:io';

import 'package:dio/dio.dart';
import "dart:convert";
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

import 'constants.dart' as Constants;
part 'api.g.dart';

@RestApi(baseUrl: Constants.API_URL)
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET("/products")
  Future<List<Product>> getProducts();

  @GET("/productByBarcode/{barcode}")
  Future<Product> getProductByBarcode(@Path("barcode") String barcode);

  @GET("/productByName/{name}")
  Future<Product> getProductByName(@Path("name") String name);

  @GET("/products/search/{text}")
  Future<List<String>> productSearch(@Path("text") String text);

  @GET("/manufacturer/search/{text}")
  Future<List<String>> manufacturerSearch(@Path("text") String text);

  @GET("/categories")
  Future<List<Category>> getCategories();

  @POST("sendRating")
  @FormUrlEncoded()
  Future<ProductResponse> sendRating(@Body() Product product);


  @POST("sendProductWithRating")
  @MultiPart()
  Future<ProductResponse> saveProduct(
      @Part() int id,
      @Part() String name,
      @Part() String barcode,
      @Part() String manufacturer,
      @Part() String description,
      @Part() String country,
      @Part() Map<String,int> ratings,
      @Part() Map<String,String> ratingInfo,
      @Part() int category_id,
      @Part() File imageFile,
  );

  @POST("socialLogin")
  @FormUrlEncoded()
  Future<User> login(@Field() String accessToken, @Field() String provider);

  @POST("socialLogout")
  Future<String> logout();

  @GET("/tastings")
  Future<List<Tasting>> tastings();

  @GET("/tastingProducts/{id}")
  Future<List<Product>> tastingProducts(@Path("id") int id);

  @GET("/reviews/{page}/{pageSize}/{id}")
  Future<List<Review>> getReviews(@Path("page") int page, @Path("pageSize") int pageSize, @Path("id") int id);
}

@JsonSerializable()
class Tasting {
  late int id;
  late String name;
  late int status;

  Tasting({required this.id, required this.name, required this.status});

  factory Tasting.fromJson(Map<String, dynamic> json) => _$TastingFromJson(json);

  Map<String, dynamic> toJson() => _$TastingToJson(this);
}


@JsonSerializable()
class User {
  late String accessToken;
  late String role;
  late String name;

  User({required this.accessToken, required this.name, required this.role});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Product {
  int? id;
  int? category_id;
  int? tasting_id;
  String? name;
  String? barcode;
  String? description;
  String? manufacturer;
  String? country;
  String? image;
  String? overall;

  Category? category;

  late List<Criteria> criterias;

  //late List<Rating> ratings;
  Map<String, int> ratings;
  Map<String, String> ratingInfo;

  Product({this.id, this.category_id, this.name, this.barcode, this.image, this.tasting_id, this.overall, required this.criterias, required this.ratings, required this.ratingInfo});

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

@JsonSerializable()
class Category {
  int? id;
  String? name;
  late List<Criteria> criterias = List.empty();

  Category({this.id, this.name, required this.criterias});

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  bool operator ==(dynamic other) =>
      other != null && other is Category && this.id == other.id;

  @override
  int get hashCode => super.hashCode;
}


@JsonSerializable()
class Criteria {
  int? id;
  String? name;
  String? option1;
  String? option2;
  String? option3;
  String? option4;
  String? option5;

  Criteria({this.id, this.name,});

  factory Criteria.fromJson(Map<String, dynamic> json) => _$CriteriaFromJson(json);

  Map<String, dynamic> toJson() => _$CriteriaToJson(this);
}

@JsonSerializable()
class Rating {
  int? criteriaId;
  int value;

  Rating({this.criteriaId, required this.value});

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);

  Map<String, dynamic> toJson() => _$RatingToJson(this);
}

@JsonSerializable()
class Review {
  int? id;
  String? review;
  String? user;

  Review({this.id, this.review, this.user});

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  bool operator ==(dynamic other) =>
      other != null && other is Category && this.id == other.id;

  @override
  int get hashCode => super.hashCode;
}

@JsonSerializable()
class ProductResponse {
  late String message;
  late bool success;

  ProductResponse({required this.success, required this.message});

  factory ProductResponse.fromJson(Map<String, dynamic> json) => _$ProductResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductResponseToJson(this);
}
