import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../services/entitlement_service.dart';
import 'states/common_state.dart';
import 'states/entitlement_state.dart';

class EntitlementCubit extends Cubit<EntitlementCubitState> {
  final EntitlementService _entitlementService = EntitlementService();
  final Logger _logger = Logger('EntitlementCubit');

  EntitlementCubit() : super(EntitlementCubitState.initial());

  Future<void> bootstrap() async {
    emit(state.copyWith(isLoading: true));

    final snapshotResult = await _entitlementService.getEntitlementSnapshot();
    if (snapshotResult.isErr()) {
      emit(state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: ErrorState(
          type: snapshotResult.error.type.name,
          description: snapshotResult.error.description,
        ),
      ));
      return;
    }

    emit(state.copyWith(
      snapshot: snapshotResult.value,
      isLoading: false,
      isInitialized: true,
      error: null,
    ));

    await refreshEntitlement(force: false);
  }

  Future<void> refreshEntitlement({required bool force}) async {
    emit(state.copyWith(
      isRefreshing: true,
      error: null,
    ));

    final result = await _entitlementService.refreshEntitlement(force: force);
    if (result.isErr()) {
      _logger.warning('Failed to refresh entitlement', result.error);
      emit(state.copyWith(
        isRefreshing: false,
        error: ErrorState(
          type: result.error.type.name,
          description: result.error.description,
        ),
      ));
      return;
    }

    emit(state.copyWith(
      snapshot: result.value,
      isRefreshing: false,
      error: null,
    ));
  }

  Future<void> purchasePremium() async {
    emit(state.copyWith(
      isPurchasing: true,
      error: null,
    ));

    final result = await _entitlementService.purchasePremium();
    if (result.isErr()) {
      emit(state.copyWith(
        isPurchasing: false,
        error: ErrorState(
          type: result.error.type.name,
          description: result.error.description,
        ),
      ));
      return;
    }

    emit(state.copyWith(
      snapshot: result.value,
      isPurchasing: false,
      error: null,
    ));
  }

  Future<void> restorePurchases() async {
    emit(state.copyWith(
      isRestoring: true,
      error: null,
    ));

    final result = await _entitlementService.restorePurchases();
    if (result.isErr()) {
      emit(state.copyWith(
        isRestoring: false,
        error: ErrorState(
          type: result.error.type.name,
          description: result.error.description,
        ),
      ));
      return;
    }

    emit(state.copyWith(
      snapshot: result.value,
      isRestoring: false,
      error: null,
    ));
  }
}
