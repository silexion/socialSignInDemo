
import 'package:pontozz/api.dart';

class UpdateItemEvent {
  Product item;
  int index;

  UpdateItemEvent(this.item, this.index);
}