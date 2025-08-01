import 'package:flutter/material.dart';
import '../constants/strings.dart';

/// Connects our custom [Strings] lookup into Flutter’s localization system.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// Retrieve the current [AppLocalizations].
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(
        context, AppLocalizations)!;
  }

  /// Look up the localized string for [key].
  String t(String key) => Strings.localizedMap(locale)[key] ?? key;

  /// The list of locales this delegate supports.
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('en', 'GB'),
  ];

  /// The delegate to wire into MaterialApp.
  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' &&
          (locale.countryCode == 'US' || locale.countryCode == 'GB');

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
