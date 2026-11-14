import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';

import '../../domain/entities/location.dart';

class LocationSearchBar extends StatefulWidget {
  const LocationSearchBar({
    super.key,
    required this.value,
    required this.onChanged,
    required this.results,
    required this.onSelectResult,
    this.searching = false,
    this.placeholder,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final List<Location> results;
  final ValueChanged<Location> onSelectResult;
  final bool searching;

  /// Hint text; defaults to the localized "search places" hint.
  final String? placeholder;

  @override
  State<LocationSearchBar> createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(covariant LocationSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the field in sync when the provider clears the keyword.
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _shadow = [
    BoxShadow(color: Color(0x26000000), blurRadius: 6, offset: Offset(0, 2)),
  ];

  @override
  Widget build(BuildContext context) {
    final query = widget.value;
    final showResults = query.length > 2 && widget.results.isNotEmpty;
    final showEmpty =
        query.length > 2 && widget.results.isEmpty && !widget.searching;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 12, right: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _shadow,
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onChanged,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                  decoration: InputDecoration(
                    hintText:
                        widget.placeholder ?? context.l10n.searchPlaceholder,
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (query.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF9CA3AF),
                  ),
                  onPressed: () => widget.onChanged(''),
                ),
            ],
          ),
        ),
        if (showResults || showEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 320),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: _shadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: showEmpty
                ? Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        context.l10n.searchNotFound,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.results.length.clamp(0, 6),
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      indent: 14,
                      endIndent: 14,
                      color: Color(0xFFF3F4F6),
                    ),
                    itemBuilder: (context, i) {
                      final item = widget.results[i];
                      return InkWell(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          widget.onSelectResult(item);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              if (item.address.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
