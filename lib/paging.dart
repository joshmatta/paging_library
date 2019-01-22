library paging;

import 'package:flutter/material.dart';

/// Signature for a function that returns a Future List of type 'T' i.e. list
/// of items in a particular page that is being asynchronously called.
///
/// Used by [Pagination] widget.
typedef PaginationBuilder<T> = Future<List<T>> Function(int currentListSize);

/// Signature for a function that creates a widget for a given item of type 'T'.
typedef ItemWidgetBuilder<T> = Widget Function(T item);

/// A scrollable list which implements pagination.
///
/// When scrolled to the end of the list [Pagination] calls [pageBuilder] which
/// must be implemented which returns a Future List of type 'T'.
///
/// [itemBuilder] creates widget instances on demand.
class Pagination<T> extends StatefulWidget {

  /// Creates a scrollable, paginated, linear array of widgets.
  ///
  /// The arguments [pageBuilder], [itemBuilder] must not be null.
  Pagination({
    Key key,
    @required this.pageBuilder,
    @required this.itemBuilder,
    this.progress,
    this.onError,
  })  : assert(pageBuilder != null),
        assert(itemBuilder != null),
        super(key: key);

  final PaginationBuilder<T> pageBuilder;
  final ItemWidgetBuilder<T> itemBuilder;
  final Widget progress;
  final Function(dynamic error) onError;

  @override
  _PaginationState<T> createState() => _PaginationState<T>();
}

class _PaginationState<T> extends State<Pagination<T>> {
  final List<T> _list = List();
  bool _isLoading = false;
  bool _isEndOfList = false;

  void fetchMore() {
    if (!_isLoading) {
      _isLoading = true;
      widget.pageBuilder(_list.length).then((list) {
        _isLoading = false;
        if (list.isEmpty) {
          _isEndOfList = true;
        }
        setState(() {
          _list.addAll(list);
        });
      }).catchError((error) {
        print(error);
        if (widget.onError != null) {
          widget.onError(error);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMore();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, position) {
        if (position < _list.length) {
          return widget.itemBuilder(_list[position]);
        } else if (position == _list.length && !_isEndOfList) {
          fetchMore();
          return widget.progress ??
              Align(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
        }
        return null;
      },
    );
  }
}