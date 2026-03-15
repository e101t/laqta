import 'package:flutter/material.dart';
import 'package:luqta/core/localization/ar_translations.dart';
import 'package:luqta/core/localization/en_translations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
      'welcomeToLuqta': EnTranslations.welcomeToLuqta,
      'authSubtitle': EnTranslations.authSubtitle,
      'signInTitle': EnTranslations.signInTitle,
      'signUpTitle': EnTranslations.signUpTitle,
      'signInWithGoogle': EnTranslations.signInWithGoogle,
      'signInWithApple': EnTranslations.signInWithApple,
      'signInWithPhone': EnTranslations.signInWithPhone,
      'signUpWithGoogle': EnTranslations.signUpWithGoogle,
      'signUpWithApple': EnTranslations.signUpWithApple,
      'signUpWithPhone': EnTranslations.signUpWithPhone,
      'phoneNumber': EnTranslations.phoneNumber,
      'verifyOTP': EnTranslations.verifyOTP,
      'enterOTP': EnTranslations.enterOTP,
      'resendCode': EnTranslations.resendCode,
      'verify': EnTranslations.verify,
      'or': EnTranslations.or,
      'googleSignInUnsupported': EnTranslations.googleSignInUnsupported,
      'googleSignInFailed': EnTranslations.googleSignInFailed,
      'appleSignInUnavailable': EnTranslations.appleSignInUnavailable,
      'appleSignInFailed': EnTranslations.appleSignInFailed,
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
      'welcomeToLuqta': ArTranslations.welcomeToLuqta,
      'authSubtitle': ArTranslations.authSubtitle,
      'signInTitle': ArTranslations.signInTitle,
      'signUpTitle': ArTranslations.signUpTitle,
      'signInWithGoogle': ArTranslations.signInWithGoogle,
      'signInWithApple': ArTranslations.signInWithApple,
      'signInWithPhone': ArTranslations.signInWithPhone,
      'signUpWithGoogle': ArTranslations.signUpWithGoogle,
      'signUpWithApple': ArTranslations.signUpWithApple,
      'signUpWithPhone': ArTranslations.signUpWithPhone,
      'phoneNumber': ArTranslations.phoneNumber,
      'verifyOTP': ArTranslations.verifyOTP,
      'enterOTP': ArTranslations.enterOTP,
      'resendCode': ArTranslations.resendCode,
      'verify': ArTranslations.verify,
      'or': ArTranslations.or,
      'googleSignInUnsupported': ArTranslations.googleSignInUnsupported,
      'googleSignInFailed': ArTranslations.googleSignInFailed,
      'appleSignInUnavailable': ArTranslations.appleSignInUnavailable,
      'appleSignInFailed': ArTranslations.appleSignInFailed,
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
  String get welcomeToLuqta => translate('welcomeToLuqta');
  String get authSubtitle => translate('authSubtitle');
  String get signInTitle => translate('signInTitle');
  String get signUpTitle => translate('signUpTitle');
  String get signInWithGoogle => translate('signInWithGoogle');
  String get signInWithApple => translate('signInWithApple');
  String get signInWithPhone => translate('signInWithPhone');
  String get signUpWithGoogle => translate('signUpWithGoogle');
  String get signUpWithApple => translate('signUpWithApple');
  String get signUpWithPhone => translate('signUpWithPhone');
  String get phoneNumber => translate('phoneNumber');
  String get verifyOTP => translate('verifyOTP');
  String get enterOTP => translate('enterOTP');
  String get resendCode => translate('resendCode');
  String get verify => translate('verify');
  String get orLabel => translate('or');
  String get googleSignInUnsupported => translate('googleSignInUnsupported');
  String get googleSignInFailed => translate('googleSignInFailed');
  String get appleSignInUnavailable => translate('appleSignInUnavailable');
  String get appleSignInFailed => translate('appleSignInFailed');
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
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
