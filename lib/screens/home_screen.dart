import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/memo.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  List<Memo> _memos = [];
  bool _isEditing = false;
  int _currentColorValue = 0;
  String? _editingMemoId; // null = new memo, non-null = editing existing
  bool _isBoldFilterActive = false;

  // Muted/dusty tone colors (deeper for better readability)
  static const List<Color> _colors = [
    Color(0xFF5B8BA0), // dusty blue
    Color(0xFF6B9B6B), // dusty green
    Color(0xFFCC8855), // dusty orange
    Color(0xFF7B6B9B), // dusty indigo
    Color(0xFFAA9944), // dusty yellow/olive
  ];

  @override
  void initState() {
    super.initState();
    _loadMemos();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // Don't call setState on every keystroke - it interferes with text input
  }

  Future<void> _loadMemos() async {
    final memos = await _storageService.loadMemos();

    // Migrate old memos that exceed max width
    bool needsSave = false;
    for (int i = 0; i < memos.length; i++) {
      final trimmed = _trimToMaxWidth(memos[i].title, isBold: memos[i].isBold);
      if (trimmed != memos[i].title) {
        memos[i] = memos[i].copyWith(title: trimmed);
        needsSave = true;
      }
    }

    setState(() {
      _memos = memos;
    });

    if (needsSave) {
      await _storageService.saveMemos(_memos);
    }
  }

  // Max text width in pixels (roughly 80% of typical phone width)
  static const double _maxTextWidth = 300.0;
  static const TextStyle _memoTextStyle = TextStyle(fontSize: 16);

  static double _measureTextWidth(String text, {bool isBold = false}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: _memoTextStyle.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  static String _trimToMaxWidth(String text, {bool isBold = false}) {
    if (_measureTextWidth(text, isBold: isBold) <= _maxTextWidth) {
      return text;
    }
    // Binary search for the right length
    int low = 0;
    int high = text.length;
    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      if (_measureTextWidth(text.substring(0, mid), isBold: isBold) <= _maxTextWidth) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    return text.substring(0, low);
  }

  Future<void> _addMemo(String title) async {
    if (title.trim().isEmpty) return;

    final trimmedTitle = _trimToMaxWidth(title.trim());

    final memo = Memo(
      id: _uuid.v4(),
      title: trimmedTitle,
      colorValue: _currentColorValue,
      createdAt: DateTime.now(),
    );

    setState(() {
      _memos.insert(0, memo);
    });

    await _storageService.saveMemos(_memos);
  }

  Future<void> _updateMemo(String id, String title) async {
    if (title.trim().isEmpty) {
      await _deleteMemo(id);
      return;
    }

    final memo = _memos.firstWhere((m) => m.id == id);
    final trimmedTitle = _trimToMaxWidth(title.trim(), isBold: memo.isBold);

    setState(() {
      final index = _memos.indexWhere((m) => m.id == id);
      if (index != -1) {
        _memos[index] = _memos[index].copyWith(title: trimmedTitle);
      }
    });

    await _storageService.saveMemos(_memos);
  }

  Future<void> _deleteMemo(String id) async {
    setState(() {
      _memos.removeWhere((memo) => memo.id == id);
    });

    await _storageService.saveMemos(_memos);
  }

  void _copyMemo(String id) {
    final memo = _memos.firstWhere((m) => m.id == id);
    Clipboard.setData(ClipboardData(text: memo.title));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('메모가 복사되었습니다'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _editMemo(String id) {
    final memo = _memos.firstWhere((m) => m.id == id);
    _controller.text = memo.title;
    setState(() {
      _isEditing = true;
      _editingMemoId = id;
      _currentColorValue = memo.colorValue;
    });
    // Delay focus request to ensure widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _toggleBold(String id) async {
    setState(() {
      final index = _memos.indexWhere((m) => m.id == id);
      if (index != -1) {
        _memos[index] = _memos[index].copyWith(isBold: !_memos[index].isBold);
      }
    });

    await _storageService.saveMemos(_memos);
  }

  Future<void> _reorderMemo(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    setState(() {
      final memo = _memos.removeAt(oldIndex);
      // Adjust newIndex if removing affected it
      final adjustedIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
      _memos.insert(adjustedIndex.clamp(0, _memos.length), memo);
    });

    await _storageService.saveMemos(_memos);
  }

  void _startEditing() {
    _controller.clear();
    setState(() {
      _isEditing = true;
      _editingMemoId = null; // New memo
      _currentColorValue = _colors[_random.nextInt(_colors.length)].toARGB32();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingMemoId = null;
      _controller.clear();
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controller.text.isEmpty) {
      _cancelEditing();
    }
  }

  Future<void> _onSubmitted(String value) async {
    final text = _controller.text;
    final editingId = _editingMemoId;

    _controller.clear();
    setState(() {
      _isEditing = false;
      _editingMemoId = null;
    });

    if (editingId != null) {
      await _updateMemo(editingId, text);
    } else {
      await _addMemo(text);
    }
  }

  // Maximum height ratio for memo display area
  static const double _maxMemoHeightRatio = 0.8;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final backgroundColor = themeProvider.backgroundColor(context);
    final pipeColor = themeProvider.pipeColor(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final maxMemoHeight = screenHeight * _maxMemoHeightRatio;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        onTap: _isEditing ? _cancelEditing : null,
        behavior: HitTestBehavior.translucent,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxMemoHeight),
            child: SingleChildScrollView(
              child: MemoDisplay(
                memos: _memos,
                onDelete: _deleteMemo,
                onCopy: _copyMemo,
                onEdit: _editMemo,
                onToggleBold: _toggleBold,
                onReorder: _reorderMemo,
                isEditing: _isEditing,
                editingMemoId: _editingMemoId,
                controller: _controller,
                focusNode: _focusNode,
                currentColorValue: _currentColorValue,
                onSubmitted: _onSubmitted,
                onKeyEvent: _handleKeyEvent,
                currentEditingIsBold: _editingMemoId != null
                    ? (_memos.where((m) => m.id == _editingMemoId).firstOrNull?.isBold ?? false)
                    : false,
                pipeColor: pipeColor,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _isEditing
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Add button
                  _buildBottomButton(
                    icon: Icons.add,
                    onPressed: _startEditing,
                    isActive: false,
                    themeProvider: themeProvider,
                  ),
                  const SizedBox(width: 8),
                  // Filter button
                  _buildBottomButton(
                    icon: Icons.filter_list,
                    onPressed: _toggleBoldFilter,
                    isActive: _isBoldFilterActive,
                    themeProvider: themeProvider,
                  ),
                  const SizedBox(width: 8),
                  // Settings button
                  _buildBottomButton(
                    icon: Icons.settings,
                    onPressed: () => _openSettings(context),
                    isActive: false,
                    themeProvider: themeProvider,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isActive,
    required ThemeProvider themeProvider,
  }) {
    return SizedBox(
      width: 36,
      height: 24,
      child: Material(
        color: isActive ? Colors.grey[600] : Colors.grey[400],
        borderRadius: BorderRadius.circular(3),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(3),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      ),
    );
  }

  void _toggleBoldFilter() {
    setState(() {
      _isBoldFilterActive = !_isBoldFilterActive;
    });
  }

  Future<void> _openSettings(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    if (result == true) {
      // Memos were cleared, reload
      await _loadMemos();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class MemoDisplay extends StatelessWidget {
  final List<Memo> memos;
  final Function(String) onDelete;
  final Function(String) onCopy;
  final Function(String) onEdit;
  final Function(String) onToggleBold;
  final Function(int, int) onReorder;
  final bool isEditing;
  final String? editingMemoId;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int currentColorValue;
  final Function(String) onSubmitted;
  final Function(KeyEvent) onKeyEvent;
  final bool currentEditingIsBold;
  final Color pipeColor;

  const MemoDisplay({
    super.key,
    required this.memos,
    required this.onDelete,
    required this.onCopy,
    required this.onEdit,
    required this.onToggleBold,
    required this.onReorder,
    required this.isEditing,
    this.editingMemoId,
    required this.controller,
    required this.focusNode,
    required this.currentColorValue,
    required this.onSubmitted,
    required this.onKeyEvent,
    this.currentEditingIsBold = false,
    required this.pipeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (memos.isEmpty && !isEditing) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth - 32;
        final rows = _buildMemoRows(context, maxWidth);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: rows,
          ),
        );
      },
    );
  }

  List<Widget> _buildMemoRows(BuildContext context, double maxWidth) {
    final List<Widget> rows = [];

    // Build list of items to display (including input field position)
    final List<_DisplayItem> displayItems = [];

    // If adding new memo, insert input at position 0
    if (isEditing && editingMemoId == null) {
      displayItems.add(_DisplayItem.input());
    }

    for (int i = 0; i < memos.length; i++) {
      final memo = memos[i];
      if (isEditing && memo.id == editingMemoId) {
        // Replace this memo with input field
        displayItems.add(_DisplayItem.input(memoId: memo.id));
      } else {
        displayItems.add(_DisplayItem.memo(memo, i));
      }
    }

    if (displayItems.isEmpty) return rows;

    // Calculate widths and group into rows
    final List<_ItemWithWidth> itemsWithWidth = [];
    for (final item in displayItems) {
      double width;
      if (item.isInput) {
        // Estimate input width based on current text or placeholder
        final text = controller.text.isEmpty ? '메모 입력...' : controller.text;
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: currentEditingIsBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        width = textPainter.width + 20; // Add some padding for input
      } else {
        final textPainter = TextPainter(
          text: TextSpan(
            text: item.memo!.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: item.memo!.isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        width = textPainter.width;
      }
      itemsWithWidth.add(_ItemWithWidth(item, width));
    }

    // Group into rows
    final List<List<_ItemWithWidth>> rowItems = [];
    List<_ItemWithWidth> currentRow = [];
    double currentRowWidth = 0;
    const pipeWidth = 32.0;

    for (final itemWithWidth in itemsWithWidth) {
      final neededWidth = currentRow.isEmpty
          ? itemWithWidth.width
          : itemWithWidth.width + pipeWidth;

      if (currentRow.isEmpty) {
        currentRow.add(itemWithWidth);
        currentRowWidth = itemWithWidth.width;
      } else if (currentRowWidth + neededWidth <= maxWidth) {
        currentRow.add(itemWithWidth);
        currentRowWidth += neededWidth;
      } else {
        rowItems.add(currentRow);
        currentRow = [itemWithWidth];
        currentRowWidth = itemWithWidth.width;
      }
    }
    if (currentRow.isNotEmpty) {
      rowItems.add(currentRow);
    }

    // Build rows
    for (final row in rowItems) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: _buildRowWithPipes(context, row),
          ),
        ),
      );
    }

    return rows;
  }

  List<Widget> _buildRowWithPipes(BuildContext context, List<_ItemWithWidth> rowItems) {
    final List<Widget> children = [];

    for (int i = 0; i < rowItems.length; i++) {
      final itemWithWidth = rowItems[i];
      final item = itemWithWidth.item;

      if (item.isInput) {
        // Render inline input field
        children.add(
          IntrinsicWidth(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: onKeyEvent,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                inputFormatters: [
                  _PixelWidthLimitingFormatter(
                    maxWidth: _HomeScreenState._maxTextWidth,
                    isBold: currentEditingIsBold,
                  ),
                ],
                autofocus: true,
                style: TextStyle(
                  color: Color(currentColorValue),
                  fontSize: 16,
                  fontWeight: currentEditingIsBold ? FontWeight.bold : FontWeight.normal,
                ),
                decoration: const InputDecoration(
                  hintText: '메모 입력...',
                  border: InputBorder.none,
                  counterText: '',
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: onSubmitted,
              ),
            ),
          ),
        );
      } else {
        // Render memo with gestures
        final memo = item.memo!;
        final memoIndex = item.memoIndex!;

        children.add(
          _SwipeableMemo(
            key: ValueKey(memo.id),
            memo: memo,
            memoIndex: memoIndex,
            totalMemos: memos.length,
            onDelete: onDelete,
            onCopy: onCopy,
            onEdit: onEdit,
            onToggleBold: onToggleBold,
            onReorder: onReorder,
          ),
        );
      }

      // Add pipe between items
      if (i < rowItems.length - 1) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '|',
              style: TextStyle(
                color: pipeColor,
                fontSize: 16,
              ),
            ),
          ),
        );
      }
    }

    return children;
  }
}

class _SwipeableMemo extends StatefulWidget {
  final Memo memo;
  final int memoIndex;
  final int totalMemos;
  final Function(String) onDelete;
  final Function(String) onCopy;
  final Function(String) onEdit;
  final Function(String) onToggleBold;
  final Function(int, int) onReorder;

  const _SwipeableMemo({
    super.key,
    required this.memo,
    required this.memoIndex,
    required this.totalMemos,
    required this.onDelete,
    required this.onCopy,
    required this.onEdit,
    required this.onToggleBold,
    required this.onReorder,
  });

  @override
  State<_SwipeableMemo> createState() => _SwipeableMemoState();
}

class _SwipeableMemoState extends State<_SwipeableMemo> {
  double _swipeOffset = 0.0;
  static const double _deleteThreshold = 50.0;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _swipeOffset += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    // Check if swiped far enough to delete
    if (_swipeOffset.abs() > _deleteThreshold) {
      // Call delete - parent will rebuild and remove this widget
      widget.onDelete(widget.memo.id);
    } else {
      // Reset position
      setState(() {
        _swipeOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate opacity based on swipe distance
    final opacity = (1.0 - (_swipeOffset.abs() / _deleteThreshold * 0.7)).clamp(0.3, 1.0);

    return GestureDetector(
      onTap: () => widget.onEdit(widget.memo.id),
      onDoubleTap: () => widget.onToggleBold(widget.memo.id),
      onLongPress: () => widget.onCopy(widget.memo.id),
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Transform.translate(
        offset: Offset(_swipeOffset, 0),
        child: Opacity(
          opacity: opacity,
          child: Text(
            widget.memo.title,
            style: TextStyle(
              color: Color(widget.memo.colorValue),
              fontSize: 16,
              fontWeight: widget.memo.isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _DisplayItem {
  final bool isInput;
  final Memo? memo;
  final int? memoIndex;
  final String? memoId; // For editing existing memo

  _DisplayItem._({
    required this.isInput,
    this.memo,
    this.memoIndex,
    this.memoId,
  });

  factory _DisplayItem.input({String? memoId}) => _DisplayItem._(
        isInput: true,
        memoId: memoId,
      );

  factory _DisplayItem.memo(Memo memo, int index) => _DisplayItem._(
        isInput: false,
        memo: memo,
        memoIndex: index,
      );
}

class _ItemWithWidth {
  final _DisplayItem item;
  final double width;

  _ItemWithWidth(this.item, this.width);
}

// Drag reorder temporarily disabled - will revisit UX
// class _DragData {
//   final Memo memo;
//   final int index;
//   _DragData(this.memo, this.index);
// }

class _PixelWidthLimitingFormatter extends TextInputFormatter {
  final double maxWidth;
  final bool isBold;

  _PixelWidthLimitingFormatter({
    required this.maxWidth,
    this.isBold = false,
  });

  double _measureWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_measureWidth(newValue.text) <= maxWidth) {
      return newValue;
    }
    // Reject the new input, keep old value
    return oldValue;
  }
}
