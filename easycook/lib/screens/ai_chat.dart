import 'package:flutter/material.dart';
import 'package:easycook/services/recomendation_service.dart';

class AiChat extends StatefulWidget {
  const AiChat({Key? key}) : super(key: key);

  @override
  State<AiChat> createState() => _AiChatState();
}

class _AiChatState extends State<AiChat> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];
  bool isRequesting = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(text: _controller.text, isUser: true));
        isRequesting = true;
      });

      _controller.clear();

      // Menambahkan pesan rekomendasi di bawah pesan pengguna
      _getRecommendations();
    }
  }

  void _getRecommendations() async {
    try {
      final result = await RecommendationService.getLunchRecommendation(
        _messages.last.text,
      );

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
              text: result.choices[0]!.message!.content!, isUser: false));
          isRequesting = false;
        });
      }
    } catch (e) {
      const snackBar = SnackBar(
        content: Text('Failed to send a request. Please try again.'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        isRequesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFF99).withOpacity(0.8),
        centerTitle: true,
        title: const Text(
          "Rekomendasi Masakan",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xff000000),
          ),
        ),
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              // reverse: true, // Tetapkan reverse ke true di sini
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  text: message.text,
                  isUser: message.isUser,
                );
              },
            ),
          ),
          if (isRequesting)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'cari rekomendasi masakan dengen AI',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _sendMessage();
                    _getRecommendations();
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF58A975) : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
