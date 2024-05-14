part of 'bottom_nav_bloc.dart';

@immutable
sealed class BottomNavEvent {
  const BottomNavEvent(this.tabIndex);

  final int tabIndex;

  List<Object> get props => [tabIndex];
}

final class ChangeTabEvent extends BottomNavEvent {
  const ChangeTabEvent(super.tabIndex);
}
