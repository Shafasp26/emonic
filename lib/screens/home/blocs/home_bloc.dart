import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState(selectedTab: 0)) {
    on<TabChanged>(_onTabChanged);
  }

  void _onTabChanged(TabChanged event, Emitter<HomeState> emit) {
    emit(HomeState(selectedTab: event.index));
  }
}
