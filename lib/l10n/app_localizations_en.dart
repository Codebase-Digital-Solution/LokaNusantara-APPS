// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LokaNusantara';

  @override
  String get language => 'Language';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get followSystem => 'Use device language';

  @override
  String get contentLanguageNote =>
      'Place names, descriptions and events from the server stay in Indonesian.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get errorNetwork => 'Network connection failed';

  @override
  String get errorNotFound => 'Data not found';

  @override
  String get errorUnauthorized => 'Access denied';

  @override
  String get errorValidation => 'Validation failed';

  @override
  String get errorServer => 'Something went wrong on the server';

  @override
  String get errorUnknown => 'Something went wrong';

  @override
  String get catTradisi => 'Tradition';

  @override
  String get catPura => 'Temple';

  @override
  String get catMasjid => 'Mosque';

  @override
  String get catGereja => 'Church';

  @override
  String get catVihara => 'Buddhist Temple';

  @override
  String get catKlenteng => 'Chinese Temple';

  @override
  String get catKuliner => 'Culinary';

  @override
  String get catOther => 'Other';

  @override
  String get etqGeneral1 => 'Dress modestly and keep quiet.';

  @override
  String get etqGeneral2 =>
      'Ask before photographing locals or customary activities.';

  @override
  String get etqGeneral3 => 'Follow the rules and directions of local staff.';

  @override
  String get etqTradisi1 =>
      'Ask before photographing locals, homes or ceremonies.';

  @override
  String get etqTradisi2 =>
      'Follow the customary village rules and your local guide.';

  @override
  String get etqTradisi3 =>
      'Do not touch or step over sacred objects and offerings.';

  @override
  String get etqTradisi4 =>
      'Dress modestly; some areas require a kamen (sarong) and sash.';

  @override
  String get etqTradisi5 =>
      'Tickets and donations help preserve local customs; hire a local guide when you can.';

  @override
  String get etqPura1 =>
      'Wear a kamen (sarong) and a sash around your waist; they can usually be borrowed at the entrance.';

  @override
  String get etqPura2 =>
      'Women who are menstruating may not enter the sacred areas.';

  @override
  String get etqPura3 =>
      'Do not climb, sit on or lean against sacred structures.';

  @override
  String get etqPura4 => 'Do not walk in front of people who are praying.';

  @override
  String get etqPura5 =>
      'Avoid stepping on canang (offerings) on the street and in temple courtyards.';

  @override
  String get etqMasjid1 =>
      'Dress modestly and cover up; women wear a headscarf.';

  @override
  String get etqMasjid2 =>
      'Take off your shoes before entering the prayer area.';

  @override
  String get etqMasjid3 =>
      'Avoid visiting during congregational prayers unless you are there to pray.';

  @override
  String get etqMasjid4 =>
      'Keep quiet and do not pass in front of anyone who is praying.';

  @override
  String get etqGereja1 => 'Dress modestly, covering shoulders and knees.';

  @override
  String get etqGereja2 => 'Keep quiet, especially during Mass or a service.';

  @override
  String get etqGereja3 =>
      'Ask before photographing the interior during a service.';

  @override
  String get etqVihara1 => 'Dress modestly, covering shoulders and knees.';

  @override
  String get etqVihara2 =>
      'Take off your shoes before entering the shrine hall (Dhammasala).';

  @override
  String get etqVihara3 =>
      'Do not touch Buddha statues or pose for photos with your back to them.';

  @override
  String get etqVihara4 => 'Keep quiet in meditation areas.';

  @override
  String get etqKlenteng1 => 'Dress modestly and keep quiet.';

  @override
  String get etqKlenteng2 => 'Do not touch the altar, statues or prayer items.';

  @override
  String get etqKlenteng3 => 'Ask before photographing people who are praying.';

  @override
  String get etqKlenteng4 =>
      'Chinese New Year and Cap Go Meh are very busy, so come early.';

  @override
  String get etqKuliner1 =>
      'Many traditional warung open early and close once the food runs out.';

  @override
  String get etqKuliner2 =>
      'Some Balinese dishes contain pork; ask if you need halal food.';

  @override
  String get etqKuliner3 =>
      'Sambal matah and betutu are quite spicy, so ask for the heat level you like.';

  @override
  String get etqKuliner4 =>
      'Bring cash; not every warung accepts cashless payment.';

  @override
  String get dateToday => 'Today';

  @override
  String get dateOngoing => 'Happening now';

  @override
  String get datePast => 'Over';

  @override
  String get dateTomorrow => 'Tomorrow';

  @override
  String dateInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count days',
      one: 'In 1 day',
    );
    return '$_temp0';
  }

  @override
  String dateInWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count weeks',
      one: 'In 1 week',
    );
    return '$_temp0';
  }

  @override
  String dateInMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count months',
      one: 'In 1 month',
    );
    return '$_temp0';
  }

  @override
  String get homeDestinations => 'Destinations';

  @override
  String homeSeeAllCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'See all $count destinations',
      one: 'See 1 destination',
    );
    return '$_temp0';
  }

  @override
  String get homeAllDestinations => 'All Destinations';

  @override
  String get homeSearchHint => 'Search destinations or areas...';

  @override
  String homeDestinationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count destinations',
      one: '1 destination',
    );
    return '$_temp0';
  }

  @override
  String get homeNoMatch => 'No matching destinations.';

  @override
  String get homeTagline =>
      'Discover Bali\'s traditions, places of worship and local food';

  @override
  String get homeCategoryAll => 'All';

  @override
  String get homeNotFound => 'No destinations found';

  @override
  String get mapRouteUnavailableTitle => 'No Route Available';

  @override
  String get mapRouteUnavailableBody =>
      'No route was found for this mode of transport.';

  @override
  String get mapRouteFailedTitle => 'Failed';

  @override
  String get mapRouteFailedBody =>
      'Couldn\'t get the route. Check your internet connection.';

  @override
  String get mapClose => 'Close map';

  @override
  String get mapMyLocation => 'My location';

  @override
  String get mapReload => 'Reload';

  @override
  String get mapZoomIn => 'Zoom in';

  @override
  String get mapZoomOut => 'Zoom out';

  @override
  String get mapPreparing => 'Preparing the map';

  @override
  String get mapLoadingNearby => 'Loading destinations near you';

  @override
  String mapTrailSummary(int count, int km) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stops',
      one: '1 stop',
    );
    return '$_temp0, about $km km';
  }

  @override
  String get mapCloseTrail => 'Close trail';

  @override
  String get shellHome => 'Home';

  @override
  String get shellSaved => 'Saved';

  @override
  String get shellAgenda => 'Events';

  @override
  String get shellProfile => 'Profile';

  @override
  String get shellOpenMap => 'Open map';

  @override
  String get shellMap => 'Map';

  @override
  String get splashTagline => 'Explore the traditions of Nusantara';

  @override
  String get notifTitle => 'Notifications';

  @override
  String notifWindow(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Cultural events in the next $days days',
      one: 'Cultural events in the next day',
    );
    return '$_temp0';
  }

  @override
  String get notifEstimatedDate => 'Estimated date, may change';

  @override
  String get notifEmptyTitle => 'No notifications yet';

  @override
  String notifEmptyBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'Cultural events happening in the next $days days will show up here.',
      one: 'Cultural events happening in the next day will show up here.',
    );
    return '$_temp0';
  }

  @override
  String get trailTitle => 'Story Trails';

  @override
  String trailStopCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stops',
      one: '1 stop',
    );
    return '$_temp0';
  }

  @override
  String trailAboutKm(int km) {
    return 'about $km km';
  }

  @override
  String get trailStory => 'The Trail\'s Story';

  @override
  String get trailStops => 'Stops';

  @override
  String get trailShowOnMap => 'Show Trail on Map';

  @override
  String get searchPlaceholder => 'Search places...';

  @override
  String get searchNotFound => 'No places found';

  @override
  String get detailMakePlan => 'Create Visit Plan';

  @override
  String get detailAskLoka => 'Ask Tanya Loka about this place';

  @override
  String get detailAbout => 'About';

  @override
  String get detailHistory => 'History';

  @override
  String get detailHistoryEmpty =>
      'The history of this place is not available yet.';

  @override
  String get detailEtiquette => 'Visiting Etiquette';

  @override
  String get detailAddress => 'Address';

  @override
  String get detailReviews => 'Reviews';

  @override
  String get detailReviewsEmpty =>
      'No reviews yet. Be the first to share your story.';

  @override
  String detailReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String get detailNotRated => 'Not rated yet';

  @override
  String get detailDistance => 'Distance';

  @override
  String get detailCategory => 'Category';

  @override
  String get detailVisitor => 'Visitor';

  @override
  String get detailRoute => 'Get Directions';

  @override
  String get detailModeCar => 'Car';

  @override
  String get detailModeWalk => 'Walk';

  @override
  String get detailModeBike => 'Bike';

  @override
  String get detailRating => 'Rating';

  @override
  String get detailNoRating => 'No rating yet';

  @override
  String get detailDescription => 'Description';

  @override
  String get detailLatestReviews => 'Latest Reviews';

  @override
  String get detailFullHistory => 'Full History & Details';

  @override
  String get detailReadMore => 'Read more';

  @override
  String get planTitle => 'Visit Plan';

  @override
  String get planDeleteTitle => 'Delete plan';

  @override
  String get planDeleteMessage =>
      'This visit plan will be removed from your account.';

  @override
  String get planDelete => 'Delete';

  @override
  String planDeleteFailed(String error) {
    return 'Could not delete: $error';
  }

  @override
  String planPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String planDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String planMeta(String people, String days, String budget) {
    return '$people  •  $days  •  budget $budget';
  }

  @override
  String get planSummary => 'Summary';

  @override
  String get planCosts => 'Cost breakdown';

  @override
  String get planTotalEstimate => 'Estimated total';

  @override
  String get planSchedule => 'Schedule';

  @override
  String planDay(int day) {
    return 'Day $day';
  }

  @override
  String get planTips => 'Tips';

  @override
  String get planDisclaimer =>
      'The plan and costs are AI estimates. Double-check prices, opening hours and ceremony schedules before you go.';

  @override
  String get planSavedMessage =>
      'Plan saved. Find it in Saved, under the Plans tab.';

  @override
  String planSaveFailed(String error) {
    return 'Could not save: $error';
  }

  @override
  String get planSavedLabel => 'Plan saved';

  @override
  String get planSaveButton => 'Save Plan';

  @override
  String get planWithinBudget => 'Within budget';

  @override
  String get planOverBudget => 'Over budget';

  @override
  String get planEstimatedTotal => 'Estimated total';

  @override
  String get planPerPerson => 'Per person';

  @override
  String get planBudgetLeft => 'Budget left';

  @override
  String get planShortfall => 'Shortfall';

  @override
  String get planBuilding => 'Building your plan';

  @override
  String planBuildingBody(String people, String days, String budget) {
    return 'AI is estimating costs for $people, $days, with a budget of $budget. This usually takes a few seconds.';
  }

  @override
  String get planBudgetLabel => 'Total group budget';

  @override
  String get planPeople => 'Number of people';

  @override
  String get planDuration => 'Length of visit';

  @override
  String planPerPersonApprox(String amount) {
    return 'About $amount per person';
  }

  @override
  String get planNotesLabel => 'Notes (optional)';

  @override
  String get planNotesHint =>
      'E.g. traveling with kids, by scooter, halal food only';

  @override
  String get planCreate => 'Create Plan';

  @override
  String get planSheetDisclaimer =>
      'The plan and costs are AI estimates. Actual prices may differ.';

  @override
  String get planDecrease => 'Decrease';

  @override
  String get planIncrease => 'Increase';

  @override
  String planErrBudget(String amount) {
    return 'Minimum budget is $amount';
  }

  @override
  String planErrPeople(int max) {
    return 'Number of people must be 1 to $max';
  }

  @override
  String planErrDays(int max) {
    return 'Length of visit must be 1 to $max days';
  }

  @override
  String planErrNotes(int max) {
    return 'Notes can be at most $max characters';
  }

  @override
  String get audioTitle => 'Audio Guide';

  @override
  String audioPart(int index, int total) {
    return 'Part $index of $total';
  }

  @override
  String get audioListen => 'Hear this place\'s story (in Indonesian)';

  @override
  String get audioStop => 'Stop';

  @override
  String get audioSpeed => 'Speed';

  @override
  String get audioSpeedSlow => 'Slow';

  @override
  String get audioSpeedNormal => 'Normal';

  @override
  String get audioSpeedFast => 'Fast';

  @override
  String get audioNoVoice =>
      'No Indonesian voice is installed on this device, so the narration uses the default voice. Install one in your Text-to-Speech settings.';

  @override
  String get reviewWrite => 'Write a Review';

  @override
  String get reviewPickRating => 'Choose a rating';

  @override
  String get reviewVeryBad => 'Very Bad';

  @override
  String get reviewBad => 'Bad';

  @override
  String get reviewOkay => 'Okay';

  @override
  String get reviewGood => 'Good';

  @override
  String get reviewVeryGood => 'Very Good';

  @override
  String get reviewRating => 'Rating';

  @override
  String get reviewComment => 'Comment (optional)';

  @override
  String get reviewHint => 'Share your experience here...';

  @override
  String bookmarkSaved(String name) {
    return '$name saved';
  }

  @override
  String bookmarkRemoved(String name) {
    return '$name removed from saved';
  }

  @override
  String bookmarkFailed(String error) {
    return 'Could not save: $error';
  }

  @override
  String get dialogOk => 'OK';

  @override
  String get savedTitle => 'Saved';

  @override
  String savedSubtitle(int places, int plans) {
    String _temp0 = intl.Intl.pluralLogic(
      places,
      locale: localeName,
      other: '$places destinations',
      one: '1 destination',
    );
    String _temp1 = intl.Intl.pluralLogic(
      plans,
      locale: localeName,
      other: '$plans plans',
      one: '1 plan',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get savedSubtitleSignedOut => 'Your saved items live in your account';

  @override
  String get savedTabPlaces => 'Places';

  @override
  String get savedTabPlans => 'Plans';

  @override
  String get savedPlacesSignInTitle => 'Sign in to see your saved places';

  @override
  String get savedPlacesFailed => 'Couldn\'t load saved places';

  @override
  String get savedPlacesEmpty => 'No saved destinations yet';

  @override
  String get savedPlacesSignInBody =>
      'Destinations you save are stored in your account, so they stay when you switch devices.';

  @override
  String savedPullToRetry(String error) {
    return '$error Pull down to try again.';
  }

  @override
  String get savedPlacesEmptyBody =>
      'Tap the save icon on any destination you want to visit later.';

  @override
  String get savedRemove => 'Remove from saved';

  @override
  String get savedPlansSignInTitle => 'Sign in to see your plans';

  @override
  String get savedPlansFailed => 'Couldn\'t load plans';

  @override
  String get savedPlansEmpty => 'No saved plans yet';

  @override
  String get savedPlansSignInBody =>
      'Visit plans you save are stored in your account.';

  @override
  String get savedPlansEmptyBody =>
      'Open a place, create a Visit Plan, then tap Save Plan.';

  @override
  String savedPlanMeta(int people, int days, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      people,
      locale: localeName,
      other: '$people people',
      one: '1 person',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0  •  $_temp1  •  $total';
  }

  @override
  String get savedWithinBudget => 'Within budget';

  @override
  String get savedOverBudget => 'Over budget';

  @override
  String get savedExploreHome => 'Explore Home';

  @override
  String get savedSignInPlaceRequired => 'Sign in first to save destinations';

  @override
  String get savedSignInPlanRequired => 'Sign in first to save plans';

  @override
  String get recentTitle => 'History';

  @override
  String get recentSubtitle => 'Destinations you viewed recently';

  @override
  String get recentEmptyTitle => 'No history yet';

  @override
  String get recentEmptyBody => 'Destinations you open will show up here.';

  @override
  String get recentClear => 'Clear history';

  @override
  String get recentClearMessage => 'All destination history will be cleared.';

  @override
  String get recentClearConfirm => 'Clear';

  @override
  String get profileGuestName => 'Guest Explorer';

  @override
  String get profileGuestEmail => 'Sign in to write reviews';

  @override
  String get profileRecent => 'Recently Viewed';

  @override
  String get profileOpenMap => 'Open Map';

  @override
  String get profileShowIntro => 'View App Introduction';

  @override
  String get profileAbout => 'About LokaNusantara';

  @override
  String get profileAboutBody =>
      'A cultural map of the Indonesian archipelago: traditions, houses of worship and local food, starting with Bali.';

  @override
  String get profileIntroOnLaunch => 'Show introduction on launch';

  @override
  String get profileIntroOnLaunchDone =>
      'The introduction will show next time you open the app';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileSignOutMessage => 'Are you sure you want to sign out?';

  @override
  String get profileSignOutConfirm => 'Yes, sign out';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get profileAuthTitle => 'Save and share your journey';

  @override
  String get profileAuthBody =>
      'Sign in with Google to save destinations and write reviews.';

  @override
  String get profileReminders => 'Cultural event reminders';

  @override
  String get profileRemindersBlocked =>
      'Notifications are blocked. Allow them in your phone settings.';

  @override
  String get profileRemindersHint =>
      'The day before and on the day of the event';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authFailedTitle => 'Sign-in Failed';

  @override
  String get authErrorConfig => 'Google sign-in is not set up yet';

  @override
  String get authErrorFailed => 'Google sign-in failed';

  @override
  String get authLater => 'Maybe later';

  @override
  String get authTagline =>
      'Explore traditions, houses of worship and stories\nin every corner of Indonesia';

  @override
  String get authTitle => 'Sign in to start exploring';

  @override
  String get authSubtitle =>
      'One tap with your Google account, no new password needed.';

  @override
  String get authBenefitSaveTitle => 'Save favorite destinations';

  @override
  String get authBenefitSaveBody => 'Collect the places you want to visit.';

  @override
  String get authBenefitReviewTitle => 'Write reviews';

  @override
  String get authBenefitReviewBody =>
      'Share your experience with other explorers.';

  @override
  String get authBenefitSyncTitle => 'Stored in your account';

  @override
  String get authBenefitSyncBody =>
      'Your saved items stay when you switch devices.';

  @override
  String get authPrivacy =>
      'We only use the name, email and profile photo from your Google account.';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get onbWelcomeTitle => 'Welcome to LokaNusantara';

  @override
  String get onbWelcomeBody =>
      'Indonesia\'s cultural map in your hand. Discover traditions, houses of worship and local food in one app.';

  @override
  String get onbTraditionTitle => 'Traditions & Houses of Worship';

  @override
  String get onbTraditionBody =>
      'Visit customary villages, Hindu temples, mosques, churches, Buddhist and Chinese temples, with their history and visiting etiquette.';

  @override
  String get onbCulinaryTitle => 'Flavors of Indonesia';

  @override
  String get onbCulinaryBody =>
      'Taste legendary dishes from family-run warung, from babi guling to ayam betutu.';

  @override
  String get onbRouteTitle => 'Save & Find Routes';

  @override
  String get onbRouteBody =>
      'Save favorite destinations, revisit your history and get directions straight to the spot.';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbStart => 'Start Exploring';

  @override
  String get tanyaSuggest1 => 'What is the Galungan holiday?';

  @override
  String get tanyaSuggest2 => 'What is the etiquette for entering a temple?';

  @override
  String get tanyaSuggest3 => 'Where is the oldest Muslim village in Bali?';

  @override
  String get tanyaSuggest4 => 'Which local dishes are a must-try in Gianyar?';

  @override
  String get tanyaSuggest5 =>
      'Which customary villages keep the Bali Aga traditions?';

  @override
  String get tanyaSuggest6 => 'What ceremonies are coming up soon?';

  @override
  String tanyaAboutPlace(String name) {
    return 'Tell me about $name: a short history, what is worth seeing, and the etiquette when visiting.';
  }

  @override
  String get tanyaNewChat => 'New chat';

  @override
  String get tanyaNewChatMessage => 'The current chat will be cleared.';

  @override
  String get tanyaNewChatConfirm => 'Start new';

  @override
  String get tanyaSubtitle => 'AI cultural guide';

  @override
  String get tanyaGreeting => 'Om Swastyastu!';

  @override
  String get tanyaIntro =>
      'I\'m Loka, your cultural guide. Ask me about traditions, houses of worship, food or upcoming ceremonies in Bali. My answers come from LokaNusantara data.';

  @override
  String get tanyaTryAsking => 'Try asking';

  @override
  String get tanyaTyping => 'Loka is looking for an answer';

  @override
  String get tanyaHint => 'Ask about Balinese culture...';

  @override
  String get tanyaDisclaimer =>
      'AI answers can be wrong. Double-check important information with local sources.';

  @override
  String get agendaTitle => 'Traditions & Culture';

  @override
  String get agendaSubtitle => 'Holy days, ceremonies and festivals in Bali';

  @override
  String get agendaAll => 'All';

  @override
  String get agendaEmptyCategory => 'No events in this category yet.';

  @override
  String get agendaSoon => 'Soon';

  @override
  String get agendaEstimate => 'Estimated';

  @override
  String get agendaEstimateNote =>
      'This date is an estimate. Holy days that follow the lunar calendar or a committee\'s decision can shift, so check official announcements before you visit.';

  @override
  String get agendaViewOnMap => 'View on Map';

  @override
  String get agendaLocationDetail => 'Place Details';

  @override
  String reminderTomorrow(String name) {
    return 'Tomorrow: $name';
  }

  @override
  String reminderToday(String name) {
    return 'Today: $name';
  }

  @override
  String get reminderEstimate => 'Estimated date, check local announcements.';

  @override
  String get reminderDefaultPlace => 'Cultural event in Bali.';

  @override
  String get reminderChannelName => 'Cultural event reminders';

  @override
  String get reminderChannelDescription =>
      'Reminders the day before and on the day of a cultural event.';

  @override
  String get navFailed => 'Failed';

  @override
  String get navReviewSaveFailed => 'Could not save your review';

  @override
  String get langNameId => 'Indonesian';

  @override
  String get langNameEn => 'English';

  @override
  String get langNameKo => 'Korean';

  @override
  String get langNameJa => 'Japanese';

  @override
  String get langNameZh => 'Chinese';
}
