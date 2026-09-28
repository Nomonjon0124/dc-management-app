/// Parses meeting schedule values as the wall-clock time returned by the API.
///
/// Meeting `start_time` is a scheduled local time. Some API responses include
/// a `Z` or `+05:00` suffix even though the value is already expressed in the
/// organisation's local timezone. [DateTime.parse] would normalize that value
/// to UTC and shift the displayed schedule by five hours, so the timezone
/// suffix is intentionally ignored here.
DateTime? parseMeetingWallClock(dynamic value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return null;

  final wallClock = raw.replaceFirst(
    RegExp(r'(?:Z|[+-]\d{2}:?\d{2})$', caseSensitive: false),
    '',
  );
  return DateTime.tryParse(wallClock) ?? DateTime.tryParse(raw);
}
