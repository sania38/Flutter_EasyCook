
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bottom_nav_event.dart';
part 'bottom_nav_state.dart';

class BottomNavBloc extends Bloc<BottomNavEvent, BottomNavState> {
  BottomNavBloc() : super(const BottomNavInitial(0)) {
    on<BottomNavEvent>((event, emit) {
      if (event is ChangeTabEvent) {
        emit(BottomNavInitial(event.tabIndex));
      }
    });
  }
}
