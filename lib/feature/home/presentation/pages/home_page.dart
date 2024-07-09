import 'package:chat_app/core/utils/user_data.dart';
import 'package:chat_app/feature/home/presentation/widgets/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/chat_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Chatify'),
        foregroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: UserSearchDelegate());
                },
              ),
            ],
          ),
        ],
      ),
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder(
        stream: _firestore.collection("chat_rooms").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No messages found.'));
          }
          final String currentUserID = _auth.currentUser!.uid;

          List<String> matchingChatRoomIDs = [];
          List<Map<String, dynamic>> chatRoomsData = [];

          snapshot.data!.docs.forEach((doc) {
            String chatRoomID = doc.id;
            String senderID = doc["senderID"];
            String receiverID = doc["receiverID"];

            if (senderID == currentUserID) {
              matchingChatRoomIDs.add(chatRoomID);
              Map<String, dynamic> roomData = {
                'chatRoomID': doc.id,
                'senderID': senderID,
                'receiverID': receiverID,
                'senderName': doc['senderName'],
                'receiverName': doc['receiverName'],
                'timestamp': doc['timestamp'],
                'type': doc['type'],
                'message': doc['type'] == 'text' ? doc['message'] : null,
              };
              chatRoomsData.add(roomData);
            } else if (receiverID == currentUserID) {
              matchingChatRoomIDs.add(chatRoomID);
              Map<String, dynamic> roomData = {
                'chatRoomID': doc.id,
                'senderID': receiverID,
                'receiverID': senderID,
                'senderName': doc['receiverName'],
                'receiverName': doc['senderName'],
                'timestamp': doc['timestamp'],
                'type': doc['type'],
                'message': doc['type'] == 'text' ? doc['message'] : null,
              };
              chatRoomsData.add(roomData);
            }
          });
          chatRoomsData
              .sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

          return ListView.builder(
            itemCount: chatRoomsData.length,
            itemBuilder: (context, index) {
              String receiverId = chatRoomsData[index]['receiverID'];
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection("users").doc(receiverId).get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  Timestamp timestamp = chatRoomsData[index]["timestamp"];
                  DateTime dateTime = timestamp.toDate();
                  String formattedTime = DateFormat.Hm().format(dateTime);
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('${chatRoomsData[index]['receiverName']}'),
                      subtitle: Text('Loading...'),
                    );
                  }

                  if (snapshot.hasError) {
                    return ListTile(
                      title: Text('${chatRoomsData[index]['receiverName']}'),
                      subtitle: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return ListTile(
                      title: Text('${chatRoomsData[index]['receiverName']}'),
                      subtitle: Text('No user data found'),
                    );
                  }

                  Map<String, dynamic> userData =
                      snapshot.data!.data() as Map<String, dynamic>;

                  return Container(
                    margin: EdgeInsets.only(top: 1, left: 2, right: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          userData['photoUrl'],
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            '${chatRoomsData[index]['receiverName']}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(width: 5),
                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color:
                                  (userData['isActive']) ? Colors.green : null,
                            ),
                          ),
                        ],
                      ),
                      subtitle: chatRoomsData[index]['type'] == 'text'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    chatRoomsData[index]['message'],
                                    maxLines: 1,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "image",
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              receiverID: chatRoomsData[index]['receiverID'],
                              receiverName: chatRoomsData[index]
                                  ['receiverName'],
                              isActive: userData['isActive'],
                              photoUrl: userData['photoUrl'],
                              senderName: FirebaseAuth
                                  .instance.currentUser!.displayName!,
                            ), // Pass user name to ChatPage
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class UserSearchDelegate extends SearchDelegate<User> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('Enter a name to search'));
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<UserData>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots()
          .map((querySnapshot) => querySnapshot.docs
              .map((doc) => UserData.fromFirestore(doc))
              .toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No users found'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final user = snapshot.data![index];
            return ListTile(
              title: Text(user.name!),
              subtitle: Text(user.email!),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiverID: user.id!,
                      receiverName: user.name!,
                      isActive: user.isActive!,
                      photoUrl: user.photoUrl!,
                      senderName:
                          FirebaseAuth.instance.currentUser!.displayName!,
                    ), // Pass user name to ChatPage
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
