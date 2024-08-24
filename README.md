# animated_reorderable_list_view

This library is a easy-to-use solution for implementing animated list with drag-and-drop functionality in Flutter.

## Features

- [x] Smooth transition during item insertion and removal from the list with animations.
- [x] Drag and Drop support (ReorderableList) for ListView with Animation.
- [x] This class is an extension of standard ReorderableListView, enabling you to utilize all of its features. [ReorderableListView class](https://api.flutter.dev/flutter/material/ReorderableListView-class.html)
- [x] It can be both animated and reordered at the same time
- [x] Animating items is as simple as updating the list.
- [x] Customizable animation.
- [x] Reorder, Insert, Remove, Move, Swap, Multiple-Removes

## Installing

```sh
flutter pub add animated_reorderable_list_view
flutter pub get
```


## Usage

```dart
class AnimatedReorderableListViewExampleState
    extends State<AnimatedReorderableListViewExample>
    with SingleTickerProviderStateMixin {
  final List<String> _items = List.generate(10, (index) => 'Item ${index + 1}');
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var animatedReorderableListView = AnimatedReorderableListView(
      state: this,
      items: _items,
      animationController: animationController,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          _items.insert(oldIndex < newIndex ? newIndex - 1 : newIndex,
              _items.removeAt(oldIndex));
        });
      },
      children: [
        for (int i = 0; i < _items.length; ++i)
          ListTile(key: GlobalKey(),
                   title: Text(_items[i]),
                   trailing: ReorderableDragStartListener(
                    index: i,
                    child: const Icon(Icons.drag_handle),
                   ))
      ],
    );
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              animatedReorderableListView.insert(0, 'New Item');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              animatedReorderableListView.removeAt(0);
            },
          ),
        ],
      ),
      body: animatedReorderableListView,
    );
  }
}
```
