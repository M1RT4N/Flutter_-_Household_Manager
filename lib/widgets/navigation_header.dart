import 'package:flutter/material.dart';

const _sectionBubbleRadius = 8.0;
const _buttonPadding = 16.0;
const _sectionBarSize = 60.0;
const _buttonPaddingSection = 16.0;

class NavigationHeader<E extends Enum> extends StatefulWidget {
  final List<E> values;

  final Widget Function(E) selectionCallback;

  const NavigationHeader({
    super.key,
    required this.values,
    required this.selectionCallback,
  });

  @override
  State<NavigationHeader<E>> createState() => _NavigationHeaderState<E>();
}

class _NavigationHeaderState<E extends Enum>
    extends State<NavigationHeader<E>> {
  late E _selectedSection;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedSection = widget.values.first;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - _sectionBarSize,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: _sectionBarSize,
              maxHeight: _sectionBarSize,
              child: _buildSectionButtons(),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [widget.selectionCallback(_selectedSection)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _buttonPadding),
      child: Row(
        children: [
          for (final section in widget.values)
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(_sectionBubbleRadius),
                      right: Radius.circular(_sectionBubbleRadius),
                    ),
                  ),
                  padding: EdgeInsets.all(_buttonPaddingSection),
                  backgroundColor: section == _selectedSection
                      ? Colors.blue[900]
                      : Colors.grey[900],
                ),
                onPressed: () {
                  setState(() {
                    _selectedSection = section;
                  });
                },
                child: Text(
                  section.toString(),
                  style: TextStyle(
                    color: section == _selectedSection
                        ? Colors.white
                        : Colors.grey,
                    fontWeight: section == _selectedSection
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
