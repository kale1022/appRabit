import 'dart:async';
import 'package:flutter/material.dart';

class DebouncedSearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const DebouncedSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  @override
  State<DebouncedSearchField> createState() => DebouncedSearchFieldState();
}

class DebouncedSearchFieldState extends State<DebouncedSearchField>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    // Update UI to show text as user types
    setState(() {});
    
    // Cancel previous timer and start new one
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.onChanged(text);
    });
  }

  void _onSubmitted(String text) {
    // Cancel debounce timer and search immediately on Enter
    _debounceTimer?.cancel();
    widget.onChanged(text);
  }

  void clearSearch() {
    _controller.clear();
    setState(() {});
  }

  void _onFocusChanged(bool hasFocus) {
    setState(() {
      _hasFocus = hasFocus;
    });
    if (hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _hasFocus ? const Color(0xFF6366F1) : Colors.grey[300]!,
          width: _hasFocus ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onTextChanged,
        onSubmitted: _onSubmitted,
        onTap: () => _onFocusChanged(true),
        onTapOutside: (_) => _onFocusChanged(false),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: _hasFocus ? const Color(0xFF6366F1) : Colors.grey[600],
            size: 20,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 14.0,
          ),
        ),
      ),
    );
  }
}
