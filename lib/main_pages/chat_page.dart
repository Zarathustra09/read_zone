import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:read_zone/components/navbar.dart'; // Import your Navbar
import 'package:read_zone/theme.dart'; // Import your theme

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final OpenAI _openAI;

  final ChatUser _user = ChatUser(
    id: '1',
    firstName: 'Current',
    lastName: 'User',
  );

  final ChatUser _gptChatUser = ChatUser(
    id: '2',
    firstName: 'Chat',
    lastName: 'GPT',
  );

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];

  @override
  void initState() {
    super.initState();
    _openAI = OpenAI.instance.build(
      token: dotenv.env['OPENAI_API_KEY']!,
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 5),
      ),
      enableLog: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'GPT Chat',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: DashChat(
              currentUser: _user,
              messageOptions: const MessageOptions(
                currentUserContainerColor: Colors.black,
                containerColor: AppTheme.primaryColor,
                textColor: Colors.white,
              ),
              onSend: (ChatMessage m) {
                getChatResponse(m);
              },
              messages: _messages,
              typingUsers: _typingUsers,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Navbar(
        currentIndex: 3, // Set current index to 3 for the chat page
        onTap: (index) {
          setState(() {
            // Handle navigation tap here if needed
          });
        },
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });
    List<Map<String, dynamic>> messagesHistory =
    _messages.reversed.toList().map((m) {
      if (m.user == _user) {
        return Messages(role: Role.user, content: m.text).toJson();
      } else {
        return Messages(role: Role.assistant, content: m.text).toJson();
      }
    }).toList();
    final request = ChatCompleteText(
      messages: messagesHistory,
      maxToken: 200,
      model: GptTurboChatModel(),
    );
    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                  user: _gptChatUser,
                  createdAt: DateTime.now(),
                  text: element.message!.content));
        });
      }
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}