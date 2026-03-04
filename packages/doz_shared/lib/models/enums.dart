/// Enums used across the DOZ Taxi application.
library;

enum UserRole {
  rider,
  driver,
  admin;

  String toJson() => name;

  static UserRole fromJson(String? value) {
    switch (value) {
      case 'driver':
        return UserRole.driver;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.rider;
    }
  }
}

enum RideStatus {
  pending,
  bidding,
  accepted,
  driverArriving,
  inProgress,
  completed,
  cancelled;

  String toJson() {
    switch (this) {
      case RideStatus.driverArriving:
        return 'driver_arriving';
      case RideStatus.inProgress:
        return 'in_progress';
      default:
        return name;
    }
  }

  static RideStatus fromJson(String? value) {
    switch (value) {
      case 'bidding':
        return RideStatus.bidding;
      case 'accepted':
        return RideStatus.accepted;
      case 'driver_arriving':
        return RideStatus.driverArriving;
      case 'in_progress':
        return RideStatus.inProgress;
      case 'completed':
        return RideStatus.completed;
      case 'cancelled':
        return RideStatus.cancelled;
      default:
        return RideStatus.pending;
    }
  }
}

enum BidStatus {
  pending,
  accepted,
  rejected,
  expired;

  String toJson() => name;

  static BidStatus fromJson(String? value) {
    switch (value) {
      case 'accepted':
        return BidStatus.accepted;
      case 'rejected':
        return BidStatus.rejected;
      case 'expired':
        return BidStatus.expired;
      default:
        return BidStatus.pending;
    }
  }
}

enum PaymentMethod {
  cash,
  wallet,
  card;

  String toJson() => name;

  static PaymentMethod fromJson(String? value) {
    switch (value) {
      case 'wallet':
        return PaymentMethod.wallet;
      case 'card':
        return PaymentMethod.card;
      default:
        return PaymentMethod.cash;
    }
  }
}

enum NotificationType {
  rideUpdate,
  bidReceived,
  bidAccepted,
  payment,
  promo,
  system;

  String toJson() {
    switch (this) {
      case NotificationType.rideUpdate:
        return 'ride_update';
      case NotificationType.bidReceived:
        return 'bid_received';
      case NotificationType.bidAccepted:
        return 'bid_accepted';
      default:
        return name;
    }
  }

  static NotificationType fromJson(String? value) {
    switch (value) {
      case 'ride_update':
        return NotificationType.rideUpdate;
      case 'bid_received':
        return NotificationType.bidReceived;
      case 'bid_accepted':
        return NotificationType.bidAccepted;
      case 'payment':
        return NotificationType.payment;
      case 'promo':
        return NotificationType.promo;
      default:
        return NotificationType.system;
    }
  }
}

enum WalletTransactionType {
  topUp,
  payment,
  refund,
  commission,
  withdrawal;

  String toJson() {
    switch (this) {
      case WalletTransactionType.topUp:
        return 'top_up';
      default:
        return name;
    }
  }

  static WalletTransactionType fromJson(String? value) {
    switch (value) {
      case 'top_up':
        return WalletTransactionType.topUp;
      case 'payment':
        return WalletTransactionType.payment;
      case 'refund':
        return WalletTransactionType.refund;
      case 'commission':
        return WalletTransactionType.commission;
      case 'withdrawal':
        return WalletTransactionType.withdrawal;
      default:
        return WalletTransactionType.payment;
    }
  }
}
