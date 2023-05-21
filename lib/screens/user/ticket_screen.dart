import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({Key? key}) : super(key: key);

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Tickets"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Geri butonuna basıldığında yapılacak işlemler
              GoRouter.of(context).go('/news'); // Anasayfaya yönlendirme
            },
          ),
      ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 10,
            margin: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black)
            ),
            child: Row(
              children: [
                Container(color: Colors.red,height: 100, width: 100,),
                Column(
                  children: [
                    Text("başlık"),
                    Text("durum"),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go('/ticket-add');
              },
              child: Icon(Icons.add)
          )
        ],
      ),
    );
  }
}

class TicketAddScreen extends StatelessWidget {
  const TicketAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Ticket"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Geri butonuna basıldığında yapılacak işlemler
            GoRouter.of(context).go('/tickets'); // Anasayfaya yönlendirme
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 10,
            margin: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(3.0),
            child: Text("Konu: "),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black)
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width - 10,
            margin: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(3.0),
            child: Text("Destek mesajı: "),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black)
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 10,
            margin: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(3.0),
            child: TextButton(onPressed: () {

            },
    child: Text("Gönder")),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black)
            ),
          ),
        ],
      ),
    );
  }
}


