import 'package:flutter/material.dart';
import 'services/crypto_service.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();
  runApp(const XoDosApp());
}

class XoDosApp extends StatelessWidget {
  const XoDosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XoDos Messenger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  
  bool hideTyping = true;
  bool hideReadReceipts = true;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final rawText = _controller.text;
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await DatabaseService.saveMessage(
      id: id,
      text: rawText,
      isMe: true,
      timestamp: "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
    );

    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final messages = DatabaseService.getMessages();

    return Scaffold(
      appBar: AppBar(
        title: const Text('XoDos Messenger 🐉'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.security),
            onSelected: (value) {
              setState(() {
                if (value == 'typing') hideTyping = !hideTyping;
                if (value == 'read') hideReadReceipts = !hideReadReceipts;
              });
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                checked: hideTyping,
                value: 'typing',
                child: const Text('Ocultar "Digitando..."'),
              ),
              CheckedPopupMenuItem(
                checked: hideReadReceipts,
                value: 'read',
                child: const Text('Ocultar Tiques Azuis'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['isMe'] ?? false;
                final isDeleted = msg['isDeletedBySender'] ?? false;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.deepPurple : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        if (isDeleted)
                          const Text(
                            '🚫 Remetente tentou apagar',
                            style: TextStyle(color: Colors.redAccent, fontSize: 10, fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Mensagem criptografada...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurpleAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
