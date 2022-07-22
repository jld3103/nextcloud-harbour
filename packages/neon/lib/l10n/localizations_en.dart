


import 'localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nextcloud Neon';

  @override
  String get loginAccountAlreadyExists => 'The account you are trying to add already exists';

  @override
  String get loginAgain => 'Login again';

  @override
  String get loginOpenAgain => 'Open again';

  @override
  String get loginSwitchToBrowserWindow => 'Please switch to the browser window that just opened and proceed there';

  @override
  String get loginWorksWith => 'works with';

  @override
  String get errorCredentialsForAccountNoLongerMatch => 'The credentials for this account no longer match';

  @override
  String get errorServerHadAProblemProcessingYourRequest => 'The server had a problem while processing your request. You might want to try again';

  @override
  String get errorSomethingWentWrongTryAgainLater => 'Something went wrong. Please try again later';

  @override
  String get errorUnableToReachServer => 'Unable to reach the server';

  @override
  String errorUnableToReachServerAt(String url) {
    return 'Unable to reach the server at $url';
  }

  @override
  String get errorConnectionTimedOut => 'Connection has timed out';

  @override
  String get errorNoCompatibleNextcloudAppsFound => 'No compatible Nextcloud apps could be found.\nWe are working hard to implement more and more apps!';

  @override
  String get errorServerInMaintenanceMode => 'The server is in maintenance mode. Please try again later or contact the server admin.';

  @override
  String errorMissingPermission(String name) {
    return 'Permission for $name is missing';
  }

  @override
  String get validatorEmptyField => 'This field can not be empty';

  @override
  String get validatorInvalidURL => 'Invalid URL provided';

  @override
  String get delete => 'Delete';

  @override
  String get remove => 'Remove';

  @override
  String get rename => 'Rename';

  @override
  String get move => 'Move';

  @override
  String get copy => 'Copy';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get showSlashHide => 'Show/Hide';

  @override
  String get exit => 'Exit';

  @override
  String get disabled => 'Disabled';

  @override
  String get settings => 'Settings';

  @override
  String settingsForApp(String name) {
    return 'Settings - $name';
  }

  @override
  String settingsForAccount(String username, String host) {
    return 'Settings - $username@$host';
  }

  @override
  String get settingsApps => 'Apps';

  @override
  String get settingsExport => 'Export settings';

  @override
  String get settingsImport => 'Import settings';

  @override
  String get settingsImportWrongFileExtension => 'Settings import has wrong file extension (has to be .json.base64)';

  @override
  String get optionsCategoryGeneral => 'General';

  @override
  String get optionsCategoryTheme => 'Theme';

  @override
  String get optionsCategoryPushNotifications => 'Push notifications';

  @override
  String get optionsCategoryOther => 'Other';

  @override
  String get optionsCategoryAccounts => 'Accounts';

  @override
  String get optionsCategoryStartup => 'Startup';

  @override
  String get optionsCategorySystemTray => 'System tray';

  @override
  String get optionsSortOrderAscending => 'Ascending';

  @override
  String get optionsSortOrderDescending => 'Descending';

  @override
  String get globalOptionsThemeMode => 'Theme mode';

  @override
  String get globalOptionsThemeModeLight => 'Light';

  @override
  String get globalOptionsThemeModeDark => 'Dark';

  @override
  String get globalOptionsThemeModeAutomatic => 'Automatic';

  @override
  String get globalOptionsThemeOLEDAsDark => 'OLED theme as dark theme';

  @override
  String get globalOptionsPushNotificationsNotice =>
      'External services are used for delivering push notifications. While the content is encrypted and can only be ready by this app, extracting metadata like the time and count of notifications is still possible.';

  @override
  String get globalOptionsPushNotificationsEnabled => 'Enabled';

  @override
  String get globalOptionsPushNotificationsEnabledDisabledNotice =>
      'No UnifiedPush distributor could be found. Please go to https://unifiedpush.org/users/distributors and setup any of the listed distributors. Then re-open this app and you should be able to enable notifications';

  @override
  String get globalOptionsPushNotificationsDistributor => 'UnifiedPush Distributor';

  @override
  String get globalOptionsPushNotificationsDistributorGotifyUP => 'Gotify-UP';

  @override
  String get globalOptionsPushNotificationsDistributorFirebaseEmbedded => 'Firebase (FOSS)';

  @override
  String get globalOptionsPushNotificationsDistributorNtfy => 'ntfy';

  @override
  String get globalOptionsPushNotificationsDistributorFCMUP => 'FCM-UP';

  @override
  String get globalOptionsPushNotificationsDistributorNextPush => 'NextPush';

  @override
  String get globalOptionsPushNotificationsDistributorNoProvider2Push => 'NoProvider2Push';

  @override
  String get globalOptionsStartupMinimized => 'Start minimized';

  @override
  String get globalOptionsStartupMinimizeInsteadOfExit => 'Minimize instead of exit';

  @override
  String get globalOptionsSystemTrayEnabled => 'Enable system tray';

  @override
  String get globalOptionsSystemTrayHideToTrayWhenMinimized => 'Hide to system tray when minimized';

  @override
  String get globalOptionsAccountsRememberLastUsedAccount => 'Remember last used account';

  @override
  String globalOptionsAccountsRemoveConfirm(String name, String url) {
    return 'Are you sure you want to remove the account $name from $url?';
  }

  @override
  String get globalOptionsAccountsAdd => 'Add account';

  @override
  String get accountOptionsInitialApp => 'App to show initially';

  @override
  String get accountOptionsAutomatic => 'Automatic';

  @override
  String get licenses => 'Licenses';

  @override
  String get filesName => 'Files';

  @override
  String get filesUploadFiles => 'Upload files';

  @override
  String get filesUploadImages => 'Upload images';

  @override
  String get filesUploadCamera => 'Upload from camera';

  @override
  String get filesCreateFolder => 'Create folder';

  @override
  String get filesFolderName => 'Folder name';

  @override
  String get filesRenameFolder => 'Rename folder';

  @override
  String get filesRenameFile => 'Rename file';

  @override
  String get filesDetails => 'Details';

  @override
  String get filesDetailsFileName => 'File name';

  @override
  String get filesDetailsFolderName => 'Folder name';

  @override
  String get filesDetailsParentFolder => 'Parent folder';

  @override
  String get filesDetailsFileSize => 'File size';

  @override
  String get filesDetailsFolderSize => 'Folder size';

  @override
  String get filesDetailsLastModified => 'Last modified';

  @override
  String get filesDetailsIsFavorite => 'Is favorite';

  @override
  String get filesSync => 'Sync';

  @override
  String filesDeleteFileConfirm(String name) {
    return 'Are you sure you want to delete the file \'$name\'?';
  }

  @override
  String filesDeleteFolderConfirm(String name) {
    return 'Are you sure you want to delete the folder \'$name\'?';
  }

  @override
  String get filesChooseFolder => 'Choose folder';

  @override
  String get filesAddToFavorites => 'Add to favorites';

  @override
  String get filesRemoveFromFavorites => 'Remove from favorites';

  @override
  String filesConfirmUploadSizeWarning(String warningSize, String actualSize) {
    return 'Are you sure you want to upload a file that is bigger than $warningSize ($actualSize)?';
  }

  @override
  String filesConfirmDownloadSizeWarning(String warningSize, String actualSize) {
    return 'Are you sure you want to download a file that is bigger than $warningSize ($actualSize)?';
  }

  @override
  String get filesOptionsShowPreviews => 'Show previews for files';

  @override
  String get filesOptionsUploadQueueParallelism => 'Upload queue parallelism';

  @override
  String get filesOptionsDownloadQueueParallelism => 'Download queue parallelism';

  @override
  String get filesOptionsUploadSizeWarning => 'Upload size warning';

  @override
  String get filesOptionsDownloadSizeWarning => 'Download size warning';

  @override
  String get newsName => 'News';

  @override
  String get newsAddFeed => 'Add feed';

  @override
  String get newsFolder => 'Folder';

  @override
  String get newsFolderRoot => 'Root Folder';

  @override
  String get newsCreateFolder => 'Create folder';

  @override
  String get newsCreateFolderName => 'Folder name';

  @override
  String newsDeleteFolderConfirm(String name) {
    return 'Are you sure you want to delete the folder \'$name\'?';
  }

  @override
  String get newsRenameFolder => 'Rename folder';

  @override
  String newsRemoveFeedConfirm(String name) {
    return 'Are you sure you want to remove the feed \'$name\'?';
  }

  @override
  String get newsMoveFeed => 'Move feed';

  @override
  String get newsRenameFeed => 'Rename feed';

  @override
  String get newsArticles => 'Articles';

  @override
  String get newsFolders => 'Folders';

  @override
  String get newsFeeds => 'Feeds';

  @override
  String get newsFilterAll => 'All';

  @override
  String get newsFilterUnread => 'Unread';

  @override
  String get newsFilterStarred => 'Starred';

  @override
  String newsUnreadArticles(int count) {
    return '$count unread';
  }

  @override
  String get newsShowFeedURL => 'Show URL';

  @override
  String get newsCopyFeedURL => 'Copy URL';

  @override
  String get newsCopiedFeedURL => 'URL copied to clipboard';

  @override
  String get newsCopyFeedErrorMessage => 'Copy error message';

  @override
  String get newsCopiedFeedErrorMessage => 'Error message copied to clipboard';

  @override
  String get newsOptionsDefaultCategory => 'Category to show by default';

  @override
  String get newsOptionsArticleViewType => 'How to open article';

  @override
  String get newsOptionsArticleViewTypeDirect => 'Show text directly';

  @override
  String get newsOptionsArticleViewTypeInternalBrowser => 'Open in internal browser';

  @override
  String get newsOptionsArticleViewTypeExternalBrowser => 'Open in external browser';

  @override
  String get newsOptionsDefaultArticlesFilter => 'Articles to show by default';

  @override
  String get newsOptionsArticlesSortProperty => 'How to sort articles';

  @override
  String get newsOptionsArticlesSortPropertyPublishDate => 'Publish date';

  @override
  String get newsOptionsArticlesSortPropertyAlphabetical => 'Alphabetical';

  @override
  String get newsOptionsArticlesSortPropertyFeed => 'Feed';

  @override
  String get newsOptionsArticlesSortOrder => 'Sort order of articles';

  @override
  String get newsOptionsFeedsSortProperty => 'How to sort feeds';

  @override
  String get newsOptionsFeedsSortPropertyAlphabetical => 'Alphabetical';

  @override
  String get newsOptionsFeedsSortPropertyUnreadCount => 'Unread count';

  @override
  String get newsOptionsFeedsSortOrder => 'Sort order of feeds';

  @override
  String get newsOptionsFoldersSortProperty => 'How to sort folders';

  @override
  String get newsOptionsFoldersSortPropertyAlphabetical => 'Alphabetical';

  @override
  String get newsOptionsFoldersSortPropertyUnreadCount => 'Unread count';

  @override
  String get newsOptionsFoldersSortOrder => 'Sort order of folders';

  @override
  String get newsOptionsDefaultFolderViewType => 'What should be shown first when opening a folder';

  @override
  String get notesName => 'Notes';

  @override
  String get notesNote => 'Note';

  @override
  String get notesNotes => 'Notes';

  @override
  String get notesCategories => 'Categories';

  @override
  String get notesCreateNote => 'Create note';

  @override
  String get notesCategory => 'Category';

  @override
  String get notesChangeCategory => 'Change category';

  @override
  String get notesSetCategory => 'Set category';

  @override
  String get notesNoteTitle => 'Title';

  @override
  String get notesNoteChangedOnServer => 'The note has been changed on the server. Please refresh and try again';

  @override
  String notesNotesInCategory(int count) {
    return '$count notes';
  }

  @override
  String get notesUncategorized => 'Uncategorized';

  @override
  String get notesEdit => 'Edit';

  @override
  String get notesPreview => 'Preview';

  @override
  String notesDeleteNoteConfirm(String name) {
    return 'Are you sure you want to delete the note \'$name\'?';
  }

  @override
  String get notesOptionsDefaultCategory => 'Category to show by default';

  @override
  String get notesOptionsDefaultNoteViewType => 'How to show note';

  @override
  String get notesOptionsDefaultNoteViewTypePreview => 'Preview';

  @override
  String get notesOptionsDefaultNoteViewTypeEdit => 'Editor';

  @override
  String get notesOptionsNotesSortOrder => 'Sort order of notes';

  @override
  String get notesOptionsNotesSortProperty => 'How to sort notes';

  @override
  String get notesOptionsNotesSortPropertyLastModified => 'Last modified';

  @override
  String get notesOptionsNotesSortPropertyAlphabetical => 'Alphabetical';

  @override
  String get notesOptionsCategoriesSortOrder => 'Sort order of categories';

  @override
  String get notesOptionsCategoriesSortProperty => 'How to sort categories';

  @override
  String get notesOptionsCategoriesSortPropertyAlphabetical => 'Alphabetical';

  @override
  String get notesOptionsCategoriesSortPropertyNotesCount => 'Count of notes';

  @override
  String get notificationsName => 'Notifications';

  @override
  String get notificationsNextcloudAppNotImplementedYet => 'Sorry, this Nextcloud app has not been implemented yet';
}
