import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../services/ai_model_service.dart';

class ChatScreen extends StatefulWidget {
  final int? conversationId;
  const ChatScreen({super.key, this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  int? _conversationId;
  String _conversationTitle = 'Nouvelle conversation';
  bool _isLoading = false;
  String _activeModelName = 'Aucun modèle';
  bool _noModelSelected = false;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    _loadActiveModel();
    if (_conversationId != null) {
      _loadConversation();
    } else {
      _createConversation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadActiveModel() async {
    final model = await AiModelService.instance.getActiveModel();
    if (mounted) {
      setState(() {
        if (model != null) {
          _activeModelName = model['name'] as String;
          _noModelSelected = false;
        } else {
          _activeModelName = 'Aucun modèle';
          _noModelSelected = true;
        }
      });
    }
  }

  Future<void> _createConversation() async {
    final db = DatabaseHelper.instance;
    final id = await db.insertConversation('Nouvelle conversation');
    setState(() => _conversationId = id);
  }

  Future<void> _loadConversation() async {
    final db = DatabaseHelper.instance;
    final messages = await db.getMessages(_conversationId!);
    final conv = await db.getConversation(_conversationId!);
    setState(() {
      _messages = messages;
      _conversationTitle = conv?['title'] ?? 'Conversation';
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _conversationId == null) return;

    _controller.clear();
    final db = DatabaseHelper.instance;

    // Insert user message
    await db.insertMessageSimple(_conversationId!, text, true);
    await db.updateConversationLastMessage(_conversationId!, text);

    // Update title if first message
    if (_messages.isEmpty) {
      final title = text.length > 40 ? '${text.substring(0, 40)}...' : text;
      final conv = await db.getConversation(_conversationId!);
      if (conv != null && conv['title'] == 'Nouvelle conversation') {
        final db2 = await db.database;
        await db2.update('conversations', {'title': title}, where: 'id = ?', whereArgs: [_conversationId]);
        setState(() => _conversationTitle = title);
      }
    }

    setState(() {
      _messages.add({'content': text, 'role': 'user', 'created_at': DateTime.now().toIso8601String()});
      _isLoading = true;
    });
    _scrollToBottom();

    // Get AI response from active model
    final response = await AiModelService.instance.chat(text);

    await db.insertMessageSimple(_conversationId!, response, false);
    await db.updateConversationLastMessage(_conversationId!, response);

    setState(() {
      _messages.add({'content': response, 'role': 'assistant', 'created_at': DateTime.now().toIso8601String()});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_conversationTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(_noModelSelected ? Icons.warning_amber_rounded : Icons.auto_awesome, size: 12, color: _noModelSelected ? AppColors.primaryAmber : Colors.white70),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _activeModelName,
                    style: TextStyle(fontSize: 11, color: _noModelSelected ? AppColors.primaryAmber : Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_noModelSelected)
            IconButton(
              icon: const Icon(Icons.warning_amber_rounded, color: AppColors.primaryAmber),
              tooltip: 'Aucun modèle sélectionné',
              onPressed: () => context.push('/models'),
            ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => context.push('/models'),
            tooltip: 'Changer de modèle',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_noModelSelected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.primaryAmber.withAlpha(30),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.primaryAmber, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Aucun modèle IA sélectionné. Les réponses utilisent le mode par défaut.', style: TextStyle(fontSize: 12, color: AppColors.primaryAmber))),
                  TextButton(
                    onPressed: () => context.push('/models'),
                    child: const Text('Choisir un modèle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.primaryPurple.withAlpha(25), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.auto_awesome, color: AppColors.primaryPurple, size: 40)),
                          const SizedBox(height: 20),
                          const Text('Assistant IA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Posez-moi des questions sur vos ventes, stock, clients...', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _noModelSelected ? AppColors.primaryAmber.withAlpha(25) : AppColors.primaryPurple.withAlpha(25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_noModelSelected ? Icons.warning_amber_rounded : Icons.auto_awesome, size: 14, color: _noModelSelected ? AppColors.primaryAmber : AppColors.primaryPurple),
                                const SizedBox(width: 6),
                                Text(_activeModelName, style: TextStyle(fontSize: 12, color: _noModelSelected ? AppColors.primaryAmber : AppColors.primaryPurple, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildSuggestionChip('Analyser mes ventes'),
                              _buildSuggestionChip('Etat du stock'),
                              _buildSuggestionChip('Conseils business'),
                              _buildSuggestionChip('Depenses du mois'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildTypingIndicator();
                      }
                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';
                      return _buildMessageBubble(msg['content'], isUser);
                    },
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppColors.primaryPurple.withAlpha(25),
      side: BorderSide(color: AppColors.primaryPurple.withAlpha(50)),
      onPressed: () {
        _controller.text = text;
        _sendMessage();
      },
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryPurple : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.textDark,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryPurple.withAlpha(128))),
            const SizedBox(width: 10),
            Text('Reflexion avec $_activeModelName...', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Demander un conseil IA...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: AppColors.primaryPurple, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
