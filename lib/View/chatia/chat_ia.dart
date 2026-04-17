// lib/screens/chat_screen_with_api.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:onyfast/Controller/chatIa/chatIAController.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/utils/testInternet.dart';
import 'package:onyfast/model/chatIA/chatmodel.dart';
import '../../Color/app_color_model.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

class MosalisichatScreen extends StatefulWidget {
  const MosalisichatScreen({super.key});

  @override
  _MosalisichatScreenState createState() => _MosalisichatScreenState();
}

class _MosalisichatScreenState extends State<MosalisichatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatController _chatController = Get.put(ChatController());
  final GetStorage _storage = GetStorage();
  
  bool CheckConnected = false;
  bool _showScrollToBottomButton = false;
  int _unreadCount = 0;
  String? _conversationId;
  
  void checkConnection() async {
    try {
      bool isConnected = await hasInternetConnection();
      if (mounted) {
        setState(() {
          CheckConnected = isConnected;
        });
      }
    } on SocketException catch (_) {
      if (mounted) {
        setState(() {
          CheckConnected = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkConnection();
    
    // Génère un ID unique pour cette conversation
    var user = _storage.read('userInfo') ?? {};
    _conversationId = 'chat_position_${user['id'] ?? 'default'}';
    
    // Écoute les changements de scroll
    _scrollController.addListener(_onScroll);
    
    // Ajouter le message de bienvenue si la liste est vide
    if (_chatController.messages.isEmpty) {
      _chatController.addMessage(
        ChatMessage(
          text: "Bonjour ! Bienvenue sur Onyfast. Je suis votre assistant virtuel et je suis là pour répondre à toutes vos questions. Comment puis-je vous aider aujourd'hui ?",
          isUser: false,
          timestamp: DateTime.now(),
          status: MessageStatus.read,
        ),
      );
    }
    
    // Scroll au bas après le chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScrollPosition();
    });
  }
  
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    // Vérifie si on est proche du bas (moins de 100 pixels)
    final isAtBottom = _scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 100;
    
    // Affiche/cache le bouton selon la position
    if (isAtBottom != !_showScrollToBottomButton) {
      setState(() {
        _showScrollToBottomButton = !isAtBottom;
      });
    }
    
    // Sauvegarde la position actuelle
    _saveScrollPosition();
  }
  
  void _saveScrollPosition() {
    if (_scrollController.hasClients) {
      _storage.write(_conversationId!, _scrollController.position.pixels);
    }
  }
  
  void _restoreScrollPosition() {
    if (!_scrollController.hasClients) return;
    
    final savedPosition = _storage.read(_conversationId!);
    
    if (savedPosition != null && savedPosition is double) {
      // Restaure la position sauvegardée
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients && mounted) {
          final maxExtent = _scrollController.position.maxScrollExtent;
          final targetPosition = savedPosition.clamp(0.0, maxExtent);
          _scrollController.jumpTo(targetPosition);
        }
      });
    } else {
      // Si pas de position sauvegardée, va en bas
      _scrollToBottom(animated: false);
    }
  }
  
  @override
  void dispose() {
    _saveScrollPosition(); // Sauvegarde avant de quitter
    _scrollController.removeListener(_onScroll);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients && mounted) {
          if (animated) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
          
          // Cache le bouton et réinitialise le compteur
          if (mounted) {
            setState(() {
              _showScrollToBottomButton = false;
              _unreadCount = 0;
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    checkConnection();
    return scaffold(context);
  }

  Widget scaffold(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: Color(0xFFF5F5F5),
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: _buildChatBody(context),
                ),
                _buildInputArea(context),
              ],
            ),
            // Bouton "Scroll to Bottom"
            if (_showScrollToBottomButton)
              Positioned(
                right: 4.w,
                bottom: 20.h,
                child: _buildScrollToBottomButton(),
              ),
          ],
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: _buildChatBody(context),
              ),
              _buildInputArea(context),
            ],
          ),
          // Bouton "Scroll to Bottom"
          if (_showScrollToBottomButton)
            Positioned(
              right: 4.w,
              bottom: 20.h,
              child: _buildScrollToBottomButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildScrollToBottomButton() {
    return GestureDetector(
      onTap: () => _scrollToBottom(animated: true),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: globalColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Platform.isIOS ? CupertinoIcons.arrow_down : Icons.arrow_downward,
              color: Colors.white,
              size: 6.w,
            ),
          ),
          
          // Badge avec le nombre de nouveaux messages
          if (_unreadCount > 0)
            Positioned(
              top: -1.w,
              right: -1.w,
              child: Container(
                padding: EdgeInsets.all(1.5.w),
                constraints: BoxConstraints(
                  minWidth: 5.w,
                  minHeight: 5.w,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.destructiveRed,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _unreadCount > 99 ? '99+' : '$_unreadCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Container(
      padding: EdgeInsets.only(
        left: 4.w,
        right: 4.w,
        top: statusBarHeight + 1.h,
        bottom: 2.h,
      ),
      decoration: BoxDecoration(
        color: globalColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Platform.isIOS ? CupertinoIcons.back : Icons.arrow_back,
              color: Colors.white,
              size: 6.w,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: 3.w),
          Container(
            width: 11.w,
            height: 11.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent,
              color: globalColor,
              size: 6.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Onybot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.dp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() {
                  return Text(
                     _chatController.isLoading.value 
                        ? 'En train d\'écrire...' 
                        : ((!CheckConnected) ? 'Hors ligne' : 'En ligne'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11.dp,
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            width: 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              color: (CheckConnected) ? Colors.greenAccent : Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBody(BuildContext context) {
    return Obx(() {
      final messagesList = _chatController.messages;
      final isLoading = _chatController.isLoading.value;
      
      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: messagesList.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == messagesList.length && isLoading) {
            return _buildTypingIndicator();
          }
          return _buildMessageBubble(messagesList[index]);
        },
      );
    });
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildAvatar(false),
          SizedBox(width: 3.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: _TypingAnimation(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[ 
            _buildAvatar(false),
            SizedBox(width: 3.w),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: message.isFailed 
                  ? () => _showRetryDialog(message) 
                  : null,
              child: Container(
                constraints: BoxConstraints(maxWidth: 75.w),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: message.isUser 
                      ? (message.isFailed 
                          ? Colors.red.withOpacity(0.1) 
                          : globalColor)
                      : Colors.white,
                  border: message.isFailed 
                      ? Border.all(color: Colors.red, width: 1)
                      : null,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(message.isUser ? 20 : 5),
                    topRight: Radius.circular(message.isUser ? 5 : 20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    message.isUser
  ? Text(
      message.text,
      style: TextStyle(
        color: message.isFailed ? Colors.red[900] : Colors.white,
        fontSize: 13.dp,
        height: 1.4,
      ),
    )
  : GptMarkdown(
      message.text,
      style: TextStyle(
        color: Color(0xFF333333),
        fontSize: 13.dp,
        height: 1.4,
      ),
    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            color: message.isUser
                                ? (message.isFailed 
                                    ? Colors.red[700] 
                                    : Colors.white.withOpacity(0.7))
                                : Color(0xFF999999),
                            fontSize: 9.dp,
                          ),
                        ),
                        if (message.isUser) ...[
                          SizedBox(width: 1.w),
                          _buildMessageStatus(message),
                        ],
                      ],
                    ),
                    if (message.isFailed && message.errorMessage != null) ...[
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Icon(Icons.info_outline, 
                              size: 3.w, 
                              color: Colors.red[700]),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              message.errorMessage!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 9.dp,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      TextButton.icon(
                        icon: Icon(Icons.refresh, size: 4.w, color: Colors.red[700]),
                        label: Text(
                          'Réessayer',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 10.dp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => _retryMessage(message),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 3.w),
            _buildAvatar(true),
          ],
        ],
      ),
    );
  }

  void _showRetryDialog(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message non envoyé'),
        content: Text('Voulez-vous réessayer d\'envoyer ce message ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _retryMessage(message);
            },
            child: Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  void _retryMessage(ChatMessage message) async {
  await _chatController.retryMessage(message.id);
  
  // Toujours scroll en bas après le retry
  _scrollToBottom();
}

  Widget _buildMessageStatus(ChatMessage message) {
    IconData icon;
    Color color = Color(message.statusColor);

    switch (message.status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 3.w,
          height: 3.w,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
          ),
        );
      case MessageStatus.sent:
        icon = Icons.check;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        break;
    }

    return Icon(
      icon,
      size: 3.w,
      color: message.isUser ? Colors.white.withOpacity(0.7) : color,
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: isUser ? globalColor : Colors.white,
        border: Border.all(
          color: isUser ? Colors.transparent : globalColor,
          width: 2,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person : Icons.support_agent,
        color: isUser ? Colors.white : globalColor,
        size: 5.w,
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  cursorColor: globalColor,
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Tapez votre message...',
                    hintStyle: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 13.dp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 1.5.h,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 13.dp,
                    color: Color(0xFF333333),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) => _sendMessage(),
                  enabled: !_chatController.isLoading.value,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Obx(() => Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _chatController.isLoading.value 
                    ? Colors.grey 
                    : globalColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: globalColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: _chatController.isLoading.value
                    ? SizedBox(
                        width: 5.w,
                        height: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        Platform.isIOS ? CupertinoIcons.paperplane_fill : Icons.send,
                        color: Colors.white,
                        size: 5.w,
                      ),
                onPressed: _chatController.isLoading.value 
                    ? null 
                    : () => _sendMessage(),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
  final message = _messageController.text.trim();
  if (message.isEmpty) return;

  if (!CheckConnected) {
    SnackBarService.networkError();
    return;
  }

  _messageController.clear();

  // Envoyer le message via le contrôleur (API)
  await _chatController.sendMessage(message);

  // Toujours scroll en bas après l'envoi d'un message
  _scrollToBottom();
}

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class _TypingAnimation extends StatefulWidget {
  @override
  __TypingAnimationState createState() => __TypingAnimationState();
}

class __TypingAnimationState extends State<_TypingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    
    _controller = AnimationController(
      duration: Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + (0.5 * (1 - (2 * value - 1).abs()));
            
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 1.5.w),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 2.5.w,
                  height: 2.5.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF999999),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}