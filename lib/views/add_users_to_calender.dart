// import 'package:flutter/material.dart';
// import 'package:todolist/views/calender_page_view.dart';

// class AddUserstoCalenderScreen extends StatefulWidget {
//   const AddUserstoCalenderScreen({super.key});

//   @override
//   State<AddUserstoCalenderScreen> createState() =>
//       _AddUserstoCalenderScreenState();
// }

// class _AddUserstoCalenderScreenState extends State<AddUserstoCalenderScreen> {
//   List<TextEditingController> controllers = [];
//   List<TextField> textFields = [];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           List<String> emails =
//               controllers.map((controller) => controller.text).toList();

//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => CalenderViewPage(emails: emails),
//             ),
//           );
//         },
//         child: const Text("Add Event"),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             ListTile(
//               title: const Text('Add Email'),
//               trailing: const Icon(Icons.add),
//               onTap: () {
//                 print("Controllers length: ${controllers.length}");
//                 setState(() {
//                   TextEditingController controller = TextEditingController();
//                   controllers.add(controller);

//                   textFields.add(TextField(controller: controller));
//                 });
//               },
//             ),
//             ListView.builder(
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: textFields[index],
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete),
//                     onPressed: () {
//                       setState(() {
//                         controllers.removeAt(index);
//                         textFields.removeAt(index);
//                       });
//                     },
//                   ),
//                 );
//               },
//               itemCount: controllers.length,
//               shrinkWrap: true,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
