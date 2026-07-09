import 'package:laqta/core/localization/app_localizations.dart';

class ErrorMapper {
  ErrorMapper._();

  static String messageForStatusCode(int code) {
    switch (code) {
      case 400:
        return AppLocalizations.current.errBadRequest;
      case 401:
        return AppLocalizations.current.errorSessionExpired;
      case 403:
        return AppLocalizations.current.errForbidden;
      case 404:
        return AppLocalizations.current.errNotFound;
      case 409:
        return AppLocalizations.current.errConflict;
      case 422:
        return AppLocalizations.current.errValidation;
      case 429:
        return AppLocalizations.current.errRateLimited;
      case 500:
        return AppLocalizations.current.errServer;
      case 503:
        return AppLocalizations.current.errServiceUnavailable;
      case -1:
        return AppLocalizations.current.offlineNoConnection;
      default:
        return AppLocalizations.current.errorUnexpected;
    }
  }
}
