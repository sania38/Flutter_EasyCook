part of 'bottom_nav_bloc.dart';

@immutable
sealed class BottomNavState {
  const BottomNavState(this.tabIndex);

  final int tabIndex;

  @override
  // ignore: override_on_non_overriding_member
  List<Object> get props => [tabIndex];
}

final class BottomNavInitial extends BottomNavState {
  const BottomNavInitial(super.tabIndex);
}
