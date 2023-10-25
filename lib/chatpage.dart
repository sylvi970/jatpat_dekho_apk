import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jatpat_dekho_apk/btm.dart';
import 'package:jatpat_dekho_apk/main.dart';
import 'package:http/http.dart' as http;

class User {
  var id;
  var name;
  var email;
  var imageUrl;
  var isOnline;
  var latestMessage;
  var latestSender;
  var unread;
  var latestMessageTime;
  var unformattedTime;

  User({
    this.id,
    this.name,
    this.email,
    this.imageUrl,
    this.isOnline,
    this.latestMessage,
    this.latestSender,
    this.unread,
    this.latestMessageTime,
    this.unformattedTime,
  });
}

class Message {
  var sender;
  var time;
  var text;
  var sent;
  var delivered;
  var unread;

  Message({
    this.sender,
    this.time,
    this.text,
    this.sent,
    this.delivered,
    this.unread,
  });
}

class ChatScreen extends StatefulWidget {
  final User receiver;
  final LoggedInUser loggedInUser;
  final String jwtToken;
  const ChatScreen(
      {super.key,
      required this.receiver,
      required this.jwtToken,
      required this.loggedInUser});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

Future<List<Message>> getAllMessages(String receiverId, String token) async {
  final response = await http.get(
    Uri.parse('$baseUrl/allMessages?receiver=$receiverId'),
    headers: {
      'Authorization': token,
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> messagesJson = json.decode(response.body);
    print(messagesJson);
    List<Message> messages = [];
    messagesJson.forEach((message) {
      messages.add(Message(
          sender: message['sender'],
          time: message['updatedAt'],
          text: message['contents'],
          sent: true,
          delivered: true,
          unread: false));
    });
    return messages;
  } else {
    throw Exception('Failed to load messages');
  }
}

class _ChatScreenState extends State<ChatScreen> {
  var prevMsgDate = DateTime.now();
  Widget chatBubble(Message message, bool isMe, bool isSameUser) {
    print(prevMsgDate);

    print(DateTime.parse(message.time));
    return Column(
      children: <Widget>[
        if (prevMsgDate.day != DateTime.parse(message.time).day ||
            prevMsgDate.month != DateTime.parse(message.time).month ||
            prevMsgDate.year != DateTime.parse(message.time).year)
          _showDateArea(DateTime.parse(message.time)),
        Container(
          alignment: isMe ? Alignment.topRight : Alignment.topLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.80,
            ),
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Text(
              message.text,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Text(
              '${DateTime.parse(message.time).toLocal().hour} : ${DateTime.parse(message.time).toLocal().minute}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  _sendMessageArea() {
    TextEditingController textEditingController = TextEditingController();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 70,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.emoji_emotions),
            iconSize: 25,
            color: Colors.black,
            onPressed: () {},
          ),
          Expanded(
              child: TextField(
            controller: textEditingController,
            decoration: const InputDecoration.collapsed(
              hintText: 'Send a message...',
            ),
            textCapitalization: TextCapitalization.sentences,
          )),
          IconButton(
            icon: const Icon(Icons.send),
            iconSize: 25,
            color: Colors.black,
            onPressed: () {
              String messageText = textEditingController.text;
              if (messageText.isNotEmpty) {
                // Send the 'messageText' to the backend, e.g., using an API call.
                // You can use the 'messageText' to send it to your backend.
                //sendMessageToBackend(messageText);
                textEditingController
                    .clear(); // Clear the text field after sending.
              }
            },
          )
        ],
      ),
    );
  }

  _showDateArea(DateTime date) {
    prevMsgDate = date;
    String showDate;

    if (date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      showDate = "Today";
    } else if (date.day == DateTime.now().day - 1 &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      showDate = 'Yesterday';
    } else {
      showDate = '${date.day}/${date.month}/${date.year}';
    }
    print("success");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 20,
      color: Colors.white,
      child: Text(showDate), // Display the date
    );
  }

  @override
  Widget build(BuildContext context) {
    var prevUserId = '-1';
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        titleSpacing: 0.0, // Remove spacing between the image and the title
        title: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 20, // Adjust the size as needed
              backgroundImage: NetworkImage(
                '$baseUrl/${widget.receiver.imageUrl}',
              ),
            ),
            const SizedBox(
                width: 10), // Add some spacing between the image and title
            RichText(
              // Add your title as before
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.receiver.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const TextSpan(text: '\n'),
                  widget.receiver.isOnline
                      ? const TextSpan(
                          text: 'Online',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      : const TextSpan(
                          text: 'Offline',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: FutureBuilder<List<Message>>(
        future: getAllMessages(widget.receiver.id,
            widget.jwtToken), // Replace with the function that fetches messages
        builder: (BuildContext context, AsyncSnapshot<List<Message>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for data, you can display a loading indicator.
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // If there's an error, you can display an error message.
            return Text('Error: ${snapshot.error}');
          } else {
            // Once the data is available, you can build your UI with it.
            List<Message>? messages = snapshot.data;
            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    //reverse: true,
                    padding: const EdgeInsets.all(20),
                    itemCount: messages!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Message message = messages[index];

                      final bool isMe =
                          message.sender == widget.loggedInUser.id;
                      final bool isSameUser = prevUserId == message.sender;
                      prevUserId = message.sender;
                      return chatBubble(message, isMe, isSameUser);
                    },
                  ),
                ),
                _sendMessageArea(),
              ],
            );
          }
        },
      ),
    );
  }
}

class ChatPageScreen extends StatelessWidget {
  final LoggedInUser loggedInUser;
  final String jwtToken;

  const ChatPageScreen(
      {super.key, required this.jwtToken, required this.loggedInUser});

  Future<List<User>> fetchChats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chats'), // Replace with your API endpoint
      headers: {
        'Authorization': jwtToken,
      },
    );

    if (response.statusCode == 200) {
      // print(json.decode(response.body));

      var userChats = json.decode(response.body)['userChats'];
      print(userChats[0]['users'][1]);
      List<dynamic> latestMessages =
          json.decode(response.body)['latestMessages'];
      List<dynamic> latestSenders = json.decode(response.body)['latestSenders'];

      List<User> chatUsers = [];

      for (int i = 0; i < latestSenders.length; i++) {
        var user;
        userChats[i]['users'][0] == loggedInUser.id
            ? user = await http.post(
                Uri.parse(
                    '$baseUrl/getUserDetails?userId=${userChats[i]["users"][1]}'),
              )
            : user = await http.post(
                Uri.parse(
                    '$baseUrl/getUserDetails?userId=${userChats[i]["users"][0]}'),
              );

        if (user.statusCode == 200) {
          user = json.decode(user.body);
          print(user);
          final String utcTimeString = userChats[i]
              ['updatedAt']; // Assuming this is your UTC time as a string
          final DateTime utcTime = DateTime.parse(utcTimeString);

          // Convert to local time (e.g., UTC+5:30 for Indian Standard Time)
          final localTime = utcTime.toLocal();
          DateTime now = DateTime.now();
          print(now.day);
          print(localTime.day);

          final String formattedTime;
          if (localTime.day == now.day &&
              localTime.month == now.month &&
              localTime.year == now.year) {
            formattedTime = '${localTime.hour}:${localTime.minute}';
          } else {
            formattedTime =
                '${localTime.day}/${localTime.month}/${localTime.year}';
          }
          chatUsers.add(User(
              id: user['id'],
              name: user['name'],
              email: user['email'],
              imageUrl: user['photo'][0].toString().substring(15),
              isOnline: false,
              unread: false,
              latestMessage: latestMessages[i],
              latestSender: latestSenders[i],
              latestMessageTime: formattedTime,
              unformattedTime: DateTime.parse(userChats[i]['updatedAt'])));
        }
      }
      print(chatUsers[0].name);
      return chatUsers;
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception('Failed to load chats');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        title: const Text("CHATS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
          future: fetchChats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final chats = snapshot.data;
              print(chats!.length);

              {
                for (var i = 0; i < chats.length - 1; i++) {
                  if (chats[i]
                      .unformattedTime
                      .isBefore(chats[i + 1].unformattedTime)) {
                    var temp = chats[i];
                    chats[i] = chats[i + 1];
                    chats[i + 1] = temp;
                  }
                }
              }

              //throw Exception('yeah');

              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (BuildContext context, int index) {
                  final User chatUser = chats[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          receiver: chatUser,
                          jwtToken: jwtToken,
                          loggedInUser: loggedInUser,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: chatUser.unread
                                ? BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(40)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  )
                                : BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  NetworkImage('$baseUrl/${chatUser.imageUrl}'),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.65,
                            padding: const EdgeInsets.only(
                              left: 20,
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          chatUser.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        chatUser.isOnline
                                            ? Container(
                                                margin: const EdgeInsets.only(
                                                    left: 5),
                                                width: 7,
                                                height: 7,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.green,
                                                ),
                                              )
                                            : Container(
                                                child: null,
                                              ),
                                      ],
                                    ),
                                    Text(
                                      chatUser.latestMessageTime,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    chatUser.latestMessage,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }),
    );
  }
}
