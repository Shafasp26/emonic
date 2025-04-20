part of 'sign_up_bloc.dart';

sealed class SignUpState extends Equatable {
  const SignUpState();
  
  @override
  List<Object> get props => [];
}

final class SignUpInitial extends SignUpState {}

class SignUpSuccess extends SignUpState {}
class SignUpFailure extends SignUpState {
  final String message;

  const SignUpFailure([this.message = 'An error occurred during sign up']);

  @override
  List<Object> get props => [message];
}
class SignUpProcess extends SignUpState {}