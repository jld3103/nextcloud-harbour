
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'localizations_en.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations returned
/// by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'l10n/localizations.dart';
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
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Nextcloud Neon'**
  String get appName;

  /// No description provided for @loginAccountAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'The account you are trying to add already exists'**
  String get loginAccountAlreadyExists;

  /// No description provided for @loginAgain.
  ///
  /// In en, this message translates to:
  /// **'Login again'**
  String get loginAgain;

  /// No description provided for @loginOpenAgain.
  ///
  /// In en, this message translates to:
  /// **'Open again'**
  String get loginOpenAgain;

  /// No description provided for @loginSwitchToBrowserWindow.
  ///
  /// In en, this message translates to:
  /// **'Please switch to the browser window that just opened and proceed there'**
  String get loginSwitchToBrowserWindow;

  /// No description provided for @loginWorksWith.
  ///
  /// In en, this message translates to:
  /// **'works with'**
  String get loginWorksWith;

  /// No description provided for @errorCredentialsForAccountNoLongerMatch.
  ///
  /// In en, this message translates to:
  /// **'The credentials for this account no longer match'**
  String get errorCredentialsForAccountNoLongerMatch;

  /// No description provided for @errorServerHadAProblemProcessingYourRequest.
  ///
  /// In en, this message translates to:
  /// **'The server had a problem while processing your request. You might want to try again'**
  String get errorServerHadAProblemProcessingYourRequest;

  /// No description provided for @errorSomethingWentWrongTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later'**
  String get errorSomethingWentWrongTryAgainLater;

  /// No description provided for @errorUnableToReachServer.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the server'**
  String get errorUnableToReachServer;

  /// No description provided for @errorUnableToReachServerAt.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the server at {url}'**
  String errorUnableToReachServerAt(String url);

  /// No description provided for @errorConnectionTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Connection has timed out'**
  String get errorConnectionTimedOut;

  /// No description provided for @errorNoCompatibleNextcloudAppsFound.
  ///
  /// In en, this message translates to:
  /// **'No compatible Nextcloud apps could be found.\nWe are working hard to implement more and more apps!'**
  String get errorNoCompatibleNextcloudAppsFound;

  /// No description provided for @errorServerInMaintenanceMode.
  ///
  /// In en, this message translates to:
  /// **'The server is in maintenance mode. Please try again later or contact the server admin.'**
  String get errorServerInMaintenanceMode;

  /// No description provided for @errorMissingPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission for {name} is missing'**
  String errorMissingPermission(String name);

  /// No description provided for @validatorEmptyField.
  ///
  /// In en, this message translates to:
  /// **'This field can not be empty'**
  String get validatorEmptyField;

  /// No description provided for @validatorInvalidURL.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL provided'**
  String get validatorInvalidURL;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @showSlashHide.
  ///
  /// In en, this message translates to:
  /// **'Show/Hide'**
  String get showSlashHide;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsForApp.
  ///
  /// In en, this message translates to:
  /// **'Settings - {name}'**
  String settingsForApp(String name);

  /// No description provided for @settingsForAccount.
  ///
  /// In en, this message translates to:
  /// **'Settings - {username}@{host}'**
  String settingsForAccount(String username, String host);

  /// No description provided for @settingsApps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get settingsApps;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export settings'**
  String get settingsExport;

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Import settings'**
  String get settingsImport;

  /// No description provided for @settingsImportWrongFileExtension.
  ///
  /// In en, this message translates to:
  /// **'Settings import has wrong file extension (has to be .json.base64)'**
  String get settingsImportWrongFileExtension;

  /// No description provided for @optionsCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get optionsCategoryGeneral;

  /// No description provided for @optionsCategoryTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get optionsCategoryTheme;

  /// No description provided for @optionsCategoryPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get optionsCategoryPushNotifications;

  /// No description provided for @optionsCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get optionsCategoryOther;

  /// No description provided for @optionsCategoryAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get optionsCategoryAccounts;

  /// No description provided for @optionsCategoryStartup.
  ///
  /// In en, this message translates to:
  /// **'Startup'**
  String get optionsCategoryStartup;

  /// No description provided for @optionsCategorySystemTray.
  ///
  /// In en, this message translates to:
  /// **'System tray'**
  String get optionsCategorySystemTray;

  /// No description provided for @optionsSortOrderAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get optionsSortOrderAscending;

  /// No description provided for @optionsSortOrderDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get optionsSortOrderDescending;

  /// No description provided for @globalOptionsThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get globalOptionsThemeMode;

  /// No description provided for @globalOptionsThemeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get globalOptionsThemeModeLight;

  /// No description provided for @globalOptionsThemeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get globalOptionsThemeModeDark;

  /// No description provided for @globalOptionsThemeModeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get globalOptionsThemeModeAutomatic;

  /// No description provided for @globalOptionsThemeOLEDAsDark.
  ///
  /// In en, this message translates to:
  /// **'OLED theme as dark theme'**
  String get globalOptionsThemeOLEDAsDark;

  /// No description provided for @globalOptionsPushNotificationsNotice.
  ///
  /// In en, this message translates to:
  /// **'External services are used for delivering push notifications. While the content is encrypted and can only be ready by this app, extracting metadata like the time and count of notifications is still possible.'**
  String get globalOptionsPushNotificationsNotice;

  /// No description provided for @globalOptionsPushNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get globalOptionsPushNotificationsEnabled;

  /// No description provided for @globalOptionsPushNotificationsEnabledDisabledNotice.
  ///
  /// In en, this message translates to:
  /// **'No UnifiedPush distributor could be found. Please go to https://unifiedpush.org/users/distributors and setup any of the listed distributors. Then re-open this app and you should be able to enable notifications'**
  String get globalOptionsPushNotificationsEnabledDisabledNotice;

  /// No description provided for @globalOptionsPushNotificationsDistributor.
  ///
  /// In en, this message translates to:
  /// **'UnifiedPush Distributor'**
  String get globalOptionsPushNotificationsDistributor;

  /// No description provided for @globalOptionsPushNotificationsDistributorGotifyUP.
  ///
  /// In en, this message translates to:
  /// **'Gotify-UP'**
  String get globalOptionsPushNotificationsDistributorGotifyUP;

  /// No description provided for @globalOptionsPushNotificationsDistributorFirebaseEmbedded.
  ///
  /// In en, this message translates to:
  /// **'Firebase (FOSS)'**
  String get globalOptionsPushNotificationsDistributorFirebaseEmbedded;

  /// No description provided for @globalOptionsPushNotificationsDistributorNtfy.
  ///
  /// In en, this message translates to:
  /// **'ntfy'**
  String get globalOptionsPushNotificationsDistributorNtfy;

  /// No description provided for @globalOptionsPushNotificationsDistributorFCMUP.
  ///
  /// In en, this message translates to:
  /// **'FCM-UP'**
  String get globalOptionsPushNotificationsDistributorFCMUP;

  /// No description provided for @globalOptionsPushNotificationsDistributorNextPush.
  ///
  /// In en, this message translates to:
  /// **'NextPush'**
  String get globalOptionsPushNotificationsDistributorNextPush;

  /// No description provided for @globalOptionsPushNotificationsDistributorNoProvider2Push.
  ///
  /// In en, this message translates to:
  /// **'NoProvider2Push'**
  String get globalOptionsPushNotificationsDistributorNoProvider2Push;

  /// No description provided for @globalOptionsStartupMinimized.
  ///
  /// In en, this message translates to:
  /// **'Start minimized'**
  String get globalOptionsStartupMinimized;

  /// No description provided for @globalOptionsStartupMinimizeInsteadOfExit.
  ///
  /// In en, this message translates to:
  /// **'Minimize instead of exit'**
  String get globalOptionsStartupMinimizeInsteadOfExit;

  /// No description provided for @globalOptionsSystemTrayEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable system tray'**
  String get globalOptionsSystemTrayEnabled;

  /// No description provided for @globalOptionsSystemTrayHideToTrayWhenMinimized.
  ///
  /// In en, this message translates to:
  /// **'Hide to system tray when minimized'**
  String get globalOptionsSystemTrayHideToTrayWhenMinimized;

  /// No description provided for @globalOptionsAccountsRememberLastUsedAccount.
  ///
  /// In en, this message translates to:
  /// **'Remember last used account'**
  String get globalOptionsAccountsRememberLastUsedAccount;

  /// No description provided for @globalOptionsAccountsRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the account {name} from {url}?'**
  String globalOptionsAccountsRemoveConfirm(String name, String url);

  /// No description provided for @globalOptionsAccountsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get globalOptionsAccountsAdd;

  /// No description provided for @accountOptionsInitialApp.
  ///
  /// In en, this message translates to:
  /// **'App to show initially'**
  String get accountOptionsInitialApp;

  /// No description provided for @accountOptionsAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get accountOptionsAutomatic;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @filesName.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get filesName;

  /// No description provided for @filesUploadFiles.
  ///
  /// In en, this message translates to:
  /// **'Upload files'**
  String get filesUploadFiles;

  /// No description provided for @filesUploadImages.
  ///
  /// In en, this message translates to:
  /// **'Upload images'**
  String get filesUploadImages;

  /// No description provided for @filesUploadCamera.
  ///
  /// In en, this message translates to:
  /// **'Upload from camera'**
  String get filesUploadCamera;

  /// No description provided for @filesCreateFolder.
  ///
  /// In en, this message translates to:
  /// **'Create folder'**
  String get filesCreateFolder;

  /// No description provided for @filesFolderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get filesFolderName;

  /// No description provided for @filesRenameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get filesRenameFolder;

  /// No description provided for @filesRenameFile.
  ///
  /// In en, this message translates to:
  /// **'Rename file'**
  String get filesRenameFile;

  /// No description provided for @filesDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get filesDetails;

  /// No description provided for @filesDetailsFileName.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get filesDetailsFileName;

  /// No description provided for @filesDetailsFolderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get filesDetailsFolderName;

  /// No description provided for @filesDetailsParentFolder.
  ///
  /// In en, this message translates to:
  /// **'Parent folder'**
  String get filesDetailsParentFolder;

  /// No description provided for @filesDetailsFileSize.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get filesDetailsFileSize;

  /// No description provided for @filesDetailsFolderSize.
  ///
  /// In en, this message translates to:
  /// **'Folder size'**
  String get filesDetailsFolderSize;

  /// No description provided for @filesDetailsLastModified.
  ///
  /// In en, this message translates to:
  /// **'Last modified'**
  String get filesDetailsLastModified;

  /// No description provided for @filesDetailsIsFavorite.
  ///
  /// In en, this message translates to:
  /// **'Is favorite'**
  String get filesDetailsIsFavorite;

  /// No description provided for @filesSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get filesSync;

  /// No description provided for @filesDeleteFileConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the file \'{name}\'?'**
  String filesDeleteFileConfirm(String name);

  /// No description provided for @filesDeleteFolderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the folder \'{name}\'?'**
  String filesDeleteFolderConfirm(String name);

  /// No description provided for @filesChooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get filesChooseFolder;

  /// No description provided for @filesAddToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get filesAddToFavorites;

  /// No description provided for @filesRemoveFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get filesRemoveFromFavorites;

  /// No description provided for @filesConfirmUploadSizeWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to upload a file that is bigger than {warningSize} ({actualSize})?'**
  String filesConfirmUploadSizeWarning(String warningSize, String actualSize);

  /// No description provided for @filesConfirmDownloadSizeWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to download a file that is bigger than {warningSize} ({actualSize})?'**
  String filesConfirmDownloadSizeWarning(String warningSize, String actualSize);

  /// No description provided for @filesOptionsShowPreviews.
  ///
  /// In en, this message translates to:
  /// **'Show previews for files'**
  String get filesOptionsShowPreviews;

  /// No description provided for @filesOptionsUploadQueueParallelism.
  ///
  /// In en, this message translates to:
  /// **'Upload queue parallelism'**
  String get filesOptionsUploadQueueParallelism;

  /// No description provided for @filesOptionsDownloadQueueParallelism.
  ///
  /// In en, this message translates to:
  /// **'Download queue parallelism'**
  String get filesOptionsDownloadQueueParallelism;

  /// No description provided for @filesOptionsUploadSizeWarning.
  ///
  /// In en, this message translates to:
  /// **'Upload size warning'**
  String get filesOptionsUploadSizeWarning;

  /// No description provided for @filesOptionsDownloadSizeWarning.
  ///
  /// In en, this message translates to:
  /// **'Download size warning'**
  String get filesOptionsDownloadSizeWarning;

  /// No description provided for @newsName.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get newsName;

  /// No description provided for @newsAddFeed.
  ///
  /// In en, this message translates to:
  /// **'Add feed'**
  String get newsAddFeed;

  /// No description provided for @newsFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get newsFolder;

  /// No description provided for @newsFolderRoot.
  ///
  /// In en, this message translates to:
  /// **'Root Folder'**
  String get newsFolderRoot;

  /// No description provided for @newsCreateFolder.
  ///
  /// In en, this message translates to:
  /// **'Create folder'**
  String get newsCreateFolder;

  /// No description provided for @newsCreateFolderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get newsCreateFolderName;

  /// No description provided for @newsDeleteFolderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the folder \'{name}\'?'**
  String newsDeleteFolderConfirm(String name);

  /// No description provided for @newsRenameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get newsRenameFolder;

  /// No description provided for @newsRemoveFeedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the feed \'{name}\'?'**
  String newsRemoveFeedConfirm(String name);

  /// No description provided for @newsMoveFeed.
  ///
  /// In en, this message translates to:
  /// **'Move feed'**
  String get newsMoveFeed;

  /// No description provided for @newsRenameFeed.
  ///
  /// In en, this message translates to:
  /// **'Rename feed'**
  String get newsRenameFeed;

  /// No description provided for @newsArticles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get newsArticles;

  /// No description provided for @newsFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get newsFolders;

  /// No description provided for @newsFeeds.
  ///
  /// In en, this message translates to:
  /// **'Feeds'**
  String get newsFeeds;

  /// No description provided for @newsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get newsFilterAll;

  /// No description provided for @newsFilterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get newsFilterUnread;

  /// No description provided for @newsFilterStarred.
  ///
  /// In en, this message translates to:
  /// **'Starred'**
  String get newsFilterStarred;

  /// No description provided for @newsUnreadArticles.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String newsUnreadArticles(int count);

  /// No description provided for @newsShowFeedURL.
  ///
  /// In en, this message translates to:
  /// **'Show URL'**
  String get newsShowFeedURL;

  /// No description provided for @newsCopyFeedURL.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get newsCopyFeedURL;

  /// No description provided for @newsCopiedFeedURL.
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard'**
  String get newsCopiedFeedURL;

  /// No description provided for @newsCopyFeedErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy error message'**
  String get newsCopyFeedErrorMessage;

  /// No description provided for @newsCopiedFeedErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error message copied to clipboard'**
  String get newsCopiedFeedErrorMessage;

  /// No description provided for @newsOptionsDefaultCategory.
  ///
  /// In en, this message translates to:
  /// **'Category to show by default'**
  String get newsOptionsDefaultCategory;

  /// No description provided for @newsOptionsArticleViewType.
  ///
  /// In en, this message translates to:
  /// **'How to open article'**
  String get newsOptionsArticleViewType;

  /// No description provided for @newsOptionsArticleViewTypeDirect.
  ///
  /// In en, this message translates to:
  /// **'Show text directly'**
  String get newsOptionsArticleViewTypeDirect;

  /// No description provided for @newsOptionsArticleViewTypeInternalBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in internal browser'**
  String get newsOptionsArticleViewTypeInternalBrowser;

  /// No description provided for @newsOptionsArticleViewTypeExternalBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in external browser'**
  String get newsOptionsArticleViewTypeExternalBrowser;

  /// No description provided for @newsOptionsDefaultArticlesFilter.
  ///
  /// In en, this message translates to:
  /// **'Articles to show by default'**
  String get newsOptionsDefaultArticlesFilter;

  /// No description provided for @newsOptionsArticlesSortProperty.
  ///
  /// In en, this message translates to:
  /// **'How to sort articles'**
  String get newsOptionsArticlesSortProperty;

  /// No description provided for @newsOptionsArticlesSortPropertyPublishDate.
  ///
  /// In en, this message translates to:
  /// **'Publish date'**
  String get newsOptionsArticlesSortPropertyPublishDate;

  /// No description provided for @newsOptionsArticlesSortPropertyAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get newsOptionsArticlesSortPropertyAlphabetical;

  /// No description provided for @newsOptionsArticlesSortPropertyFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get newsOptionsArticlesSortPropertyFeed;

  /// No description provided for @newsOptionsArticlesSortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort order of articles'**
  String get newsOptionsArticlesSortOrder;

  /// No description provided for @newsOptionsFeedsSortProperty.
  ///
  /// In en, this message translates to:
  /// **'How to sort feeds'**
  String get newsOptionsFeedsSortProperty;

  /// No description provided for @newsOptionsFeedsSortPropertyAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get newsOptionsFeedsSortPropertyAlphabetical;

  /// No description provided for @newsOptionsFeedsSortPropertyUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'Unread count'**
  String get newsOptionsFeedsSortPropertyUnreadCount;

  /// No description provided for @newsOptionsFeedsSortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort order of feeds'**
  String get newsOptionsFeedsSortOrder;

  /// No description provided for @newsOptionsFoldersSortProperty.
  ///
  /// In en, this message translates to:
  /// **'How to sort folders'**
  String get newsOptionsFoldersSortProperty;

  /// No description provided for @newsOptionsFoldersSortPropertyAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get newsOptionsFoldersSortPropertyAlphabetical;

  /// No description provided for @newsOptionsFoldersSortPropertyUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'Unread count'**
  String get newsOptionsFoldersSortPropertyUnreadCount;

  /// No description provided for @newsOptionsFoldersSortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort order of folders'**
  String get newsOptionsFoldersSortOrder;

  /// No description provided for @newsOptionsDefaultFolderViewType.
  ///
  /// In en, this message translates to:
  /// **'What should be shown first when opening a folder'**
  String get newsOptionsDefaultFolderViewType;

  /// No description provided for @notesName.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesName;

  /// No description provided for @notesNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get notesNote;

  /// No description provided for @notesNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesNotes;

  /// No description provided for @notesCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get notesCategories;

  /// No description provided for @notesCreateNote.
  ///
  /// In en, this message translates to:
  /// **'Create note'**
  String get notesCreateNote;

  /// No description provided for @notesCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get notesCategory;

  /// No description provided for @notesChangeCategory.
  ///
  /// In en, this message translates to:
  /// **'Change category'**
  String get notesChangeCategory;

  /// No description provided for @notesSetCategory.
  ///
  /// In en, this message translates to:
  /// **'Set category'**
  String get notesSetCategory;

  /// No description provided for @notesNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notesNoteTitle;

  /// No description provided for @notesNoteChangedOnServer.
  ///
  /// In en, this message translates to:
  /// **'The note has been changed on the server. Please refresh and try again'**
  String get notesNoteChangedOnServer;

  /// No description provided for @notesNotesInCategory.
  ///
  /// In en, this message translates to:
  /// **'{count} notes'**
  String notesNotesInCategory(int count);

  /// No description provided for @notesUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get notesUncategorized;

  /// No description provided for @notesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get notesEdit;

  /// No description provided for @notesPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get notesPreview;

  /// No description provided for @notesDeleteNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the note \'{name}\'?'**
  String notesDeleteNoteConfirm(String name);

  /// No description provided for @notesOptionsDefaultCategory.
  ///
  /// In en, this message translates to:
  /// **'Category to show by default'**
  String get notesOptionsDefaultCategory;

  /// No description provided for @notesOptionsDefaultNoteViewType.
  ///
  /// In en, this message translates to:
  /// **'How to show note'**
  String get notesOptionsDefaultNoteViewType;

  /// No description provided for @notesOptionsDefaultNoteViewTypePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get notesOptionsDefaultNoteViewTypePreview;

  /// No description provided for @notesOptionsDefaultNoteViewTypeEdit.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get notesOptionsDefaultNoteViewTypeEdit;

  /// No description provided for @notesOptionsNotesSortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort order of notes'**
  String get notesOptionsNotesSortOrder;

  /// No description provided for @notesOptionsNotesSortProperty.
  ///
  /// In en, this message translates to:
  /// **'How to sort notes'**
  String get notesOptionsNotesSortProperty;

  /// No description provided for @notesOptionsNotesSortPropertyLastModified.
  ///
  /// In en, this message translates to:
  /// **'Last modified'**
  String get notesOptionsNotesSortPropertyLastModified;

  /// No description provided for @notesOptionsNotesSortPropertyAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get notesOptionsNotesSortPropertyAlphabetical;

  /// No description provided for @notesOptionsCategoriesSortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort order of categories'**
  String get notesOptionsCategoriesSortOrder;

  /// No description provided for @notesOptionsCategoriesSortProperty.
  ///
  /// In en, this message translates to:
  /// **'How to sort categories'**
  String get notesOptionsCategoriesSortProperty;

  /// No description provided for @notesOptionsCategoriesSortPropertyAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get notesOptionsCategoriesSortPropertyAlphabetical;

  /// No description provided for @notesOptionsCategoriesSortPropertyNotesCount.
  ///
  /// In en, this message translates to:
  /// **'Count of notes'**
  String get notesOptionsCategoriesSortPropertyNotesCount;

  /// No description provided for @notificationsName.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsName;

  /// No description provided for @notificationsNextcloudAppNotImplementedYet.
  ///
  /// In en, this message translates to:
  /// **'Sorry, this Nextcloud app has not been implemented yet'**
  String get notificationsNextcloudAppNotImplementedYet;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
