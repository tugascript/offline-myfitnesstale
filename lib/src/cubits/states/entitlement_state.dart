import 'package:equatable/equatable.dart';

import '../../services/dtos/entitlement_state_dto.dart';
import 'common_state.dart';

final class EntitlementCubitState extends Equatable {
  final EntitlementStateDto? snapshot;
  final bool isLoading;
  final bool isRefreshing;
  final bool isPurchasing;
  final bool isRestoring;
  final bool isInitialized;
  final ErrorState? error;

  const EntitlementCubitState({
    this.snapshot,
    required this.isLoading,
    required this.isRefreshing,
    required this.isPurchasing,
    required this.isRestoring,
    required this.isInitialized,
    this.error,
  });

  factory EntitlementCubitState.initial() {
    return const EntitlementCubitState(
      isLoading: false,
      isRefreshing: false,
      isPurchasing: false,
      isRestoring: false,
      isInitialized: false,
    );
  }

  EntitlementCubitState copyWith({
    EntitlementStateDto? snapshot,
    bool? isLoading,
    bool? isRefreshing,
    bool? isPurchasing,
    bool? isRestoring,
    bool? isInitialized,
    ErrorState? error,
  }) {
    return EntitlementCubitState(
      snapshot: snapshot ?? this.snapshot,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isRestoring: isRestoring ?? this.isRestoring,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        snapshot,
        isLoading,
        isRefreshing,
        isPurchasing,
        isRestoring,
        isInitialized,
        error,
      ];
}
