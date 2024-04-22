class PriorityApiModel {
  String? priority;
  List<String>? steps;

  PriorityApiModel({this.priority, this.steps});

  PriorityApiModel.fromJson(Map<String, dynamic> json) {
    priority = json['priority'];
    steps = json['steps'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['priority'] = this.priority;
    data['steps'] = this.steps;
    return data;
  }
}
