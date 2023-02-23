
import 'package:pontozz/api.dart';
import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class UpdateItemEvent {
  Product item;
  int index;

  UpdateItemEvent(this.item, this.index);
}