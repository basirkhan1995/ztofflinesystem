part of 'subscription_bloc.dart';

sealed class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();
}


class LoadSubscriptionEvent extends SubscriptionEvent{
  @override
  List<Object?> get props => [];
}
class GenerateSubscriptionEvent extends SubscriptionEvent {
  final String expireDate;
  const GenerateSubscriptionEvent(this.expireDate);
  @override
  List<Object?> get props => [expireDate];
}


