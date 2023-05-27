import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../blocs/settings/settings_cubit.dart';
import '../../localizations/localizations.dart';

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
          tickets = responseBody
              .map((ticket) => {...ticket, 'isSelected': false})
              .toList();
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
    });
    if (!isEditing) {
      // Clear the selected ticket IDs when exiting editing mode
      selectedTicketIds.clear();
      // Reset the tile color for all tickets
      for (final ticket in tickets) {
        ticket['isSelected'] = false;
      }
    }
  }

  void selectTicket(int? ticketId) {
    setState(() {
      // Update the isSelected property for each ticket
      for (final ticket in tickets) {
        ticket['isSelected'] = (ticket['id'] == ticketId);
      }
    });
    // Update the selectedTicketIds list
    selectedTicketIds.clear();
    if (isEditing && ticketId != null) {
      selectedTicketIds.add(ticketId);
    } else {
      selectedTicketIds.clear();
    }
  }

  void resetTileColor(int ticketId) {
    // Find the index of the ticket in the tickets list
    final index = tickets.indexWhere((ticket) => ticket['id'] == ticketId);
    if (index != -1) {
      // Reset the tile color to its original state
      setState(() {
        tickets[index]['isSelected'] = false;
      });
    }
  }

  Future<void> removeSelectedTickets() async {
    final url = 'https://api.qline.app/api/tickets/close';
    final settings = context.read<SettingsCubit>();
    final bearerToken = settings.state.userInfo[3]; // Retrieve the bearer token
    final headers = {'Authorization': 'Bearer $bearerToken'};
    try {
      for (final ticketId in selectedTicketIds) {
        final body = {'id': ticketId.toString()};
        final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
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
        title: Text('${AppLocalizations.of(context).getTranslate('support_center')}'),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: removeSelectedTickets,
              child: Text(
                '${AppLocalizations.of(context).getTranslate('remove')}',
                style: TextStyle(color: Colors.white),
              ),
            ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: toggleEditing,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (BuildContext context, int index) {
          final ticket = tickets[index];
          final ticketId = ticket['id'];
          Color statusColor = Colors.green; // Initial color is green

          if (ticket['status'] == 'user_closed') {
            statusColor = Colors.red; // Change color to red for 'user_closed' status
          }

          // Exclude tickets with status 'user_closed' from the list if in editing mode
          if (isEditing && ticket['status'] == 'user_closed') {
            return SizedBox(); // Return an empty SizedBox to hide the ticket
          }

          Widget tile;
          if (isEditing) {
            tile = RadioListTile<int>(
              value: ticketId,
              groupValue: selectedTicketIds.isNotEmpty ? selectedTicketIds.first : null,
              contentPadding: EdgeInsets.all(15),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket['title'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context).getTranslate('status')}: ${ticket['status']}',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${AppLocalizations.of(context).getTranslate('update')}: ${ticket['updated_at']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              onChanged: selectTicket,
            );
          } else {
            tile = ListTile(
              contentPadding: EdgeInsets.all(15),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket['title'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context).getTranslate('status')}: ${ticket['status']}',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${AppLocalizations.of(context).getTranslate('update')}: ${ticket['updated_at']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              onTap: () {
                // Handle ticket tap for viewing or editing
                // Navigate to the ticket details or edit screen
              },
            );
          }

          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: tile,
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          if (isEditing) {
            final selectedTicketId = selectedTicketIds.isNotEmpty ? selectedTicketIds.first : null;
            if (selectedTicketId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReplyTicketScreen(ticketId: selectedTicketId),
                ),
              ).then((value) {
                // Handle any necessary actions after returning from ReplyTicketScreen
                if (value == 'done') {
                  toggleEditing(); // Enable editing mode
                }
              });
            } else {
              // Show a message to the user indicating that no ticket is selected
            }
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTicketScreen()),
            ).then((value) {
              // Handle any necessary actions after returning from AddTicketScreen
            });
          }
        },
        child: isEditing ? Icon(Icons.reply_outlined) : Icon(Icons.add),
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
        title: Text('${AppLocalizations.of(context).getTranslate('add_ticket')}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: '${AppLocalizations.of(context).getTranslate('title')}',
              ),
            ),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: '${AppLocalizations.of(context).getTranslate('message')}',
              ),
            ),
            TextField(
              controller: topicController,
              decoration: InputDecoration(
                labelText: '${AppLocalizations.of(context).getTranslate('topic')}',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: createTicket,
              child: Text('${AppLocalizations.of(context).getTranslate('create_ticket')}'),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screen to reply to a ticket
class ReplyTicketScreen extends StatefulWidget {
  final int ticketId;

  const ReplyTicketScreen({Key? key, required this.ticketId}) : super(key: key);

  @override
  _ReplyTicketScreenState createState() => _ReplyTicketScreenState();
}

class _ReplyTicketScreenState extends State<ReplyTicketScreen> {
  TextEditingController replyController = TextEditingController();

  void replyToTicket() async {
    final replyUrl = 'https://api.qline.app/api/tickets/respond';
    final settings = context.read<SettingsCubit>();
    final bearerToken = settings.state.userInfo[3]; // Retrieve the bearer token
    final headers = {'Authorization': 'Bearer $bearerToken'};
    final body = {
      'id': widget.ticketId.toString(),
      'message': replyController.text,
    };

    try {
      final response = await http.post(Uri.parse(replyUrl), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Reply sent successfully
        Navigator.pop(context); // Go back to the previous screen and pass the result
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
        title: Text('${AppLocalizations.of(context).getTranslate('reply_ticket')}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: replyController,
              decoration: InputDecoration(
                labelText: '${AppLocalizations.of(context).getTranslate('response')}',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: replyToTicket,
              child: Text('${AppLocalizations.of(context).getTranslate('reply')}'),
            ),
          ],
        ),
      ),
    );
  }
}
