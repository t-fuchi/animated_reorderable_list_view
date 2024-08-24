import 'package:flutter/material.dart';
import 'package:animated_reorderable_list_view/animated_reorderable_list_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedReorderableListViewExample(),
    );
  }
}

class AnimatedReorderableListViewExample extends StatefulWidget {
  const AnimatedReorderableListViewExample({super.key});
  @override
  AnimatedReorderableListViewExampleState createState() =>
      AnimatedReorderableListViewExampleState();
}

class AnimatedReorderableListViewExampleState
    extends State<AnimatedReorderableListViewExample>
    with SingleTickerProviderStateMixin {
  final List<({String title, bool isChecked})> _items = List.generate(
      10, (index) => (title: 'Item ${index + 1}', isChecked: false));
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
          ListTile(
              key: GlobalKey(),
              leading: Checkbox(
                  value: _items[i].isChecked,
                  onChanged: (value) {
                    setState(() {
                      _items[i] = (title: _items[i].title, isChecked: value!);
                    });
                  }),
              title: Text(_items[i].title),
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
              icon: const Icon(Icons.arrow_upward),
              onPressed: () {
                animatedReorderableListView.move(4, 0);
              }),
          IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: () {
                animatedReorderableListView.move(0, 4);
              }),
          IconButton(
              icon: const Icon(Icons.swap_vert),
              onPressed: () {
                animatedReorderableListView.swap(0, 4);
              }),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              animatedReorderableListView
                  .insert(0, (title: 'New Item', isChecked: false));
            },
          ),
          IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () {
                setState(() {
                  for (int i = 0; i < _items.length; ++i) {
                    _items[i] = (title: _items[i].title, isChecked: true);
                  }
                });
              }),
          IconButton(
              icon: const Icon(Icons.remove_done),
              onPressed: () {
                setState(() {
                  for (int i = 0; i < _items.length; ++i) {
                    _items[i] = (title: _items[i].title, isChecked: false);
                  }
                });
              }),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Set<int> indexes = {
                for (int i = 0; i < _items.length; ++i)
                  if (_items[i].isChecked) i
              };
              animatedReorderableListView.removeItemsAt(indexes);
            },
          ),
        ],
      ),
      body: animatedReorderableListView,
    );
  }
}
