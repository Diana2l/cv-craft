import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('About Us'),
        ),  
        backgroundColor: Colors.teal, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('aboutus').doc('aboutusText').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Text("Error fetching data");
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text("Document does not exist");
            } else {
              var aboutText = snapshot.data!.get('text') as String;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aboutText,
                    style: const TextStyle(fontSize: 16.0, height: 1.5),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
