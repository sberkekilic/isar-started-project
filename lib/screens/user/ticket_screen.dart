import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../blocs/settings/settings_cubit.dart';

class TicketScreen extends StatefulWidget {
  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  List<dynamic> tickets = []; // List to store the fetched tickets
  List<int> selectedTicketIds = []; // List to store the IDs of selected tickets
  bool isEditing = false; // Flag to indicate if editing mode is enabled

  @override
  void initState() {
    super.initState();
    fetchTickets(); // Fetch tickets when the screen initializes
  }

  Future<void> fetchTickets() async {
    final url = 'https://api.qline.app/api/tickets/';
    final settings = context.read<SettingsCubit>();
    final bearerToken = settings.state.userInfo[3];

    // Replace 'YOUR_BEARER_TOKEN' with the actual bearer token
    final headers = {'Authorization': 'Bearer $bearerToken'};

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          tickets = responseBody;
        });
      } else {
        // Handle error response
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or server errors
      print('Error: $e');
    }
  }

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;
      // Clear the selected ticket IDs when exiting editing mode
      if (!isEditing) {
        if (selectedTicketIds.isNotEmpty) {
          selectedTicketIds.clear();
        }
      }
    });
  }


  void selectTicket(int ticketId) {
    setState(() {
      // Add or remove the selected ticket ID based on its current state
      if (selectedTicketIds.contains(ticketId)) {
        selectedTicketIds.remove(ticketId);
      } else {
        selectedTicketIds.add(ticketId);
      }
    });
  }

  Future<void> removeSelectedTickets() async {
    final url = 'https://api.qline.app/api/tickets/close';
    final settings = context.read<SettingsCubit>();
    final bearerToken = settings.state.userInfo[3]; // Retrieve the bearer token

    final headers = {'Authorization': 'Bearer $bearerToken'};

    try {
      for (final ticketId in selectedTicketIds) {
        final body = {'id': ticketId.toString()};
        final response = await http.post(Uri.parse(url), headers: headers, body: body);

        if (response.statusCode == 200) {
          // Ticket deleted successfully
          setState(() {
            // Remove the deleted ticket from the tickets list
            tickets.removeWhere((ticket) => ticket['id'] == ticketId);
          });
        } else {
          // Handle error response
          print('Error deleting ticket $ticketId: ${response.statusCode}');
        }
      }

      // Clear the selected ticket IDs after deleting
      selectedTicketIds.clear();
      fetchTickets();
    } catch (e) {
      // Handle network or server errors
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket Screen'),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: removeSelectedTickets,
              child: Text(
                'Remove',
                style: TextStyle(color: Colors.white),
              ),
            ),
          TextButton(

            child: Text(
                isEditing
                    ? "Done"
                    : "Select",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: toggleEditing,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (BuildContext context, int index) {
          final ticket = tickets[index];
          final ticketId = ticket['id'];
          final isSelected = selectedTicketIds.contains(ticketId);
          return ListTile(
            title: Text(ticket['title']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('id: ${ticket['id']}'),
                Text('topic: ${ticket['topic']}'),
                Text('Status: ${ticket['status']}'),
                Text('Created At: ${ticket['created_at']}'),
                Text('Updated At: ${ticket['updated_at']}'),
              ],
            ),
            onTap: () {
              if (isEditing) {
                selectTicket(ticketId);
              } else {
                // Handle ticket tap for viewing or editing
                // Navigate to the ticket details or edit screen
              }
            },
            tileColor: isSelected ? Colors.grey : null,
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'reply',
            onPressed: () {
              final selectedTicketId = selectedTicketIds.isNotEmpty ? selectedTicketIds.first : null;
              if (selectedTicketId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReplyTicketScreen(ticketId: selectedTicketId),
                  ),
                ).then((value) {
                  // Handle any necessary actions after returning from ReplyTicketScreen
                });
              } else {
                // Show a message to the user indicating that no ticket is selected
              }
            },
            child: Icon(Icons.reply_outlined),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTicketScreen()),
              ).then((value) {
                // Handle any necessary actions after returning from AddTicketScreen
              });
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

// Placeholder screen to add a ticket
class AddTicketScreen extends StatefulWidget {

  @override
  _AddTicketScreenState createState() => _AddTicketScreenState();
}

class _AddTicketScreenState extends State<AddTicketScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController topicController = TextEditingController();

  void createTicket() async {
    final createUrl = 'https://api.qline.app/api/tickets/';
    final settings = context.read<SettingsCubit>();
    final bearerToken = settings.state.userInfo[3]; // Retrieve the bearer token

    final headers = {'Authorization': 'Bearer $bearerToken'};
    final body = {
      'title': titleController.text,
      'message': messageController.text,
      'topic': topicController.text,
    };

    try {
      final response = await http.post(Uri.parse(createUrl), headers: headers, body: body);

      if (response.statusCode == 301) {
        final redirectUrl = response.headers['location'];

        if (redirectUrl != null) {
          final redirectedResponse = await http.post(Uri.parse(redirectUrl), headers: headers, body: body);
          if (redirectedResponse.statusCode == 200) {
            // Ticket created successfully
            Navigator.pop(context); // Go back to the previous screen
          } else {
            // Handle error response
            print('Error: ${redirectedResponse.statusCode}');
          }
        } else {
          print('Error: Redirect URL not found');
        }
      } else if (response.statusCode == 200) {
        // Ticket created successfully
        Navigator.pop(context); // Go back to the previous screen
      } else {
        // Handle error response
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or server errors
      print('Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Message',
              ),
            ),
            TextField(
              controller: topicController,
              decoration: InputDecoration(
                labelText: 'Topic',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                createTicket();
                Navigator.pop(context);
              },
              child: Text('Create Ticket'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReplyTicketScreen extends StatefulWidget {
  final int ticketId;

  const ReplyTicketScreen({required this.ticketId});

  @override
  State<ReplyTicketScreen> createState() => _ReplyTicketScreenState();
}

class _ReplyTicketScreenState extends State<ReplyTicketScreen> {
  final TextEditingController messageController = TextEditingController();

  void replyToTicket() async {
    final url = 'https://api.qline.app/api/tickets/respond';
    final settings = context.read<SettingsCubit>();
    final bearerToken = settings.state.userInfo[3]; // Retrieve the bearer token

    final headers = {'Authorization': 'Bearer $bearerToken'};
    final body = {
      'message': messageController.text,
      '_method': 'POST',
      'id': widget.ticketId.toString(),
    };

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        // Ticket replied successfully
        // Perform any necessary actions or show a success message
        Navigator.pop(context); // Go back to the previous screen
      } else {
        // Handle error response
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or server errors
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reply Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: messageController,
              decoration: InputDecoration(labelText: 'Message'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: replyToTicket,
              child: Text('Reply'),
            ),
          ],
        ),
      ),
    );
  }
}

