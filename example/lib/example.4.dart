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
          ListTile(
              key: GlobalKey(),
              title: TextFormField(
                initialValue: _items[i],
                onChanged: (value) {
                  _items[i] = value;
                },
              ),
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
