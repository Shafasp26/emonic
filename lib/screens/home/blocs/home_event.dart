part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class TabChanged extends HomeEvent {
  final int index;

  const TabChanged(this.index);

  @override
  List<Object> get props => [index];
}
