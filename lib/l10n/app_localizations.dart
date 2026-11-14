import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'LokaNusantara'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In id, this message translates to:
  /// **'Pilih Bahasa'**
  String get chooseLanguage;

  /// No description provided for @followSystem.
  ///
  /// In id, this message translates to:
  /// **'Ikuti bahasa perangkat'**
  String get followSystem;

  /// No description provided for @contentLanguageNote.
  ///
  /// In id, this message translates to:
  /// **'Nama tempat, deskripsi, dan agenda dari server tetap dalam Bahasa Indonesia.'**
  String get contentLanguageNote;

  /// No description provided for @commonCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get commonClose;

  /// No description provided for @commonSeeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get commonSeeAll;

  /// No description provided for @errorNetwork.
  ///
  /// In id, this message translates to:
  /// **'Koneksi jaringan gagal'**
  String get errorNetwork;

  /// No description provided for @errorNotFound.
  ///
  /// In id, this message translates to:
  /// **'Data tidak ditemukan'**
  String get errorNotFound;

  /// No description provided for @errorUnauthorized.
  ///
  /// In id, this message translates to:
  /// **'Akses tidak diizinkan'**
  String get errorUnauthorized;

  /// No description provided for @errorValidation.
  ///
  /// In id, this message translates to:
  /// **'Validasi gagal'**
  String get errorValidation;

  /// No description provided for @errorServer.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan pada server'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan'**
  String get errorUnknown;

  /// No description provided for @catTradisi.
  ///
  /// In id, this message translates to:
  /// **'Tradisi'**
  String get catTradisi;

  /// No description provided for @catPura.
  ///
  /// In id, this message translates to:
  /// **'Pura'**
  String get catPura;

  /// No description provided for @catMasjid.
  ///
  /// In id, this message translates to:
  /// **'Masjid'**
  String get catMasjid;

  /// No description provided for @catGereja.
  ///
  /// In id, this message translates to:
  /// **'Gereja'**
  String get catGereja;

  /// No description provided for @catVihara.
  ///
  /// In id, this message translates to:
  /// **'Vihara'**
  String get catVihara;

  /// No description provided for @catKlenteng.
  ///
  /// In id, this message translates to:
  /// **'Klenteng'**
  String get catKlenteng;

  /// No description provided for @catKuliner.
  ///
  /// In id, this message translates to:
  /// **'Kuliner'**
  String get catKuliner;

  /// No description provided for @catOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get catOther;

  /// No description provided for @etqGeneral1.
  ///
  /// In id, this message translates to:
  /// **'Berpakaian sopan dan jaga ketenangan.'**
  String get etqGeneral1;

  /// No description provided for @etqGeneral2.
  ///
  /// In id, this message translates to:
  /// **'Minta izin sebelum memotret warga atau kegiatan adat.'**
  String get etqGeneral2;

  /// No description provided for @etqGeneral3.
  ///
  /// In id, this message translates to:
  /// **'Ikuti aturan dan arahan pengelola setempat.'**
  String get etqGeneral3;

  /// No description provided for @etqTradisi1.
  ///
  /// In id, this message translates to:
  /// **'Minta izin sebelum memotret warga, rumah, atau upacara adat.'**
  String get etqTradisi1;

  /// No description provided for @etqTradisi2.
  ///
  /// In id, this message translates to:
  /// **'Ikuti aturan desa adat dan arahan pemandu setempat.'**
  String get etqTradisi2;

  /// No description provided for @etqTradisi3.
  ///
  /// In id, this message translates to:
  /// **'Jangan menyentuh atau melangkahi benda dan sesajen sakral.'**
  String get etqTradisi3;

  /// No description provided for @etqTradisi4.
  ///
  /// In id, this message translates to:
  /// **'Kenakan pakaian sopan; beberapa area mewajibkan kamen dan selendang.'**
  String get etqTradisi4;

  /// No description provided for @etqTradisi5.
  ///
  /// In id, this message translates to:
  /// **'Tiket dan donasi membantu pelestarian adat, gunakan pemandu lokal bila ada.'**
  String get etqTradisi5;

  /// No description provided for @etqPura1.
  ///
  /// In id, this message translates to:
  /// **'Kenakan kamen (sarung) dan selendang di pinggang; biasanya bisa dipinjam di pintu masuk.'**
  String get etqPura1;

  /// No description provided for @etqPura2.
  ///
  /// In id, this message translates to:
  /// **'Perempuan yang sedang haid tidak diperkenankan memasuki area suci.'**
  String get etqPura2;

  /// No description provided for @etqPura3.
  ///
  /// In id, this message translates to:
  /// **'Jangan memanjat, duduk di, atau bersandar pada bangunan suci.'**
  String get etqPura3;

  /// No description provided for @etqPura4.
  ///
  /// In id, this message translates to:
  /// **'Jangan berjalan di depan umat yang sedang bersembahyang.'**
  String get etqPura4;

  /// No description provided for @etqPura5.
  ///
  /// In id, this message translates to:
  /// **'Hindari menginjak canang (sesajen) di jalan dan halaman pura.'**
  String get etqPura5;

  /// No description provided for @etqMasjid1.
  ///
  /// In id, this message translates to:
  /// **'Berpakaian sopan dan menutup aurat; perempuan mengenakan kerudung.'**
  String get etqMasjid1;

  /// No description provided for @etqMasjid2.
  ///
  /// In id, this message translates to:
  /// **'Lepas alas kaki sebelum memasuki area salat.'**
  String get etqMasjid2;

  /// No description provided for @etqMasjid3.
  ///
  /// In id, this message translates to:
  /// **'Hindari berkunjung saat salat berjamaah, kecuali untuk beribadah.'**
  String get etqMasjid3;

  /// No description provided for @etqMasjid4.
  ///
  /// In id, this message translates to:
  /// **'Jaga ketenangan dan jangan melintas di depan orang yang sedang salat.'**
  String get etqMasjid4;

  /// No description provided for @etqGereja1.
  ///
  /// In id, this message translates to:
  /// **'Berpakaian sopan, menutup bahu dan lutut.'**
  String get etqGereja1;

  /// No description provided for @etqGereja2.
  ///
  /// In id, this message translates to:
  /// **'Jaga ketenangan, terutama saat misa atau ibadah berlangsung.'**
  String get etqGereja2;

  /// No description provided for @etqGereja3.
  ///
  /// In id, this message translates to:
  /// **'Minta izin sebelum memotret interior saat ada ibadah.'**
  String get etqGereja3;

  /// No description provided for @etqVihara1.
  ///
  /// In id, this message translates to:
  /// **'Berpakaian sopan, menutup bahu dan lutut.'**
  String get etqVihara1;

  /// No description provided for @etqVihara2.
  ///
  /// In id, this message translates to:
  /// **'Lepas alas kaki sebelum memasuki ruang puja (Dhammasala).'**
  String get etqVihara2;

  /// No description provided for @etqVihara3.
  ///
  /// In id, this message translates to:
  /// **'Jangan menyentuh rupang Buddha atau berfoto membelakanginya.'**
  String get etqVihara3;

  /// No description provided for @etqVihara4.
  ///
  /// In id, this message translates to:
  /// **'Jaga ketenangan di area meditasi.'**
  String get etqVihara4;

  /// No description provided for @etqKlenteng1.
  ///
  /// In id, this message translates to:
  /// **'Berpakaian sopan dan jaga ketenangan.'**
  String get etqKlenteng1;

  /// No description provided for @etqKlenteng2.
  ///
  /// In id, this message translates to:
  /// **'Jangan menyentuh altar, rupang, dan perlengkapan sembahyang.'**
  String get etqKlenteng2;

  /// No description provided for @etqKlenteng3.
  ///
  /// In id, this message translates to:
  /// **'Minta izin sebelum memotret umat yang sedang bersembahyang.'**
  String get etqKlenteng3;

  /// No description provided for @etqKlenteng4.
  ///
  /// In id, this message translates to:
  /// **'Saat Imlek dan Cap Go Meh suasana sangat ramai, datanglah lebih awal.'**
  String get etqKlenteng4;

  /// No description provided for @etqKuliner1.
  ///
  /// In id, this message translates to:
  /// **'Banyak warung tradisional buka sejak pagi dan tutup saat hidangan habis.'**
  String get etqKuliner1;

  /// No description provided for @etqKuliner2.
  ///
  /// In id, this message translates to:
  /// **'Beberapa hidangan Bali mengandung babi; tanyakan bila Anda memerlukan makanan halal.'**
  String get etqKuliner2;

  /// No description provided for @etqKuliner3.
  ///
  /// In id, this message translates to:
  /// **'Sambal matah dan betutu cukup pedas, minta tingkat pedas sesuai selera.'**
  String get etqKuliner3;

  /// No description provided for @etqKuliner4.
  ///
  /// In id, this message translates to:
  /// **'Siapkan uang tunai, tidak semua warung menerima pembayaran nontunai.'**
  String get etqKuliner4;

  /// No description provided for @dateToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get dateToday;

  /// No description provided for @dateOngoing.
  ///
  /// In id, this message translates to:
  /// **'Sedang berlangsung'**
  String get dateOngoing;

  /// No description provided for @datePast.
  ///
  /// In id, this message translates to:
  /// **'Sudah lewat'**
  String get datePast;

  /// No description provided for @dateTomorrow.
  ///
  /// In id, this message translates to:
  /// **'Besok'**
  String get dateTomorrow;

  /// No description provided for @dateInDays.
  ///
  /// In id, this message translates to:
  /// **'Dalam {count} hari'**
  String dateInDays(int count);

  /// No description provided for @dateInWeeks.
  ///
  /// In id, this message translates to:
  /// **'Dalam {count} minggu'**
  String dateInWeeks(int count);

  /// No description provided for @dateInMonths.
  ///
  /// In id, this message translates to:
  /// **'Dalam {count} bulan'**
  String dateInMonths(int count);

  /// No description provided for @homeDestinations.
  ///
  /// In id, this message translates to:
  /// **'Destinasi'**
  String get homeDestinations;

  /// No description provided for @homeSeeAllCount.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua {count} destinasi'**
  String homeSeeAllCount(int count);

  /// No description provided for @homeAllDestinations.
  ///
  /// In id, this message translates to:
  /// **'Semua Destinasi'**
  String get homeAllDestinations;

  /// No description provided for @homeSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari destinasi atau daerah...'**
  String get homeSearchHint;

  /// No description provided for @homeDestinationCount.
  ///
  /// In id, this message translates to:
  /// **'{count} destinasi'**
  String homeDestinationCount(int count);

  /// No description provided for @homeNoMatch.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada destinasi yang cocok.'**
  String get homeNoMatch;

  /// No description provided for @homeTagline.
  ///
  /// In id, this message translates to:
  /// **'Temukan tradisi, rumah ibadah, dan kuliner khas Bali'**
  String get homeTagline;

  /// No description provided for @homeCategoryAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get homeCategoryAll;

  /// No description provided for @homeNotFound.
  ///
  /// In id, this message translates to:
  /// **'Destinasi tidak ditemukan'**
  String get homeNotFound;

  /// No description provided for @mapRouteUnavailableTitle.
  ///
  /// In id, this message translates to:
  /// **'Rute Tidak Tersedia'**
  String get mapRouteUnavailableTitle;

  /// No description provided for @mapRouteUnavailableBody.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada rute yang ditemukan untuk mode transportasi ini.'**
  String get mapRouteUnavailableBody;

  /// No description provided for @mapRouteFailedTitle.
  ///
  /// In id, this message translates to:
  /// **'Gagal'**
  String get mapRouteFailedTitle;

  /// No description provided for @mapRouteFailedBody.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat mengambil rute. Periksa koneksi internet.'**
  String get mapRouteFailedBody;

  /// No description provided for @mapClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup peta'**
  String get mapClose;

  /// No description provided for @mapMyLocation.
  ///
  /// In id, this message translates to:
  /// **'Lokasi saya'**
  String get mapMyLocation;

  /// No description provided for @mapReload.
  ///
  /// In id, this message translates to:
  /// **'Muat ulang'**
  String get mapReload;

  /// No description provided for @mapZoomIn.
  ///
  /// In id, this message translates to:
  /// **'Perbesar'**
  String get mapZoomIn;

  /// No description provided for @mapZoomOut.
  ///
  /// In id, this message translates to:
  /// **'Perkecil'**
  String get mapZoomOut;

  /// No description provided for @mapPreparing.
  ///
  /// In id, this message translates to:
  /// **'Menyiapkan peta'**
  String get mapPreparing;

  /// No description provided for @mapLoadingNearby.
  ///
  /// In id, this message translates to:
  /// **'Memuat destinasi di sekitarmu'**
  String get mapLoadingNearby;

  /// No description provided for @mapTrailSummary.
  ///
  /// In id, this message translates to:
  /// **'{count} titik singgah, sekitar {km} km'**
  String mapTrailSummary(int count, int km);

  /// No description provided for @mapCloseTrail.
  ///
  /// In id, this message translates to:
  /// **'Tutup jalur'**
  String get mapCloseTrail;

  /// No description provided for @shellHome.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get shellHome;

  /// No description provided for @shellSaved.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan'**
  String get shellSaved;

  /// No description provided for @shellAgenda.
  ///
  /// In id, this message translates to:
  /// **'Agenda'**
  String get shellAgenda;

  /// No description provided for @shellProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get shellProfile;

  /// No description provided for @shellOpenMap.
  ///
  /// In id, this message translates to:
  /// **'Buka peta'**
  String get shellOpenMap;

  /// No description provided for @shellMap.
  ///
  /// In id, this message translates to:
  /// **'Peta'**
  String get shellMap;

  /// No description provided for @splashTagline.
  ///
  /// In id, this message translates to:
  /// **'Jelajahi tradisi Nusantara'**
  String get splashTagline;

  /// No description provided for @notifTitle.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notifTitle;

  /// No description provided for @notifWindow.
  ///
  /// In id, this message translates to:
  /// **'Agenda budaya dalam {days} hari ke depan'**
  String notifWindow(int days);

  /// No description provided for @notifEstimatedDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal perkiraan, bisa berubah'**
  String get notifEstimatedDate;

  /// No description provided for @notifEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada notifikasi'**
  String get notifEmptyTitle;

  /// No description provided for @notifEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Agenda budaya yang akan berlangsung dalam {days} hari ke depan akan muncul di sini.'**
  String notifEmptyBody(int days);

  /// No description provided for @trailTitle.
  ///
  /// In id, this message translates to:
  /// **'Jalur Kisah'**
  String get trailTitle;

  /// No description provided for @trailStopCount.
  ///
  /// In id, this message translates to:
  /// **'{count} titik singgah'**
  String trailStopCount(int count);

  /// No description provided for @trailAboutKm.
  ///
  /// In id, this message translates to:
  /// **'sekitar {km} km'**
  String trailAboutKm(int km);

  /// No description provided for @trailStory.
  ///
  /// In id, this message translates to:
  /// **'Kisah Jalur'**
  String get trailStory;

  /// No description provided for @trailStops.
  ///
  /// In id, this message translates to:
  /// **'Titik Singgah'**
  String get trailStops;

  /// No description provided for @trailShowOnMap.
  ///
  /// In id, this message translates to:
  /// **'Lihat Jalur di Peta'**
  String get trailShowOnMap;

  /// No description provided for @searchPlaceholder.
  ///
  /// In id, this message translates to:
  /// **'Cari lokasi...'**
  String get searchPlaceholder;

  /// No description provided for @searchNotFound.
  ///
  /// In id, this message translates to:
  /// **'Lokasi tidak ditemukan'**
  String get searchNotFound;

  /// No description provided for @detailMakePlan.
  ///
  /// In id, this message translates to:
  /// **'Buat Rencana Kunjungan'**
  String get detailMakePlan;

  /// No description provided for @detailAskLoka.
  ///
  /// In id, this message translates to:
  /// **'Tanya Loka tentang tempat ini'**
  String get detailAskLoka;

  /// No description provided for @detailAbout.
  ///
  /// In id, this message translates to:
  /// **'Tentang'**
  String get detailAbout;

  /// No description provided for @detailHistory.
  ///
  /// In id, this message translates to:
  /// **'Sejarah'**
  String get detailHistory;

  /// No description provided for @detailHistoryEmpty.
  ///
  /// In id, this message translates to:
  /// **'Kisah sejarah tempat ini belum tersedia.'**
  String get detailHistoryEmpty;

  /// No description provided for @detailEtiquette.
  ///
  /// In id, this message translates to:
  /// **'Etika Berkunjung'**
  String get detailEtiquette;

  /// No description provided for @detailAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat'**
  String get detailAddress;

  /// No description provided for @detailReviews.
  ///
  /// In id, this message translates to:
  /// **'Ulasan'**
  String get detailReviews;

  /// No description provided for @detailReviewsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada ulasan. Jadilah yang pertama berbagi cerita.'**
  String get detailReviewsEmpty;

  /// No description provided for @detailReviewCount.
  ///
  /// In id, this message translates to:
  /// **'{count} ulasan'**
  String detailReviewCount(int count);

  /// No description provided for @detailNotRated.
  ///
  /// In id, this message translates to:
  /// **'Belum dinilai'**
  String get detailNotRated;

  /// No description provided for @detailDistance.
  ///
  /// In id, this message translates to:
  /// **'Jarak'**
  String get detailDistance;

  /// No description provided for @detailCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get detailCategory;

  /// No description provided for @detailVisitor.
  ///
  /// In id, this message translates to:
  /// **'Pengunjung'**
  String get detailVisitor;

  /// No description provided for @detailRoute.
  ///
  /// In id, this message translates to:
  /// **'Lihat Rute'**
  String get detailRoute;

  /// No description provided for @detailModeCar.
  ///
  /// In id, this message translates to:
  /// **'Mobil'**
  String get detailModeCar;

  /// No description provided for @detailModeWalk.
  ///
  /// In id, this message translates to:
  /// **'Jalan'**
  String get detailModeWalk;

  /// No description provided for @detailModeBike.
  ///
  /// In id, this message translates to:
  /// **'Sepeda'**
  String get detailModeBike;

  /// No description provided for @detailRating.
  ///
  /// In id, this message translates to:
  /// **'Rating'**
  String get detailRating;

  /// No description provided for @detailNoRating.
  ///
  /// In id, this message translates to:
  /// **'Belum ada rating'**
  String get detailNoRating;

  /// No description provided for @detailDescription.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi'**
  String get detailDescription;

  /// No description provided for @detailLatestReviews.
  ///
  /// In id, this message translates to:
  /// **'Ulasan Terbaru'**
  String get detailLatestReviews;

  /// No description provided for @detailFullHistory.
  ///
  /// In id, this message translates to:
  /// **'Sejarah & Detail Lengkap'**
  String get detailFullHistory;

  /// No description provided for @detailReadMore.
  ///
  /// In id, this message translates to:
  /// **'Baca selengkapnya'**
  String get detailReadMore;

  /// No description provided for @planTitle.
  ///
  /// In id, this message translates to:
  /// **'Rencana Kunjungan'**
  String get planTitle;

  /// No description provided for @planDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus rencana'**
  String get planDeleteTitle;

  /// No description provided for @planDeleteMessage.
  ///
  /// In id, this message translates to:
  /// **'Rencana kunjungan ini akan dihapus dari akunmu.'**
  String get planDeleteMessage;

  /// No description provided for @planDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get planDelete;

  /// No description provided for @planDeleteFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menghapus: {error}'**
  String planDeleteFailed(String error);

  /// No description provided for @planPeopleCount.
  ///
  /// In id, this message translates to:
  /// **'{count} orang'**
  String planPeopleCount(int count);

  /// No description provided for @planDaysCount.
  ///
  /// In id, this message translates to:
  /// **'{count} hari'**
  String planDaysCount(int count);

  /// No description provided for @planMeta.
  ///
  /// In id, this message translates to:
  /// **'{people}  •  {days}  •  budget {budget}'**
  String planMeta(String people, String days, String budget);

  /// No description provided for @planSummary.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan'**
  String get planSummary;

  /// No description provided for @planCosts.
  ///
  /// In id, this message translates to:
  /// **'Rincian biaya'**
  String get planCosts;

  /// No description provided for @planTotalEstimate.
  ///
  /// In id, this message translates to:
  /// **'Total perkiraan'**
  String get planTotalEstimate;

  /// No description provided for @planSchedule.
  ///
  /// In id, this message translates to:
  /// **'Jadwal'**
  String get planSchedule;

  /// No description provided for @planDay.
  ///
  /// In id, this message translates to:
  /// **'Hari {day}'**
  String planDay(int day);

  /// No description provided for @planTips.
  ///
  /// In id, this message translates to:
  /// **'Tips'**
  String get planTips;

  /// No description provided for @planDisclaimer.
  ///
  /// In id, this message translates to:
  /// **'Rencana dan biaya disusun oleh AI sebagai perkiraan. Cek kembali harga, jam buka, dan jadwal upacara sebelum berangkat.'**
  String get planDisclaimer;

  /// No description provided for @planSavedMessage.
  ///
  /// In id, this message translates to:
  /// **'Rencana disimpan. Lihat di Tersimpan, tab Rencana.'**
  String get planSavedMessage;

  /// No description provided for @planSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan: {error}'**
  String planSaveFailed(String error);

  /// No description provided for @planSavedLabel.
  ///
  /// In id, this message translates to:
  /// **'Rencana tersimpan'**
  String get planSavedLabel;

  /// No description provided for @planSaveButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan Rencana'**
  String get planSaveButton;

  /// No description provided for @planWithinBudget.
  ///
  /// In id, this message translates to:
  /// **'Sesuai budget'**
  String get planWithinBudget;

  /// No description provided for @planOverBudget.
  ///
  /// In id, this message translates to:
  /// **'Melebihi budget'**
  String get planOverBudget;

  /// No description provided for @planEstimatedTotal.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan total'**
  String get planEstimatedTotal;

  /// No description provided for @planPerPerson.
  ///
  /// In id, this message translates to:
  /// **'Per orang'**
  String get planPerPerson;

  /// No description provided for @planBudgetLeft.
  ///
  /// In id, this message translates to:
  /// **'Sisa budget'**
  String get planBudgetLeft;

  /// No description provided for @planShortfall.
  ///
  /// In id, this message translates to:
  /// **'Kekurangan'**
  String get planShortfall;

  /// No description provided for @planBuilding.
  ///
  /// In id, this message translates to:
  /// **'Menyusun rencanamu'**
  String get planBuilding;

  /// No description provided for @planBuildingBody.
  ///
  /// In id, this message translates to:
  /// **'AI sedang menghitung biaya untuk {people}, {days}, dengan budget {budget}. Biasanya butuh beberapa detik.'**
  String planBuildingBody(String people, String days, String budget);

  /// No description provided for @planBudgetLabel.
  ///
  /// In id, this message translates to:
  /// **'Budget total rombongan'**
  String get planBudgetLabel;

  /// No description provided for @planPeople.
  ///
  /// In id, this message translates to:
  /// **'Jumlah orang'**
  String get planPeople;

  /// No description provided for @planDuration.
  ///
  /// In id, this message translates to:
  /// **'Lama kunjungan'**
  String get planDuration;

  /// No description provided for @planPerPersonApprox.
  ///
  /// In id, this message translates to:
  /// **'Sekitar {amount} per orang'**
  String planPerPersonApprox(String amount);

  /// No description provided for @planNotesLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get planNotesLabel;

  /// No description provided for @planNotesHint.
  ///
  /// In id, this message translates to:
  /// **'Misal: bawa anak kecil, naik motor, mau kuliner halal'**
  String get planNotesHint;

  /// No description provided for @planCreate.
  ///
  /// In id, this message translates to:
  /// **'Buat Rencana'**
  String get planCreate;

  /// No description provided for @planSheetDisclaimer.
  ///
  /// In id, this message translates to:
  /// **'Rencana dan biaya adalah perkiraan dari AI. Harga sebenarnya bisa berbeda.'**
  String get planSheetDisclaimer;

  /// No description provided for @planDecrease.
  ///
  /// In id, this message translates to:
  /// **'Kurangi'**
  String get planDecrease;

  /// No description provided for @planIncrease.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get planIncrease;

  /// No description provided for @planErrBudget.
  ///
  /// In id, this message translates to:
  /// **'Budget minimal {amount}'**
  String planErrBudget(String amount);

  /// No description provided for @planErrPeople.
  ///
  /// In id, this message translates to:
  /// **'Jumlah orang harus 1 sampai {max}'**
  String planErrPeople(int max);

  /// No description provided for @planErrDays.
  ///
  /// In id, this message translates to:
  /// **'Lama kunjungan harus 1 sampai {max} hari'**
  String planErrDays(int max);

  /// No description provided for @planErrNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan maksimal {max} karakter'**
  String planErrNotes(int max);

  /// No description provided for @audioTitle.
  ///
  /// In id, this message translates to:
  /// **'Pemandu Audio'**
  String get audioTitle;

  /// No description provided for @audioPart.
  ///
  /// In id, this message translates to:
  /// **'Bagian {index} dari {total}'**
  String audioPart(int index, int total);

  /// No description provided for @audioListen.
  ///
  /// In id, this message translates to:
  /// **'Dengarkan kisah tempat ini'**
  String get audioListen;

  /// No description provided for @audioStop.
  ///
  /// In id, this message translates to:
  /// **'Berhenti'**
  String get audioStop;

  /// No description provided for @audioSpeed.
  ///
  /// In id, this message translates to:
  /// **'Kecepatan'**
  String get audioSpeed;

  /// No description provided for @audioSpeedSlow.
  ///
  /// In id, this message translates to:
  /// **'Lambat'**
  String get audioSpeedSlow;

  /// No description provided for @audioSpeedNormal.
  ///
  /// In id, this message translates to:
  /// **'Normal'**
  String get audioSpeedNormal;

  /// No description provided for @audioSpeedFast.
  ///
  /// In id, this message translates to:
  /// **'Cepat'**
  String get audioSpeedFast;

  /// No description provided for @audioNoVoice.
  ///
  /// In id, this message translates to:
  /// **'Suara bahasa Indonesia belum terpasang di perangkat, jadi narasi memakai suara bawaan. Pasang di pengaturan Text-to-Speech.'**
  String get audioNoVoice;

  /// No description provided for @reviewWrite.
  ///
  /// In id, this message translates to:
  /// **'Tulis Ulasan'**
  String get reviewWrite;

  /// No description provided for @reviewPickRating.
  ///
  /// In id, this message translates to:
  /// **'Pilih rating'**
  String get reviewPickRating;

  /// No description provided for @reviewVeryBad.
  ///
  /// In id, this message translates to:
  /// **'Sangat Buruk'**
  String get reviewVeryBad;

  /// No description provided for @reviewBad.
  ///
  /// In id, this message translates to:
  /// **'Buruk'**
  String get reviewBad;

  /// No description provided for @reviewOkay.
  ///
  /// In id, this message translates to:
  /// **'Cukup'**
  String get reviewOkay;

  /// No description provided for @reviewGood.
  ///
  /// In id, this message translates to:
  /// **'Bagus'**
  String get reviewGood;

  /// No description provided for @reviewVeryGood.
  ///
  /// In id, this message translates to:
  /// **'Sangat Bagus'**
  String get reviewVeryGood;

  /// No description provided for @reviewRating.
  ///
  /// In id, this message translates to:
  /// **'Rating'**
  String get reviewRating;

  /// No description provided for @reviewComment.
  ///
  /// In id, this message translates to:
  /// **'Komentar (opsional)'**
  String get reviewComment;

  /// No description provided for @reviewHint.
  ///
  /// In id, this message translates to:
  /// **'Tulis pengalamanmu di sini...'**
  String get reviewHint;

  /// No description provided for @bookmarkSaved.
  ///
  /// In id, this message translates to:
  /// **'{name} disimpan'**
  String bookmarkSaved(String name);

  /// No description provided for @bookmarkRemoved.
  ///
  /// In id, this message translates to:
  /// **'{name} dihapus dari simpanan'**
  String bookmarkRemoved(String name);

  /// No description provided for @bookmarkFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan: {error}'**
  String bookmarkFailed(String error);

  /// No description provided for @dialogOk.
  ///
  /// In id, this message translates to:
  /// **'OK'**
  String get dialogOk;

  /// No description provided for @savedTitle.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan'**
  String get savedTitle;

  /// No description provided for @savedSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{places} destinasi, {plans} rencana'**
  String savedSubtitle(int places, int plans);

  /// No description provided for @savedSubtitleSignedOut.
  ///
  /// In id, this message translates to:
  /// **'Simpanan tersimpan di akunmu'**
  String get savedSubtitleSignedOut;

  /// No description provided for @savedTabPlaces.
  ///
  /// In id, this message translates to:
  /// **'Tempat'**
  String get savedTabPlaces;

  /// No description provided for @savedTabPlans.
  ///
  /// In id, this message translates to:
  /// **'Rencana'**
  String get savedTabPlans;

  /// No description provided for @savedPlacesSignInTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk melihat simpanan'**
  String get savedPlacesSignInTitle;

  /// No description provided for @savedPlacesFailed.
  ///
  /// In id, this message translates to:
  /// **'Simpanan gagal dimuat'**
  String get savedPlacesFailed;

  /// No description provided for @savedPlacesEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada destinasi tersimpan'**
  String get savedPlacesEmpty;

  /// No description provided for @savedPlacesSignInBody.
  ///
  /// In id, this message translates to:
  /// **'Destinasi yang kamu simpan disimpan di akunmu, jadi tetap ada saat kamu ganti perangkat.'**
  String get savedPlacesSignInBody;

  /// No description provided for @savedPullToRetry.
  ///
  /// In id, this message translates to:
  /// **'{error} Tarik ke bawah untuk mencoba lagi.'**
  String savedPullToRetry(String error);

  /// No description provided for @savedPlacesEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Ketuk ikon simpan pada destinasi yang ingin kamu kunjungi nanti.'**
  String get savedPlacesEmptyBody;

  /// No description provided for @savedRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus dari simpanan'**
  String get savedRemove;

  /// No description provided for @savedPlansSignInTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk melihat rencana'**
  String get savedPlansSignInTitle;

  /// No description provided for @savedPlansFailed.
  ///
  /// In id, this message translates to:
  /// **'Rencana gagal dimuat'**
  String get savedPlansFailed;

  /// No description provided for @savedPlansEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada rencana tersimpan'**
  String get savedPlansEmpty;

  /// No description provided for @savedPlansSignInBody.
  ///
  /// In id, this message translates to:
  /// **'Rencana kunjungan yang kamu simpan tersimpan di akunmu.'**
  String get savedPlansSignInBody;

  /// No description provided for @savedPlansEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Buka sebuah tempat, buat Rencana Kunjungan, lalu ketuk Simpan Rencana.'**
  String get savedPlansEmptyBody;

  /// No description provided for @savedPlanMeta.
  ///
  /// In id, this message translates to:
  /// **'{people} orang  •  {days} hari  •  {total}'**
  String savedPlanMeta(int people, int days, String total);

  /// No description provided for @savedWithinBudget.
  ///
  /// In id, this message translates to:
  /// **'Sesuai budget'**
  String get savedWithinBudget;

  /// No description provided for @savedOverBudget.
  ///
  /// In id, this message translates to:
  /// **'Melebihi budget'**
  String get savedOverBudget;

  /// No description provided for @savedExploreHome.
  ///
  /// In id, this message translates to:
  /// **'Jelajahi Beranda'**
  String get savedExploreHome;

  /// No description provided for @savedSignInPlaceRequired.
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk menyimpan destinasi'**
  String get savedSignInPlaceRequired;

  /// No description provided for @savedSignInPlanRequired.
  ///
  /// In id, this message translates to:
  /// **'Masuk dulu untuk menyimpan rencana'**
  String get savedSignInPlanRequired;

  /// No description provided for @recentTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get recentTitle;

  /// No description provided for @recentSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Destinasi yang terakhir kamu lihat'**
  String get recentSubtitle;

  /// No description provided for @recentEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat masih kosong'**
  String get recentEmptyTitle;

  /// No description provided for @recentEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Destinasi yang kamu buka akan muncul di sini.'**
  String get recentEmptyBody;

  /// No description provided for @recentClear.
  ///
  /// In id, this message translates to:
  /// **'Hapus riwayat'**
  String get recentClear;

  /// No description provided for @recentClearMessage.
  ///
  /// In id, this message translates to:
  /// **'Semua riwayat destinasi akan dihapus.'**
  String get recentClearMessage;

  /// No description provided for @recentClearConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get recentClearConfirm;

  /// No description provided for @profileGuestName.
  ///
  /// In id, this message translates to:
  /// **'Penjelajah Tamu'**
  String get profileGuestName;

  /// No description provided for @profileGuestEmail.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk menulis ulasan'**
  String get profileGuestEmail;

  /// No description provided for @profileRecent.
  ///
  /// In id, this message translates to:
  /// **'Terakhir Dilihat'**
  String get profileRecent;

  /// No description provided for @profileOpenMap.
  ///
  /// In id, this message translates to:
  /// **'Buka Peta'**
  String get profileOpenMap;

  /// No description provided for @profileShowIntro.
  ///
  /// In id, this message translates to:
  /// **'Lihat Pengenalan Aplikasi'**
  String get profileShowIntro;

  /// No description provided for @profileAbout.
  ///
  /// In id, this message translates to:
  /// **'Tentang LokaNusantara'**
  String get profileAbout;

  /// No description provided for @profileAboutBody.
  ///
  /// In id, this message translates to:
  /// **'Peta budaya Nusantara: tradisi, rumah ibadah, dan kuliner khas, dimulai dari Bali.'**
  String get profileAboutBody;

  /// No description provided for @profileIntroOnLaunch.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan pengenalan saat dibuka'**
  String get profileIntroOnLaunch;

  /// No description provided for @profileIntroOnLaunchDone.
  ///
  /// In id, this message translates to:
  /// **'Pengenalan akan tampil saat aplikasi dibuka lagi'**
  String get profileIntroOnLaunchDone;

  /// No description provided for @profileSignOut.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get profileSignOut;

  /// No description provided for @profileSignOutMessage.
  ///
  /// In id, this message translates to:
  /// **'Yakin ingin keluar dari akunmu?'**
  String get profileSignOutMessage;

  /// No description provided for @profileSignOutConfirm.
  ///
  /// In id, this message translates to:
  /// **'Ya, Keluar'**
  String get profileSignOutConfirm;

  /// No description provided for @profilePhoto.
  ///
  /// In id, this message translates to:
  /// **'Foto profil'**
  String get profilePhoto;

  /// No description provided for @profileAuthTitle.
  ///
  /// In id, this message translates to:
  /// **'Simpan dan bagikan perjalananmu'**
  String get profileAuthTitle;

  /// No description provided for @profileAuthBody.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Google untuk menyimpan destinasi dan menulis ulasan.'**
  String get profileAuthBody;

  /// No description provided for @profileReminders.
  ///
  /// In id, this message translates to:
  /// **'Pengingat agenda budaya'**
  String get profileReminders;

  /// No description provided for @profileRemindersBlocked.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi diblokir. Izinkan di pengaturan HP.'**
  String get profileRemindersBlocked;

  /// No description provided for @profileRemindersHint.
  ///
  /// In id, this message translates to:
  /// **'Sehari sebelum dan pada hari agenda'**
  String get profileRemindersHint;

  /// No description provided for @authSignIn.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get authSignIn;

  /// No description provided for @authFailedTitle.
  ///
  /// In id, this message translates to:
  /// **'Gagal Masuk'**
  String get authFailedTitle;

  /// No description provided for @authErrorConfig.
  ///
  /// In id, this message translates to:
  /// **'Login Google belum dikonfigurasi'**
  String get authErrorConfig;

  /// No description provided for @authErrorFailed.
  ///
  /// In id, this message translates to:
  /// **'Login Google gagal'**
  String get authErrorFailed;

  /// No description provided for @authLater.
  ///
  /// In id, this message translates to:
  /// **'Nanti saja'**
  String get authLater;

  /// No description provided for @authTagline.
  ///
  /// In id, this message translates to:
  /// **'Jelajahi tradisi, rumah ibadah, dan kisah\ndi setiap sudut Nusantara'**
  String get authTagline;

  /// No description provided for @authTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk mulai menjelajah'**
  String get authTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Satu ketukan dengan akun Google, tanpa perlu membuat password baru.'**
  String get authSubtitle;

  /// No description provided for @authBenefitSaveTitle.
  ///
  /// In id, this message translates to:
  /// **'Simpan destinasi favorit'**
  String get authBenefitSaveTitle;

  /// No description provided for @authBenefitSaveBody.
  ///
  /// In id, this message translates to:
  /// **'Kumpulkan tempat yang ingin kamu kunjungi.'**
  String get authBenefitSaveBody;

  /// No description provided for @authBenefitReviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Tulis ulasan'**
  String get authBenefitReviewTitle;

  /// No description provided for @authBenefitReviewBody.
  ///
  /// In id, this message translates to:
  /// **'Bagikan pengalamanmu untuk penjelajah lain.'**
  String get authBenefitReviewBody;

  /// No description provided for @authBenefitSyncTitle.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan di akunmu'**
  String get authBenefitSyncTitle;

  /// No description provided for @authBenefitSyncBody.
  ///
  /// In id, this message translates to:
  /// **'Simpananmu tetap ada saat ganti perangkat.'**
  String get authBenefitSyncBody;

  /// No description provided for @authPrivacy.
  ///
  /// In id, this message translates to:
  /// **'Kami hanya memakai nama, email, dan foto profil dari akun Google kamu.'**
  String get authPrivacy;

  /// No description provided for @authContinueGoogle.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan dengan Google'**
  String get authContinueGoogle;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang di LokaNusantara'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeBody.
  ///
  /// In id, this message translates to:
  /// **'Peta budaya Nusantara dalam genggamanmu. Temukan tradisi, rumah ibadah, dan kuliner khas dalam satu aplikasi.'**
  String get onbWelcomeBody;

  /// No description provided for @onbTraditionTitle.
  ///
  /// In id, this message translates to:
  /// **'Tradisi & Rumah Ibadah'**
  String get onbTraditionTitle;

  /// No description provided for @onbTraditionBody.
  ///
  /// In id, this message translates to:
  /// **'Kunjungi desa adat, pura, masjid, gereja, vihara, dan klenteng, lengkap dengan kisah sejarah dan etika berkunjungnya.'**
  String get onbTraditionBody;

  /// No description provided for @onbCulinaryTitle.
  ///
  /// In id, this message translates to:
  /// **'Cita Rasa Nusantara'**
  String get onbCulinaryTitle;

  /// No description provided for @onbCulinaryBody.
  ///
  /// In id, this message translates to:
  /// **'Cicipi kuliner legendaris dari warung turun-temurun, dari babi guling hingga ayam betutu.'**
  String get onbCulinaryBody;

  /// No description provided for @onbRouteTitle.
  ///
  /// In id, this message translates to:
  /// **'Simpan & Temukan Rute'**
  String get onbRouteTitle;

  /// No description provided for @onbRouteBody.
  ///
  /// In id, this message translates to:
  /// **'Simpan destinasi favorit, lihat kembali riwayat jelajahmu, dan dapatkan rute langsung ke lokasi.'**
  String get onbRouteBody;

  /// No description provided for @onbSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get onbSkip;

  /// No description provided for @onbStart.
  ///
  /// In id, this message translates to:
  /// **'Mulai Jelajah'**
  String get onbStart;

  /// No description provided for @tanyaSuggest1.
  ///
  /// In id, this message translates to:
  /// **'Apa itu Hari Raya Galungan?'**
  String get tanyaSuggest1;

  /// No description provided for @tanyaSuggest2.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana etika masuk pura?'**
  String get tanyaSuggest2;

  /// No description provided for @tanyaSuggest3.
  ///
  /// In id, this message translates to:
  /// **'Di mana kampung Muslim tertua di Bali?'**
  String get tanyaSuggest3;

  /// No description provided for @tanyaSuggest4.
  ///
  /// In id, this message translates to:
  /// **'Kuliner khas apa yang wajib dicoba di Gianyar?'**
  String get tanyaSuggest4;

  /// No description provided for @tanyaSuggest5.
  ///
  /// In id, this message translates to:
  /// **'Desa adat mana yang menjaga tradisi Bali Aga?'**
  String get tanyaSuggest5;

  /// No description provided for @tanyaSuggest6.
  ///
  /// In id, this message translates to:
  /// **'Ada upacara apa dalam waktu dekat?'**
  String get tanyaSuggest6;

  /// No description provided for @tanyaAboutPlace.
  ///
  /// In id, this message translates to:
  /// **'Ceritakan tentang {name}: sejarah singkatnya, apa yang menarik untuk dilihat, dan etika saat berkunjung.'**
  String tanyaAboutPlace(String name);

  /// No description provided for @tanyaNewChat.
  ///
  /// In id, this message translates to:
  /// **'Percakapan baru'**
  String get tanyaNewChat;

  /// No description provided for @tanyaNewChatMessage.
  ///
  /// In id, this message translates to:
  /// **'Percakapan saat ini akan dihapus.'**
  String get tanyaNewChatMessage;

  /// No description provided for @tanyaNewChatConfirm.
  ///
  /// In id, this message translates to:
  /// **'Mulai baru'**
  String get tanyaNewChatConfirm;

  /// No description provided for @tanyaSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pemandu budaya berbasis AI'**
  String get tanyaSubtitle;

  /// No description provided for @tanyaGreeting.
  ///
  /// In id, this message translates to:
  /// **'Om Swastyastu!'**
  String get tanyaGreeting;

  /// No description provided for @tanyaIntro.
  ///
  /// In id, this message translates to:
  /// **'Aku Loka, pemandu budayamu. Tanyakan tentang tradisi, rumah ibadah, kuliner, atau agenda upacara di Bali. Jawabanku berasal dari data LokaNusantara.'**
  String get tanyaIntro;

  /// No description provided for @tanyaTryAsking.
  ///
  /// In id, this message translates to:
  /// **'Coba tanyakan'**
  String get tanyaTryAsking;

  /// No description provided for @tanyaTyping.
  ///
  /// In id, this message translates to:
  /// **'Loka sedang mencari jawaban'**
  String get tanyaTyping;

  /// No description provided for @tanyaHint.
  ///
  /// In id, this message translates to:
  /// **'Tanyakan tentang budaya Bali...'**
  String get tanyaHint;

  /// No description provided for @tanyaDisclaimer.
  ///
  /// In id, this message translates to:
  /// **'Jawaban AI bisa keliru. Cek kembali informasi penting ke sumber setempat.'**
  String get tanyaDisclaimer;

  /// No description provided for @agendaTitle.
  ///
  /// In id, this message translates to:
  /// **'Tradisi & Kebudayaan'**
  String get agendaTitle;

  /// No description provided for @agendaSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Hari raya, upacara, dan festival di Bali'**
  String get agendaSubtitle;

  /// No description provided for @agendaAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get agendaAll;

  /// No description provided for @agendaEmptyCategory.
  ///
  /// In id, this message translates to:
  /// **'Belum ada agenda untuk kategori ini.'**
  String get agendaEmptyCategory;

  /// No description provided for @agendaSoon.
  ///
  /// In id, this message translates to:
  /// **'Segera'**
  String get agendaSoon;

  /// No description provided for @agendaEstimate.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan'**
  String get agendaEstimate;

  /// No description provided for @agendaEstimateNote.
  ///
  /// In id, this message translates to:
  /// **'Tanggal ini perkiraan. Hari raya yang mengikuti kalender bulan atau keputusan panitia bisa bergeser, cek pengumuman resmi sebelum berkunjung.'**
  String get agendaEstimateNote;

  /// No description provided for @agendaViewOnMap.
  ///
  /// In id, this message translates to:
  /// **'Lihat di Peta'**
  String get agendaViewOnMap;

  /// No description provided for @agendaLocationDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Lokasi'**
  String get agendaLocationDetail;

  /// No description provided for @reminderTomorrow.
  ///
  /// In id, this message translates to:
  /// **'Besok: {name}'**
  String reminderTomorrow(String name);

  /// No description provided for @reminderToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini: {name}'**
  String reminderToday(String name);

  /// No description provided for @reminderEstimate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal perkiraan, cek pengumuman setempat.'**
  String get reminderEstimate;

  /// No description provided for @reminderDefaultPlace.
  ///
  /// In id, this message translates to:
  /// **'Agenda budaya di Bali.'**
  String get reminderDefaultPlace;

  /// No description provided for @reminderChannelName.
  ///
  /// In id, this message translates to:
  /// **'Pengingat agenda budaya'**
  String get reminderChannelName;

  /// No description provided for @reminderChannelDescription.
  ///
  /// In id, this message translates to:
  /// **'Pengingat sehari sebelum dan pada hari agenda budaya berlangsung.'**
  String get reminderChannelDescription;

  /// No description provided for @navFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal'**
  String get navFailed;

  /// No description provided for @navReviewSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan ulasan'**
  String get navReviewSaveFailed;

  /// No description provided for @langNameId.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get langNameId;

  /// No description provided for @langNameEn.
  ///
  /// In id, this message translates to:
  /// **'Inggris'**
  String get langNameEn;

  /// No description provided for @langNameKo.
  ///
  /// In id, this message translates to:
  /// **'Korea'**
  String get langNameKo;

  /// No description provided for @langNameJa.
  ///
  /// In id, this message translates to:
  /// **'Jepang'**
  String get langNameJa;

  /// No description provided for @langNameZh.
  ///
  /// In id, this message translates to:
  /// **'Mandarin'**
  String get langNameZh;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
