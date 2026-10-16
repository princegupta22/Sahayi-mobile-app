import '../l10n/app_language.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _weekdaysEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _weekdaysMl = ['തിങ്കൾ', 'ചൊവ്വ', 'ബുധൻ', 'വ്യാഴം', 'വെള്ളി', 'ശനി', 'ഞായർ'];

String formatChatTime(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.hour >= 12 ? 'PM' : 'AM'}';
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

int _daysAgo(DateTime t) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day)
      .difference(DateTime(t.year, t.month, t.day))
      .inDays;
}

String _yesterday(AppLanguage lang) =>
    lang == AppLanguage.malayalam ? 'ഇന്നലെ' : 'Yesterday';

/// Day separator in a chat, like WhatsApp: "Today", "Yesterday",
/// a weekday within the last week, otherwise "12 Oct 2026".
String formatDayLabel(DateTime t, AppLanguage lang) {
  final diff = _daysAgo(t);
  final ml = lang == AppLanguage.malayalam;
  if (diff <= 0) return ml ? 'ഇന്ന്' : 'Today';
  if (diff == 1) return _yesterday(lang);
  if (diff < 7) return (ml ? _weekdaysMl : _weekdaysEn)[t.weekday - 1];
  return '${t.day} ${_months[t.month - 1]} ${t.year}';
}

/// Inbox time: "9:41 AM" today, "Yesterday", weekday within a week,
/// otherwise "12 Oct" (with the year if it isn't this year).
String formatInboxTime(DateTime t, [AppLanguage lang = AppLanguage.english]) {
  final diff = _daysAgo(t);
  if (diff <= 0) return formatChatTime(t);
  if (diff == 1) return _yesterday(lang);
  if (diff < 7) {
    final name = (lang == AppLanguage.malayalam ? _weekdaysMl : _weekdaysEn)[t.weekday - 1];
    return lang == AppLanguage.malayalam ? name : name.substring(0, 3);
  }
  final sameYear = t.year == DateTime.now().year;
  return '${t.day} ${_months[t.month - 1]}${sameYear ? '' : ' ${t.year}'}';
}
