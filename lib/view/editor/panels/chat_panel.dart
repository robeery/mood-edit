import 'package:flutter/material.dart';
import '../../../model/chat_message.dart';
import '../../../theme/app_theme.dart';
import '../../../viewmodel/editor_viewmodel.dart';

class ChatPanel extends StatefulWidget {
  final EditorViewModel vm;

  const ChatPanel({super.key, required this.vm});

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final TextEditingController _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _sendChat() async {
    final text = _chatController.text;
    if (text.trim().isEmpty) return;
    _chatController.clear();
    final error = await widget.vm.sendMessage(text);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.vm.messages;

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Expanded(
            child: messages.isEmpty && !widget.vm.isWaitingForAi
                ? const Center(
                    child: Text(
                      'ASK AI ANYTHING',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        letterSpacing: 3,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: messages.length + (widget.vm.isWaitingForAi ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return _buildLoadingBubble();
                      }
                      final msg = messages[index];
                      return _buildMessageBubble(msg);
                    },
                  ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.muted, width: 0.5),
        ),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: msg.isUser
              ? AppColors.highlight.withValues(alpha: 0.15)
              : AppColors.bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: msg.isUser ? AppColors.highlight.withValues(alpha: 0.3) : AppColors.muted,
            width: 0.5,
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? AppColors.highlight : AppColors.accent,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.muted, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'MODEL ',
                style: TextStyle(color: AppColors.muted, fontSize: 9, letterSpacing: 2),
              ),
              DropdownButton<String>(
                value: widget.vm.selectedModel,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.accent, fontSize: 11),
                underline: const SizedBox.shrink(),
                isDense: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.muted, size: 16),
                items: EditorViewModel.availableModels.map((model) {
                  return DropdownMenuItem(
                    value: model,
                    child: Text(model, style: const TextStyle(fontSize: 11)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) widget.vm.setSelectedModel(value);
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: const TextStyle(color: AppColors.highlight, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: AppColors.muted, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onSubmitted: (_) => _sendChat(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.accent, size: 20),
                onPressed: _sendChat,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
