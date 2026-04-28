class UploadConfig {
  static const String gitOwner = 'shenfangqi123';
  static const String gitRepo = 'flutter_resume';
  static const String gitRef = 'master';
  static const String remoteBaseUrl =
      'https://cdn.jsdelivr.net/gh/$gitOwner/$gitRepo@$gitRef/';

  static const String presentationKey =
      'public/content/resume_presentation.json';
  static const String uploadsPrefix = 'public/products';
  static const String eventsKey = 'public/content/resume_events.json';
  static const String timelineKey = 'public/content/resume_timeline.json';
  static const String unsplashKey = 'public/content/resume_unsplash.json';

  static String remoteUrlFor(String path) => '$remoteBaseUrl$path';
}
