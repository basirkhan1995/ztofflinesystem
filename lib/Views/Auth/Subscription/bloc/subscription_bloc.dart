import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoonpro/Services/repositories.dart';
import 'package:zaitoonpro/Views/Auth/Subscription/model/sub_model.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final Repositories _repo;

  SubscriptionBloc(this._repo) : super(SubscriptionInitial()) {
    // ── Load current subscription ──
    on<LoadSubscriptionEvent>((event, emit) async {
      emit(SubscriptionLoadingState());
      try {
        final res = await _repo.getSubscriptions();
        emit(SubscriptionLoadedState(res));
      } catch (e) {
        emit(SubscriptionErrorState(e.toString()));
      }
    });

    // ── Generate new key (no old key needed) ──
    on<GenerateSubscriptionEvent>((event, emit) async {
      emit(SubscriptionLoadingState());
      try {
        final res = await _repo.generateSubscription(
          expireDate: event.expireDate,
        );
        final msg = res["msg"];
        if (msg == "success") {
          emit(SubscriptionGeneratedState(res["newKey"] as String));
        } else {
          emit(SubscriptionErrorState(msg?.toString() ?? "Unknown error"));
        }
      } catch (e) {
        emit(SubscriptionErrorState(e.toString()));
      }
    });
  }
}