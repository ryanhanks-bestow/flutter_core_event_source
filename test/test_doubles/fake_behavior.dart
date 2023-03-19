import 'package:core_event_source/common.dart';
import 'package:core_event_source/event_source.dart';
import 'package:core_event_source/event_sourced_behavior.dart';

typedef FakeCommand = JsonObject;
typedef FakeEvent = JsonObject;
typedef FakeState = int;
typedef FakeView = int;

class FakeBehavior
    implements
        EventSourcedBehavior<FakeCommand, FakeEvent, FakeState, FakeView> {
  @override
  CommandHandler<FakeCommand, FakeEvent, FakeState> get commandHandler =>
      (_, __) => EventSourcedBehaviorEffect.persist([{}]);

  @override
  StateEventHandler<FakeEvent, FakeState> get eventHandler =>
      (state, _) => state + 1;

  @override
  FakeState get initialState => 0;

  @override
  FakeView get initialView => 1;

  @override
  ViewEventHandler<FakeEvent, FakeView> get viewHandler =>
      (previous, _) => previous * 2;
}

class FakeEventJsonConverter extends JsonEventConverter<FakeEvent> {
  FakeEventJsonConverter()
      : super((p0) => p0 as Map<String, dynamic>, (object) => object);
}
