class NotificationsModel {
  String? title;
  DateTime? time;
  NotificationsModel({this.title, this.time});

  NotificationsModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        time = json['time'] != null ? DateTime.parse(json['time']) : null;
}
