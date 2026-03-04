/// DOZ Shared Package
///
/// Shared code for the DOZ Taxi application suite:
/// - doz_rider (Rider app)
/// - doz_driver (Driver app)
/// - doz_admin (Admin dashboard)
///
/// Exports all public APIs: models, services, theme,
/// localization, widgets, and utilities.
library doz_shared;

// ── Models ────────────────────────────────────────────────────────────────────
export 'models/enums.dart';
export 'models/user_model.dart';
export 'models/driver_model.dart';
export 'models/ride_model.dart';
export 'models/bid_model.dart';
export 'models/rating_model.dart';
export 'models/wallet_model.dart';
export 'models/wallet_transaction_model.dart';
export 'models/notification_model.dart';
export 'models/vehicle_type_model.dart';
export 'models/location_model.dart';

// ── Services ──────────────────────────────────────────────────────────────────
export 'services/storage_service.dart';
export 'services/api_client.dart';
export 'services/auth_service.dart';
export 'services/websocket_service.dart';
export 'services/location_service.dart';

// ── Theme ─────────────────────────────────────────────────────────────────────
export 'theme/doz_colors.dart';
export 'theme/doz_text_styles.dart';
export 'theme/doz_theme.dart';

// ── Localization ──────────────────────────────────────────────────────────────
export 'l10n/app_localizations.dart';

// ── Widgets ───────────────────────────────────────────────────────────────────
export 'widgets/doz_button.dart';
export 'widgets/doz_text_field.dart';
export 'widgets/doz_card.dart';
export 'widgets/doz_bottom_sheet.dart';
export 'widgets/doz_loading.dart';
export 'widgets/doz_empty_state.dart';
export 'widgets/doz_avatar.dart';
export 'widgets/doz_rating_stars.dart';
export 'widgets/doz_price_tag.dart';
export 'widgets/doz_status_badge.dart';

// ── Utils ─────────────────────────────────────────────────────────────────────
export 'utils/constants.dart';
export 'utils/formatters.dart';
export 'utils/validators.dart';
export 'utils/extensions.dart';
