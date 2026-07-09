import 'package:flutter/material.dart';
import 'package:laqta/core/localization/ar_translations.dart';
import 'package:laqta/core/localization/en_translations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Last locale loaded by the delegate. Lets non-widget layers (network,
  /// security gates) and widgets rendered above the MaterialApp localization
  /// scope resolve translations without a BuildContext.
  static AppLocalizations current = AppLocalizations(const Locale('ar'));

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Context-safe lookup that falls back to [current] when the widget sits
  /// outside the MaterialApp localizations scope.
  static AppLocalizations resolve(BuildContext? context) {
    if (context != null) {
      final scoped = maybeOf(context);
      if (scoped != null) {
        return scoped;
      }
    }
    return current;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': EnTranslations.appName,
      'cancel': EnTranslations.cancel,
      'confirm': EnTranslations.confirm,
      'save': EnTranslations.save,
      'delete': EnTranslations.delete,
      'edit': EnTranslations.edit,
      'search': EnTranslations.search,
      'filter': EnTranslations.filter,
      'next': EnTranslations.next,
      'back': EnTranslations.back,
      'done': EnTranslations.done,
      'todayLabel': EnTranslations.todayLabel,
      'upcomingLabel': EnTranslations.upcomingLabel,
      'analyticsLabel': EnTranslations.analyticsLabel,
      'yes': EnTranslations.yes,
      'no': EnTranslations.no,
      'submit': EnTranslations.submit,
      'notSpecified': EnTranslations.notSpecified,
      'days': EnTranslations.days,
      'minutes': EnTranslations.minutes,
      'typeLabel': EnTranslations.typeLabel,
      'statusLabel': EnTranslations.statusLabel,
      'reportedLabel': EnTranslations.reportedLabel,
      'openedByLabel': EnTranslations.openedByLabel,
      'loading': EnTranslations.loading,
      'error': EnTranslations.error,
      'somethingWentWrong': EnTranslations.somethingWentWrong,
      'retry': EnTranslations.retry,
      'weakPassword': EnTranslations.weakPassword,
      'fairPassword': EnTranslations.fairPassword,
      'goodPassword': EnTranslations.goodPassword,
      'strongPassword': EnTranslations.strongPassword,
      'noData': EnTranslations.noData,
      'pressBackAgainToExit': EnTranslations.pressBackAgainToExit,
      'noPhotographers': EnTranslations.noPhotographers,
      'noResults': EnTranslations.noResults,
      'selectLanguage': EnTranslations.selectLanguage,
      'selectLanguageSubtitle': EnTranslations.selectLanguageSubtitle,
      'languageHint': EnTranslations.languageHint,
      'welcomeBack': EnTranslations.welcomeBack,
      'welcomeToLaqta': EnTranslations.welcomeToLaqta,
      'authSubtitle': EnTranslations.authSubtitle,
      'signInTitle': EnTranslations.signInTitle,
      'signUpTitle': EnTranslations.signUpTitle,
      'signInWithPhone': EnTranslations.signInWithPhone,
      'signUpWithPhone': EnTranslations.signUpWithPhone,
      'phoneNumber': EnTranslations.phoneNumber,
      'verifyOTP': EnTranslations.verifyOTP,
      'enterOTP': EnTranslations.enterOTP,
      'resendCode': EnTranslations.resendCode,
      'verify': EnTranslations.verify,
      'or': EnTranslations.or,
      'phoneAuthUnsupported': EnTranslations.phoneAuthUnsupported,
      'phoneAuthSupportInfo': EnTranslations.phoneAuthSupportInfo,
      'phoneNumberRequired': EnTranslations.phoneNumberRequired,
      'verificationFailed': EnTranslations.verificationFailed,
      'phoneAuthError': EnTranslations.phoneAuthError,
      'otpInvalid': EnTranslations.otpInvalid,
      'verificationIdMissing': EnTranslations.verificationIdMissing,
      'otpVerificationFailed': EnTranslations.otpVerificationFailed,
      'resendFailed': EnTranslations.resendFailed,
      'resendError': EnTranslations.resendError,
      'otpSentSuccess': EnTranslations.otpSentSuccess,
      'chooseRole': EnTranslations.chooseRole,
      'customer': EnTranslations.customer,
      'photographer': EnTranslations.photographer,
      'iAmCustomer': EnTranslations.iAmCustomer,
      'iAmPhotographer': EnTranslations.iAmPhotographer,
      'completeProfile': EnTranslations.completeProfile,
      'fullName': EnTranslations.fullName,
      'governorate': EnTranslations.governorate,
      'selectGovernorate': EnTranslations.selectGovernorate,
      'interests': EnTranslations.interests,
      'bio': EnTranslations.bio,
      'specialties': EnTranslations.specialties,
      'basePrice': EnTranslations.basePrice,
      'instagram': EnTranslations.instagram,
      'tiktok': EnTranslations.tiktok,
      'uploadPortfolio': EnTranslations.uploadPortfolio,
      'home': EnTranslations.home,
      'explore': EnTranslations.explore,
      'messages': EnTranslations.messages,
      'accountSection': EnTranslations.accountSection,
      'bookWithConfidence': EnTranslations.bookWithConfidence,
      'requestQuickPrompt': EnTranslations.requestQuickPrompt,
      'activeRequests': EnTranslations.activeRequests,
      'shop': EnTranslations.shop,
      'featuredProducts': EnTranslations.featuredProducts,
      'noProducts': EnTranslations.noProducts,
      'productsEmptyMessage': EnTranslations.productsEmptyMessage,
      'orderNow': EnTranslations.orderNow,
      'upcomingBookings': EnTranslations.upcomingBookings,
      'noBookings': EnTranslations.noBookings,
      'noBookingsMessage': EnTranslations.noBookingsMessage,
      'past': EnTranslations.past,
      'explorePhotographers': EnTranslations.explorePhotographers,
      'bookNow': EnTranslations.bookNow,
      'startingFrom': EnTranslations.startingFrom,
      'viewProfile': EnTranslations.viewProfile,
      'topRated': EnTranslations.topRated,
      'offers': EnTranslations.offers,
      'selectDate': EnTranslations.selectDate,
      'selectTime': EnTranslations.selectTime,
      'invalidDateTime': EnTranslations.invalidDateTime,
      'invalidBudgetRange': EnTranslations.invalidBudgetRange,
      'invalidLocation': EnTranslations.invalidLocation,
      'confirmBooking': EnTranslations.confirmBooking,
      'chat': EnTranslations.chat,
      'typeMessage': EnTranslations.typeMessage,
      'send': EnTranslations.send,
      'deleteChatTitle': EnTranslations.deleteChatTitle,
      'deleteConversationPrompt': EnTranslations.deleteConversationPrompt,
      'deleteChatPrompt': EnTranslations.deleteChatPrompt,
      'chatDeleted': EnTranslations.chatDeleted,
      'chatDeleteFailed': EnTranslations.chatDeleteFailed,
      'noMessagesTitle': EnTranslations.noMessagesTitle,
      'noChatResults': EnTranslations.noChatResults,
      'startConversationWithPhotographer':
          EnTranslations.startConversationWithPhotographer,
      'tryAnotherNameOrKeyword': EnTranslations.tryAnotherNameOrKeyword,
      'unableToDetermineUser': EnTranslations.unableToDetermineUser,
      'userBlocked': EnTranslations.userBlocked,
      'userUnblocked': EnTranslations.userUnblocked,
      'blockUser': EnTranslations.blockUser,
      'reportUser': EnTranslations.reportUser,
      'sendImage': EnTranslations.sendImage,
      'sendVideo': EnTranslations.sendVideo,
      'sendDocument': EnTranslations.sendDocument,
      'uploadingImage': EnTranslations.uploadingImage,
      'uploadingVideo': EnTranslations.uploadingVideo,
      'uploadingDocument': EnTranslations.uploadingDocument,
      'sendImageFailed': EnTranslations.sendImageFailed,
      'sendVideoFailed': EnTranslations.sendVideoFailed,
      'sendDocumentFailed': EnTranslations.sendDocumentFailed,
      'onlineNow': EnTranslations.onlineNow,
      'noMessagesYet': EnTranslations.noMessagesYet,
      'startConversationPrompt': EnTranslations.startConversationPrompt,
      'cannotOpenFile': EnTranslations.cannotOpenFile,
      'reviews': EnTranslations.reviews,
      'male': EnTranslations.male,
      'female': EnTranslations.female,
      'yearsOldSuffix': EnTranslations.yearsOldSuffix,
      'verifiedBadge': EnTranslations.verifiedBadge,
      'proBadge': EnTranslations.proBadge,
      'recommendedBadge': EnTranslations.recommendedBadge,
      'newBadge': EnTranslations.newBadge,
      'availableTodayBadge': EnTranslations.availableTodayBadge,
      'offerBadge': EnTranslations.offerBadge,
      'notifications': EnTranslations.notifications,
      'noNotifications': EnTranslations.noNotifications,
      'readAllNotifications': EnTranslations.readAllNotifications,
      'userNotAuthenticated': EnTranslations.userNotAuthenticated,
      'loadNotificationsFailed': EnTranslations.loadNotificationsFailed,
      'markNotificationReadFailed': EnTranslations.markNotificationReadFailed,
      'markAllNotificationsReadFailed':
          EnTranslations.markAllNotificationsReadFailed,
      'deleteNotificationFailed': EnTranslations.deleteNotificationFailed,
      'settings': EnTranslations.settings,
      'notificationsSection': EnTranslations.notificationsSection,
      'appearanceSection': EnTranslations.appearanceSection,
      'accessibilitySection': EnTranslations.accessibilitySection,
      'legalSection': EnTranslations.legalSection,
      'language': EnTranslations.language,
      'darkMode': EnTranslations.darkMode,
      'darkModeSubtitle': EnTranslations.darkModeSubtitle,
      'logout': EnTranslations.logout,
      'logoutSuccess': EnTranslations.logoutSuccess,
      'logoutFailed': EnTranslations.logoutFailed,
      'deleteAccount': EnTranslations.deleteAccount,
      'deleteAccountConfirm': EnTranslations.deleteAccountConfirm,
      'deleteAccountSuccess': EnTranslations.deleteAccountSuccess,
      'deleteAccountFailed': EnTranslations.deleteAccountFailed,
      'noUserLoggedIn': EnTranslations.noUserLoggedIn,
      'enableNotifications': EnTranslations.enableNotifications,
      'notificationsSubtitle': EnTranslations.notificationsSubtitle,
      'reduceMotion': EnTranslations.reduceMotion,
      'reduceMotionSubtitle': EnTranslations.reduceMotionSubtitle,
      'languageChanged': EnTranslations.languageChanged,
      'privacy': EnTranslations.privacy,
      'terms': EnTranslations.terms,
      'accept': EnTranslations.accept,
      'reject': EnTranslations.reject,
      'dashboard': EnTranslations.dashboard,
      'myBookings': EnTranslations.myBookings,
      'favorites': EnTranslations.favorites,
      'availability': EnTranslations.availability,
      'manageSlots': EnTranslations.manageSlots,
      'weeklyTemplate': EnTranslations.weeklyTemplate,
      'popularSpecialties': EnTranslations.popularSpecialties,
      'recentSearches': EnTranslations.recentSearches,
      'clearAll': EnTranslations.clearAll,
      'missingReviewInfo': EnTranslations.missingReviewInfo,
      'payment': EnTranslations.payment,
      'payDeposit': EnTranslations.payDeposit,
      'payFull': EnTranslations.payFull,
      'paymentSuccessful': EnTranslations.paymentSuccessful,
      'paymentFailed': EnTranslations.paymentFailed,
      'paymentsUnavailable': EnTranslations.paymentsUnavailable,
      'createPost': EnTranslations.createPost,
      'createStory': EnTranslations.createStory,
      'addPhoto': EnTranslations.addPhoto,
      'camera': EnTranslations.camera,
      'gallery': EnTranslations.gallery,
      'captionOptional': EnTranslations.captionOptional,
      'sharePost': EnTranslations.sharePost,
      'shareStory': EnTranslations.shareStory,
      'mediaRequired': EnTranslations.mediaRequired,
      'notPhotographer': EnTranslations.notPhotographer,
      'postPublished': EnTranslations.postPublished,
      'storyPublished': EnTranslations.storyPublished,
      'requests': EnTranslations.requests,
      'myRequests': EnTranslations.myRequests,
      'createRequest': EnTranslations.createRequest,
      'editRequest': EnTranslations.editRequest,
      'requestDetails': EnTranslations.requestDetails,
      'requestNotFound': EnTranslations.requestNotFound,
      'requestLoadError': EnTranslations.requestLoadError,
      'noDeadline': EnTranslations.noDeadline,
      'offersClosed': EnTranslations.offersClosed,
      'receivingOffers': EnTranslations.receivingOffers,
      'photographyType': EnTranslations.photographyType,
      'styleLabel': EnTranslations.styleLabel,
      'dateLabel': EnTranslations.dateLabel,
      'timeLabel': EnTranslations.timeLabel,
      'locationLabel': EnTranslations.locationLabel,
      'mapLabel': EnTranslations.mapLabel,
      'addressLabel': EnTranslations.addressLabel,
      'notesLabel': EnTranslations.notesLabel,
      'viewAll': EnTranslations.viewAll,
      'addressOptional': EnTranslations.addressOptional,
      'addressHint': EnTranslations.addressHint,
      'selectLocationOnMap': EnTranslations.selectLocationOnMap,
      'locationSelected': EnTranslations.locationSelected,
      'budget': EnTranslations.budget,
      'minLabel': EnTranslations.minLabel,
      'maxLabel': EnTranslations.maxLabel,
      'duration': EnTranslations.duration,
      'hours': EnTranslations.hours,
      'deliverables': EnTranslations.deliverables,
      'photosCount': EnTranslations.photosCount,
      'videoMinutes': EnTranslations.videoMinutes,
      'includeVideo': EnTranslations.includeVideo,
      'includeEditing': EnTranslations.includeEditing,
      'additionalNotes': EnTranslations.additionalNotes,
      'addReferenceImages': EnTranslations.addReferenceImages,
      'saveDraft': EnTranslations.saveDraft,
      'publishRequest': EnTranslations.publishRequest,
      'saveChanges': EnTranslations.saveChanges,
      'draftSaved': EnTranslations.draftSaved,
      'requestPublished': EnTranslations.requestPublished,
      'requestUpdated': EnTranslations.requestUpdated,
      'requestSubmitFailed': EnTranslations.requestSubmitFailed,
      'requestCancelFailed': EnTranslations.requestCancelFailed,
      'cancelRequest': EnTranslations.cancelRequest,
      'cancelRequestPrompt': EnTranslations.cancelRequestPrompt,
      'requestCanceled': EnTranslations.requestCanceled,
      'drafts': EnTranslations.drafts,
      'active': EnTranslations.active,
      'closed': EnTranslations.closed,
      'noRequests': EnTranslations.noRequests,
      'noDrafts': EnTranslations.noDrafts,
      'noActiveRequests': EnTranslations.noActiveRequests,
      'noClosedRequests': EnTranslations.noClosedRequests,
      'requestStatusDraft': EnTranslations.requestStatusDraft,
      'requestStatusAwaitingOffers': EnTranslations.requestStatusAwaitingOffers,
      'requestStatusOfferSelected': EnTranslations.requestStatusOfferSelected,
      'requestStatusClosed': EnTranslations.requestStatusClosed,
      'requestStatusCanceled': EnTranslations.requestStatusCanceled,
      'requestStatusExpired': EnTranslations.requestStatusExpired,
      'requestStatusPublished': EnTranslations.requestStatusPublished,
      'offersSection': EnTranslations.offersSection,
      'noOffersYet': EnTranslations.noOffersYet,
      'offersComingSoon': EnTranslations.offersComingSoon,
      'offerRequiredFields': EnTranslations.offerRequiredFields,
      'sendOffer': EnTranslations.sendOffer,
      'sendOfferPrompt': EnTranslations.sendOfferPrompt,
      'acceptOffer': EnTranslations.acceptOffer,
      'acceptOfferPrompt': EnTranslations.acceptOfferPrompt,
      'acceptOfferFailed': EnTranslations.acceptOfferFailed,
      'deliveryInDays': EnTranslations.deliveryInDays,
      'offerSent': EnTranslations.offerSent,
      'offerFailed': EnTranslations.offerFailed,
      'trustScore': EnTranslations.trustScore,
      'trustLevelNew': EnTranslations.trustLevelNew,
      'trustLevelHigh': EnTranslations.trustLevelHigh,
      'trustLevelMedium': EnTranslations.trustLevelMedium,
      'trustLevelLow': EnTranslations.trustLevelLow,
      'priceLabel': EnTranslations.priceLabel,
      'deliveryDays': EnTranslations.deliveryDays,
      'notesOptional': EnTranslations.notesOptional,
      'references': EnTranslations.references,
      'includesVideo': EnTranslations.includesVideo,
      'includesEditing': EnTranslations.includesEditing,
      'budgetFrom': EnTranslations.budgetFrom,
      'budgetUpTo': EnTranslations.budgetUpTo,
      'requestsEmptyMessage': EnTranslations.requestsEmptyMessage,
      'openRequests': EnTranslations.openRequests,
      'noRequestsFound': EnTranslations.noRequestsFound,
      'noRequestsFoundMessage': EnTranslations.noRequestsFoundMessage,
      'bookingRoom': EnTranslations.bookingRoom,
      'bookingNotFound': EnTranslations.bookingNotFound,
      'bookingLoadError': EnTranslations.bookingLoadError,
      'startJob': EnTranslations.startJob,
      'uploadDelivery': EnTranslations.uploadDelivery,
      'acceptDelivery': EnTranslations.acceptDelivery,
      'requestRevision': EnTranslations.requestRevision,
      'openDispute': EnTranslations.openDispute,
      'cancelBooking': EnTranslations.cancelBooking,
      'bookingCancelPrompt': EnTranslations.bookingCancelPrompt,
      'bookingCancelSuccess': EnTranslations.bookingCancelSuccess,
      'bookingCancelFailed': EnTranslations.bookingCancelFailed,
      'bookingUpdateFailed': EnTranslations.bookingUpdateFailed,
      'disputeOpenFailed': EnTranslations.disputeOpenFailed,
      'revisionLimitReached': EnTranslations.revisionLimitReached,
      'revisionDescribeChanges': EnTranslations.revisionDescribeChanges,
      'timeline': EnTranslations.timeline,
      'delivery': EnTranslations.delivery,
      'filesLabel': EnTranslations.filesLabel,
      'addPhotos': EnTranslations.addPhotos,
      'addVideo': EnTranslations.addVideo,
      'submitDelivery': EnTranslations.submitDelivery,
      'leaveReview': EnTranslations.leaveReview,
      'deliveryFilesRequired': EnTranslations.deliveryFilesRequired,
      'deliverySubmitFailed': EnTranslations.deliverySubmitFailed,
      'noDeliveryYet': EnTranslations.noDeliveryYet,
      'photos': EnTranslations.photos,
      'videos': EnTranslations.videos,
      'note': EnTranslations.note,
      'revisionRequest': EnTranslations.revisionRequest,
      'bookingStarted': EnTranslations.bookingStarted,
      'bookingCompleted': EnTranslations.bookingCompleted,
      'bookingCanceledMessage': EnTranslations.bookingCanceledMessage,
      'bookingCanceled': EnTranslations.bookingCanceled,
      'bookingAcceptedMessage': EnTranslations.bookingAcceptedMessage,
      'bookingAcceptFailed': EnTranslations.bookingAcceptFailed,
      'bookingRejectedMessage': EnTranslations.bookingRejectedMessage,
      'bookingRejectFailed': EnTranslations.bookingRejectFailed,
      'disputeOpened': EnTranslations.disputeOpened,
      'bookingInProgress': EnTranslations.bookingInProgress,
      'bookingAwaitingDelivery': EnTranslations.bookingAwaitingDelivery,
      'bookingDelivered': EnTranslations.bookingDelivered,
      'bookingRevisionRequested': EnTranslations.bookingRevisionRequested,
      'bookingDisputeOpen': EnTranslations.bookingDisputeOpen,
      'adminDashboard': EnTranslations.adminDashboard,
      'adminDisputes': EnTranslations.adminDisputes,
      'adminReports': EnTranslations.adminReports,
      'adminUsers': EnTranslations.adminUsers,
      'requestsToday': EnTranslations.requestsToday,
      'totalBookings': EnTranslations.totalBookings,
      'cancellations': EnTranslations.cancellations,
      'openDisputesCount': EnTranslations.openDisputesCount,
      'reviewDisputes': EnTranslations.reviewDisputes,
      'reviewReports': EnTranslations.reviewReports,
      'manageUsers': EnTranslations.manageUsers,
      'noDisputes': EnTranslations.noDisputes,
      'noDisputesMessage': EnTranslations.noDisputesMessage,
      'disputeDetails': EnTranslations.disputeDetails,
      'bookingSummary': EnTranslations.bookingSummary,
      'resolutionNote': EnTranslations.resolutionNote,
      'resolveRelease': EnTranslations.resolveRelease,
      'resolveRefund': EnTranslations.resolveRefund,
      'resolvePartial': EnTranslations.resolvePartial,
      'disputeResolved': EnTranslations.disputeResolved,
      'disputeResolveFailed': EnTranslations.disputeResolveFailed,
      'reportsEmpty': EnTranslations.reportsEmpty,
      'usersEmpty': EnTranslations.usersEmpty,
      'markResolved': EnTranslations.markResolved,
      'dismiss': EnTranslations.dismiss,
      'warningSent': EnTranslations.warningSent,
      'warningFailed': EnTranslations.warningFailed,
      'block': EnTranslations.block,
      'unblock': EnTranslations.unblock,
      'sendWarning': EnTranslations.sendWarning,
      'accountBlocked': EnTranslations.accountBlocked,
      'accountBlockedMessage': EnTranslations.accountBlockedMessage,
      'signOut': EnTranslations.signOut,
      'policies': EnTranslations.policies,
      'bookingPolicies': EnTranslations.bookingPolicies,
      'policiesSubtitle': EnTranslations.policiesSubtitle,
      'bookingPoliciesSubtitle': EnTranslations.bookingPoliciesSubtitle,
      'readPolicies': EnTranslations.readPolicies,
      'agreeToTerms': EnTranslations.agreeToTerms,
      'iUnderstand': EnTranslations.iUnderstand,
      'escrowPolicy': EnTranslations.escrowPolicy,
      'escrowPolicyDesc': EnTranslations.escrowPolicyDesc,
      'escrowReleaseTitle': EnTranslations.escrowReleaseTitle,
      'escrowReleaseDesc': EnTranslations.escrowReleaseDesc,
      'revisionPolicy': EnTranslations.revisionPolicy,
      'revisionPolicyDesc': EnTranslations.revisionPolicyDesc,
      'revisionExtraTitle': EnTranslations.revisionExtraTitle,
      'revisionExtraDesc': EnTranslations.revisionExtraDesc,
      'cancellationPolicy': EnTranslations.cancellationPolicy,
      'cancellation48Hours': EnTranslations.cancellation48Hours,
      'cancellation48HoursAfter': EnTranslations.cancellation48HoursAfter,
      'cancellationPhotographer': EnTranslations.cancellationPhotographer,
      'disputePolicy': EnTranslations.disputePolicy,
      'disputePolicyDesc': EnTranslations.disputePolicyDesc,
      'disputeProcess': EnTranslations.disputeProcess,
      'disputeStep1': EnTranslations.disputeStep1,
      'disputeStep2': EnTranslations.disputeStep2,
      'disputeStep3': EnTranslations.disputeStep3,
      'disputeStep4': EnTranslations.disputeStep4,
      'trustScorePolicy': EnTranslations.trustScorePolicy,
      'trustScoreDesc': EnTranslations.trustScoreDesc,
      'trustMetric1': EnTranslations.trustMetric1,
      'trustMetric2': EnTranslations.trustMetric2,
      'trustMetric3': EnTranslations.trustMetric3,
      'trustMetric4': EnTranslations.trustMetric4,
      'trustMetric5': EnTranslations.trustMetric5,
      'privacyPolicy': EnTranslations.privacyPolicy,
      'privacyPhoneNumber': EnTranslations.privacyPhoneNumber,
      'privacyFiles': EnTranslations.privacyFiles,
      'privacyContact': EnTranslations.privacyContact,
      'privacyLinks': EnTranslations.privacyLinks,
      'paymentPolicy': EnTranslations.paymentPolicy,
      'paymentDeposit': EnTranslations.paymentDeposit,
      'paymentRelease': EnTranslations.paymentRelease,
      'paymentRefund': EnTranslations.paymentRefund,
      'addReview': EnTranslations.addReview,
      'addToFavorites': EnTranslations.addToFavorites,
      'additionalDetails': EnTranslations.additionalDetails,
      'applyFilters': EnTranslations.applyFilters,
      'bookingConfirmed': EnTranslations.bookingConfirmed,
      'bookingPending': EnTranslations.bookingPending,
      'bookingRejected': EnTranslations.bookingRejected,
      'clearFilters': EnTranslations.clearFilters,
      'commentOptional': EnTranslations.commentOptional,
      'communication': EnTranslations.communication,
      'deliverySpeed': EnTranslations.deliverySpeed,
      'detailsLabel': EnTranslations.detailsLabel,
      'distanceUnavailable': EnTranslations.distanceUnavailable,
      'distanceUnit': EnTranslations.distanceUnit,
      'downloadLinks': EnTranslations.downloadLinks,
      'estimatedDistance': EnTranslations.estimatedDistance,
      'filterByGovernorate': EnTranslations.filterByGovernorate,
      'filterByPrice': EnTranslations.filterByPrice,
      'filterByRating': EnTranslations.filterByRating,
      'filterBySpecialty': EnTranslations.filterBySpecialty,
      'location': EnTranslations.location,
      'maxPrice': EnTranslations.maxPrice,
      'minPrice': EnTranslations.minPrice,
      'notes': EnTranslations.notes,
      'onTimeDelivery': EnTranslations.onTimeDelivery,
      'photographerInGov': EnTranslations.photographerInGov,
      'policyHighlightOne': EnTranslations.policyHighlightOne,
      'policyHighlightThree': EnTranslations.policyHighlightThree,
      'policyHighlightTwo': EnTranslations.policyHighlightTwo,
      'policyHighlightsTitle': EnTranslations.policyHighlightsTitle,
      'price': EnTranslations.price,
      'quality': EnTranslations.quality,
      'rateExperience': EnTranslations.rateExperience,
      'rating': EnTranslations.rating,
      'readFullTerms': EnTranslations.readFullTerms,
      'reasonLabel': EnTranslations.reasonLabel,
      'recommendQuestion': EnTranslations.recommendQuestion,
      'removeFromFavorites': EnTranslations.removeFromFavorites,
      'report': EnTranslations.report,
      'reportContent': EnTranslations.reportContent,
      'reviewCommentHint': EnTranslations.reviewCommentHint,
      'reviewSubmitFailed': EnTranslations.reviewSubmitFailed,
      'reviewSubmitted': EnTranslations.reviewSubmitted,
      'searchPhotographers': EnTranslations.searchPhotographers,
      'selectReason': EnTranslations.selectReason,
      'sessionType': EnTranslations.sessionType,
      'signInWith': EnTranslations.signInWith,
      'smartReview': EnTranslations.smartReview,
      'smartReviewSubtitle': EnTranslations.smartReviewSubtitle,
      'sortBy': EnTranslations.sortBy,
      'submitReport': EnTranslations.submitReport,
      'submitReview': EnTranslations.submitReview,
      'suggestAlternative': EnTranslations.suggestAlternative,
      'todaySchedule': EnTranslations.todaySchedule,
      'total': EnTranslations.total,
      'typing': EnTranslations.typing,
      'writeComment': EnTranslations.writeComment,
      'errorNetworkMessage': EnTranslations.errorNetworkMessage,
      'errorServerMessage': EnTranslations.errorServerMessage,
      'errorSessionExpired': EnTranslations.errorSessionExpired,
      'errorUnexpected': EnTranslations.errorUnexpected,
      'sendReport': EnTranslations.sendReport,
      'reportSent': EnTranslations.reportSent,
      'restartAppPrompt': EnTranslations.restartAppPrompt,
      'reportIdLabel': EnTranslations.reportIdLabel,
      'offlineWeakConnection': EnTranslations.offlineWeakConnection,
      'offlineNoConnection': EnTranslations.offlineNoConnection,
      'lastOnlineLabel': EnTranslations.lastOnlineLabel,
      'justNow': EnTranslations.justNow,
      'minutesAgoTemplate': EnTranslations.minutesAgoTemplate,
      'updateAvailableTitle': EnTranslations.updateAvailableTitle,
      'updateAvailableBody': EnTranslations.updateAvailableBody,
      'updateAction': EnTranslations.updateAction,
      'laterAction': EnTranslations.laterAction,
      'forceUpdateTitle': EnTranslations.forceUpdateTitle,
      'forceUpdateBody': EnTranslations.forceUpdateBody,
      'updateNowAction': EnTranslations.updateNowAction,
      'securityMaintenanceTitle': EnTranslations.securityMaintenanceTitle,
      'secureConnectionFailed': EnTranslations.secureConnectionFailed,
      'securityAlertTitle': EnTranslations.securityAlertTitle,
      'continueAction': EnTranslations.continueAction,
      'okAction': EnTranslations.okAction,
      'untrustedDeviceWarning': EnTranslations.untrustedDeviceWarning,
      'confirmIdentityForPayment': EnTranslations.confirmIdentityForPayment,
      'identityConfirmationFailed':
          EnTranslations.identityConfirmationFailed,
      'enableNotificationsTitle': EnTranslations.enableNotificationsTitle,
      'enableNotificationsBody': EnTranslations.enableNotificationsBody,
      'allowAction': EnTranslations.allowAction,
      'pageNotFound': EnTranslations.pageNotFound,
      'goHomeAction': EnTranslations.goHomeAction,
      'bookingLoadFailed': EnTranslations.bookingLoadFailed,
      'missingRouteParam': EnTranslations.missingRouteParam,
      'skip': EnTranslations.skip,
      'startNow': EnTranslations.startNow,
      'onboardingSlide1Title': EnTranslations.onboardingSlide1Title,
      'onboardingSlide1Body': EnTranslations.onboardingSlide1Body,
      'onboardingSlide2Title': EnTranslations.onboardingSlide2Title,
      'onboardingSlide2Body': EnTranslations.onboardingSlide2Body,
      'onboardingSlide3Title': EnTranslations.onboardingSlide3Title,
      'onboardingSlide3Body': EnTranslations.onboardingSlide3Body,
      'loginSubtitle': EnTranslations.loginSubtitle,
      'phoneOrUsername': EnTranslations.phoneOrUsername,
      'passwordLabel': EnTranslations.passwordLabel,
      'forgotPasswordQ': EnTranslations.forgotPasswordQ,
      'loginAction': EnTranslations.loginAction,
      'noAccountPrompt': EnTranslations.noAccountPrompt,
      'createAccountAction': EnTranslations.createAccountAction,
      'registerSubtitle': EnTranslations.registerSubtitle,
      'haveAccountPrompt': EnTranslations.haveAccountPrompt,
      'chooseAccountType': EnTranslations.chooseAccountType,
      'basicInfoSection': EnTranslations.basicInfoSection,
      'firstNameLabel': EnTranslations.firstNameLabel,
      'lastNameLabel': EnTranslations.lastNameLabel,
      'usernameLabel': EnTranslations.usernameLabel,
      'usernameHint': EnTranslations.usernameHint,
      'personalInfoSection': EnTranslations.personalInfoSection,
      'birthdateLabel': EnTranslations.birthdateLabel,
      'chooseBirthdate': EnTranslations.chooseBirthdate,
      'provinceLabel': EnTranslations.provinceLabel,
      'phoneVerificationSection': EnTranslations.phoneVerificationSection,
      'resendInSecondsTemplate': EnTranslations.resendInSecondsTemplate,
      'sendOtpViaSms': EnTranslations.sendOtpViaSms,
      'confirmPasswordLabel': EnTranslations.confirmPasswordLabel,
      'forgotPasswordTitle': EnTranslations.forgotPasswordTitle,
      'forgotPasswordSubtitle': EnTranslations.forgotPasswordSubtitle,
      'newPasswordLabel': EnTranslations.newPasswordLabel,
      'setPasswordAction': EnTranslations.setPasswordAction,
      'rememberedPasswordPrompt': EnTranslations.rememberedPasswordPrompt,
      'venueOwner': EnTranslations.venueOwner,
      'loginMissingCredentials': EnTranslations.loginMissingCredentials,
      'invalidCredentials': EnTranslations.invalidCredentials,
      'firstNameRequired': EnTranslations.firstNameRequired,
      'lastNameRequired': EnTranslations.lastNameRequired,
      'usernameLengthError': EnTranslations.usernameLengthError,
      'usernameNoSpaces': EnTranslations.usernameNoSpaces,
      'usernameInvalidChars': EnTranslations.usernameInvalidChars,
      'chooseGenderError': EnTranslations.chooseGenderError,
      'chooseBirthdateError': EnTranslations.chooseBirthdateError,
      'agePolicyError': EnTranslations.agePolicyError,
      'chooseProvinceError': EnTranslations.chooseProvinceError,
      'invalidPhoneError': EnTranslations.invalidPhoneError,
      'enterOtpError': EnTranslations.enterOtpError,
      'passwordPolicyError': EnTranslations.passwordPolicyError,
      'passwordMismatchError': EnTranslations.passwordMismatchError,
      'sendOtpFirstError': EnTranslations.sendOtpFirstError,
      'otpSendFailedError': EnTranslations.otpSendFailedError,
      'tryAgainLater': EnTranslations.tryAgainLater,
      'datePickerChoose': EnTranslations.datePickerChoose,
      'serviceUnavailableUpdate': EnTranslations.serviceUnavailableUpdate,
      'usernameTaken': EnTranslations.usernameTaken,
      'phoneTaken': EnTranslations.phoneTaken,
      'codeExpired': EnTranslations.codeExpired,
      'invalidOtpCode': EnTranslations.invalidOtpCode,
      'waitBeforeNewCode': EnTranslations.waitBeforeNewCode,
      'stepOfTemplate': EnTranslations.stepOfTemplate,
      'paymentCancelled': EnTranslations.paymentCancelled,
      'confirmPaymentTitle': EnTranslations.confirmPaymentTitle,
      'confirmPaymentBodyTemplate': EnTranslations.confirmPaymentBodyTemplate,
      'fraudAmountMismatch': EnTranslations.fraudAmountMismatch,
      'fraudUntrustedEnv': EnTranslations.fraudUntrustedEnv,
      'fraudModifiedDevice': EnTranslations.fraudModifiedDevice,
      'fraudRelogin': EnTranslations.fraudRelogin,
      'loginToViewFavorites': EnTranslations.loginToViewFavorites,
      'favoritesLoadFailed': EnTranslations.favoritesLoadFailed,
      'loginToManageFavorites': EnTranslations.loginToManageFavorites,
      'removedFromFavorites': EnTranslations.removedFromFavorites,
      'removeFromFavoritesFailed': EnTranslations.removeFromFavoritesFailed,
      'noFavoritesTitle': EnTranslations.noFavoritesTitle,
      'noFavoritesMessage': EnTranslations.noFavoritesMessage,
      'searchTipFavorites': EnTranslations.searchTipFavorites,
      'achievementsTitle': EnTranslations.achievementsTitle,
      'progressLabel': EnTranslations.progressLabel,
      'allAchievements': EnTranslations.allAchievements,
      'achievementUnlocked': EnTranslations.achievementUnlocked,
      'pointsEarnedTemplate': EnTranslations.pointsEarnedTemplate,
      'totalProgress': EnTranslations.totalProgress,
      'rewardPointsTemplate': EnTranslations.rewardPointsTemplate,
      'forYouTab': EnTranslations.forYouTab,
      'mostViewedTab': EnTranslations.mostViewedTab,
      'weddingsTab': EnTranslations.weddingsTab,
      'sessionsTab': EnTranslations.sessionsTab,
      'discussionsTab': EnTranslations.discussionsTab,
      'dashboardSearchHint': EnTranslations.dashboardSearchHint,
      'noPostsYet': EnTranslations.noPostsYet,
      'noPostsSubtitle': EnTranslations.noPostsSubtitle,
      'sponsoredLabel': EnTranslations.sponsoredLabel,
      'featuredLabel': EnTranslations.featuredLabel,
      'downloadLinkOpenFailed': EnTranslations.downloadLinkOpenFailed,
      'emailInvalid': EnTranslations.emailInvalid,
      'nameRequired': EnTranslations.nameRequired,
      'nameTooLong': EnTranslations.nameTooLong,
      'nameInvalidChars': EnTranslations.nameInvalidChars,
      'otpSixDigits': EnTranslations.otpSixDigits,
      'futureDateRequired': EnTranslations.futureDateRequired,
      'mustBeAdult': EnTranslations.mustBeAdult,
      'hoursAgoTemplate': EnTranslations.hoursAgoTemplate,
      'daysAgoTemplate': EnTranslations.daysAgoTemplate,
      'weeksAgoTemplate': EnTranslations.weeksAgoTemplate,
      'remainingHoursTemplate': EnTranslations.remainingHoursTemplate,
      'remainingMinutesTemplate': EnTranslations.remainingMinutesTemplate,
      'endingSoon': EnTranslations.endingSoon,
      'achFirstBookingTitle': EnTranslations.achFirstBookingTitle,
      'achFirstBookingDesc': EnTranslations.achFirstBookingDesc,
      'achBookingExpertTitle': EnTranslations.achBookingExpertTitle,
      'achBookingExpertDesc': EnTranslations.achBookingExpertDesc,
      'achBookingProTitle': EnTranslations.achBookingProTitle,
      'achBookingProDesc': EnTranslations.achBookingProDesc,
      'achReviewCollectorTitle': EnTranslations.achReviewCollectorTitle,
      'achReviewCollectorDesc': EnTranslations.achReviewCollectorDesc,
      'achTopRatedTitle': EnTranslations.achTopRatedTitle,
      'achTopRatedDesc': EnTranslations.achTopRatedDesc,
      'achPopularTitle': EnTranslations.achPopularTitle,
      'achPopularDesc': EnTranslations.achPopularDesc,
      'achEarlyBirdTitle': EnTranslations.achEarlyBirdTitle,
      'achEarlyBirdDesc': EnTranslations.achEarlyBirdDesc,
      'achNightOwlTitle': EnTranslations.achNightOwlTitle,
      'achNightOwlDesc': EnTranslations.achNightOwlDesc,
      'achMoneyMakerTitle': EnTranslations.achMoneyMakerTitle,
      'achMoneyMakerDesc': EnTranslations.achMoneyMakerDesc,
      'tierPlatinumPlus': EnTranslations.tierPlatinumPlus,
      'tierGoldPlus': EnTranslations.tierGoldPlus,
      'tierSilverPlus': EnTranslations.tierSilverPlus,
      'tierBronzePlus': EnTranslations.tierBronzePlus,
      'loyaltyBookingCompleted': EnTranslations.loyaltyBookingCompleted,
      'loyaltyReferFriend': EnTranslations.loyaltyReferFriend,
      'loyaltyWriteReview': EnTranslations.loyaltyWriteReview,
      'loyaltyFirstBooking': EnTranslations.loyaltyFirstBooking,
      'loyaltyRedeem': EnTranslations.loyaltyRedeem,
      'pointsLabel': EnTranslations.pointsLabel,
      'placeLabel': EnTranslations.placeLabel,
      'goldenHourMorning': EnTranslations.goldenHourMorning,
      'goldenHourEvening': EnTranslations.goldenHourEvening,
      'goldenHourNext': EnTranslations.goldenHourNext,
      'endsAtTemplate': EnTranslations.endsAtTemplate,
      'morningLabel': EnTranslations.morningLabel,
      'eveningLabel': EnTranslations.eveningLabel,
      'tomorrowMorningLabel': EnTranslations.tomorrowMorningLabel,
      'amMarker': EnTranslations.amMarker,
      'pmMarker': EnTranslations.pmMarker,
      'inMinutesTemplate': EnTranslations.inMinutesTemplate,
      'inHoursTemplate': EnTranslations.inHoursTemplate,
      'inHoursMinutesTemplate': EnTranslations.inHoursMinutesTemplate,
      'happeningNowTemplate': EnTranslations.happeningNowTemplate,
      'photographersCountTemplate': EnTranslations.photographersCountTemplate,
      'emptyBookingsTitle': EnTranslations.emptyBookingsTitle,
      'emptyBookingsMessage': EnTranslations.emptyBookingsMessage,
      'browsePhotographers': EnTranslations.browsePhotographers,
      'emptyFavoritesTitle': EnTranslations.emptyFavoritesTitle,
      'emptyFavoritesMessage': EnTranslations.emptyFavoritesMessage,
      'exploreNow': EnTranslations.exploreNow,
      'emptyChatsTitle': EnTranslations.emptyChatsTitle,
      'emptyChatsMessage': EnTranslations.emptyChatsMessage,
      'findPhotographer': EnTranslations.findPhotographer,
      'emptyNotificationsTitle': EnTranslations.emptyNotificationsTitle,
      'emptyNotificationsMessage': EnTranslations.emptyNotificationsMessage,
      'emptySearchQueryTemplate': EnTranslations.emptySearchQueryTemplate,
      'emptySearchFiltersMessage': EnTranslations.emptySearchFiltersMessage,
      'emptyStoriesTitle': EnTranslations.emptyStoriesTitle,
      'emptyStoriesMessage': EnTranslations.emptyStoriesMessage,
      'emptyReviewsTitle': EnTranslations.emptyReviewsTitle,
      'emptyReviewsMessage': EnTranslations.emptyReviewsMessage,
      'writeReviewAction': EnTranslations.writeReviewAction,
      'emptyPortfolioTitle': EnTranslations.emptyPortfolioTitle,
      'emptyPortfolioMessage': EnTranslations.emptyPortfolioMessage,
      'addPhotosAction': EnTranslations.addPhotosAction,
      'emptyTransactionsTitle': EnTranslations.emptyTransactionsTitle,
      'emptyTransactionsMessage': EnTranslations.emptyTransactionsMessage,
      'errorOccurredTitle': EnTranslations.errorOccurredTitle,
      'errorGenericMessage': EnTranslations.errorGenericMessage,
      'noConnectionTitle': EnTranslations.noConnectionTitle,
      'noConnectionMessage': EnTranslations.noConnectionMessage,
      'createLabel': EnTranslations.createLabel,
      'profileTab': EnTranslations.profileTab,
      'mainNavigationLabel': EnTranslations.mainNavigationLabel,
      'newReel': EnTranslations.newReel,
      'newStory': EnTranslations.newStory,
      'sponsoredAdTitle': EnTranslations.sponsoredAdTitle,
      'plansTitle': EnTranslations.plansTitle,
      'newRequest': EnTranslations.newRequest,
      'venuesTitle': EnTranslations.venuesTitle,
      'photoSpotsTitle': EnTranslations.photoSpotsTitle,
      'whatToCreate': EnTranslations.whatToCreate,
      'placesTitle': EnTranslations.placesTitle,
      'photographersTitle': EnTranslations.photographersTitle,
      'followTab': EnTranslations.followTab,
      'errBadRequest': EnTranslations.errBadRequest,
      'errForbidden': EnTranslations.errForbidden,
      'errNotFound': EnTranslations.errNotFound,
      'errConflict': EnTranslations.errConflict,
      'errValidation': EnTranslations.errValidation,
      'errRateLimited': EnTranslations.errRateLimited,
      'errServer': EnTranslations.errServer,
      'errServiceUnavailable': EnTranslations.errServiceUnavailable,
      'reportInappropriate': EnTranslations.reportInappropriate,
      'reportFraudImpersonation': EnTranslations.reportFraudImpersonation,
      'reportAbuse': EnTranslations.reportAbuse,
      'reportStolenImages': EnTranslations.reportStolenImages,
      'reportMisinformation': EnTranslations.reportMisinformation,
      'otherLabel': EnTranslations.otherLabel,
      'sendReportAction': EnTranslations.sendReportAction,
      'reportReasonField': EnTranslations.reportReasonField,
      'extraDetailsOptional': EnTranslations.extraDetailsOptional,
      'reportSentThanks': EnTranslations.reportSentThanks,
      'reportSendFailed': EnTranslations.reportSendFailed,
      'submitReportAction': EnTranslations.submitReportAction,
      'raspIntrusionLogout': EnTranslations.raspIntrusionLogout,
      'raspIntegrityFailed': EnTranslations.raspIntegrityFailed,
      'raspModifiedDevice': EnTranslations.raspModifiedDevice,
      'raspUntrustedEnv': EnTranslations.raspUntrustedEnv,
      'uploadTimeout': EnTranslations.uploadTimeout,
      'connectionTimeoutMsg': EnTranslations.connectionTimeoutMsg,
      'confirmIdentityToContinue': EnTranslations.confirmIdentityToContinue,
      'moodWarmSoft': EnTranslations.moodWarmSoft,
      'moodUrbanSharp': EnTranslations.moodUrbanSharp,
      'moodRomantic': EnTranslations.moodRomantic,
      'moodNaturalOutdoor': EnTranslations.moodNaturalOutdoor,
      'moodDramaticDeep': EnTranslations.moodDramaticDeep,
      'waitlistFullMsg': EnTranslations.waitlistFullMsg,
      'waitlistBaghdadOnly': EnTranslations.waitlistBaghdadOnly,
      'waitlistNotifyExpansion': EnTranslations.waitlistNotifyExpansion,
      'waitlistNotifyCity': EnTranslations.waitlistNotifyCity,
      'nameLabel': EnTranslations.nameLabel,
      'enterName': EnTranslations.enterName,
      'enterValidPhone': EnTranslations.enterValidPhone,
      'cityLabel': EnTranslations.cityLabel,
      'enterCity': EnTranslations.enterCity,
      'accountTypeLabel': EnTranslations.accountTypeLabel,
      'interestRegistered': EnTranslations.interestRegistered,
      'notifyOnExpand': EnTranslations.notifyOnExpand,
      'allFilter': EnTranslations.allFilter,
      'openFilter': EnTranslations.openFilter,
      'resolvedFilter': EnTranslations.resolvedFilter,
      'searchReportsHint': EnTranslations.searchReportsHint,
      'searchUsersHint': EnTranslations.searchUsersHint,
      'deleteViaPolicy': EnTranslations.deleteViaPolicy,
      'phoneAfterBooking': EnTranslations.phoneAfterBooking,
      'privacyContactNote': EnTranslations.privacyContactNote,
      'yesterday': EnTranslations.yesterday,
      'conversationFallback': EnTranslations.conversationFallback,
      'noChatsYet': EnTranslations.noChatsYet,
      'chatsLoadFailed': EnTranslations.chatsLoadFailed,
      'searchMessagesHint': EnTranslations.searchMessagesHint,
      'photographersFilter': EnTranslations.photographersFilter,
      'arrangementsFilter': EnTranslations.arrangementsFilter,
      'quickAskPrice': EnTranslations.quickAskPrice,
      'quickAskAvailable': EnTranslations.quickAskAvailable,
      'quickAskEvent': EnTranslations.quickAskEvent,
      'quickAskPackages': EnTranslations.quickAskPackages,
      'coursesListTitle': EnTranslations.coursesListTitle,
      'coursesLoadError': EnTranslations.coursesLoadError,
      'noCoursesAvailable': EnTranslations.noCoursesAvailable,
      'courseFull': EnTranslations.courseFull,
      'seatsCountTemplate': EnTranslations.seatsCountTemplate,
      'courseLoadFailed': EnTranslations.courseLoadFailed,
      'courseNotFound': EnTranslations.courseNotFound,
      'seatsOfTemplate': EnTranslations.seatsOfTemplate,
      'availableSeats': EnTranslations.availableSeats,
      'sessionsLabel': EnTranslations.sessionsLabel,
      'courseCompleted': EnTranslations.courseCompleted,
      'enrolling': EnTranslations.enrolling,
      'enrollNow': EnTranslations.enrollNow,
      'completeCourseTitleDesc': EnTranslations.completeCourseTitleDesc,
      'invalidPrice': EnTranslations.invalidPrice,
      'invalidSeatsCount': EnTranslations.invalidSeatsCount,
      'addAtLeastOneSession': EnTranslations.addAtLeastOneSession,
      'enterOnlineSessionLink': EnTranslations.enterOnlineSessionLink,
      'currentUserCheckFailed': EnTranslations.currentUserCheckFailed,
      'courseSaveFailed': EnTranslations.courseSaveFailed,
      'editCourse': EnTranslations.editCourse,
      'newCourse': EnTranslations.newCourse,
      'unpublish': EnTranslations.unpublish,
      'publish': EnTranslations.publish,
      'addCourseCover': EnTranslations.addCourseCover,
      'courseTitleLabel': EnTranslations.courseTitleLabel,
      'courseTitleHint': EnTranslations.courseTitleHint,
      'descriptionLabel': EnTranslations.descriptionLabel,
      'courseDescriptionHint': EnTranslations.courseDescriptionHint,
      'courseLocationLabel': EnTranslations.courseLocationLabel,
      'courseLocationHint': EnTranslations.courseLocationHint,
      'onlineSessionLink': EnTranslations.onlineSessionLink,
      'priceIqdLabel': EnTranslations.priceIqdLabel,
      'seatsCountLabel': EnTranslations.seatsCountLabel,
      'addSpecialtyHint': EnTranslations.addSpecialtyHint,
      'addSession': EnTranslations.addSession,
      'savingProgress': EnTranslations.savingProgress,
      'deleteCourseConfirmTemplate': EnTranslations.deleteCourseConfirmTemplate,
      'myTeachingCourses': EnTranslations.myTeachingCourses,
      'noCoursesYet': EnTranslations.noCoursesYet,
      'createFirstCourse': EnTranslations.createFirstCourse,
      'seatsRatioTemplate': EnTranslations.seatsRatioTemplate,
      'published': EnTranslations.published,
      'draft': EnTranslations.draft,
      'paymentStartFailed': EnTranslations.paymentStartFailed,
      'paymentConfirmFailed': EnTranslations.paymentConfirmFailed,
      'paymentProcessError': EnTranslations.paymentProcessError,
      'traineeFallback': EnTranslations.traineeFallback,
      'newEnrollmentTitle': EnTranslations.newEnrollmentTitle,
      'newEnrollmentBodyTemplate': EnTranslations.newEnrollmentBodyTemplate,
      'paymentSuccessTitle': EnTranslations.paymentSuccessTitle,
      'enrolledInCourseTemplate': EnTranslations.enrolledInCourseTemplate,
      'paymentGatewayDisabled': EnTranslations.paymentGatewayDisabled,
      'payingProgress': EnTranslations.payingProgress,
      'payNow': EnTranslations.payNow,
      'myCoursesTitle': EnTranslations.myCoursesTitle,
      'myCoursesLoadError': EnTranslations.myCoursesLoadError,
      'notEnrolledYet': EnTranslations.notEnrolledYet,
      'browseCoursesPrompt': EnTranslations.browseCoursesPrompt,
      'browseCourses': EnTranslations.browseCourses,
      'enrollmentConfirmed': EnTranslations.enrollmentConfirmed,
      'enrollmentCanceled': EnTranslations.enrollmentCanceled,
      'awaitingPayment': EnTranslations.awaitingPayment,
      'noCreatorsForMood': EnTranslations.noCreatorsForMood,
      'tryAnotherMood': EnTranslations.tryAnotherMood,
      'suggestedCreators': EnTranslations.suggestedCreators,
      'moodPrefixTemplate': EnTranslations.moodPrefixTemplate,
      'creatorsCountTemplate': EnTranslations.creatorsCountTemplate,
      'discoverTitle': EnTranslations.discoverTitle,
      'exploreSearchHint': EnTranslations.exploreSearchHint,
      'photographersSection': EnTranslations.photographersSection,
      'photoSpotsSection': EnTranslations.photoSpotsSection,
      'noResultsNow': EnTranslations.noResultsNow,
      'tryRefreshOrSearch': EnTranslations.tryRefreshOrSearch,
      'featuredVenues': EnTranslations.featuredVenues,
      'featuredPhotoSpots': EnTranslations.featuredPhotoSpots,
      'noPhotoSpotsNow': EnTranslations.noPhotoSpotsNow,
      'iraqLabel': EnTranslations.iraqLabel,
      'startsFromTemplate': EnTranslations.startsFromTemplate,
      'placeLoadFailed': EnTranslations.placeLoadFailed,
      'placeDescription': EnTranslations.placeDescription,
      'noDescriptionAvailable': EnTranslations.noDescriptionAvailable,
      'venuesLoadEmpty': EnTranslations.venuesLoadEmpty,
      'venueSearchHint': EnTranslations.venueSearchHint,
      'venueLoadFailed': EnTranslations.venueLoadFailed,
      'venueBookingTitle': EnTranslations.venueBookingTitle,
      'venueBookingSubtitle': EnTranslations.venueBookingSubtitle,
      'eventDateLabel': EnTranslations.eventDateLabel,
      'guestCountLabel': EnTranslations.guestCountLabel,
      'guestCountHint': EnTranslations.guestCountHint,
      'extraNotesLabel': EnTranslations.extraNotesLabel,
      'eventDetailsHint': EnTranslations.eventDetailsHint,
      'bookingSendFailed': EnTranslations.bookingSendFailed,
      'venueDetailsLoadFailed': EnTranslations.venueDetailsLoadFailed,
      'capacityLabelTemplate': EnTranslations.capacityLabelTemplate,
      'aboutVenue': EnTranslations.aboutVenue,
      'upcomingAvailability': EnTranslations.upcomingAvailability,
      'messageAction': EnTranslations.messageAction,
      'yourAvailablePoints': EnTranslations.yourAvailablePoints,
      'pointSingular': EnTranslations.pointSingular,
      'totalLabel': EnTranslations.totalLabel,
      'usedLabel': EnTranslations.usedLabel,
      'discountLabel': EnTranslations.discountLabel,
      'pointsToNextTierTemplate': EnTranslations.pointsToNextTierTemplate,
      'completeBookingAction': EnTranslations.completeBookingAction,
      'plusPointsTemplate': EnTranslations.plusPointsTemplate,
      'pointsInfoTitle': EnTranslations.pointsInfoTitle,
      'pointsInfoBody': EnTranslations.pointsInfoBody,
      'daysAgoPlural': EnTranslations.daysAgoPlural,
      'currentUserUnknown': EnTranslations.currentUserUnknown,
      'chooseItemToPromote': EnTranslations.chooseItemToPromote,
      'sponsoredCampaignDesc': EnTranslations.sponsoredCampaignDesc,
      'promoteAccount': EnTranslations.promoteAccount,
      'promoteReel': EnTranslations.promoteReel,
      'promoteStory': EnTranslations.promoteStory,
      'promoteVenuePlace': EnTranslations.promoteVenuePlace,
      'reelFallbackTemplate': EnTranslations.reelFallbackTemplate,
      'storyFallbackTemplate': EnTranslations.storyFallbackTemplate,
      'noCampaignToShow': EnTranslations.noCampaignToShow,
      'impressionsLabel': EnTranslations.impressionsLabel,
      'clicksLabel': EnTranslations.clicksLabel,
      'spendLabel': EnTranslations.spendLabel,
      'budgetLabel': EnTranslations.budgetLabel,
      'totalBudgetLabel': EnTranslations.totalBudgetLabel,
      'dailyBudgetLabel': EnTranslations.dailyBudgetLabel,
      'spentLabel': EnTranslations.spentLabel,
      'targetsLabel': EnTranslations.targetsLabel,
      'statusUnderReview': EnTranslations.statusUnderReview,
      'statusApproved': EnTranslations.statusApproved,
      'statusRejectedF': EnTranslations.statusRejectedF,
      'statusActive': EnTranslations.statusActive,
      'statusPaused': EnTranslations.statusPaused,
      'statusCompletedF': EnTranslations.statusCompletedF,
      'statusDraft': EnTranslations.statusDraft,
      'myAccountOption': EnTranslations.myAccountOption,
      'featuredReel': EnTranslations.featuredReel,
      'featuredStory': EnTranslations.featuredStory,
      'venueOrPlace': EnTranslations.venueOrPlace,
      'chooseWhatToPromote': EnTranslations.chooseWhatToPromote,
      'accountOption': EnTranslations.accountOption,
      'reelOption': EnTranslations.reelOption,
      'storyOption': EnTranslations.storyOption,
      'targetItemLabel': EnTranslations.targetItemLabel,
      'adDurationLabel': EnTranslations.adDurationLabel,
      'dayUnit': EnTranslations.dayUnit,
      'daysUnit': EnTranslations.daysUnit,
      'regionLabel': EnTranslations.regionLabel,
      'allIraq': EnTranslations.allIraq,
      'governorateOption': EnTranslations.governorateOption,
      'loginFirstOrChooseItem': EnTranslations.loginFirstOrChooseItem,
      'campaignCreateFailed': EnTranslations.campaignCreateFailed,
      'plansAndSubscriptions': EnTranslations.plansAndSubscriptions,
      'yearlyDiscount': EnTranslations.yearlyDiscount,
      'monthly': EnTranslations.monthly,
      'noPlansAvailable': EnTranslations.noPlansAvailable,
      'planActivatedTemplate': EnTranslations.planActivatedTemplate,
      'planActivationFailed': EnTranslations.planActivationFailed,
      'comparePlans': EnTranslations.comparePlans,
      'portfolioImagesTemplate': EnTranslations.portfolioImagesTemplate,
      'reelsPerMonthTemplate': EnTranslations.reelsPerMonthTemplate,
      'betterSearchVisibility': EnTranslations.betterSearchVisibility,
      'basicAnalytics': EnTranslations.basicAnalytics,
      'adsDiscount': EnTranslations.adsDiscount,
      'fasterSupport': EnTranslations.fasterSupport,
      'perMonth': EnTranslations.perMonth,
      'activePlan': EnTranslations.activePlan,
      'choosePlan': EnTranslations.choosePlan,
      'photographerLoadFailed': EnTranslations.photographerLoadFailed,
      'weddingPhotographer': EnTranslations.weddingPhotographer,
      'projectsLabel': EnTranslations.projectsLabel,
      'followersLabel': EnTranslations.followersLabel,
      'followingLabel': EnTranslations.followingLabel,
      'contactAction': EnTranslations.contactAction,
      'worksTab': EnTranslations.worksTab,
      'reviewsTab': EnTranslations.reviewsTab,
      'reelsTab': EnTranslations.reelsTab,
      'followTabLabel': EnTranslations.followTabLabel,
      'sessionsHighlight': EnTranslations.sessionsHighlight,
      'behindScenes': EnTranslations.behindScenes,
      'studioHighlight': EnTranslations.studioHighlight,
      'noWorksYet': EnTranslations.noWorksYet,
      'noReelsYet': EnTranslations.noReelsYet,
      'ratingSummary': EnTranslations.ratingSummary,
      'ratingSummaryTemplate': EnTranslations.ratingSummaryTemplate,
      'verifiedSpecialtyNote': EnTranslations.verifiedSpecialtyNote,
      'usernameReserved': EnTranslations.usernameReserved,
      'usernameFormatError': EnTranslations.usernameFormatError,
      'usernameUnavailable': EnTranslations.usernameUnavailable,
      'usernameVerifyFailed': EnTranslations.usernameVerifyFailed,
      'noSignedInUser': EnTranslations.noSignedInUser,
      'saveError': EnTranslations.saveError,
      'usernameFieldLabel': EnTranslations.usernameFieldLabel,
      'usernameExampleHint': EnTranslations.usernameExampleHint,
      'enterUsername': EnTranslations.enterUsername,
      'usernameFormatNoSpaces': EnTranslations.usernameFormatNoSpaces,
      'minTwoChars': EnTranslations.minTwoChars,
      'checkingProgress': EnTranslations.checkingProgress,
      'usernameAvailable': EnTranslations.usernameAvailable,
      'usernameSuggestions': EnTranslations.usernameSuggestions,
      'loadingShort': EnTranslations.loadingShort,
      'suggestionsAction': EnTranslations.suggestionsAction,
      'emailOptionalLabel': EnTranslations.emailOptionalLabel,
      'emailFormatError': EnTranslations.emailFormatError,
      'fullNameLabel': EnTranslations.fullNameLabel,
      'fullNameHint': EnTranslations.fullNameHint,
      'fullNameRequired': EnTranslations.fullNameRequired,
      'genderLabel': EnTranslations.genderLabel,
      'birthYearLabel': EnTranslations.birthYearLabel,
      'birthYearHint': EnTranslations.birthYearHint,
      'enterBirthYear': EnTranslations.enterBirthYear,
      'birthYearAdultError': EnTranslations.birthYearAdultError,
      'chooseGovernorateHint': EnTranslations.chooseGovernorateHint,
      'confirmOver18Checkbox': EnTranslations.confirmOver18Checkbox,
      'loginToViewPortfolio': EnTranslations.loginToViewPortfolio,
      'portfolioLoadFailed': EnTranslations.portfolioLoadFailed,
      'imageAddFailed': EnTranslations.imageAddFailed,
      'portfolioNeedsSubscription': EnTranslations.portfolioNeedsSubscription,
      'portfolioPhotographersOnly': EnTranslations.portfolioPhotographersOnly,
      'portfolioLimitReached': EnTranslations.portfolioLimitReached,
      'noPortfolioImages': EnTranslations.noPortfolioImages,
      'portfolioShowQuality': EnTranslations.portfolioShowQuality,
      'addFirstImage': EnTranslations.addFirstImage,
      'profileLoadFailed': EnTranslations.profileLoadFailed,
      'enterFieldTemplate': EnTranslations.enterFieldTemplate,
      'completeBasicInfo': EnTranslations.completeBasicInfo,
      'notAdded': EnTranslations.notAdded,
      'accountVerification': EnTranslations.accountVerification,
      'manageTeachingCourses': EnTranslations.manageTeachingCourses,
      'adminPanel': EnTranslations.adminPanel,
      'governoratePrefixTemplate': EnTranslations.governoratePrefixTemplate,
      'locationDescriptionHint': EnTranslations.locationDescriptionHint,
      'searchFailedTryAgain': EnTranslations.searchFailedTryAgain,
      'escrowPolicyTitle': EnTranslations.escrowPolicyTitle,
      'escrowPolicyBody': EnTranslations.escrowPolicyBody,
      'editPolicyTitle': EnTranslations.editPolicyTitle,
      'editPolicyBody': EnTranslations.editPolicyBody,
      'cancelPolicyTitle': EnTranslations.cancelPolicyTitle,
      'cancelPolicyBody': EnTranslations.cancelPolicyBody,
      'privacyPolicyTitle': EnTranslations.privacyPolicyTitle,
      'privacyPolicyBody': EnTranslations.privacyPolicyBody,
      'disputesPolicyTitle': EnTranslations.disputesPolicyTitle,
      'disputesPolicyBody': EnTranslations.disputesPolicyBody,
      'before48h': EnTranslations.before48h,
      'within48h': EnTranslations.within48h,
      'noShow': EnTranslations.noShow,
      'reportSpam': EnTranslations.reportSpam,
      'reportFraud': EnTranslations.reportFraud,
      'reportHarassment': EnTranslations.reportHarassment,
      'reportCopyright': EnTranslations.reportCopyright,
      'reportSentSuccess': EnTranslations.reportSentSuccess,
      'reportReviewSoon': EnTranslations.reportReviewSoon,
      'reportingAbout': EnTranslations.reportingAbout,
      'describeIssueHint': EnTranslations.describeIssueHint,
      'addReportDetails': EnTranslations.addReportDetails,
      'detailsMin20Chars': EnTranslations.detailsMin20Chars,
      'reportReviewNote': EnTranslations.reportReviewNote,
      'submitReportCheck': EnTranslations.submitReportCheck,
      'storeLuxuryFrame': EnTranslations.storeLuxuryFrame,
      'storeLuxuryFrameSub': EnTranslations.storeLuxuryFrameSub,
      'storePrintedAlbum': EnTranslations.storePrintedAlbum,
      'storePrintedAlbumSub': EnTranslations.storePrintedAlbumSub,
      'bestSeller': EnTranslations.bestSeller,
      'storeProductSession': EnTranslations.storeProductSession,
      'storeProductSessionSub': EnTranslations.storeProductSessionSub,
      'storeCuratedSubtitle': EnTranslations.storeCuratedSubtitle,
      'storeOrderInstruction': EnTranslations.storeOrderInstruction,
      'storeOrderMessageTemplate': EnTranslations.storeOrderMessageTemplate,
      'verifyAccountPrompt': EnTranslations.verifyAccountPrompt,
      'requestStatus': EnTranslations.requestStatus,
      'verifiedLabel': EnTranslations.verifiedLabel,
      'notVerifiedLabel': EnTranslations.notVerifiedLabel,
      'portfolioReview': EnTranslations.portfolioReview,
      'identityReview': EnTranslations.identityReview,
      'completedLabel': EnTranslations.completedLabel,
      'awaitingReview': EnTranslations.awaitingReview,
      'rejectionReasonTemplate': EnTranslations.rejectionReasonTemplate,
      'underReview': EnTranslations.underReview,
      'rejectedLabel': EnTranslations.rejectedLabel,
      'notSubmitted': EnTranslations.notSubmitted,
      'sortPriceLowFirst': EnTranslations.sortPriceLowFirst,
      'sortTopTrust': EnTranslations.sortTopTrust,
      'sortFastestDelivery': EnTranslations.sortFastestDelivery,
      'sortNearest': EnTranslations.sortNearest,
      'sortPriceLowToHigh': EnTranslations.sortPriceLowToHigh,
      'sortHighestTrust': EnTranslations.sortHighestTrust,
      'sortFastestDeliveryLong': EnTranslations.sortFastestDeliveryLong,
      'sortNearestToYou': EnTranslations.sortNearestToYou,
      'province_baghdad': EnTranslations.provinceBaghdad,
      'province_basra': EnTranslations.provinceBasra,
      'province_nineveh': EnTranslations.provinceNineveh,
      'province_erbil': EnTranslations.provinceErbil,
      'province_najaf': EnTranslations.provinceNajaf,
      'province_karbala': EnTranslations.provinceKarbala,
      'province_kirkuk': EnTranslations.provinceKirkuk,
      'province_dhi_qar': EnTranslations.provinceDhiQar,
      'province_sulaymaniyah': EnTranslations.provinceSulaymaniyah,
      'province_anbar': EnTranslations.provinceAnbar,
      'province_diyala': EnTranslations.provinceDiyala,
      'province_saladin': EnTranslations.provinceSaladin,
      'province_maysan': EnTranslations.provinceMaysan,
      'province_wasit': EnTranslations.provinceWasit,
      'province_muthanna': EnTranslations.provinceMuthanna,
      'province_qadisiyah': EnTranslations.provinceQadisiyah,
      'province_babil': EnTranslations.provinceBabil,
      'province_duhok': EnTranslations.provinceDuhok,
      'callAction': EnTranslations.callAction,
      'enrollmentCreateFailed': EnTranslations.enrollmentCreateFailed,
      'imageUploadFailed': EnTranslations.imageUploadFailed,
      'endTimeAfterStart': EnTranslations.endTimeAfterStart,
      'inPersonLabel': EnTranslations.inPersonLabel,
      'onlineLabel': EnTranslations.onlineLabel,
      'deleteCourseTitle': EnTranslations.deleteCourseTitle,
      'deleteCourseFailed': EnTranslations.deleteCourseFailed,
      'viewPhotographer': EnTranslations.viewPhotographer,
      'requestSameStyle': EnTranslations.requestSameStyle,
      'locationOnMap': EnTranslations.locationOnMap,
      'loyaltyPointsTitle': EnTranslations.loyaltyPointsTitle,
      'historyLabel': EnTranslations.historyLabel,
      'nextLevelProgress': EnTranslations.nextLevelProgress,
      'tierBronze': EnTranslations.tierBronze,
      'tierSilver': EnTranslations.tierSilver,
      'tierGold': EnTranslations.tierGold,
      'tierPlatinum': EnTranslations.tierPlatinum,
      'howToEarnPoints': EnTranslations.howToEarnPoints,
      'campaignAnalyticsTitle': EnTranslations.campaignAnalyticsTitle,
      'campaignCreatedForReview': EnTranslations.campaignCreatedForReview,
      'chatOpenAfterBooking': EnTranslations.chatOpenAfterBooking,
      'usernameCheckError': EnTranslations.usernameCheckError,
      'confirmOver18': EnTranslations.confirmOver18,
      'maxPortfolioImages': EnTranslations.maxPortfolioImages,
      'imageAddedSuccess': EnTranslations.imageAddedSuccess,
      'imageDeletedSuccess': EnTranslations.imageDeletedSuccess,
      'portfolioSaveFailed': EnTranslations.portfolioSaveFailed,
      'portfolioTitle': EnTranslations.portfolioTitle,
      'deleteImageTitle': EnTranslations.deleteImageTitle,
      'deleteImageConfirm': EnTranslations.deleteImageConfirm,
      'profilePhotoUpdated': EnTranslations.profilePhotoUpdated,
      'editFieldTemplate': EnTranslations.editFieldTemplate,
      'fieldCannotBeEmptyTemplate': EnTranslations.fieldCannotBeEmptyTemplate,
      'fieldUpdatedTemplate': EnTranslations.fieldUpdatedTemplate,
      'fieldUpdateFailedTemplate': EnTranslations.fieldUpdateFailedTemplate,
      'myAccountTitle': EnTranslations.myAccountTitle,
      'descriptionOptional': EnTranslations.descriptionOptional,
      'saveLocation': EnTranslations.saveLocation,
      'bookingPoliciesTitle': EnTranslations.bookingPoliciesTitle,
      'chooseReportReason': EnTranslations.chooseReportReason,
      'reportSendError': EnTranslations.reportSendError,
      'sendReportTitle': EnTranslations.sendReportTitle,
      'reportReasonLabel': EnTranslations.reportReasonLabel,
      'extraDetailsLabel': EnTranslations.extraDetailsLabel,
      'deleteAccountPolicy': EnTranslations.deleteAccountPolicy,
      'contentPolicy': EnTranslations.contentPolicy,
      'chooseEventDateFirst': EnTranslations.chooseEventDateFirst,
      'bookingRequestSent': EnTranslations.bookingRequestSent,
      'verificationRequestSent': EnTranslations.verificationRequestSent,
      'verificationRequestFailed': EnTranslations.verificationRequestFailed,
      'photographerVerificationTitle': EnTranslations.photographerVerificationTitle,
      'sendVerificationRequest': EnTranslations.sendVerificationRequest,
      'loadMoreFailed': EnTranslations.loadMoreFailed,
      'noItems': EnTranslations.noItems,
      'loadFailed': EnTranslations.loadFailed,
      'waitlistSubmitFailed': EnTranslations.waitlistSubmitFailed,
      'userLabel': EnTranslations.userLabel,
      'venuePlaceLabel': EnTranslations.venuePlaceLabel,
      'registerInterest': EnTranslations.registerInterest,
      'recheckAction': EnTranslations.recheckAction,
    },
    'ar': {
      'appName': ArTranslations.appName,
      'cancel': ArTranslations.cancel,
      'confirm': ArTranslations.confirm,
      'save': ArTranslations.save,
      'delete': ArTranslations.delete,
      'edit': ArTranslations.edit,
      'search': ArTranslations.search,
      'filter': ArTranslations.filter,
      'next': ArTranslations.next,
      'back': ArTranslations.back,
      'done': ArTranslations.done,
      'todayLabel': ArTranslations.todayLabel,
      'upcomingLabel': ArTranslations.upcomingLabel,
      'analyticsLabel': ArTranslations.analyticsLabel,
      'yes': ArTranslations.yes,
      'no': ArTranslations.no,
      'submit': ArTranslations.submit,
      'notSpecified': ArTranslations.notSpecified,
      'days': ArTranslations.days,
      'minutes': ArTranslations.minutes,
      'typeLabel': ArTranslations.typeLabel,
      'statusLabel': ArTranslations.statusLabel,
      'reportedLabel': ArTranslations.reportedLabel,
      'openedByLabel': ArTranslations.openedByLabel,
      'loading': ArTranslations.loading,
      'error': ArTranslations.error,
      'somethingWentWrong': ArTranslations.somethingWentWrong,
      'retry': ArTranslations.retry,
      'weakPassword': ArTranslations.weakPassword,
      'fairPassword': ArTranslations.fairPassword,
      'goodPassword': ArTranslations.goodPassword,
      'strongPassword': ArTranslations.strongPassword,
      'noData': ArTranslations.noData,
      'pressBackAgainToExit': ArTranslations.pressBackAgainToExit,
      'noPhotographers': ArTranslations.noPhotographers,
      'noResults': ArTranslations.noResults,
      'selectLanguage': ArTranslations.selectLanguage,
      'selectLanguageSubtitle': ArTranslations.selectLanguageSubtitle,
      'languageHint': ArTranslations.languageHint,
      'welcomeBack': ArTranslations.welcomeBack,
      'welcomeToLaqta': ArTranslations.welcomeToLaqta,
      'authSubtitle': ArTranslations.authSubtitle,
      'signInTitle': ArTranslations.signInTitle,
      'signUpTitle': ArTranslations.signUpTitle,
      'signInWithPhone': ArTranslations.signInWithPhone,
      'signUpWithPhone': ArTranslations.signUpWithPhone,
      'phoneNumber': ArTranslations.phoneNumber,
      'verifyOTP': ArTranslations.verifyOTP,
      'enterOTP': ArTranslations.enterOTP,
      'resendCode': ArTranslations.resendCode,
      'verify': ArTranslations.verify,
      'or': ArTranslations.or,
      'phoneAuthUnsupported': ArTranslations.phoneAuthUnsupported,
      'phoneAuthSupportInfo': ArTranslations.phoneAuthSupportInfo,
      'phoneNumberRequired': ArTranslations.phoneNumberRequired,
      'verificationFailed': ArTranslations.verificationFailed,
      'phoneAuthError': ArTranslations.phoneAuthError,
      'otpInvalid': ArTranslations.otpInvalid,
      'verificationIdMissing': ArTranslations.verificationIdMissing,
      'otpVerificationFailed': ArTranslations.otpVerificationFailed,
      'resendFailed': ArTranslations.resendFailed,
      'resendError': ArTranslations.resendError,
      'otpSentSuccess': ArTranslations.otpSentSuccess,
      'chooseRole': ArTranslations.chooseRole,
      'customer': ArTranslations.customer,
      'photographer': ArTranslations.photographer,
      'iAmCustomer': ArTranslations.iAmCustomer,
      'iAmPhotographer': ArTranslations.iAmPhotographer,
      'completeProfile': ArTranslations.completeProfile,
      'fullName': ArTranslations.fullName,
      'governorate': ArTranslations.governorate,
      'selectGovernorate': ArTranslations.selectGovernorate,
      'interests': ArTranslations.interests,
      'bio': ArTranslations.bio,
      'specialties': ArTranslations.specialties,
      'basePrice': ArTranslations.basePrice,
      'instagram': ArTranslations.instagram,
      'tiktok': ArTranslations.tiktok,
      'uploadPortfolio': ArTranslations.uploadPortfolio,
      'home': ArTranslations.home,
      'explore': ArTranslations.explore,
      'messages': ArTranslations.messages,
      'accountSection': ArTranslations.accountSection,
      'bookWithConfidence': ArTranslations.bookWithConfidence,
      'requestQuickPrompt': ArTranslations.requestQuickPrompt,
      'activeRequests': ArTranslations.activeRequests,
      'shop': ArTranslations.shop,
      'featuredProducts': ArTranslations.featuredProducts,
      'noProducts': ArTranslations.noProducts,
      'productsEmptyMessage': ArTranslations.productsEmptyMessage,
      'orderNow': ArTranslations.orderNow,
      'upcomingBookings': ArTranslations.upcomingBookings,
      'noBookings': ArTranslations.noBookings,
      'noBookingsMessage': ArTranslations.noBookingsMessage,
      'past': ArTranslations.past,
      'explorePhotographers': ArTranslations.explorePhotographers,
      'bookNow': ArTranslations.bookNow,
      'startingFrom': ArTranslations.startingFrom,
      'viewProfile': ArTranslations.viewProfile,
      'topRated': ArTranslations.topRated,
      'offers': ArTranslations.offers,
      'selectDate': ArTranslations.selectDate,
      'selectTime': ArTranslations.selectTime,
      'invalidDateTime': ArTranslations.invalidDateTime,
      'invalidBudgetRange': ArTranslations.invalidBudgetRange,
      'invalidLocation': ArTranslations.invalidLocation,
      'confirmBooking': ArTranslations.confirmBooking,
      'chat': ArTranslations.chat,
      'typeMessage': ArTranslations.typeMessage,
      'send': ArTranslations.send,
      'deleteChatTitle': ArTranslations.deleteChatTitle,
      'deleteConversationPrompt': ArTranslations.deleteConversationPrompt,
      'deleteChatPrompt': ArTranslations.deleteChatPrompt,
      'chatDeleted': ArTranslations.chatDeleted,
      'chatDeleteFailed': ArTranslations.chatDeleteFailed,
      'noMessagesTitle': ArTranslations.noMessagesTitle,
      'noChatResults': ArTranslations.noChatResults,
      'startConversationWithPhotographer':
          ArTranslations.startConversationWithPhotographer,
      'tryAnotherNameOrKeyword': ArTranslations.tryAnotherNameOrKeyword,
      'unableToDetermineUser': ArTranslations.unableToDetermineUser,
      'userBlocked': ArTranslations.userBlocked,
      'userUnblocked': ArTranslations.userUnblocked,
      'blockUser': ArTranslations.blockUser,
      'reportUser': ArTranslations.reportUser,
      'sendImage': ArTranslations.sendImage,
      'sendVideo': ArTranslations.sendVideo,
      'sendDocument': ArTranslations.sendDocument,
      'uploadingImage': ArTranslations.uploadingImage,
      'uploadingVideo': ArTranslations.uploadingVideo,
      'uploadingDocument': ArTranslations.uploadingDocument,
      'sendImageFailed': ArTranslations.sendImageFailed,
      'sendVideoFailed': ArTranslations.sendVideoFailed,
      'sendDocumentFailed': ArTranslations.sendDocumentFailed,
      'onlineNow': ArTranslations.onlineNow,
      'noMessagesYet': ArTranslations.noMessagesYet,
      'startConversationPrompt': ArTranslations.startConversationPrompt,
      'cannotOpenFile': ArTranslations.cannotOpenFile,
      'reviews': ArTranslations.reviews,
      'male': ArTranslations.male,
      'female': ArTranslations.female,
      'yearsOldSuffix': ArTranslations.yearsOldSuffix,
      'verifiedBadge': ArTranslations.verifiedBadge,
      'proBadge': ArTranslations.proBadge,
      'recommendedBadge': ArTranslations.recommendedBadge,
      'newBadge': ArTranslations.newBadge,
      'availableTodayBadge': ArTranslations.availableTodayBadge,
      'offerBadge': ArTranslations.offerBadge,
      'notifications': ArTranslations.notifications,
      'noNotifications': ArTranslations.noNotifications,
      'readAllNotifications': ArTranslations.readAllNotifications,
      'userNotAuthenticated': ArTranslations.userNotAuthenticated,
      'loadNotificationsFailed': ArTranslations.loadNotificationsFailed,
      'markNotificationReadFailed': ArTranslations.markNotificationReadFailed,
      'markAllNotificationsReadFailed':
          ArTranslations.markAllNotificationsReadFailed,
      'deleteNotificationFailed': ArTranslations.deleteNotificationFailed,
      'settings': ArTranslations.settings,
      'notificationsSection': ArTranslations.notificationsSection,
      'appearanceSection': ArTranslations.appearanceSection,
      'accessibilitySection': ArTranslations.accessibilitySection,
      'legalSection': ArTranslations.legalSection,
      'language': ArTranslations.language,
      'darkMode': ArTranslations.darkMode,
      'darkModeSubtitle': ArTranslations.darkModeSubtitle,
      'logout': ArTranslations.logout,
      'logoutSuccess': ArTranslations.logoutSuccess,
      'logoutFailed': ArTranslations.logoutFailed,
      'deleteAccount': ArTranslations.deleteAccount,
      'deleteAccountConfirm': ArTranslations.deleteAccountConfirm,
      'deleteAccountSuccess': ArTranslations.deleteAccountSuccess,
      'deleteAccountFailed': ArTranslations.deleteAccountFailed,
      'noUserLoggedIn': ArTranslations.noUserLoggedIn,
      'enableNotifications': ArTranslations.enableNotifications,
      'notificationsSubtitle': ArTranslations.notificationsSubtitle,
      'reduceMotion': ArTranslations.reduceMotion,
      'reduceMotionSubtitle': ArTranslations.reduceMotionSubtitle,
      'languageChanged': ArTranslations.languageChanged,
      'privacy': ArTranslations.privacy,
      'terms': ArTranslations.terms,
      'accept': ArTranslations.accept,
      'reject': ArTranslations.reject,
      'dashboard': ArTranslations.dashboard,
      'myBookings': ArTranslations.myBookings,
      'favorites': ArTranslations.favorites,
      'availability': ArTranslations.availability,
      'manageSlots': ArTranslations.manageSlots,
      'weeklyTemplate': ArTranslations.weeklyTemplate,
      'popularSpecialties': ArTranslations.popularSpecialties,
      'recentSearches': ArTranslations.recentSearches,
      'clearAll': ArTranslations.clearAll,
      'missingReviewInfo': ArTranslations.missingReviewInfo,
      'payment': ArTranslations.payment,
      'payDeposit': ArTranslations.payDeposit,
      'payFull': ArTranslations.payFull,
      'paymentSuccessful': ArTranslations.paymentSuccessful,
      'paymentFailed': ArTranslations.paymentFailed,
      'paymentsUnavailable': ArTranslations.paymentsUnavailable,
      'createPost': ArTranslations.createPost,
      'createStory': ArTranslations.createStory,
      'addPhoto': ArTranslations.addPhoto,
      'camera': ArTranslations.camera,
      'gallery': ArTranslations.gallery,
      'captionOptional': ArTranslations.captionOptional,
      'sharePost': ArTranslations.sharePost,
      'shareStory': ArTranslations.shareStory,
      'mediaRequired': ArTranslations.mediaRequired,
      'notPhotographer': ArTranslations.notPhotographer,
      'postPublished': ArTranslations.postPublished,
      'storyPublished': ArTranslations.storyPublished,
      'requests': ArTranslations.requests,
      'myRequests': ArTranslations.myRequests,
      'createRequest': ArTranslations.createRequest,
      'editRequest': ArTranslations.editRequest,
      'requestDetails': ArTranslations.requestDetails,
      'requestNotFound': ArTranslations.requestNotFound,
      'requestLoadError': ArTranslations.requestLoadError,
      'noDeadline': ArTranslations.noDeadline,
      'offersClosed': ArTranslations.offersClosed,
      'receivingOffers': ArTranslations.receivingOffers,
      'photographyType': ArTranslations.photographyType,
      'styleLabel': ArTranslations.styleLabel,
      'dateLabel': ArTranslations.dateLabel,
      'timeLabel': ArTranslations.timeLabel,
      'locationLabel': ArTranslations.locationLabel,
      'mapLabel': ArTranslations.mapLabel,
      'addressLabel': ArTranslations.addressLabel,
      'notesLabel': ArTranslations.notesLabel,
      'viewAll': ArTranslations.viewAll,
      'addressOptional': ArTranslations.addressOptional,
      'addressHint': ArTranslations.addressHint,
      'selectLocationOnMap': ArTranslations.selectLocationOnMap,
      'locationSelected': ArTranslations.locationSelected,
      'budget': ArTranslations.budget,
      'minLabel': ArTranslations.minLabel,
      'maxLabel': ArTranslations.maxLabel,
      'hours': ArTranslations.hours,
      'deliverables': ArTranslations.deliverables,
      'photosCount': ArTranslations.photosCount,
      'videoMinutes': ArTranslations.videoMinutes,
      'includeVideo': ArTranslations.includeVideo,
      'includeEditing': ArTranslations.includeEditing,
      'additionalNotes': ArTranslations.additionalNotes,
      'addReferenceImages': ArTranslations.addReferenceImages,
      'saveDraft': ArTranslations.saveDraft,
      'publishRequest': ArTranslations.publishRequest,
      'saveChanges': ArTranslations.saveChanges,
      'draftSaved': ArTranslations.draftSaved,
      'requestPublished': ArTranslations.requestPublished,
      'requestUpdated': ArTranslations.requestUpdated,
      'requestSubmitFailed': ArTranslations.requestSubmitFailed,
      'requestCancelFailed': ArTranslations.requestCancelFailed,
      'cancelRequest': ArTranslations.cancelRequest,
      'cancelRequestPrompt': ArTranslations.cancelRequestPrompt,
      'requestCanceled': ArTranslations.requestCanceled,
      'drafts': ArTranslations.drafts,
      'active': ArTranslations.active,
      'closed': ArTranslations.closed,
      'noRequests': ArTranslations.noRequests,
      'noDrafts': ArTranslations.noDrafts,
      'noActiveRequests': ArTranslations.noActiveRequests,
      'noClosedRequests': ArTranslations.noClosedRequests,
      'requestStatusDraft': ArTranslations.requestStatusDraft,
      'requestStatusAwaitingOffers': ArTranslations.requestStatusAwaitingOffers,
      'requestStatusOfferSelected': ArTranslations.requestStatusOfferSelected,
      'requestStatusClosed': ArTranslations.requestStatusClosed,
      'requestStatusCanceled': ArTranslations.requestStatusCanceled,
      'requestStatusExpired': ArTranslations.requestStatusExpired,
      'requestStatusPublished': ArTranslations.requestStatusPublished,
      'offersSection': ArTranslations.offersSection,
      'noOffersYet': ArTranslations.noOffersYet,
      'offersComingSoon': ArTranslations.offersComingSoon,
      'offerRequiredFields': ArTranslations.offerRequiredFields,
      'sendOffer': ArTranslations.sendOffer,
      'sendOfferPrompt': ArTranslations.sendOfferPrompt,
      'acceptOffer': ArTranslations.acceptOffer,
      'acceptOfferPrompt': ArTranslations.acceptOfferPrompt,
      'acceptOfferFailed': ArTranslations.acceptOfferFailed,
      'deliveryInDays': ArTranslations.deliveryInDays,
      'offerSent': ArTranslations.offerSent,
      'offerFailed': ArTranslations.offerFailed,
      'trustScore': ArTranslations.trustScore,
      'trustLevelNew': ArTranslations.trustLevelNew,
      'trustLevelHigh': ArTranslations.trustLevelHigh,
      'trustLevelMedium': ArTranslations.trustLevelMedium,
      'trustLevelLow': ArTranslations.trustLevelLow,
      'priceLabel': ArTranslations.priceLabel,
      'deliveryDays': ArTranslations.deliveryDays,
      'notesOptional': ArTranslations.notesOptional,
      'references': ArTranslations.references,
      'includesVideo': ArTranslations.includesVideo,
      'includesEditing': ArTranslations.includesEditing,
      'budgetFrom': ArTranslations.budgetFrom,
      'budgetUpTo': ArTranslations.budgetUpTo,
      'requestsEmptyMessage': ArTranslations.requestsEmptyMessage,
      'openRequests': ArTranslations.openRequests,
      'noRequestsFound': ArTranslations.noRequestsFound,
      'noRequestsFoundMessage': ArTranslations.noRequestsFoundMessage,
      'bookingRoom': ArTranslations.bookingRoom,
      'bookingNotFound': ArTranslations.bookingNotFound,
      'bookingLoadError': ArTranslations.bookingLoadError,
      'startJob': ArTranslations.startJob,
      'uploadDelivery': ArTranslations.uploadDelivery,
      'acceptDelivery': ArTranslations.acceptDelivery,
      'requestRevision': ArTranslations.requestRevision,
      'openDispute': ArTranslations.openDispute,
      'cancelBooking': ArTranslations.cancelBooking,
      'bookingCancelPrompt': ArTranslations.bookingCancelPrompt,
      'bookingCancelSuccess': ArTranslations.bookingCancelSuccess,
      'bookingCancelFailed': ArTranslations.bookingCancelFailed,
      'bookingUpdateFailed': ArTranslations.bookingUpdateFailed,
      'disputeOpenFailed': ArTranslations.disputeOpenFailed,
      'revisionLimitReached': ArTranslations.revisionLimitReached,
      'revisionDescribeChanges': ArTranslations.revisionDescribeChanges,
      'timeline': ArTranslations.timeline,
      'delivery': ArTranslations.delivery,
      'filesLabel': ArTranslations.filesLabel,
      'addPhotos': ArTranslations.addPhotos,
      'addVideo': ArTranslations.addVideo,
      'submitDelivery': ArTranslations.submitDelivery,
      'leaveReview': ArTranslations.leaveReview,
      'deliveryFilesRequired': ArTranslations.deliveryFilesRequired,
      'deliverySubmitFailed': ArTranslations.deliverySubmitFailed,
      'noDeliveryYet': ArTranslations.noDeliveryYet,
      'photos': ArTranslations.photos,
      'videos': ArTranslations.videos,
      'note': ArTranslations.note,
      'revisionRequest': ArTranslations.revisionRequest,
      'bookingStarted': ArTranslations.bookingStarted,
      'bookingCompleted': ArTranslations.bookingCompleted,
      'bookingCanceledMessage': ArTranslations.bookingCanceledMessage,
      'bookingCanceledStatus': ArTranslations.bookingCanceledStatus,
      'disputeOpened': ArTranslations.disputeOpened,
      'bookingInProgress': ArTranslations.bookingInProgress,
      'bookingAwaitingDelivery': ArTranslations.bookingAwaitingDelivery,
      'bookingDelivered': ArTranslations.bookingDelivered,
      'bookingRevisionRequested': ArTranslations.bookingRevisionRequested,
      'bookingDisputeOpen': ArTranslations.bookingDisputeOpen,
      'adminDashboard': ArTranslations.adminDashboard,
      'adminDisputes': ArTranslations.adminDisputes,
      'adminReports': ArTranslations.adminReports,
      'adminUsers': ArTranslations.adminUsers,
      'requestsToday': ArTranslations.requestsToday,
      'totalBookings': ArTranslations.totalBookings,
      'cancellations': ArTranslations.cancellations,
      'openDisputesCount': ArTranslations.openDisputesCount,
      'reviewDisputes': ArTranslations.reviewDisputes,
      'reviewReports': ArTranslations.reviewReports,
      'manageUsers': ArTranslations.manageUsers,
      'noDisputes': ArTranslations.noDisputes,
      'noDisputesMessage': ArTranslations.noDisputesMessage,
      'disputeDetails': ArTranslations.disputeDetails,
      'resolutionNote': ArTranslations.resolutionNote,
      'resolveRelease': ArTranslations.resolveRelease,
      'resolveRefund': ArTranslations.resolveRefund,
      'resolvePartial': ArTranslations.resolvePartial,
      'disputeResolved': ArTranslations.disputeResolved,
      'disputeResolveFailed': ArTranslations.disputeResolveFailed,
      'reportsEmpty': ArTranslations.reportsEmpty,
      'usersEmpty': ArTranslations.usersEmpty,
      'markResolved': ArTranslations.markResolved,
      'dismiss': ArTranslations.dismiss,
      'warningSent': ArTranslations.warningSent,
      'warningFailed': ArTranslations.warningFailed,
      'block': ArTranslations.block,
      'unblock': ArTranslations.unblock,
      'sendWarning': ArTranslations.sendWarning,
      'accountBlocked': ArTranslations.accountBlocked,
      'accountBlockedMessage': ArTranslations.accountBlockedMessage,
      'signOut': ArTranslations.signOut,
      'policies': ArTranslations.policies,
      'bookingPolicies': ArTranslations.bookingPolicies,
      'policiesSubtitle': ArTranslations.policiesSubtitle,
      'bookingPoliciesSubtitle': ArTranslations.bookingPoliciesSubtitle,
      'readPolicies': ArTranslations.readPolicies,
      'agreeToTerms': ArTranslations.agreeToTerms,
      'iUnderstand': ArTranslations.iUnderstand,
      'escrowPolicy': ArTranslations.escrowPolicy,
      'escrowPolicyDesc': ArTranslations.escrowPolicyDesc,
      'escrowReleaseTitle': ArTranslations.escrowReleaseTitle,
      'escrowReleaseDesc': ArTranslations.escrowReleaseDesc,
      'revisionPolicy': ArTranslations.revisionPolicy,
      'revisionPolicyDesc': ArTranslations.revisionPolicyDesc,
      'revisionExtraTitle': ArTranslations.revisionExtraTitle,
      'revisionExtraDesc': ArTranslations.revisionExtraDesc,
      'cancellationPolicy': ArTranslations.cancellationPolicy,
      'cancellation48Hours': ArTranslations.cancellation48Hours,
      'cancellation48HoursAfter': ArTranslations.cancellation48HoursAfter,
      'cancellationPhotographer': ArTranslations.cancellationPhotographer,
      'disputePolicy': ArTranslations.disputePolicy,
      'disputePolicyDesc': ArTranslations.disputePolicyDesc,
      'disputeProcess': ArTranslations.disputeProcess,
      'disputeStep1': ArTranslations.disputeStep1,
      'disputeStep2': ArTranslations.disputeStep2,
      'disputeStep3': ArTranslations.disputeStep3,
      'disputeStep4': ArTranslations.disputeStep4,
      'trustScorePolicy': ArTranslations.trustScorePolicy,
      'trustScoreDesc': ArTranslations.trustScoreDesc,
      'trustMetric1': ArTranslations.trustMetric1,
      'trustMetric2': ArTranslations.trustMetric2,
      'trustMetric3': ArTranslations.trustMetric3,
      'trustMetric4': ArTranslations.trustMetric4,
      'trustMetric5': ArTranslations.trustMetric5,
      'privacyPolicy': ArTranslations.privacyPolicy,
      'privacyPhoneNumber': ArTranslations.privacyPhoneNumber,
      'privacyFiles': ArTranslations.privacyFiles,
      'privacyContact': ArTranslations.privacyContact,
      'privacyLinks': ArTranslations.privacyLinks,
      'paymentPolicy': ArTranslations.paymentPolicy,
      'paymentDeposit': ArTranslations.paymentDeposit,
      'paymentRelease': ArTranslations.paymentRelease,
      'paymentRefund': ArTranslations.paymentRefund,
      'addReview': ArTranslations.addReview,
      'addToFavorites': ArTranslations.addToFavorites,
      'additionalDetails': ArTranslations.additionalDetails,
      'applyFilters': ArTranslations.applyFilters,
      'bookingConfirmed': ArTranslations.bookingConfirmed,
      'bookingPending': ArTranslations.bookingPending,
      'bookingRejected': ArTranslations.bookingRejected,
      'clearFilters': ArTranslations.clearFilters,
      'commentOptional': ArTranslations.commentOptional,
      'communication': ArTranslations.communication,
      'deliverySpeed': ArTranslations.deliverySpeed,
      'detailsLabel': ArTranslations.detailsLabel,
      'distanceUnavailable': ArTranslations.distanceUnavailable,
      'distanceUnit': ArTranslations.distanceUnit,
      'downloadLinks': ArTranslations.downloadLinks,
      'estimatedDistance': ArTranslations.estimatedDistance,
      'filterByGovernorate': ArTranslations.filterByGovernorate,
      'filterByPrice': ArTranslations.filterByPrice,
      'filterByRating': ArTranslations.filterByRating,
      'filterBySpecialty': ArTranslations.filterBySpecialty,
      'location': ArTranslations.location,
      'maxPrice': ArTranslations.maxPrice,
      'minPrice': ArTranslations.minPrice,
      'notes': ArTranslations.notes,
      'onTimeDelivery': ArTranslations.onTimeDelivery,
      'photographerInGov': ArTranslations.photographerInGov,
      'policyHighlightOne': ArTranslations.policyHighlightOne,
      'policyHighlightThree': ArTranslations.policyHighlightThree,
      'policyHighlightTwo': ArTranslations.policyHighlightTwo,
      'policyHighlightsTitle': ArTranslations.policyHighlightsTitle,
      'price': ArTranslations.price,
      'quality': ArTranslations.quality,
      'rateExperience': ArTranslations.rateExperience,
      'rating': ArTranslations.rating,
      'readFullTerms': ArTranslations.readFullTerms,
      'reasonLabel': ArTranslations.reasonLabel,
      'recommendQuestion': ArTranslations.recommendQuestion,
      'removeFromFavorites': ArTranslations.removeFromFavorites,
      'report': ArTranslations.report,
      'reportContent': ArTranslations.reportContent,
      'reviewCommentHint': ArTranslations.reviewCommentHint,
      'reviewSubmitFailed': ArTranslations.reviewSubmitFailed,
      'reviewSubmitted': ArTranslations.reviewSubmitted,
      'searchPhotographers': ArTranslations.searchPhotographers,
      'selectReason': ArTranslations.selectReason,
      'sessionType': ArTranslations.sessionType,
      'signInWith': ArTranslations.signInWith,
      'smartReview': ArTranslations.smartReview,
      'smartReviewSubtitle': ArTranslations.smartReviewSubtitle,
      'sortBy': ArTranslations.sortBy,
      'submitReport': ArTranslations.submitReport,
      'submitReview': ArTranslations.submitReview,
      'suggestAlternative': ArTranslations.suggestAlternative,
      'todaySchedule': ArTranslations.todaySchedule,
      'total': ArTranslations.total,
      'typing': ArTranslations.typing,
      'writeComment': ArTranslations.writeComment,
      'errorNetworkMessage': ArTranslations.errorNetworkMessage,
      'errorServerMessage': ArTranslations.errorServerMessage,
      'errorSessionExpired': ArTranslations.errorSessionExpired,
      'errorUnexpected': ArTranslations.errorUnexpected,
      'sendReport': ArTranslations.sendReport,
      'reportSent': ArTranslations.reportSent,
      'restartAppPrompt': ArTranslations.restartAppPrompt,
      'reportIdLabel': ArTranslations.reportIdLabel,
      'offlineWeakConnection': ArTranslations.offlineWeakConnection,
      'offlineNoConnection': ArTranslations.offlineNoConnection,
      'lastOnlineLabel': ArTranslations.lastOnlineLabel,
      'justNow': ArTranslations.justNow,
      'minutesAgoTemplate': ArTranslations.minutesAgoTemplate,
      'updateAvailableTitle': ArTranslations.updateAvailableTitle,
      'updateAvailableBody': ArTranslations.updateAvailableBody,
      'updateAction': ArTranslations.updateAction,
      'laterAction': ArTranslations.laterAction,
      'forceUpdateTitle': ArTranslations.forceUpdateTitle,
      'forceUpdateBody': ArTranslations.forceUpdateBody,
      'updateNowAction': ArTranslations.updateNowAction,
      'securityMaintenanceTitle': ArTranslations.securityMaintenanceTitle,
      'secureConnectionFailed': ArTranslations.secureConnectionFailed,
      'securityAlertTitle': ArTranslations.securityAlertTitle,
      'continueAction': ArTranslations.continueAction,
      'okAction': ArTranslations.okAction,
      'untrustedDeviceWarning': ArTranslations.untrustedDeviceWarning,
      'confirmIdentityForPayment': ArTranslations.confirmIdentityForPayment,
      'identityConfirmationFailed':
          ArTranslations.identityConfirmationFailed,
      'enableNotificationsTitle': ArTranslations.enableNotificationsTitle,
      'enableNotificationsBody': ArTranslations.enableNotificationsBody,
      'allowAction': ArTranslations.allowAction,
      'pageNotFound': ArTranslations.pageNotFound,
      'goHomeAction': ArTranslations.goHomeAction,
      'bookingLoadFailed': ArTranslations.bookingLoadFailed,
      'missingRouteParam': ArTranslations.missingRouteParam,
      'skip': ArTranslations.skip,
      'startNow': ArTranslations.startNow,
      'onboardingSlide1Title': ArTranslations.onboardingSlide1Title,
      'onboardingSlide1Body': ArTranslations.onboardingSlide1Body,
      'onboardingSlide2Title': ArTranslations.onboardingSlide2Title,
      'onboardingSlide2Body': ArTranslations.onboardingSlide2Body,
      'onboardingSlide3Title': ArTranslations.onboardingSlide3Title,
      'onboardingSlide3Body': ArTranslations.onboardingSlide3Body,
      'loginSubtitle': ArTranslations.loginSubtitle,
      'phoneOrUsername': ArTranslations.phoneOrUsername,
      'passwordLabel': ArTranslations.passwordLabel,
      'forgotPasswordQ': ArTranslations.forgotPasswordQ,
      'loginAction': ArTranslations.loginAction,
      'noAccountPrompt': ArTranslations.noAccountPrompt,
      'createAccountAction': ArTranslations.createAccountAction,
      'registerSubtitle': ArTranslations.registerSubtitle,
      'haveAccountPrompt': ArTranslations.haveAccountPrompt,
      'chooseAccountType': ArTranslations.chooseAccountType,
      'basicInfoSection': ArTranslations.basicInfoSection,
      'firstNameLabel': ArTranslations.firstNameLabel,
      'lastNameLabel': ArTranslations.lastNameLabel,
      'usernameLabel': ArTranslations.usernameLabel,
      'usernameHint': ArTranslations.usernameHint,
      'personalInfoSection': ArTranslations.personalInfoSection,
      'birthdateLabel': ArTranslations.birthdateLabel,
      'chooseBirthdate': ArTranslations.chooseBirthdate,
      'provinceLabel': ArTranslations.provinceLabel,
      'phoneVerificationSection': ArTranslations.phoneVerificationSection,
      'resendInSecondsTemplate': ArTranslations.resendInSecondsTemplate,
      'sendOtpViaSms': ArTranslations.sendOtpViaSms,
      'confirmPasswordLabel': ArTranslations.confirmPasswordLabel,
      'forgotPasswordTitle': ArTranslations.forgotPasswordTitle,
      'forgotPasswordSubtitle': ArTranslations.forgotPasswordSubtitle,
      'newPasswordLabel': ArTranslations.newPasswordLabel,
      'setPasswordAction': ArTranslations.setPasswordAction,
      'rememberedPasswordPrompt': ArTranslations.rememberedPasswordPrompt,
      'venueOwner': ArTranslations.venueOwner,
      'loginMissingCredentials': ArTranslations.loginMissingCredentials,
      'invalidCredentials': ArTranslations.invalidCredentials,
      'firstNameRequired': ArTranslations.firstNameRequired,
      'lastNameRequired': ArTranslations.lastNameRequired,
      'usernameLengthError': ArTranslations.usernameLengthError,
      'usernameNoSpaces': ArTranslations.usernameNoSpaces,
      'usernameInvalidChars': ArTranslations.usernameInvalidChars,
      'chooseGenderError': ArTranslations.chooseGenderError,
      'chooseBirthdateError': ArTranslations.chooseBirthdateError,
      'agePolicyError': ArTranslations.agePolicyError,
      'chooseProvinceError': ArTranslations.chooseProvinceError,
      'invalidPhoneError': ArTranslations.invalidPhoneError,
      'enterOtpError': ArTranslations.enterOtpError,
      'passwordPolicyError': ArTranslations.passwordPolicyError,
      'passwordMismatchError': ArTranslations.passwordMismatchError,
      'sendOtpFirstError': ArTranslations.sendOtpFirstError,
      'otpSendFailedError': ArTranslations.otpSendFailedError,
      'tryAgainLater': ArTranslations.tryAgainLater,
      'datePickerChoose': ArTranslations.datePickerChoose,
      'serviceUnavailableUpdate': ArTranslations.serviceUnavailableUpdate,
      'usernameTaken': ArTranslations.usernameTaken,
      'phoneTaken': ArTranslations.phoneTaken,
      'codeExpired': ArTranslations.codeExpired,
      'invalidOtpCode': ArTranslations.invalidOtpCode,
      'waitBeforeNewCode': ArTranslations.waitBeforeNewCode,
      'stepOfTemplate': ArTranslations.stepOfTemplate,
      'paymentCancelled': ArTranslations.paymentCancelled,
      'confirmPaymentTitle': ArTranslations.confirmPaymentTitle,
      'confirmPaymentBodyTemplate': ArTranslations.confirmPaymentBodyTemplate,
      'fraudAmountMismatch': ArTranslations.fraudAmountMismatch,
      'fraudUntrustedEnv': ArTranslations.fraudUntrustedEnv,
      'fraudModifiedDevice': ArTranslations.fraudModifiedDevice,
      'fraudRelogin': ArTranslations.fraudRelogin,
      'loginToViewFavorites': ArTranslations.loginToViewFavorites,
      'favoritesLoadFailed': ArTranslations.favoritesLoadFailed,
      'loginToManageFavorites': ArTranslations.loginToManageFavorites,
      'removedFromFavorites': ArTranslations.removedFromFavorites,
      'removeFromFavoritesFailed': ArTranslations.removeFromFavoritesFailed,
      'noFavoritesTitle': ArTranslations.noFavoritesTitle,
      'noFavoritesMessage': ArTranslations.noFavoritesMessage,
      'searchTipFavorites': ArTranslations.searchTipFavorites,
      'achievementsTitle': ArTranslations.achievementsTitle,
      'progressLabel': ArTranslations.progressLabel,
      'allAchievements': ArTranslations.allAchievements,
      'achievementUnlocked': ArTranslations.achievementUnlocked,
      'pointsEarnedTemplate': ArTranslations.pointsEarnedTemplate,
      'totalProgress': ArTranslations.totalProgress,
      'rewardPointsTemplate': ArTranslations.rewardPointsTemplate,
      'forYouTab': ArTranslations.forYouTab,
      'mostViewedTab': ArTranslations.mostViewedTab,
      'weddingsTab': ArTranslations.weddingsTab,
      'sessionsTab': ArTranslations.sessionsTab,
      'discussionsTab': ArTranslations.discussionsTab,
      'dashboardSearchHint': ArTranslations.dashboardSearchHint,
      'noPostsYet': ArTranslations.noPostsYet,
      'noPostsSubtitle': ArTranslations.noPostsSubtitle,
      'sponsoredLabel': ArTranslations.sponsoredLabel,
      'featuredLabel': ArTranslations.featuredLabel,
      'downloadLinkOpenFailed': ArTranslations.downloadLinkOpenFailed,
      'emailInvalid': ArTranslations.emailInvalid,
      'nameRequired': ArTranslations.nameRequired,
      'nameTooLong': ArTranslations.nameTooLong,
      'nameInvalidChars': ArTranslations.nameInvalidChars,
      'otpSixDigits': ArTranslations.otpSixDigits,
      'futureDateRequired': ArTranslations.futureDateRequired,
      'mustBeAdult': ArTranslations.mustBeAdult,
      'hoursAgoTemplate': ArTranslations.hoursAgoTemplate,
      'daysAgoTemplate': ArTranslations.daysAgoTemplate,
      'weeksAgoTemplate': ArTranslations.weeksAgoTemplate,
      'remainingHoursTemplate': ArTranslations.remainingHoursTemplate,
      'remainingMinutesTemplate': ArTranslations.remainingMinutesTemplate,
      'endingSoon': ArTranslations.endingSoon,
      'achFirstBookingTitle': ArTranslations.achFirstBookingTitle,
      'achFirstBookingDesc': ArTranslations.achFirstBookingDesc,
      'achBookingExpertTitle': ArTranslations.achBookingExpertTitle,
      'achBookingExpertDesc': ArTranslations.achBookingExpertDesc,
      'achBookingProTitle': ArTranslations.achBookingProTitle,
      'achBookingProDesc': ArTranslations.achBookingProDesc,
      'achReviewCollectorTitle': ArTranslations.achReviewCollectorTitle,
      'achReviewCollectorDesc': ArTranslations.achReviewCollectorDesc,
      'achTopRatedTitle': ArTranslations.achTopRatedTitle,
      'achTopRatedDesc': ArTranslations.achTopRatedDesc,
      'achPopularTitle': ArTranslations.achPopularTitle,
      'achPopularDesc': ArTranslations.achPopularDesc,
      'achEarlyBirdTitle': ArTranslations.achEarlyBirdTitle,
      'achEarlyBirdDesc': ArTranslations.achEarlyBirdDesc,
      'achNightOwlTitle': ArTranslations.achNightOwlTitle,
      'achNightOwlDesc': ArTranslations.achNightOwlDesc,
      'achMoneyMakerTitle': ArTranslations.achMoneyMakerTitle,
      'achMoneyMakerDesc': ArTranslations.achMoneyMakerDesc,
      'tierPlatinumPlus': ArTranslations.tierPlatinumPlus,
      'tierGoldPlus': ArTranslations.tierGoldPlus,
      'tierSilverPlus': ArTranslations.tierSilverPlus,
      'tierBronzePlus': ArTranslations.tierBronzePlus,
      'loyaltyBookingCompleted': ArTranslations.loyaltyBookingCompleted,
      'loyaltyReferFriend': ArTranslations.loyaltyReferFriend,
      'loyaltyWriteReview': ArTranslations.loyaltyWriteReview,
      'loyaltyFirstBooking': ArTranslations.loyaltyFirstBooking,
      'loyaltyRedeem': ArTranslations.loyaltyRedeem,
      'pointsLabel': ArTranslations.pointsLabel,
      'placeLabel': ArTranslations.placeLabel,
      'goldenHourMorning': ArTranslations.goldenHourMorning,
      'goldenHourEvening': ArTranslations.goldenHourEvening,
      'goldenHourNext': ArTranslations.goldenHourNext,
      'endsAtTemplate': ArTranslations.endsAtTemplate,
      'morningLabel': ArTranslations.morningLabel,
      'eveningLabel': ArTranslations.eveningLabel,
      'tomorrowMorningLabel': ArTranslations.tomorrowMorningLabel,
      'amMarker': ArTranslations.amMarker,
      'pmMarker': ArTranslations.pmMarker,
      'inMinutesTemplate': ArTranslations.inMinutesTemplate,
      'inHoursTemplate': ArTranslations.inHoursTemplate,
      'inHoursMinutesTemplate': ArTranslations.inHoursMinutesTemplate,
      'happeningNowTemplate': ArTranslations.happeningNowTemplate,
      'photographersCountTemplate': ArTranslations.photographersCountTemplate,
      'emptyBookingsTitle': ArTranslations.emptyBookingsTitle,
      'emptyBookingsMessage': ArTranslations.emptyBookingsMessage,
      'browsePhotographers': ArTranslations.browsePhotographers,
      'emptyFavoritesTitle': ArTranslations.emptyFavoritesTitle,
      'emptyFavoritesMessage': ArTranslations.emptyFavoritesMessage,
      'exploreNow': ArTranslations.exploreNow,
      'emptyChatsTitle': ArTranslations.emptyChatsTitle,
      'emptyChatsMessage': ArTranslations.emptyChatsMessage,
      'findPhotographer': ArTranslations.findPhotographer,
      'emptyNotificationsTitle': ArTranslations.emptyNotificationsTitle,
      'emptyNotificationsMessage': ArTranslations.emptyNotificationsMessage,
      'emptySearchQueryTemplate': ArTranslations.emptySearchQueryTemplate,
      'emptySearchFiltersMessage': ArTranslations.emptySearchFiltersMessage,
      'emptyStoriesTitle': ArTranslations.emptyStoriesTitle,
      'emptyStoriesMessage': ArTranslations.emptyStoriesMessage,
      'emptyReviewsTitle': ArTranslations.emptyReviewsTitle,
      'emptyReviewsMessage': ArTranslations.emptyReviewsMessage,
      'writeReviewAction': ArTranslations.writeReviewAction,
      'emptyPortfolioTitle': ArTranslations.emptyPortfolioTitle,
      'emptyPortfolioMessage': ArTranslations.emptyPortfolioMessage,
      'addPhotosAction': ArTranslations.addPhotosAction,
      'emptyTransactionsTitle': ArTranslations.emptyTransactionsTitle,
      'emptyTransactionsMessage': ArTranslations.emptyTransactionsMessage,
      'errorOccurredTitle': ArTranslations.errorOccurredTitle,
      'errorGenericMessage': ArTranslations.errorGenericMessage,
      'noConnectionTitle': ArTranslations.noConnectionTitle,
      'noConnectionMessage': ArTranslations.noConnectionMessage,
      'createLabel': ArTranslations.createLabel,
      'profileTab': ArTranslations.profileTab,
      'mainNavigationLabel': ArTranslations.mainNavigationLabel,
      'newReel': ArTranslations.newReel,
      'newStory': ArTranslations.newStory,
      'sponsoredAdTitle': ArTranslations.sponsoredAdTitle,
      'plansTitle': ArTranslations.plansTitle,
      'newRequest': ArTranslations.newRequest,
      'venuesTitle': ArTranslations.venuesTitle,
      'photoSpotsTitle': ArTranslations.photoSpotsTitle,
      'whatToCreate': ArTranslations.whatToCreate,
      'placesTitle': ArTranslations.placesTitle,
      'photographersTitle': ArTranslations.photographersTitle,
      'followTab': ArTranslations.followTab,
      'errBadRequest': ArTranslations.errBadRequest,
      'errForbidden': ArTranslations.errForbidden,
      'errNotFound': ArTranslations.errNotFound,
      'errConflict': ArTranslations.errConflict,
      'errValidation': ArTranslations.errValidation,
      'errRateLimited': ArTranslations.errRateLimited,
      'errServer': ArTranslations.errServer,
      'errServiceUnavailable': ArTranslations.errServiceUnavailable,
      'reportInappropriate': ArTranslations.reportInappropriate,
      'reportFraudImpersonation': ArTranslations.reportFraudImpersonation,
      'reportAbuse': ArTranslations.reportAbuse,
      'reportStolenImages': ArTranslations.reportStolenImages,
      'reportMisinformation': ArTranslations.reportMisinformation,
      'otherLabel': ArTranslations.otherLabel,
      'sendReportAction': ArTranslations.sendReportAction,
      'reportReasonField': ArTranslations.reportReasonField,
      'extraDetailsOptional': ArTranslations.extraDetailsOptional,
      'reportSentThanks': ArTranslations.reportSentThanks,
      'reportSendFailed': ArTranslations.reportSendFailed,
      'submitReportAction': ArTranslations.submitReportAction,
      'raspIntrusionLogout': ArTranslations.raspIntrusionLogout,
      'raspIntegrityFailed': ArTranslations.raspIntegrityFailed,
      'raspModifiedDevice': ArTranslations.raspModifiedDevice,
      'raspUntrustedEnv': ArTranslations.raspUntrustedEnv,
      'uploadTimeout': ArTranslations.uploadTimeout,
      'connectionTimeoutMsg': ArTranslations.connectionTimeoutMsg,
      'confirmIdentityToContinue': ArTranslations.confirmIdentityToContinue,
      'moodWarmSoft': ArTranslations.moodWarmSoft,
      'moodUrbanSharp': ArTranslations.moodUrbanSharp,
      'moodRomantic': ArTranslations.moodRomantic,
      'moodNaturalOutdoor': ArTranslations.moodNaturalOutdoor,
      'moodDramaticDeep': ArTranslations.moodDramaticDeep,
      'waitlistFullMsg': ArTranslations.waitlistFullMsg,
      'waitlistBaghdadOnly': ArTranslations.waitlistBaghdadOnly,
      'waitlistNotifyExpansion': ArTranslations.waitlistNotifyExpansion,
      'waitlistNotifyCity': ArTranslations.waitlistNotifyCity,
      'nameLabel': ArTranslations.nameLabel,
      'enterName': ArTranslations.enterName,
      'enterValidPhone': ArTranslations.enterValidPhone,
      'cityLabel': ArTranslations.cityLabel,
      'enterCity': ArTranslations.enterCity,
      'accountTypeLabel': ArTranslations.accountTypeLabel,
      'interestRegistered': ArTranslations.interestRegistered,
      'notifyOnExpand': ArTranslations.notifyOnExpand,
      'allFilter': ArTranslations.allFilter,
      'openFilter': ArTranslations.openFilter,
      'resolvedFilter': ArTranslations.resolvedFilter,
      'searchReportsHint': ArTranslations.searchReportsHint,
      'searchUsersHint': ArTranslations.searchUsersHint,
      'deleteViaPolicy': ArTranslations.deleteViaPolicy,
      'phoneAfterBooking': ArTranslations.phoneAfterBooking,
      'privacyContactNote': ArTranslations.privacyContactNote,
      'yesterday': ArTranslations.yesterday,
      'conversationFallback': ArTranslations.conversationFallback,
      'noChatsYet': ArTranslations.noChatsYet,
      'chatsLoadFailed': ArTranslations.chatsLoadFailed,
      'searchMessagesHint': ArTranslations.searchMessagesHint,
      'photographersFilter': ArTranslations.photographersFilter,
      'arrangementsFilter': ArTranslations.arrangementsFilter,
      'quickAskPrice': ArTranslations.quickAskPrice,
      'quickAskAvailable': ArTranslations.quickAskAvailable,
      'quickAskEvent': ArTranslations.quickAskEvent,
      'quickAskPackages': ArTranslations.quickAskPackages,
      'coursesListTitle': ArTranslations.coursesListTitle,
      'coursesLoadError': ArTranslations.coursesLoadError,
      'noCoursesAvailable': ArTranslations.noCoursesAvailable,
      'courseFull': ArTranslations.courseFull,
      'seatsCountTemplate': ArTranslations.seatsCountTemplate,
      'courseLoadFailed': ArTranslations.courseLoadFailed,
      'courseNotFound': ArTranslations.courseNotFound,
      'seatsOfTemplate': ArTranslations.seatsOfTemplate,
      'availableSeats': ArTranslations.availableSeats,
      'sessionsLabel': ArTranslations.sessionsLabel,
      'courseCompleted': ArTranslations.courseCompleted,
      'enrolling': ArTranslations.enrolling,
      'enrollNow': ArTranslations.enrollNow,
      'completeCourseTitleDesc': ArTranslations.completeCourseTitleDesc,
      'invalidPrice': ArTranslations.invalidPrice,
      'invalidSeatsCount': ArTranslations.invalidSeatsCount,
      'addAtLeastOneSession': ArTranslations.addAtLeastOneSession,
      'enterOnlineSessionLink': ArTranslations.enterOnlineSessionLink,
      'currentUserCheckFailed': ArTranslations.currentUserCheckFailed,
      'courseSaveFailed': ArTranslations.courseSaveFailed,
      'editCourse': ArTranslations.editCourse,
      'newCourse': ArTranslations.newCourse,
      'unpublish': ArTranslations.unpublish,
      'publish': ArTranslations.publish,
      'addCourseCover': ArTranslations.addCourseCover,
      'courseTitleLabel': ArTranslations.courseTitleLabel,
      'courseTitleHint': ArTranslations.courseTitleHint,
      'descriptionLabel': ArTranslations.descriptionLabel,
      'courseDescriptionHint': ArTranslations.courseDescriptionHint,
      'courseLocationLabel': ArTranslations.courseLocationLabel,
      'courseLocationHint': ArTranslations.courseLocationHint,
      'onlineSessionLink': ArTranslations.onlineSessionLink,
      'priceIqdLabel': ArTranslations.priceIqdLabel,
      'seatsCountLabel': ArTranslations.seatsCountLabel,
      'addSpecialtyHint': ArTranslations.addSpecialtyHint,
      'addSession': ArTranslations.addSession,
      'savingProgress': ArTranslations.savingProgress,
      'deleteCourseConfirmTemplate': ArTranslations.deleteCourseConfirmTemplate,
      'myTeachingCourses': ArTranslations.myTeachingCourses,
      'noCoursesYet': ArTranslations.noCoursesYet,
      'createFirstCourse': ArTranslations.createFirstCourse,
      'seatsRatioTemplate': ArTranslations.seatsRatioTemplate,
      'published': ArTranslations.published,
      'draft': ArTranslations.draft,
      'paymentStartFailed': ArTranslations.paymentStartFailed,
      'paymentConfirmFailed': ArTranslations.paymentConfirmFailed,
      'paymentProcessError': ArTranslations.paymentProcessError,
      'traineeFallback': ArTranslations.traineeFallback,
      'newEnrollmentTitle': ArTranslations.newEnrollmentTitle,
      'newEnrollmentBodyTemplate': ArTranslations.newEnrollmentBodyTemplate,
      'paymentSuccessTitle': ArTranslations.paymentSuccessTitle,
      'enrolledInCourseTemplate': ArTranslations.enrolledInCourseTemplate,
      'paymentGatewayDisabled': ArTranslations.paymentGatewayDisabled,
      'payingProgress': ArTranslations.payingProgress,
      'payNow': ArTranslations.payNow,
      'myCoursesTitle': ArTranslations.myCoursesTitle,
      'myCoursesLoadError': ArTranslations.myCoursesLoadError,
      'notEnrolledYet': ArTranslations.notEnrolledYet,
      'browseCoursesPrompt': ArTranslations.browseCoursesPrompt,
      'browseCourses': ArTranslations.browseCourses,
      'enrollmentConfirmed': ArTranslations.enrollmentConfirmed,
      'enrollmentCanceled': ArTranslations.enrollmentCanceled,
      'awaitingPayment': ArTranslations.awaitingPayment,
      'noCreatorsForMood': ArTranslations.noCreatorsForMood,
      'tryAnotherMood': ArTranslations.tryAnotherMood,
      'suggestedCreators': ArTranslations.suggestedCreators,
      'moodPrefixTemplate': ArTranslations.moodPrefixTemplate,
      'creatorsCountTemplate': ArTranslations.creatorsCountTemplate,
      'discoverTitle': ArTranslations.discoverTitle,
      'exploreSearchHint': ArTranslations.exploreSearchHint,
      'photographersSection': ArTranslations.photographersSection,
      'photoSpotsSection': ArTranslations.photoSpotsSection,
      'noResultsNow': ArTranslations.noResultsNow,
      'tryRefreshOrSearch': ArTranslations.tryRefreshOrSearch,
      'featuredVenues': ArTranslations.featuredVenues,
      'featuredPhotoSpots': ArTranslations.featuredPhotoSpots,
      'noPhotoSpotsNow': ArTranslations.noPhotoSpotsNow,
      'iraqLabel': ArTranslations.iraqLabel,
      'startsFromTemplate': ArTranslations.startsFromTemplate,
      'placeLoadFailed': ArTranslations.placeLoadFailed,
      'placeDescription': ArTranslations.placeDescription,
      'noDescriptionAvailable': ArTranslations.noDescriptionAvailable,
      'venuesLoadEmpty': ArTranslations.venuesLoadEmpty,
      'venueSearchHint': ArTranslations.venueSearchHint,
      'venueLoadFailed': ArTranslations.venueLoadFailed,
      'venueBookingTitle': ArTranslations.venueBookingTitle,
      'venueBookingSubtitle': ArTranslations.venueBookingSubtitle,
      'eventDateLabel': ArTranslations.eventDateLabel,
      'guestCountLabel': ArTranslations.guestCountLabel,
      'guestCountHint': ArTranslations.guestCountHint,
      'extraNotesLabel': ArTranslations.extraNotesLabel,
      'eventDetailsHint': ArTranslations.eventDetailsHint,
      'bookingSendFailed': ArTranslations.bookingSendFailed,
      'venueDetailsLoadFailed': ArTranslations.venueDetailsLoadFailed,
      'capacityLabelTemplate': ArTranslations.capacityLabelTemplate,
      'aboutVenue': ArTranslations.aboutVenue,
      'upcomingAvailability': ArTranslations.upcomingAvailability,
      'messageAction': ArTranslations.messageAction,
      'yourAvailablePoints': ArTranslations.yourAvailablePoints,
      'pointSingular': ArTranslations.pointSingular,
      'totalLabel': ArTranslations.totalLabel,
      'usedLabel': ArTranslations.usedLabel,
      'discountLabel': ArTranslations.discountLabel,
      'pointsToNextTierTemplate': ArTranslations.pointsToNextTierTemplate,
      'completeBookingAction': ArTranslations.completeBookingAction,
      'plusPointsTemplate': ArTranslations.plusPointsTemplate,
      'pointsInfoTitle': ArTranslations.pointsInfoTitle,
      'pointsInfoBody': ArTranslations.pointsInfoBody,
      'daysAgoPlural': ArTranslations.daysAgoPlural,
      'currentUserUnknown': ArTranslations.currentUserUnknown,
      'chooseItemToPromote': ArTranslations.chooseItemToPromote,
      'sponsoredCampaignDesc': ArTranslations.sponsoredCampaignDesc,
      'promoteAccount': ArTranslations.promoteAccount,
      'promoteReel': ArTranslations.promoteReel,
      'promoteStory': ArTranslations.promoteStory,
      'promoteVenuePlace': ArTranslations.promoteVenuePlace,
      'reelFallbackTemplate': ArTranslations.reelFallbackTemplate,
      'storyFallbackTemplate': ArTranslations.storyFallbackTemplate,
      'noCampaignToShow': ArTranslations.noCampaignToShow,
      'impressionsLabel': ArTranslations.impressionsLabel,
      'clicksLabel': ArTranslations.clicksLabel,
      'spendLabel': ArTranslations.spendLabel,
      'budgetLabel': ArTranslations.budgetLabel,
      'totalBudgetLabel': ArTranslations.totalBudgetLabel,
      'dailyBudgetLabel': ArTranslations.dailyBudgetLabel,
      'spentLabel': ArTranslations.spentLabel,
      'targetsLabel': ArTranslations.targetsLabel,
      'statusUnderReview': ArTranslations.statusUnderReview,
      'statusApproved': ArTranslations.statusApproved,
      'statusRejectedF': ArTranslations.statusRejectedF,
      'statusActive': ArTranslations.statusActive,
      'statusPaused': ArTranslations.statusPaused,
      'statusCompletedF': ArTranslations.statusCompletedF,
      'statusDraft': ArTranslations.statusDraft,
      'myAccountOption': ArTranslations.myAccountOption,
      'featuredReel': ArTranslations.featuredReel,
      'featuredStory': ArTranslations.featuredStory,
      'venueOrPlace': ArTranslations.venueOrPlace,
      'chooseWhatToPromote': ArTranslations.chooseWhatToPromote,
      'accountOption': ArTranslations.accountOption,
      'reelOption': ArTranslations.reelOption,
      'storyOption': ArTranslations.storyOption,
      'targetItemLabel': ArTranslations.targetItemLabel,
      'adDurationLabel': ArTranslations.adDurationLabel,
      'dayUnit': ArTranslations.dayUnit,
      'daysUnit': ArTranslations.daysUnit,
      'regionLabel': ArTranslations.regionLabel,
      'allIraq': ArTranslations.allIraq,
      'governorateOption': ArTranslations.governorateOption,
      'loginFirstOrChooseItem': ArTranslations.loginFirstOrChooseItem,
      'campaignCreateFailed': ArTranslations.campaignCreateFailed,
      'plansAndSubscriptions': ArTranslations.plansAndSubscriptions,
      'yearlyDiscount': ArTranslations.yearlyDiscount,
      'monthly': ArTranslations.monthly,
      'noPlansAvailable': ArTranslations.noPlansAvailable,
      'planActivatedTemplate': ArTranslations.planActivatedTemplate,
      'planActivationFailed': ArTranslations.planActivationFailed,
      'comparePlans': ArTranslations.comparePlans,
      'portfolioImagesTemplate': ArTranslations.portfolioImagesTemplate,
      'reelsPerMonthTemplate': ArTranslations.reelsPerMonthTemplate,
      'betterSearchVisibility': ArTranslations.betterSearchVisibility,
      'basicAnalytics': ArTranslations.basicAnalytics,
      'adsDiscount': ArTranslations.adsDiscount,
      'fasterSupport': ArTranslations.fasterSupport,
      'perMonth': ArTranslations.perMonth,
      'activePlan': ArTranslations.activePlan,
      'choosePlan': ArTranslations.choosePlan,
      'photographerLoadFailed': ArTranslations.photographerLoadFailed,
      'weddingPhotographer': ArTranslations.weddingPhotographer,
      'projectsLabel': ArTranslations.projectsLabel,
      'followersLabel': ArTranslations.followersLabel,
      'followingLabel': ArTranslations.followingLabel,
      'contactAction': ArTranslations.contactAction,
      'worksTab': ArTranslations.worksTab,
      'reviewsTab': ArTranslations.reviewsTab,
      'reelsTab': ArTranslations.reelsTab,
      'followTabLabel': ArTranslations.followTabLabel,
      'sessionsHighlight': ArTranslations.sessionsHighlight,
      'behindScenes': ArTranslations.behindScenes,
      'studioHighlight': ArTranslations.studioHighlight,
      'noWorksYet': ArTranslations.noWorksYet,
      'noReelsYet': ArTranslations.noReelsYet,
      'ratingSummary': ArTranslations.ratingSummary,
      'ratingSummaryTemplate': ArTranslations.ratingSummaryTemplate,
      'verifiedSpecialtyNote': ArTranslations.verifiedSpecialtyNote,
      'usernameReserved': ArTranslations.usernameReserved,
      'usernameFormatError': ArTranslations.usernameFormatError,
      'usernameUnavailable': ArTranslations.usernameUnavailable,
      'usernameVerifyFailed': ArTranslations.usernameVerifyFailed,
      'noSignedInUser': ArTranslations.noSignedInUser,
      'saveError': ArTranslations.saveError,
      'usernameFieldLabel': ArTranslations.usernameFieldLabel,
      'usernameExampleHint': ArTranslations.usernameExampleHint,
      'enterUsername': ArTranslations.enterUsername,
      'usernameFormatNoSpaces': ArTranslations.usernameFormatNoSpaces,
      'minTwoChars': ArTranslations.minTwoChars,
      'checkingProgress': ArTranslations.checkingProgress,
      'usernameAvailable': ArTranslations.usernameAvailable,
      'usernameSuggestions': ArTranslations.usernameSuggestions,
      'loadingShort': ArTranslations.loadingShort,
      'suggestionsAction': ArTranslations.suggestionsAction,
      'emailOptionalLabel': ArTranslations.emailOptionalLabel,
      'emailFormatError': ArTranslations.emailFormatError,
      'fullNameLabel': ArTranslations.fullNameLabel,
      'fullNameHint': ArTranslations.fullNameHint,
      'fullNameRequired': ArTranslations.fullNameRequired,
      'genderLabel': ArTranslations.genderLabel,
      'birthYearLabel': ArTranslations.birthYearLabel,
      'birthYearHint': ArTranslations.birthYearHint,
      'enterBirthYear': ArTranslations.enterBirthYear,
      'birthYearAdultError': ArTranslations.birthYearAdultError,
      'chooseGovernorateHint': ArTranslations.chooseGovernorateHint,
      'confirmOver18Checkbox': ArTranslations.confirmOver18Checkbox,
      'loginToViewPortfolio': ArTranslations.loginToViewPortfolio,
      'portfolioLoadFailed': ArTranslations.portfolioLoadFailed,
      'imageAddFailed': ArTranslations.imageAddFailed,
      'portfolioNeedsSubscription': ArTranslations.portfolioNeedsSubscription,
      'portfolioPhotographersOnly': ArTranslations.portfolioPhotographersOnly,
      'portfolioLimitReached': ArTranslations.portfolioLimitReached,
      'noPortfolioImages': ArTranslations.noPortfolioImages,
      'portfolioShowQuality': ArTranslations.portfolioShowQuality,
      'addFirstImage': ArTranslations.addFirstImage,
      'profileLoadFailed': ArTranslations.profileLoadFailed,
      'enterFieldTemplate': ArTranslations.enterFieldTemplate,
      'completeBasicInfo': ArTranslations.completeBasicInfo,
      'notAdded': ArTranslations.notAdded,
      'accountVerification': ArTranslations.accountVerification,
      'manageTeachingCourses': ArTranslations.manageTeachingCourses,
      'adminPanel': ArTranslations.adminPanel,
      'governoratePrefixTemplate': ArTranslations.governoratePrefixTemplate,
      'locationDescriptionHint': ArTranslations.locationDescriptionHint,
      'searchFailedTryAgain': ArTranslations.searchFailedTryAgain,
      'escrowPolicyTitle': ArTranslations.escrowPolicyTitle,
      'escrowPolicyBody': ArTranslations.escrowPolicyBody,
      'editPolicyTitle': ArTranslations.editPolicyTitle,
      'editPolicyBody': ArTranslations.editPolicyBody,
      'cancelPolicyTitle': ArTranslations.cancelPolicyTitle,
      'cancelPolicyBody': ArTranslations.cancelPolicyBody,
      'privacyPolicyTitle': ArTranslations.privacyPolicyTitle,
      'privacyPolicyBody': ArTranslations.privacyPolicyBody,
      'disputesPolicyTitle': ArTranslations.disputesPolicyTitle,
      'disputesPolicyBody': ArTranslations.disputesPolicyBody,
      'before48h': ArTranslations.before48h,
      'within48h': ArTranslations.within48h,
      'noShow': ArTranslations.noShow,
      'reportSpam': ArTranslations.reportSpam,
      'reportFraud': ArTranslations.reportFraud,
      'reportHarassment': ArTranslations.reportHarassment,
      'reportCopyright': ArTranslations.reportCopyright,
      'reportSentSuccess': ArTranslations.reportSentSuccess,
      'reportReviewSoon': ArTranslations.reportReviewSoon,
      'reportingAbout': ArTranslations.reportingAbout,
      'describeIssueHint': ArTranslations.describeIssueHint,
      'addReportDetails': ArTranslations.addReportDetails,
      'detailsMin20Chars': ArTranslations.detailsMin20Chars,
      'reportReviewNote': ArTranslations.reportReviewNote,
      'submitReportCheck': ArTranslations.submitReportCheck,
      'storeLuxuryFrame': ArTranslations.storeLuxuryFrame,
      'storeLuxuryFrameSub': ArTranslations.storeLuxuryFrameSub,
      'storePrintedAlbum': ArTranslations.storePrintedAlbum,
      'storePrintedAlbumSub': ArTranslations.storePrintedAlbumSub,
      'bestSeller': ArTranslations.bestSeller,
      'storeProductSession': ArTranslations.storeProductSession,
      'storeProductSessionSub': ArTranslations.storeProductSessionSub,
      'storeCuratedSubtitle': ArTranslations.storeCuratedSubtitle,
      'storeOrderInstruction': ArTranslations.storeOrderInstruction,
      'storeOrderMessageTemplate': ArTranslations.storeOrderMessageTemplate,
      'verifyAccountPrompt': ArTranslations.verifyAccountPrompt,
      'requestStatus': ArTranslations.requestStatus,
      'verifiedLabel': ArTranslations.verifiedLabel,
      'notVerifiedLabel': ArTranslations.notVerifiedLabel,
      'portfolioReview': ArTranslations.portfolioReview,
      'identityReview': ArTranslations.identityReview,
      'completedLabel': ArTranslations.completedLabel,
      'awaitingReview': ArTranslations.awaitingReview,
      'rejectionReasonTemplate': ArTranslations.rejectionReasonTemplate,
      'underReview': ArTranslations.underReview,
      'rejectedLabel': ArTranslations.rejectedLabel,
      'notSubmitted': ArTranslations.notSubmitted,
      'sortPriceLowFirst': ArTranslations.sortPriceLowFirst,
      'sortTopTrust': ArTranslations.sortTopTrust,
      'sortFastestDelivery': ArTranslations.sortFastestDelivery,
      'sortNearest': ArTranslations.sortNearest,
      'sortPriceLowToHigh': ArTranslations.sortPriceLowToHigh,
      'sortHighestTrust': ArTranslations.sortHighestTrust,
      'sortFastestDeliveryLong': ArTranslations.sortFastestDeliveryLong,
      'sortNearestToYou': ArTranslations.sortNearestToYou,
      'province_baghdad': ArTranslations.provinceBaghdad,
      'province_basra': ArTranslations.provinceBasra,
      'province_nineveh': ArTranslations.provinceNineveh,
      'province_erbil': ArTranslations.provinceErbil,
      'province_najaf': ArTranslations.provinceNajaf,
      'province_karbala': ArTranslations.provinceKarbala,
      'province_kirkuk': ArTranslations.provinceKirkuk,
      'province_dhi_qar': ArTranslations.provinceDhiQar,
      'province_sulaymaniyah': ArTranslations.provinceSulaymaniyah,
      'province_anbar': ArTranslations.provinceAnbar,
      'province_diyala': ArTranslations.provinceDiyala,
      'province_saladin': ArTranslations.provinceSaladin,
      'province_maysan': ArTranslations.provinceMaysan,
      'province_wasit': ArTranslations.provinceWasit,
      'province_muthanna': ArTranslations.provinceMuthanna,
      'province_qadisiyah': ArTranslations.provinceQadisiyah,
      'province_babil': ArTranslations.provinceBabil,
      'province_duhok': ArTranslations.provinceDuhok,
      'callAction': ArTranslations.callAction,
      'enrollmentCreateFailed': ArTranslations.enrollmentCreateFailed,
      'imageUploadFailed': ArTranslations.imageUploadFailed,
      'endTimeAfterStart': ArTranslations.endTimeAfterStart,
      'inPersonLabel': ArTranslations.inPersonLabel,
      'onlineLabel': ArTranslations.onlineLabel,
      'deleteCourseTitle': ArTranslations.deleteCourseTitle,
      'deleteCourseFailed': ArTranslations.deleteCourseFailed,
      'viewPhotographer': ArTranslations.viewPhotographer,
      'requestSameStyle': ArTranslations.requestSameStyle,
      'locationOnMap': ArTranslations.locationOnMap,
      'loyaltyPointsTitle': ArTranslations.loyaltyPointsTitle,
      'historyLabel': ArTranslations.historyLabel,
      'nextLevelProgress': ArTranslations.nextLevelProgress,
      'tierBronze': ArTranslations.tierBronze,
      'tierSilver': ArTranslations.tierSilver,
      'tierGold': ArTranslations.tierGold,
      'tierPlatinum': ArTranslations.tierPlatinum,
      'howToEarnPoints': ArTranslations.howToEarnPoints,
      'campaignAnalyticsTitle': ArTranslations.campaignAnalyticsTitle,
      'campaignCreatedForReview': ArTranslations.campaignCreatedForReview,
      'chatOpenAfterBooking': ArTranslations.chatOpenAfterBooking,
      'usernameCheckError': ArTranslations.usernameCheckError,
      'confirmOver18': ArTranslations.confirmOver18,
      'maxPortfolioImages': ArTranslations.maxPortfolioImages,
      'imageAddedSuccess': ArTranslations.imageAddedSuccess,
      'imageDeletedSuccess': ArTranslations.imageDeletedSuccess,
      'portfolioSaveFailed': ArTranslations.portfolioSaveFailed,
      'portfolioTitle': ArTranslations.portfolioTitle,
      'deleteImageTitle': ArTranslations.deleteImageTitle,
      'deleteImageConfirm': ArTranslations.deleteImageConfirm,
      'profilePhotoUpdated': ArTranslations.profilePhotoUpdated,
      'editFieldTemplate': ArTranslations.editFieldTemplate,
      'fieldCannotBeEmptyTemplate': ArTranslations.fieldCannotBeEmptyTemplate,
      'fieldUpdatedTemplate': ArTranslations.fieldUpdatedTemplate,
      'fieldUpdateFailedTemplate': ArTranslations.fieldUpdateFailedTemplate,
      'myAccountTitle': ArTranslations.myAccountTitle,
      'descriptionOptional': ArTranslations.descriptionOptional,
      'saveLocation': ArTranslations.saveLocation,
      'bookingPoliciesTitle': ArTranslations.bookingPoliciesTitle,
      'chooseReportReason': ArTranslations.chooseReportReason,
      'reportSendError': ArTranslations.reportSendError,
      'sendReportTitle': ArTranslations.sendReportTitle,
      'reportReasonLabel': ArTranslations.reportReasonLabel,
      'extraDetailsLabel': ArTranslations.extraDetailsLabel,
      'deleteAccountPolicy': ArTranslations.deleteAccountPolicy,
      'contentPolicy': ArTranslations.contentPolicy,
      'chooseEventDateFirst': ArTranslations.chooseEventDateFirst,
      'bookingRequestSent': ArTranslations.bookingRequestSent,
      'verificationRequestSent': ArTranslations.verificationRequestSent,
      'verificationRequestFailed': ArTranslations.verificationRequestFailed,
      'photographerVerificationTitle': ArTranslations.photographerVerificationTitle,
      'sendVerificationRequest': ArTranslations.sendVerificationRequest,
      'loadMoreFailed': ArTranslations.loadMoreFailed,
      'noItems': ArTranslations.noItems,
      'loadFailed': ArTranslations.loadFailed,
      'waitlistSubmitFailed': ArTranslations.waitlistSubmitFailed,
      'userLabel': ArTranslations.userLabel,
      'venuePlaceLabel': ArTranslations.venuePlaceLabel,
      'registerInterest': ArTranslations.registerInterest,
      'recheckAction': ArTranslations.recheckAction,
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get appName => translate('appName');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get search => translate('search');
  String get searchPhotographers => translate('searchPhotographers');
  String get filter => translate('filter');
  String get next => translate('next');
  String get back => translate('back');
  String get done => translate('done');
  String get todayLabel => translate('todayLabel');
  String get upcomingLabel => translate('upcomingLabel');
  String get analyticsLabel => translate('analyticsLabel');
  String get yes => translate('yes');
  String get no => translate('no');
  String get submit => translate('submit');
  String get notSpecified => translate('notSpecified');
  String get days => translate('days');
  String get minutes => translate('minutes');
  String get typeLabel => translate('typeLabel');
  String get statusLabel => translate('statusLabel');
  String get reportedLabel => translate('reportedLabel');
  String get openedByLabel => translate('openedByLabel');
  String get loading => translate('loading');
  String get error => translate('error');
  String get somethingWentWrong => translate('somethingWentWrong');
  String get retry => translate('retry');
  String get weakPassword => translate('weakPassword');
  String get fairPassword => translate('fairPassword');
  String get goodPassword => translate('goodPassword');
  String get strongPassword => translate('strongPassword');
  String get noData => translate('noData');
  String get pressBackAgainToExit => translate('pressBackAgainToExit');
  String get noPhotographers => translate('noPhotographers');
  String get noResults => translate('noResults');
  String get selectLanguage => translate('selectLanguage');
  String get selectLanguageSubtitle => translate('selectLanguageSubtitle');
  String get languageHint => translate('languageHint');
  String get welcomeBack => translate('welcomeBack');
  String get welcomeToLaqta => translate('welcomeToLaqta');
  String get authSubtitle => translate('authSubtitle');
  String get signInTitle => translate('signInTitle');
  String get signUpTitle => translate('signUpTitle');
  String get signInWithPhone => translate('signInWithPhone');
  String get signUpWithPhone => translate('signUpWithPhone');
  String get phoneNumber => translate('phoneNumber');
  String get verifyOTP => translate('verifyOTP');
  String get enterOTP => translate('enterOTP');
  String get resendCode => translate('resendCode');
  String get verify => translate('verify');
  String get orLabel => translate('or');
  String get phoneAuthUnsupported => translate('phoneAuthUnsupported');
  String get phoneAuthSupportInfo => translate('phoneAuthSupportInfo');
  String get phoneNumberRequired => translate('phoneNumberRequired');
  String get verificationFailed => translate('verificationFailed');
  String get phoneAuthError => translate('phoneAuthError');
  String get otpInvalid => translate('otpInvalid');
  String get verificationIdMissing => translate('verificationIdMissing');
  String get otpVerificationFailed => translate('otpVerificationFailed');
  String get resendFailed => translate('resendFailed');
  String get resendError => translate('resendError');
  String get otpSentSuccess => translate('otpSentSuccess');
  String get chooseRole => translate('chooseRole');
  String get customer => translate('customer');
  String get photographer => translate('photographer');
  String get iAmCustomer => translate('iAmCustomer');
  String get iAmPhotographer => translate('iAmPhotographer');
  String get completeProfile => translate('completeProfile');
  String get fullName => translate('fullName');
  String get governorate => translate('governorate');
  String get selectGovernorate => translate('selectGovernorate');
  String get interests => translate('interests');
  String get bio => translate('bio');
  String get specialties => translate('specialties');
  String get basePrice => translate('basePrice');
  String get instagram => translate('instagram');
  String get tiktok => translate('tiktok');
  String get uploadPortfolio => translate('uploadPortfolio');
  String get home => translate('home');
  String get bookWithConfidence => translate('bookWithConfidence');
  String get requestQuickPrompt => translate('requestQuickPrompt');
  String get activeRequests => translate('activeRequests');
  String get shop => translate('shop');
  String get featuredProducts => translate('featuredProducts');
  String get noProducts => translate('noProducts');
  String get productsEmptyMessage => translate('productsEmptyMessage');
  String get orderNow => translate('orderNow');
  String get upcomingBookings => translate('upcomingBookings');
  String get noBookings => translate('noBookings');
  String get noBookingsMessage => translate('noBookingsMessage');
  String get past => translate('past');
  String get explorePhotographers => translate('explorePhotographers');
  String get bookNow => translate('bookNow');
  String get startingFrom => translate('startingFrom');
  String get viewProfile => translate('viewProfile');
  String get topRated => translate('topRated');
  String get offers => translate('offers');
  String get selectDate => translate('selectDate');
  String get selectTime => translate('selectTime');
  String get invalidDateTime => translate('invalidDateTime');
  String get invalidBudgetRange => translate('invalidBudgetRange');
  String get invalidLocation => translate('invalidLocation');
  String get confirmBooking => translate('confirmBooking');
  String get chat => translate('chat');
  String get typeMessage => translate('typeMessage');
  String get deleteChatTitle => translate('deleteChatTitle');
  String get deleteConversationPrompt => translate('deleteConversationPrompt');
  String get deleteChatPrompt => translate('deleteChatPrompt');
  String get chatDeleted => translate('chatDeleted');
  String get chatDeleteFailed => translate('chatDeleteFailed');
  String get noMessagesTitle => translate('noMessagesTitle');
  String get noChatResults => translate('noChatResults');
  String get startConversationWithPhotographer =>
      translate('startConversationWithPhotographer');
  String get tryAnotherNameOrKeyword => translate('tryAnotherNameOrKeyword');
  String get unableToDetermineUser => translate('unableToDetermineUser');
  String get userBlocked => translate('userBlocked');
  String get userUnblocked => translate('userUnblocked');
  String get blockUser => translate('blockUser');
  String get reportUser => translate('reportUser');
  String get sendImage => translate('sendImage');
  String get sendVideo => translate('sendVideo');
  String get sendDocument => translate('sendDocument');
  String get uploadingImage => translate('uploadingImage');
  String get uploadingVideo => translate('uploadingVideo');
  String get uploadingDocument => translate('uploadingDocument');
  String get sendImageFailed => translate('sendImageFailed');
  String get sendVideoFailed => translate('sendVideoFailed');
  String get sendDocumentFailed => translate('sendDocumentFailed');
  String get onlineNow => translate('onlineNow');
  String get noMessagesYet => translate('noMessagesYet');
  String get startConversationPrompt => translate('startConversationPrompt');
  String get cannotOpenFile => translate('cannotOpenFile');
  String get send => translate('send');
  String get reviews => translate('reviews');
  String get male => translate('male');
  String get female => translate('female');
  String get verifiedBadge => translate('verifiedBadge');
  String get proBadge => translate('proBadge');
  String get recommendedBadge => translate('recommendedBadge');
  String get newBadge => translate('newBadge');
  String get availableTodayBadge => translate('availableTodayBadge');
  String get offerBadge => translate('offerBadge');

  String yearsOld(int age) => '$age ${translate('yearsOldSuffix')}';
  String get notifications => translate('notifications');
  String get noNotifications => translate('noNotifications');
  String get readAllNotifications => translate('readAllNotifications');
  String get userNotAuthenticated => translate('userNotAuthenticated');
  String get loadNotificationsFailed => translate('loadNotificationsFailed');
  String get markNotificationReadFailed =>
      translate('markNotificationReadFailed');
  String get markAllNotificationsReadFailed =>
      translate('markAllNotificationsReadFailed');
  String get deleteNotificationFailed => translate('deleteNotificationFailed');
  String get settings => translate('settings');
  String get language => translate('language');
  String get logout => translate('logout');
  String get logoutSuccess => translate('logoutSuccess');
  String get logoutFailed => translate('logoutFailed');
  String get deleteAccount => translate('deleteAccount');
  String get deleteAccountConfirm => translate('deleteAccountConfirm');
  String get deleteAccountSuccess => translate('deleteAccountSuccess');
  String get deleteAccountFailed => translate('deleteAccountFailed');
  String get noUserLoggedIn => translate('noUserLoggedIn');
  String get enableNotifications => translate('enableNotifications');
  String get notificationsSubtitle => translate('notificationsSubtitle');
  String get reduceMotion => translate('reduceMotion');
  String get privacy => translate('privacy');
  String get terms => translate('terms');
  String get accept => translate('accept');
  String get reject => translate('reject');
  String get dashboard => translate('dashboard');
  String get myBookings => translate('myBookings');
  String get favorites => translate('favorites');
  String get messages => translate('messages');
  String get notificationsSection => translate('notificationsSection');
  String get appearanceSection => translate('appearanceSection');
  String get accessibilitySection => translate('accessibilitySection');
  String get legalSection => translate('legalSection');
  String get accountSection => translate('accountSection');
  String get darkMode => translate('darkMode');
  String get darkModeSubtitle => translate('darkModeSubtitle');
  String get reduceMotionSubtitle => translate('reduceMotionSubtitle');
  String get languageChanged => translate('languageChanged');
  String get availability => translate('availability');
  String get manageSlots => translate('manageSlots');
  String get weeklyTemplate => translate('weeklyTemplate');
  String get popularSpecialties => translate('popularSpecialties');
  String get recentSearches => translate('recentSearches');
  String get clearAll => translate('clearAll');
  String get missingReviewInfo => translate('missingReviewInfo');
  String get payment => translate('payment');
  String get payDeposit => translate('payDeposit');
  String get payFull => translate('payFull');
  String get paymentSuccessful => translate('paymentSuccessful');
  String get paymentFailed => translate('paymentFailed');
  String get paymentsUnavailable => translate('paymentsUnavailable');
  String get createPost => translate('createPost');
  String get createStory => translate('createStory');
  String get addPhoto => translate('addPhoto');
  String get camera => translate('camera');
  String get gallery => translate('gallery');
  String get captionOptional => translate('captionOptional');
  String get sharePost => translate('sharePost');
  String get shareStory => translate('shareStory');
  String get mediaRequired => translate('mediaRequired');
  String get notPhotographer => translate('notPhotographer');
  String get postPublished => translate('postPublished');
  String get storyPublished => translate('storyPublished');
  String get requests => translate('requests');
  String get myRequests => translate('myRequests');
  String get createRequest => translate('createRequest');
  String get editRequest => translate('editRequest');
  String get requestDetails => translate('requestDetails');
  String get requestNotFound => translate('requestNotFound');
  String get requestLoadError => translate('requestLoadError');
  String get noDeadline => translate('noDeadline');
  String get offersClosed => translate('offersClosed');
  String get receivingOffers => translate('receivingOffers');
  String get photographyType => translate('photographyType');
  String get styleLabel => translate('styleLabel');
  String get dateLabel => translate('dateLabel');
  String get timeLabel => translate('timeLabel');
  String get locationLabel => translate('locationLabel');
  String get mapLabel => translate('mapLabel');
  String get addressLabel => translate('addressLabel');
  String get notesLabel => translate('notesLabel');
  String get viewAll => translate('viewAll');
  String get addressOptional => translate('addressOptional');
  String get addressHint => translate('addressHint');
  String get selectLocationOnMap => translate('selectLocationOnMap');
  String get locationSelected => translate('locationSelected');
  String get budget => translate('budget');
  String get minLabel => translate('minLabel');
  String get maxLabel => translate('maxLabel');
  String get duration => translate('duration');
  String get hours => translate('hours');
  String get deliverables => translate('deliverables');
  String get photosCount => translate('photosCount');
  String get videoMinutes => translate('videoMinutes');
  String get includeVideo => translate('includeVideo');
  String get includeEditing => translate('includeEditing');
  String get additionalNotes => translate('additionalNotes');
  String get addReferenceImages => translate('addReferenceImages');
  String get saveDraft => translate('saveDraft');
  String get publishRequest => translate('publishRequest');
  String get saveChanges => translate('saveChanges');
  String get draftSaved => translate('draftSaved');
  String get requestPublished => translate('requestPublished');
  String get requestUpdated => translate('requestUpdated');
  String get requestSubmitFailed => translate('requestSubmitFailed');
  String get requestCancelFailed => translate('requestCancelFailed');
  String get cancelRequest => translate('cancelRequest');
  String get cancelRequestPrompt => translate('cancelRequestPrompt');
  String get requestCanceled => translate('requestCanceled');
  String get drafts => translate('drafts');
  String get active => translate('active');
  String get closed => translate('closed');
  String get noRequests => translate('noRequests');
  String get noDrafts => translate('noDrafts');
  String get noActiveRequests => translate('noActiveRequests');
  String get noClosedRequests => translate('noClosedRequests');
  String get requestStatusDraft => translate('requestStatusDraft');
  String get requestStatusAwaitingOffers =>
      translate('requestStatusAwaitingOffers');
  String get requestStatusOfferSelected =>
      translate('requestStatusOfferSelected');
  String get requestStatusClosed => translate('requestStatusClosed');
  String get requestStatusCanceled => translate('requestStatusCanceled');
  String get requestStatusExpired => translate('requestStatusExpired');
  String get requestStatusPublished => translate('requestStatusPublished');
  String get offersSection => translate('offersSection');
  String get noOffersYet => translate('noOffersYet');
  String get offersComingSoon => translate('offersComingSoon');
  String get offerRequiredFields => translate('offerRequiredFields');
  String get sendOffer => translate('sendOffer');
  String get sendOfferPrompt => translate('sendOfferPrompt');
  String get acceptOffer => translate('acceptOffer');
  String get acceptOfferPrompt => translate('acceptOfferPrompt');
  String get acceptOfferFailed => translate('acceptOfferFailed');
  String get deliveryInDays => translate('deliveryInDays');
  String get offerSent => translate('offerSent');
  String get offerFailed => translate('offerFailed');
  String get priceLabel => translate('priceLabel');
  String get deliveryDays => translate('deliveryDays');
  String get notesOptional => translate('notesOptional');
  String get references => translate('references');
  String get includesVideo => translate('includesVideo');
  String get includesEditing => translate('includesEditing');
  String get budgetFrom => translate('budgetFrom');
  String get budgetUpTo => translate('budgetUpTo');
  String get requestsEmptyMessage => translate('requestsEmptyMessage');
  String get openRequests => translate('openRequests');
  String get noRequestsFound => translate('noRequestsFound');
  String get noRequestsFoundMessage => translate('noRequestsFoundMessage');
  String get bookingRoom => translate('bookingRoom');
  String get bookingNotFound => translate('bookingNotFound');
  String get bookingLoadError => translate('bookingLoadError');
  String get startJob => translate('startJob');
  String get uploadDelivery => translate('uploadDelivery');
  String get acceptDelivery => translate('acceptDelivery');
  String get requestRevision => translate('requestRevision');
  String get openDispute => translate('openDispute');
  String get cancelBooking => translate('cancelBooking');
  String get bookingCancelPrompt => translate('bookingCancelPrompt');
  String get bookingCancelSuccess => translate('bookingCancelSuccess');
  String get bookingCancelFailed => translate('bookingCancelFailed');
  String get bookingUpdateFailed => translate('bookingUpdateFailed');
  String get disputeOpenFailed => translate('disputeOpenFailed');
  String get revisionLimitReached => translate('revisionLimitReached');
  String get revisionDescribeChanges => translate('revisionDescribeChanges');
  String get timeline => translate('timeline');
  String get delivery => translate('delivery');
  String get filesLabel => translate('filesLabel');
  String get addPhotos => translate('addPhotos');
  String get addVideo => translate('addVideo');
  String get submitDelivery => translate('submitDelivery');
  String get leaveReview => translate('leaveReview');
  String get deliveryFilesRequired => translate('deliveryFilesRequired');
  String get deliverySubmitFailed => translate('deliverySubmitFailed');
  String get noDeliveryYet => translate('noDeliveryYet');
  String get photos => translate('photos');
  String get videos => translate('videos');
  String get note => translate('note');
  String get revisionRequest => translate('revisionRequest');
  String get bookingStarted => translate('bookingStarted');
  String get bookingCompleted => translate('bookingCompleted');
  String get bookingCanceledMessage => translate('bookingCanceledMessage');
  String get bookingCanceled => translate('bookingCanceled');
  String get bookingAcceptedMessage => translate('bookingAcceptedMessage');
  String get bookingAcceptFailed => translate('bookingAcceptFailed');
  String get bookingRejectedMessage => translate('bookingRejectedMessage');
  String get bookingRejectFailed => translate('bookingRejectFailed');
  String get disputeOpened => translate('disputeOpened');
  String get bookingInProgress => translate('bookingInProgress');
  String get bookingAwaitingDelivery => translate('bookingAwaitingDelivery');
  String get bookingDelivered => translate('bookingDelivered');
  String get bookingRevisionRequested => translate('bookingRevisionRequested');
  String get bookingDisputeOpen => translate('bookingDisputeOpen');
  String get adminDashboard => translate('adminDashboard');
  String get adminDisputes => translate('adminDisputes');
  String get adminReports => translate('adminReports');
  String get adminUsers => translate('adminUsers');
  String get requestsToday => translate('requestsToday');
  String get totalBookings => translate('totalBookings');
  String get cancellations => translate('cancellations');
  String get openDisputesCount => translate('openDisputesCount');
  String get reviewDisputes => translate('reviewDisputes');
  String get reviewReports => translate('reviewReports');
  String get manageUsers => translate('manageUsers');
  String get noDisputes => translate('noDisputes');
  String get noDisputesMessage => translate('noDisputesMessage');
  String get disputeDetails => translate('disputeDetails');
  String get bookingSummary => translate('bookingSummary');
  String get resolutionNote => translate('resolutionNote');
  String get resolveRelease => translate('resolveRelease');
  String get resolveRefund => translate('resolveRefund');
  String get resolvePartial => translate('resolvePartial');
  String get disputeResolved => translate('disputeResolved');
  String get disputeResolveFailed => translate('disputeResolveFailed');
  String get reportsEmpty => translate('reportsEmpty');
  String get usersEmpty => translate('usersEmpty');
  String get markResolved => translate('markResolved');
  String get dismiss => translate('dismiss');
  String get warningSent => translate('warningSent');
  String get warningFailed => translate('warningFailed');
  String get block => translate('block');
  String get unblock => translate('unblock');
  String get sendWarning => translate('sendWarning');
  String get accountBlocked => translate('accountBlocked');
  String get accountBlockedMessage => translate('accountBlockedMessage');
  String get signOut => translate('signOut');

  // Policies
  String get policies => translate('policies');
  String get policiesSubtitle => translate('policiesSubtitle');
  String get readPolicies => translate('readPolicies');
  String get agreeToTerms => translate('agreeToTerms');
  String get iUnderstand => translate('iUnderstand');
  String get bookingPolicies => translate('bookingPolicies');
  String get bookingPoliciesSubtitle => translate('bookingPoliciesSubtitle');

  // Escrow Policy
  String get escrowPolicy => translate('escrowPolicy');
  String get escrowPolicyDesc => translate('escrowPolicyDesc');
  String get escrowReleaseTitle => translate('escrowReleaseTitle');
  String get escrowReleaseDesc => translate('escrowReleaseDesc');

  // Revision Policy
  String get revisionPolicy => translate('revisionPolicy');
  String get revisionPolicyDesc => translate('revisionPolicyDesc');
  String get revisionExtraTitle => translate('revisionExtraTitle');
  String get revisionExtraDesc => translate('revisionExtraDesc');

  // Cancellation Policy
  String get cancellationPolicy => translate('cancellationPolicy');
  String get cancellation48Hours => translate('cancellation48Hours');
  String get cancellation48HoursAfter => translate('cancellation48HoursAfter');
  String get cancellationPhotographer => translate('cancellationPhotographer');

  // Dispute Policy
  String get disputePolicy => translate('disputePolicy');
  String get disputePolicyDesc => translate('disputePolicyDesc');
  String get disputeProcess => translate('disputeProcess');
  String get disputeStep1 => translate('disputeStep1');
  String get disputeStep2 => translate('disputeStep2');
  String get disputeStep3 => translate('disputeStep3');
  String get disputeStep4 => translate('disputeStep4');

  // Trust Score Policy
  String get trustScorePolicy => translate('trustScorePolicy');
  String get trustScoreDesc => translate('trustScoreDesc');
  String get trustMetric1 => translate('trustMetric1');
  String get trustMetric2 => translate('trustMetric2');
  String get trustMetric3 => translate('trustMetric3');
  String get trustMetric4 => translate('trustMetric4');
  String get trustMetric5 => translate('trustMetric5');

  // Privacy Policy
  String get privacyPolicy => translate('privacyPolicy');
  String get privacyPhoneNumber => translate('privacyPhoneNumber');
  String get privacyFiles => translate('privacyFiles');
  String get privacyContact => translate('privacyContact');
  String get privacyLinks => translate('privacyLinks');

  // Payment Policy
  String get paymentPolicy => translate('paymentPolicy');
  String get paymentDeposit => translate('paymentDeposit');
  String get paymentRelease => translate('paymentRelease');
  String get paymentRefund => translate('paymentRefund');
  String get addReview => translate('addReview');
  String get addToFavorites => translate('addToFavorites');
  String get additionalDetails => translate('additionalDetails');
  String get applyFilters => translate('applyFilters');
  String get bookingConfirmed => translate('bookingConfirmed');
  String get bookingPending => translate('bookingPending');
  String get bookingRejected => translate('bookingRejected');
  String get clearFilters => translate('clearFilters');
  String get commentOptional => translate('commentOptional');
  String get communication => translate('communication');
  String get deliverySpeed => translate('deliverySpeed');
  String get detailsLabel => translate('detailsLabel');
  String get distanceUnavailable => translate('distanceUnavailable');
  String get distanceUnit => translate('distanceUnit');
  String get downloadLinks => translate('downloadLinks');
  String get estimatedDistance => translate('estimatedDistance');
  String get explore => translate('explore');
  String get filterByGovernorate => translate('filterByGovernorate');
  String get filterByPrice => translate('filterByPrice');
  String get filterByRating => translate('filterByRating');
  String get filterBySpecialty => translate('filterBySpecialty');
  String get location => translate('location');
  String get maxPrice => translate('maxPrice');
  String get minPrice => translate('minPrice');
  String get notes => translate('notes');
  String get onTimeDelivery => translate('onTimeDelivery');
  String get or => translate('or');
  String get photographerInGov => translate('photographerInGov');
  String get policyHighlightOne => translate('policyHighlightOne');
  String get policyHighlightThree => translate('policyHighlightThree');
  String get policyHighlightTwo => translate('policyHighlightTwo');
  String get policyHighlightsTitle => translate('policyHighlightsTitle');
  String get price => translate('price');
  String get quality => translate('quality');
  String get rateExperience => translate('rateExperience');
  String get rating => translate('rating');
  String get readFullTerms => translate('readFullTerms');
  String get reasonLabel => translate('reasonLabel');
  String get recommendQuestion => translate('recommendQuestion');
  String get removeFromFavorites => translate('removeFromFavorites');
  String get report => translate('report');
  String get reportContent => translate('reportContent');
  String get reviewCommentHint => translate('reviewCommentHint');
  String get reviewSubmitFailed => translate('reviewSubmitFailed');
  String get reviewSubmitted => translate('reviewSubmitted');
  String get selectReason => translate('selectReason');
  String get sessionType => translate('sessionType');
  String get signInWith => translate('signInWith');
  String get smartReview => translate('smartReview');
  String get smartReviewSubtitle => translate('smartReviewSubtitle');
  String get sortBy => translate('sortBy');
  String get submitReport => translate('submitReport');
  String get submitReview => translate('submitReview');
  String get suggestAlternative => translate('suggestAlternative');
  String get todaySchedule => translate('todaySchedule');
  String get total => translate('total');
  String get trustLevelHigh => translate('trustLevelHigh');
  String get trustLevelLow => translate('trustLevelLow');
  String get trustLevelMedium => translate('trustLevelMedium');
  String get trustLevelNew => translate('trustLevelNew');
  String get trustScore => translate('trustScore');
  String get typing => translate('typing');
  String get writeComment => translate('writeComment');

  // Shared state widgets
  String get errorNetworkMessage => translate('errorNetworkMessage');
  String get errorServerMessage => translate('errorServerMessage');
  String get errorSessionExpired => translate('errorSessionExpired');
  String get errorUnexpected => translate('errorUnexpected');
  String get sendReport => translate('sendReport');
  String get reportSent => translate('reportSent');
  String get restartAppPrompt => translate('restartAppPrompt');
  String get reportIdLabel => translate('reportIdLabel');
  String get offlineWeakConnection => translate('offlineWeakConnection');
  String get offlineNoConnection => translate('offlineNoConnection');
  String get lastOnlineLabel => translate('lastOnlineLabel');
  String get justNow => translate('justNow');
  String minutesAgo(int minutes) =>
      translate('minutesAgoTemplate').replaceAll('{minutes}', '$minutes');

  // Updates
  String get updateAvailableTitle => translate('updateAvailableTitle');
  String get updateAvailableBody => translate('updateAvailableBody');
  String get updateAction => translate('updateAction');
  String get laterAction => translate('laterAction');
  String get forceUpdateTitle => translate('forceUpdateTitle');
  String get forceUpdateBody => translate('forceUpdateBody');
  String get updateNowAction => translate('updateNowAction');

  // Security surfaces
  String get securityMaintenanceTitle => translate('securityMaintenanceTitle');
  String get secureConnectionFailed => translate('secureConnectionFailed');
  String get securityAlertTitle => translate('securityAlertTitle');
  String get continueAction => translate('continueAction');
  String get okAction => translate('okAction');
  String get untrustedDeviceWarning => translate('untrustedDeviceWarning');
  String get confirmIdentityForPayment =>
      translate('confirmIdentityForPayment');
  String get identityConfirmationFailed =>
      translate('identityConfirmationFailed');

  // Notifications permission
  String get enableNotificationsTitle => translate('enableNotificationsTitle');
  String get enableNotificationsBody => translate('enableNotificationsBody');
  String get allowAction => translate('allowAction');

  // Routing fallbacks
  String get pageNotFound => translate('pageNotFound');
  String get goHomeAction => translate('goHomeAction');
  String get bookingLoadFailed => translate('bookingLoadFailed');
  String get missingRouteParam => translate('missingRouteParam');

  // Onboarding carousel
  String get skip => translate('skip');
  String get startNow => translate('startNow');
  String get onboardingSlide1Title => translate('onboardingSlide1Title');
  String get onboardingSlide1Body => translate('onboardingSlide1Body');
  String get onboardingSlide2Title => translate('onboardingSlide2Title');
  String get onboardingSlide2Body => translate('onboardingSlide2Body');
  String get onboardingSlide3Title => translate('onboardingSlide3Title');
  String get onboardingSlide3Body => translate('onboardingSlide3Body');

  // Batch 2: auth, payment, favorites, achievements, dashboard
  String get loginSubtitle => translate('loginSubtitle');
  String get phoneOrUsername => translate('phoneOrUsername');
  String get passwordLabel => translate('passwordLabel');
  String get forgotPasswordQ => translate('forgotPasswordQ');
  String get loginAction => translate('loginAction');
  String get noAccountPrompt => translate('noAccountPrompt');
  String get createAccountAction => translate('createAccountAction');
  String get registerSubtitle => translate('registerSubtitle');
  String get haveAccountPrompt => translate('haveAccountPrompt');
  String get chooseAccountType => translate('chooseAccountType');
  String get basicInfoSection => translate('basicInfoSection');
  String get firstNameLabel => translate('firstNameLabel');
  String get lastNameLabel => translate('lastNameLabel');
  String get usernameLabel => translate('usernameLabel');
  String get usernameHint => translate('usernameHint');
  String get personalInfoSection => translate('personalInfoSection');
  String get birthdateLabel => translate('birthdateLabel');
  String get chooseBirthdate => translate('chooseBirthdate');
  String get provinceLabel => translate('provinceLabel');
  String get phoneVerificationSection => translate('phoneVerificationSection');
  String get sendOtpViaSms => translate('sendOtpViaSms');
  String get confirmPasswordLabel => translate('confirmPasswordLabel');
  String get forgotPasswordTitle => translate('forgotPasswordTitle');
  String get forgotPasswordSubtitle => translate('forgotPasswordSubtitle');
  String get newPasswordLabel => translate('newPasswordLabel');
  String get setPasswordAction => translate('setPasswordAction');
  String get rememberedPasswordPrompt => translate('rememberedPasswordPrompt');
  String get venueOwner => translate('venueOwner');
  String get loginMissingCredentials => translate('loginMissingCredentials');
  String get invalidCredentials => translate('invalidCredentials');
  String get firstNameRequired => translate('firstNameRequired');
  String get lastNameRequired => translate('lastNameRequired');
  String get usernameLengthError => translate('usernameLengthError');
  String get usernameNoSpaces => translate('usernameNoSpaces');
  String get usernameInvalidChars => translate('usernameInvalidChars');
  String get chooseGenderError => translate('chooseGenderError');
  String get chooseBirthdateError => translate('chooseBirthdateError');
  String get agePolicyError => translate('agePolicyError');
  String get chooseProvinceError => translate('chooseProvinceError');
  String get invalidPhoneError => translate('invalidPhoneError');
  String get enterOtpError => translate('enterOtpError');
  String get passwordPolicyError => translate('passwordPolicyError');
  String get passwordMismatchError => translate('passwordMismatchError');
  String get sendOtpFirstError => translate('sendOtpFirstError');
  String get otpSendFailedError => translate('otpSendFailedError');
  String get tryAgainLater => translate('tryAgainLater');
  String get datePickerChoose => translate('datePickerChoose');
  String get serviceUnavailableUpdate => translate('serviceUnavailableUpdate');
  String get usernameTaken => translate('usernameTaken');
  String get phoneTaken => translate('phoneTaken');
  String get codeExpired => translate('codeExpired');
  String get invalidOtpCode => translate('invalidOtpCode');
  String get waitBeforeNewCode => translate('waitBeforeNewCode');
  String get paymentCancelled => translate('paymentCancelled');
  String get confirmPaymentTitle => translate('confirmPaymentTitle');
  String get fraudAmountMismatch => translate('fraudAmountMismatch');
  String get fraudUntrustedEnv => translate('fraudUntrustedEnv');
  String get fraudModifiedDevice => translate('fraudModifiedDevice');
  String get fraudRelogin => translate('fraudRelogin');
  String get loginToViewFavorites => translate('loginToViewFavorites');
  String get favoritesLoadFailed => translate('favoritesLoadFailed');
  String get loginToManageFavorites => translate('loginToManageFavorites');
  String get removedFromFavorites => translate('removedFromFavorites');
  String get removeFromFavoritesFailed => translate('removeFromFavoritesFailed');
  String get noFavoritesTitle => translate('noFavoritesTitle');
  String get noFavoritesMessage => translate('noFavoritesMessage');
  String get searchTipFavorites => translate('searchTipFavorites');
  String get achievementsTitle => translate('achievementsTitle');
  String get progressLabel => translate('progressLabel');
  String get allAchievements => translate('allAchievements');
  String get achievementUnlocked => translate('achievementUnlocked');
  String get totalProgress => translate('totalProgress');
  String get forYouTab => translate('forYouTab');
  String get mostViewedTab => translate('mostViewedTab');
  String get weddingsTab => translate('weddingsTab');
  String get sessionsTab => translate('sessionsTab');
  String get discussionsTab => translate('discussionsTab');
  String get dashboardSearchHint => translate('dashboardSearchHint');
  String get noPostsYet => translate('noPostsYet');
  String get noPostsSubtitle => translate('noPostsSubtitle');
  String get sponsoredLabel => translate('sponsoredLabel');
  String get featuredLabel => translate('featuredLabel');
  String get downloadLinkOpenFailed => translate('downloadLinkOpenFailed');
  String get emailInvalid => translate('emailInvalid');
  String get nameRequired => translate('nameRequired');
  String get nameTooLong => translate('nameTooLong');
  String get nameInvalidChars => translate('nameInvalidChars');
  String get otpSixDigits => translate('otpSixDigits');
  String get futureDateRequired => translate('futureDateRequired');
  String get mustBeAdult => translate('mustBeAdult');

  // Batch 4 getters
  String get endingSoon => translate('endingSoon');
  String get achFirstBookingTitle => translate('achFirstBookingTitle');
  String get achFirstBookingDesc => translate('achFirstBookingDesc');
  String get achBookingExpertTitle => translate('achBookingExpertTitle');
  String get achBookingExpertDesc => translate('achBookingExpertDesc');
  String get achBookingProTitle => translate('achBookingProTitle');
  String get achBookingProDesc => translate('achBookingProDesc');
  String get achReviewCollectorTitle => translate('achReviewCollectorTitle');
  String get achReviewCollectorDesc => translate('achReviewCollectorDesc');
  String get achTopRatedTitle => translate('achTopRatedTitle');
  String get achTopRatedDesc => translate('achTopRatedDesc');
  String get achPopularTitle => translate('achPopularTitle');
  String get achPopularDesc => translate('achPopularDesc');
  String get achEarlyBirdTitle => translate('achEarlyBirdTitle');
  String get achEarlyBirdDesc => translate('achEarlyBirdDesc');
  String get achNightOwlTitle => translate('achNightOwlTitle');
  String get achNightOwlDesc => translate('achNightOwlDesc');
  String get achMoneyMakerTitle => translate('achMoneyMakerTitle');
  String get achMoneyMakerDesc => translate('achMoneyMakerDesc');
  String get tierPlatinumPlus => translate('tierPlatinumPlus');
  String get tierGoldPlus => translate('tierGoldPlus');
  String get tierSilverPlus => translate('tierSilverPlus');
  String get tierBronzePlus => translate('tierBronzePlus');
  String get loyaltyBookingCompleted => translate('loyaltyBookingCompleted');
  String get loyaltyReferFriend => translate('loyaltyReferFriend');
  String get loyaltyWriteReview => translate('loyaltyWriteReview');
  String get loyaltyFirstBooking => translate('loyaltyFirstBooking');
  String get loyaltyRedeem => translate('loyaltyRedeem');
  String get pointsLabel => translate('pointsLabel');
  String get placeLabel => translate('placeLabel');
  String get goldenHourMorning => translate('goldenHourMorning');
  String get goldenHourEvening => translate('goldenHourEvening');
  String get goldenHourNext => translate('goldenHourNext');
  String get morningLabel => translate('morningLabel');
  String get eveningLabel => translate('eveningLabel');
  String get tomorrowMorningLabel => translate('tomorrowMorningLabel');
  String get amMarker => translate('amMarker');
  String get pmMarker => translate('pmMarker');
  String get emptyBookingsTitle => translate('emptyBookingsTitle');
  String get emptyBookingsMessage => translate('emptyBookingsMessage');
  String get browsePhotographers => translate('browsePhotographers');
  String get emptyFavoritesTitle => translate('emptyFavoritesTitle');
  String get emptyFavoritesMessage => translate('emptyFavoritesMessage');
  String get exploreNow => translate('exploreNow');
  String get emptyChatsTitle => translate('emptyChatsTitle');
  String get emptyChatsMessage => translate('emptyChatsMessage');
  String get findPhotographer => translate('findPhotographer');
  String get emptyNotificationsTitle => translate('emptyNotificationsTitle');
  String get emptyNotificationsMessage => translate('emptyNotificationsMessage');
  String get emptySearchFiltersMessage => translate('emptySearchFiltersMessage');
  String get emptyStoriesTitle => translate('emptyStoriesTitle');
  String get emptyStoriesMessage => translate('emptyStoriesMessage');
  String get emptyReviewsTitle => translate('emptyReviewsTitle');
  String get emptyReviewsMessage => translate('emptyReviewsMessage');
  String get writeReviewAction => translate('writeReviewAction');
  String get emptyPortfolioTitle => translate('emptyPortfolioTitle');
  String get emptyPortfolioMessage => translate('emptyPortfolioMessage');
  String get addPhotosAction => translate('addPhotosAction');
  String get emptyTransactionsTitle => translate('emptyTransactionsTitle');
  String get emptyTransactionsMessage => translate('emptyTransactionsMessage');
  String get errorOccurredTitle => translate('errorOccurredTitle');
  String get errorGenericMessage => translate('errorGenericMessage');
  String get noConnectionTitle => translate('noConnectionTitle');
  String get noConnectionMessage => translate('noConnectionMessage');
  String get createLabel => translate('createLabel');
  String get profileTab => translate('profileTab');
  String get mainNavigationLabel => translate('mainNavigationLabel');
  String get newReel => translate('newReel');
  String get newStory => translate('newStory');
  String get sponsoredAdTitle => translate('sponsoredAdTitle');
  String get plansTitle => translate('plansTitle');
  String get newRequest => translate('newRequest');
  String get venuesTitle => translate('venuesTitle');
  String get photoSpotsTitle => translate('photoSpotsTitle');
  String get whatToCreate => translate('whatToCreate');
  String get placesTitle => translate('placesTitle');
  String get photographersTitle => translate('photographersTitle');
  String get followTab => translate('followTab');
  String get errBadRequest => translate('errBadRequest');
  String get errForbidden => translate('errForbidden');
  String get errNotFound => translate('errNotFound');
  String get errConflict => translate('errConflict');
  String get errValidation => translate('errValidation');
  String get errRateLimited => translate('errRateLimited');
  String get errServer => translate('errServer');
  String get errServiceUnavailable => translate('errServiceUnavailable');
  String get reportInappropriate => translate('reportInappropriate');
  String get reportFraudImpersonation => translate('reportFraudImpersonation');
  String get reportAbuse => translate('reportAbuse');
  String get reportStolenImages => translate('reportStolenImages');
  String get reportMisinformation => translate('reportMisinformation');
  String get otherLabel => translate('otherLabel');
  String get sendReportAction => translate('sendReportAction');
  String get reportReasonField => translate('reportReasonField');
  String get extraDetailsOptional => translate('extraDetailsOptional');
  String get reportSentThanks => translate('reportSentThanks');
  String get reportSendFailed => translate('reportSendFailed');
  String get submitReportAction => translate('submitReportAction');
  String get raspIntrusionLogout => translate('raspIntrusionLogout');
  String get raspIntegrityFailed => translate('raspIntegrityFailed');
  String get raspModifiedDevice => translate('raspModifiedDevice');
  String get raspUntrustedEnv => translate('raspUntrustedEnv');
  String get uploadTimeout => translate('uploadTimeout');
  String get connectionTimeoutMsg => translate('connectionTimeoutMsg');
  String get confirmIdentityToContinue => translate('confirmIdentityToContinue');
  String get moodWarmSoft => translate('moodWarmSoft');
  String get moodUrbanSharp => translate('moodUrbanSharp');
  String get moodRomantic => translate('moodRomantic');
  String get moodNaturalOutdoor => translate('moodNaturalOutdoor');
  String get moodDramaticDeep => translate('moodDramaticDeep');
  String get waitlistFullMsg => translate('waitlistFullMsg');
  String get waitlistBaghdadOnly => translate('waitlistBaghdadOnly');
  String get waitlistNotifyExpansion => translate('waitlistNotifyExpansion');
  String get waitlistNotifyCity => translate('waitlistNotifyCity');
  String get nameLabel => translate('nameLabel');
  String get enterName => translate('enterName');
  String get enterValidPhone => translate('enterValidPhone');
  String get cityLabel => translate('cityLabel');
  String get enterCity => translate('enterCity');
  String get accountTypeLabel => translate('accountTypeLabel');
  String get interestRegistered => translate('interestRegistered');
  String get notifyOnExpand => translate('notifyOnExpand');

  // Batch 5 getters
  String get allFilter => translate('allFilter');
  String get openFilter => translate('openFilter');
  String get resolvedFilter => translate('resolvedFilter');
  String get searchReportsHint => translate('searchReportsHint');
  String get searchUsersHint => translate('searchUsersHint');
  String get deleteViaPolicy => translate('deleteViaPolicy');
  String get phoneAfterBooking => translate('phoneAfterBooking');
  String get privacyContactNote => translate('privacyContactNote');
  String get yesterday => translate('yesterday');
  String get conversationFallback => translate('conversationFallback');
  String get noChatsYet => translate('noChatsYet');
  String get chatsLoadFailed => translate('chatsLoadFailed');
  String get searchMessagesHint => translate('searchMessagesHint');
  String get photographersFilter => translate('photographersFilter');
  String get arrangementsFilter => translate('arrangementsFilter');
  String get quickAskPrice => translate('quickAskPrice');
  String get quickAskAvailable => translate('quickAskAvailable');
  String get quickAskEvent => translate('quickAskEvent');
  String get quickAskPackages => translate('quickAskPackages');
  String get coursesListTitle => translate('coursesListTitle');
  String get coursesLoadError => translate('coursesLoadError');
  String get noCoursesAvailable => translate('noCoursesAvailable');
  String get courseFull => translate('courseFull');
  String get courseLoadFailed => translate('courseLoadFailed');
  String get courseNotFound => translate('courseNotFound');
  String get availableSeats => translate('availableSeats');
  String get sessionsLabel => translate('sessionsLabel');
  String get courseCompleted => translate('courseCompleted');
  String get enrolling => translate('enrolling');
  String get enrollNow => translate('enrollNow');
  String get completeCourseTitleDesc => translate('completeCourseTitleDesc');
  String get invalidPrice => translate('invalidPrice');
  String get invalidSeatsCount => translate('invalidSeatsCount');
  String get addAtLeastOneSession => translate('addAtLeastOneSession');
  String get enterOnlineSessionLink => translate('enterOnlineSessionLink');
  String get currentUserCheckFailed => translate('currentUserCheckFailed');
  String get courseSaveFailed => translate('courseSaveFailed');
  String get editCourse => translate('editCourse');
  String get newCourse => translate('newCourse');
  String get unpublish => translate('unpublish');
  String get publish => translate('publish');
  String get addCourseCover => translate('addCourseCover');
  String get courseTitleLabel => translate('courseTitleLabel');
  String get courseTitleHint => translate('courseTitleHint');
  String get descriptionLabel => translate('descriptionLabel');
  String get courseDescriptionHint => translate('courseDescriptionHint');
  String get courseLocationLabel => translate('courseLocationLabel');
  String get courseLocationHint => translate('courseLocationHint');
  String get onlineSessionLink => translate('onlineSessionLink');
  String get priceIqdLabel => translate('priceIqdLabel');
  String get seatsCountLabel => translate('seatsCountLabel');
  String get addSpecialtyHint => translate('addSpecialtyHint');
  String get addSession => translate('addSession');
  String get savingProgress => translate('savingProgress');
  String get myTeachingCourses => translate('myTeachingCourses');
  String get noCoursesYet => translate('noCoursesYet');
  String get createFirstCourse => translate('createFirstCourse');
  String get published => translate('published');
  String get draft => translate('draft');
  String get paymentStartFailed => translate('paymentStartFailed');
  String get paymentConfirmFailed => translate('paymentConfirmFailed');
  String get paymentProcessError => translate('paymentProcessError');
  String get traineeFallback => translate('traineeFallback');
  String get newEnrollmentTitle => translate('newEnrollmentTitle');
  String get paymentSuccessTitle => translate('paymentSuccessTitle');
  String get paymentGatewayDisabled => translate('paymentGatewayDisabled');
  String get payingProgress => translate('payingProgress');
  String get payNow => translate('payNow');
  String get myCoursesTitle => translate('myCoursesTitle');
  String get myCoursesLoadError => translate('myCoursesLoadError');
  String get notEnrolledYet => translate('notEnrolledYet');
  String get browseCoursesPrompt => translate('browseCoursesPrompt');
  String get browseCourses => translate('browseCourses');
  String get enrollmentConfirmed => translate('enrollmentConfirmed');
  String get enrollmentCanceled => translate('enrollmentCanceled');
  String get awaitingPayment => translate('awaitingPayment');
  String get noCreatorsForMood => translate('noCreatorsForMood');
  String get tryAnotherMood => translate('tryAnotherMood');
  String get suggestedCreators => translate('suggestedCreators');
  String get discoverTitle => translate('discoverTitle');
  String get exploreSearchHint => translate('exploreSearchHint');
  String get photographersSection => translate('photographersSection');
  String get photoSpotsSection => translate('photoSpotsSection');
  String get noResultsNow => translate('noResultsNow');
  String get tryRefreshOrSearch => translate('tryRefreshOrSearch');
  String get featuredVenues => translate('featuredVenues');
  String get featuredPhotoSpots => translate('featuredPhotoSpots');
  String get noPhotoSpotsNow => translate('noPhotoSpotsNow');
  String get iraqLabel => translate('iraqLabel');
  String get placeLoadFailed => translate('placeLoadFailed');
  String get placeDescription => translate('placeDescription');
  String get noDescriptionAvailable => translate('noDescriptionAvailable');
  String get venuesLoadEmpty => translate('venuesLoadEmpty');
  String get venueSearchHint => translate('venueSearchHint');
  String get venueLoadFailed => translate('venueLoadFailed');
  String get venueBookingTitle => translate('venueBookingTitle');
  String get venueBookingSubtitle => translate('venueBookingSubtitle');
  String get eventDateLabel => translate('eventDateLabel');
  String get guestCountLabel => translate('guestCountLabel');
  String get guestCountHint => translate('guestCountHint');
  String get extraNotesLabel => translate('extraNotesLabel');
  String get eventDetailsHint => translate('eventDetailsHint');
  String get bookingSendFailed => translate('bookingSendFailed');
  String get venueDetailsLoadFailed => translate('venueDetailsLoadFailed');
  String get aboutVenue => translate('aboutVenue');
  String get upcomingAvailability => translate('upcomingAvailability');
  String get messageAction => translate('messageAction');
  String get yourAvailablePoints => translate('yourAvailablePoints');
  String get pointSingular => translate('pointSingular');
  String get totalLabel => translate('totalLabel');
  String get usedLabel => translate('usedLabel');
  String get discountLabel => translate('discountLabel');
  String get completeBookingAction => translate('completeBookingAction');
  String get pointsInfoTitle => translate('pointsInfoTitle');
  String get pointsInfoBody => translate('pointsInfoBody');
  String get daysAgoPlural => translate('daysAgoPlural');
  String get currentUserUnknown => translate('currentUserUnknown');
  String get chooseItemToPromote => translate('chooseItemToPromote');
  String get sponsoredCampaignDesc => translate('sponsoredCampaignDesc');
  String get promoteAccount => translate('promoteAccount');
  String get promoteReel => translate('promoteReel');
  String get promoteStory => translate('promoteStory');
  String get promoteVenuePlace => translate('promoteVenuePlace');
  String get noCampaignToShow => translate('noCampaignToShow');
  String get impressionsLabel => translate('impressionsLabel');
  String get clicksLabel => translate('clicksLabel');
  String get spendLabel => translate('spendLabel');
  String get budgetLabel => translate('budgetLabel');
  String get totalBudgetLabel => translate('totalBudgetLabel');
  String get dailyBudgetLabel => translate('dailyBudgetLabel');
  String get spentLabel => translate('spentLabel');
  String get targetsLabel => translate('targetsLabel');
  String get statusUnderReview => translate('statusUnderReview');
  String get statusApproved => translate('statusApproved');
  String get statusRejectedF => translate('statusRejectedF');
  String get statusActive => translate('statusActive');
  String get statusPaused => translate('statusPaused');
  String get statusCompletedF => translate('statusCompletedF');
  String get statusDraft => translate('statusDraft');
  String get myAccountOption => translate('myAccountOption');
  String get featuredReel => translate('featuredReel');
  String get featuredStory => translate('featuredStory');
  String get venueOrPlace => translate('venueOrPlace');
  String get chooseWhatToPromote => translate('chooseWhatToPromote');
  String get accountOption => translate('accountOption');
  String get reelOption => translate('reelOption');
  String get storyOption => translate('storyOption');
  String get targetItemLabel => translate('targetItemLabel');
  String get adDurationLabel => translate('adDurationLabel');
  String get dayUnit => translate('dayUnit');
  String get daysUnit => translate('daysUnit');
  String get regionLabel => translate('regionLabel');
  String get allIraq => translate('allIraq');
  String get governorateOption => translate('governorateOption');
  String get loginFirstOrChooseItem => translate('loginFirstOrChooseItem');
  String get campaignCreateFailed => translate('campaignCreateFailed');
  String get plansAndSubscriptions => translate('plansAndSubscriptions');
  String get yearlyDiscount => translate('yearlyDiscount');
  String get monthly => translate('monthly');
  String get noPlansAvailable => translate('noPlansAvailable');
  String get planActivationFailed => translate('planActivationFailed');
  String get comparePlans => translate('comparePlans');
  String get betterSearchVisibility => translate('betterSearchVisibility');
  String get basicAnalytics => translate('basicAnalytics');
  String get adsDiscount => translate('adsDiscount');
  String get fasterSupport => translate('fasterSupport');
  String get perMonth => translate('perMonth');
  String get activePlan => translate('activePlan');
  String get choosePlan => translate('choosePlan');
  String get photographerLoadFailed => translate('photographerLoadFailed');
  String get weddingPhotographer => translate('weddingPhotographer');
  String get projectsLabel => translate('projectsLabel');
  String get followersLabel => translate('followersLabel');
  String get followingLabel => translate('followingLabel');
  String get contactAction => translate('contactAction');
  String get worksTab => translate('worksTab');
  String get reviewsTab => translate('reviewsTab');
  String get reelsTab => translate('reelsTab');
  String get followTabLabel => translate('followTabLabel');
  String get sessionsHighlight => translate('sessionsHighlight');
  String get behindScenes => translate('behindScenes');
  String get studioHighlight => translate('studioHighlight');
  String get noWorksYet => translate('noWorksYet');
  String get noReelsYet => translate('noReelsYet');
  String get ratingSummary => translate('ratingSummary');
  String get verifiedSpecialtyNote => translate('verifiedSpecialtyNote');
  String get usernameReserved => translate('usernameReserved');
  String get usernameFormatError => translate('usernameFormatError');
  String get usernameUnavailable => translate('usernameUnavailable');
  String get usernameVerifyFailed => translate('usernameVerifyFailed');
  String get noSignedInUser => translate('noSignedInUser');
  String get saveError => translate('saveError');
  String get usernameFieldLabel => translate('usernameFieldLabel');
  String get usernameExampleHint => translate('usernameExampleHint');
  String get enterUsername => translate('enterUsername');
  String get usernameFormatNoSpaces => translate('usernameFormatNoSpaces');
  String get minTwoChars => translate('minTwoChars');
  String get checkingProgress => translate('checkingProgress');
  String get usernameAvailable => translate('usernameAvailable');
  String get usernameSuggestions => translate('usernameSuggestions');
  String get loadingShort => translate('loadingShort');
  String get suggestionsAction => translate('suggestionsAction');
  String get emailOptionalLabel => translate('emailOptionalLabel');
  String get emailFormatError => translate('emailFormatError');
  String get fullNameLabel => translate('fullNameLabel');
  String get fullNameHint => translate('fullNameHint');
  String get fullNameRequired => translate('fullNameRequired');
  String get genderLabel => translate('genderLabel');
  String get birthYearLabel => translate('birthYearLabel');
  String get birthYearHint => translate('birthYearHint');
  String get enterBirthYear => translate('enterBirthYear');
  String get birthYearAdultError => translate('birthYearAdultError');
  String get chooseGovernorateHint => translate('chooseGovernorateHint');
  String get confirmOver18Checkbox => translate('confirmOver18Checkbox');
  String get loginToViewPortfolio => translate('loginToViewPortfolio');
  String get portfolioLoadFailed => translate('portfolioLoadFailed');
  String get imageAddFailed => translate('imageAddFailed');
  String get portfolioNeedsSubscription => translate('portfolioNeedsSubscription');
  String get portfolioPhotographersOnly => translate('portfolioPhotographersOnly');
  String get portfolioLimitReached => translate('portfolioLimitReached');
  String get noPortfolioImages => translate('noPortfolioImages');
  String get portfolioShowQuality => translate('portfolioShowQuality');
  String get addFirstImage => translate('addFirstImage');
  String get profileLoadFailed => translate('profileLoadFailed');
  String get completeBasicInfo => translate('completeBasicInfo');
  String get notAdded => translate('notAdded');
  String get accountVerification => translate('accountVerification');
  String get manageTeachingCourses => translate('manageTeachingCourses');
  String get adminPanel => translate('adminPanel');
  String get locationDescriptionHint => translate('locationDescriptionHint');
  String get searchFailedTryAgain => translate('searchFailedTryAgain');
  String get escrowPolicyTitle => translate('escrowPolicyTitle');
  String get escrowPolicyBody => translate('escrowPolicyBody');
  String get editPolicyTitle => translate('editPolicyTitle');
  String get editPolicyBody => translate('editPolicyBody');
  String get cancelPolicyTitle => translate('cancelPolicyTitle');
  String get cancelPolicyBody => translate('cancelPolicyBody');
  String get privacyPolicyTitle => translate('privacyPolicyTitle');
  String get privacyPolicyBody => translate('privacyPolicyBody');
  String get disputesPolicyTitle => translate('disputesPolicyTitle');
  String get disputesPolicyBody => translate('disputesPolicyBody');
  String get before48h => translate('before48h');
  String get within48h => translate('within48h');
  String get noShow => translate('noShow');
  String get reportSpam => translate('reportSpam');
  String get reportFraud => translate('reportFraud');
  String get reportHarassment => translate('reportHarassment');
  String get reportCopyright => translate('reportCopyright');
  String get reportSentSuccess => translate('reportSentSuccess');
  String get reportReviewSoon => translate('reportReviewSoon');
  String get reportingAbout => translate('reportingAbout');
  String get describeIssueHint => translate('describeIssueHint');
  String get addReportDetails => translate('addReportDetails');
  String get detailsMin20Chars => translate('detailsMin20Chars');
  String get reportReviewNote => translate('reportReviewNote');
  String get submitReportCheck => translate('submitReportCheck');
  String get storeLuxuryFrame => translate('storeLuxuryFrame');
  String get storeLuxuryFrameSub => translate('storeLuxuryFrameSub');
  String get storePrintedAlbum => translate('storePrintedAlbum');
  String get storePrintedAlbumSub => translate('storePrintedAlbumSub');
  String get bestSeller => translate('bestSeller');
  String get storeProductSession => translate('storeProductSession');
  String get storeProductSessionSub => translate('storeProductSessionSub');
  String get storeCuratedSubtitle => translate('storeCuratedSubtitle');
  String get storeOrderInstruction => translate('storeOrderInstruction');
  String get verifyAccountPrompt => translate('verifyAccountPrompt');
  String get requestStatus => translate('requestStatus');
  String get verifiedLabel => translate('verifiedLabel');
  String get notVerifiedLabel => translate('notVerifiedLabel');
  String get portfolioReview => translate('portfolioReview');
  String get identityReview => translate('identityReview');
  String get completedLabel => translate('completedLabel');
  String get awaitingReview => translate('awaitingReview');
  String get underReview => translate('underReview');
  String get rejectedLabel => translate('rejectedLabel');
  String get notSubmitted => translate('notSubmitted');
  String get sortPriceLowFirst => translate('sortPriceLowFirst');
  String get sortTopTrust => translate('sortTopTrust');
  String get sortFastestDelivery => translate('sortFastestDelivery');
  String get sortNearest => translate('sortNearest');
  String get sortPriceLowToHigh => translate('sortPriceLowToHigh');
  String get sortHighestTrust => translate('sortHighestTrust');
  String get sortFastestDeliveryLong => translate('sortFastestDeliveryLong');
  String get sortNearestToYou => translate('sortNearestToYou');

  String seatsCount(int count) =>
      translate('seatsCountTemplate').replaceAll('{count}', '$count');
  String seatsOf(int remaining, int capacity) => translate('seatsOfTemplate')
      .replaceAll('{remaining}', '$remaining')
      .replaceAll('{capacity}', '$capacity');
  String deleteCourseConfirm(String title) =>
      translate('deleteCourseConfirmTemplate').replaceAll('{title}', title);
  String seatsRatio(int remaining, int capacity) =>
      translate('seatsRatioTemplate')
          .replaceAll('{remaining}', '$remaining')
          .replaceAll('{capacity}', '$capacity');
  String newEnrollmentBody(String student, String course) =>
      translate('newEnrollmentBodyTemplate')
          .replaceAll('{student}', student)
          .replaceAll('{course}', course);
  String enrolledInCourse(String course) =>
      translate('enrolledInCourseTemplate').replaceAll('{course}', course);
  String moodPrefix(String mood) =>
      translate('moodPrefixTemplate').replaceAll('{mood}', mood);
  String creatorsCount(int count) =>
      translate('creatorsCountTemplate').replaceAll('{count}', '$count');
  String startsFrom(String price) =>
      translate('startsFromTemplate').replaceAll('{price}', price);
  String capacityLabel(int min, int max) => translate('capacityLabelTemplate')
      .replaceAll('{min}', '$min')
      .replaceAll('{max}', '$max');
  String pointsToNextTier(int points) =>
      translate('pointsToNextTierTemplate').replaceAll('{points}', '$points');
  String plusPoints(int points) =>
      translate('plusPointsTemplate').replaceAll('{points}', '$points');
  String pointsInfo(int rate) =>
      translate('pointsInfoBody').replaceAll('{rate}', '$rate');
  String daysAgoLong(int days) =>
      translate('daysAgoPlural').replaceAll('{days}', '$days');
  String reelFallback(String id) =>
      translate('reelFallbackTemplate').replaceAll('{id}', id);
  String storyFallback(String id) =>
      translate('storyFallbackTemplate').replaceAll('{id}', id);
  String planActivated(String plan) =>
      translate('planActivatedTemplate').replaceAll('{plan}', plan);
  String portfolioImages(int count) =>
      translate('portfolioImagesTemplate').replaceAll('{count}', '$count');
  String reelsPerMonth(int count) =>
      translate('reelsPerMonthTemplate').replaceAll('{count}', '$count');
  String ratingSummaryText(int reviews, int projects) =>
      translate('ratingSummaryTemplate')
          .replaceAll('{reviews}', '$reviews')
          .replaceAll('{projects}', '$projects');
  String enterField(String field) =>
      translate('enterFieldTemplate').replaceAll('{field}', field);
  String governoratePrefix(String gov) =>
      translate('governoratePrefixTemplate').replaceAll('{gov}', gov);
  String storeOrderMessage(String title, String subtitle, String price) =>
      translate('storeOrderMessageTemplate')
          .replaceAll('{title}', title)
          .replaceAll('{subtitle}', subtitle)
          .replaceAll('{price}', price);
  String rejectionReason(String reason) =>
      translate('rejectionReasonTemplate').replaceAll('{reason}', reason);
  String hoursAgo(int hours) =>
      translate('hoursAgoTemplate').replaceAll('{hours}', '$hours');
  String daysAgo(int days) =>
      translate('daysAgoTemplate').replaceAll('{days}', '$days');
  String weeksAgo(int weeks) =>
      translate('weeksAgoTemplate').replaceAll('{weeks}', '$weeks');
  String remainingHours(int hours) =>
      translate('remainingHoursTemplate').replaceAll('{hours}', '$hours');
  String remainingMinutes(int minutes) =>
      translate('remainingMinutesTemplate').replaceAll('{minutes}', '$minutes');
  String endsAt(String time) =>
      translate('endsAtTemplate').replaceAll('{time}', time);
  String inMinutes(int minutes) =>
      translate('inMinutesTemplate').replaceAll('{minutes}', '$minutes');
  String inHours(int hours) =>
      translate('inHoursTemplate').replaceAll('{hours}', '$hours');
  String inHoursMinutes(int hours, int minutes) =>
      translate('inHoursMinutesTemplate')
          .replaceAll('{hours}', '$hours')
          .replaceAll('{minutes}', '$minutes');
  String happeningNow(String time) =>
      translate('happeningNowTemplate').replaceAll('{time}', time);
  String photographersCount(int count) =>
      translate('photographersCountTemplate').replaceAll('{count}', '$count');
  String emptySearchQuery(String query) =>
      translate('emptySearchQueryTemplate').replaceAll('{query}', query);
  String provinceName(String id) => translate('province_$id');
  String resendInSeconds(int seconds) =>
      translate('resendInSecondsTemplate').replaceAll('{seconds}', '$seconds');
  String stepOf(int current, int total) => translate('stepOfTemplate')
      .replaceAll('{current}', '$current')
      .replaceAll('{total}', '$total');
  String pointsEarned(int points) =>
      translate('pointsEarnedTemplate').replaceAll('{points}', '$points');
  String rewardPointsLabel(int points) =>
      translate('rewardPointsTemplate').replaceAll('{points}', '$points');
  // Batch 3 getters
  String get callAction => translate('callAction');
  String get enrollmentCreateFailed => translate('enrollmentCreateFailed');
  String get imageUploadFailed => translate('imageUploadFailed');
  String get endTimeAfterStart => translate('endTimeAfterStart');
  String get inPersonLabel => translate('inPersonLabel');
  String get onlineLabel => translate('onlineLabel');
  String get deleteCourseTitle => translate('deleteCourseTitle');
  String get deleteCourseFailed => translate('deleteCourseFailed');
  String get viewPhotographer => translate('viewPhotographer');
  String get requestSameStyle => translate('requestSameStyle');
  String get locationOnMap => translate('locationOnMap');
  String get loyaltyPointsTitle => translate('loyaltyPointsTitle');
  String get historyLabel => translate('historyLabel');
  String get nextLevelProgress => translate('nextLevelProgress');
  String get tierBronze => translate('tierBronze');
  String get tierSilver => translate('tierSilver');
  String get tierGold => translate('tierGold');
  String get tierPlatinum => translate('tierPlatinum');
  String get howToEarnPoints => translate('howToEarnPoints');
  String get campaignAnalyticsTitle => translate('campaignAnalyticsTitle');
  String get campaignCreatedForReview => translate('campaignCreatedForReview');
  String get chatOpenAfterBooking => translate('chatOpenAfterBooking');
  String get usernameCheckError => translate('usernameCheckError');
  String get confirmOver18 => translate('confirmOver18');
  String get maxPortfolioImages => translate('maxPortfolioImages');
  String get imageAddedSuccess => translate('imageAddedSuccess');
  String get imageDeletedSuccess => translate('imageDeletedSuccess');
  String get portfolioSaveFailed => translate('portfolioSaveFailed');
  String get portfolioTitle => translate('portfolioTitle');
  String get deleteImageTitle => translate('deleteImageTitle');
  String get deleteImageConfirm => translate('deleteImageConfirm');
  String get profilePhotoUpdated => translate('profilePhotoUpdated');
  String get myAccountTitle => translate('myAccountTitle');
  String get descriptionOptional => translate('descriptionOptional');
  String get saveLocation => translate('saveLocation');
  String get bookingPoliciesTitle => translate('bookingPoliciesTitle');
  String get chooseReportReason => translate('chooseReportReason');
  String get reportSendError => translate('reportSendError');
  String get sendReportTitle => translate('sendReportTitle');
  String get reportReasonLabel => translate('reportReasonLabel');
  String get extraDetailsLabel => translate('extraDetailsLabel');
  String get deleteAccountPolicy => translate('deleteAccountPolicy');
  String get contentPolicy => translate('contentPolicy');
  String get chooseEventDateFirst => translate('chooseEventDateFirst');
  String get bookingRequestSent => translate('bookingRequestSent');
  String get verificationRequestSent => translate('verificationRequestSent');
  String get verificationRequestFailed => translate('verificationRequestFailed');
  String get photographerVerificationTitle => translate('photographerVerificationTitle');
  String get sendVerificationRequest => translate('sendVerificationRequest');
  String get loadMoreFailed => translate('loadMoreFailed');
  String get noItems => translate('noItems');
  String get loadFailed => translate('loadFailed');
  String get waitlistSubmitFailed => translate('waitlistSubmitFailed');
  String get userLabel => translate('userLabel');
  String get venuePlaceLabel => translate('venuePlaceLabel');
  String get registerInterest => translate('registerInterest');
  String get recheckAction => translate('recheckAction');
  String editFieldTitle(String field) =>
      translate('editFieldTemplate').replaceAll('{field}', field);
  String fieldCannotBeEmpty(String field) =>
      translate('fieldCannotBeEmptyTemplate').replaceAll('{field}', field);
  String fieldUpdated(String field) =>
      translate('fieldUpdatedTemplate').replaceAll('{field}', field);
  String fieldUpdateFailed(String field) =>
      translate('fieldUpdateFailedTemplate').replaceAll('{field}', field);

  String confirmPaymentBody(String amount, String payee) =>
      translate('confirmPaymentBodyTemplate')
          .replaceAll('{amount}', amount)
          .replaceAll('{payee}', payee);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    AppLocalizations.current = localizations;
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
