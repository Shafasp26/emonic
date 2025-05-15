part of 'home_bloc.dart';

class HomeState extends Equatable {
  final int selectedTab;

  const HomeState({required this.selectedTab});

  @override
  List<Object> get props => [selectedTab];
}
