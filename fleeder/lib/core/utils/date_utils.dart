class DisplayDateUtils {
  // Utility methods for date formatting can be added here

  // 2:05 PM · January 1, 2024
  static String displayDate(DateTime date) {
    int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    String minute = date.minute.toString().padLeft(2, '0');
    String period = date.hour < 12 ? 'AM' : 'PM';
    List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    String monthWord = months[date.month - 1];
    String dateStr = "$monthWord ${date.day}, ${date.year}";
    return "$hour:$minute $period · $dateStr";
  }

  // now, 30m, 2h, 5d, 3w, 4m, 1y
  static String displayTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}m';
    } else {
      return '${(difference.inDays / 365).floor()}y';
    }
  }
}
