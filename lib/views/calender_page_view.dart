
import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class CalenderViewPage extends StatefulWidget {
  CalenderViewPage({Key? key}) : super(key: key);

  @override
  _CalenderViewPageState createState() => _CalenderViewPageState();
}

class _CalenderViewPageState extends State<CalenderViewPage> {
  List<TextEditingController> controllers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add event to calendar example'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Add normal event'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              List<String> emails = await controllers
                  .map((controller) => controller.text)
                  .toList();

              Add2Calendar.addEvent2Cal(
                buildEvent(emails: emails),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Add Email'),
            trailing: const Icon(Icons.add),
            onTap: () {
              setState(() {
                TextEditingController controller = TextEditingController();
                controllers.add(controller);
              });
            },
          ),
          ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: TextField(controller: controllers[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      controllers.removeAt(index);
                    });
                  },
                ),
              );
            },
            itemCount: controllers.length,
            shrinkWrap: true,
          ),
        ],
      ),
    );
  }

  Event buildEvent({List<String>? emails}) {
    return Event(
      title: 'Test event',
      description: 'example',
      location: 'Flutter app',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(minutes: 30)),
      allDay: false,
      iosParams: const IOSParams(
        reminder: Duration(minutes: 40),
        url: "http://example.com",
      ),
      androidParams: AndroidParams(
        emailInvites: emails!,
      ),
    );
  }
}
