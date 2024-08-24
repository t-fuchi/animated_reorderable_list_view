import 'dart:math';

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
      buildInsertAnimationWidget: (animationController, child) {
        // Slide In Downward
        // return ClipRect(
        //   key: GlobalKey(),
        //   child: SlideTransition(
        //     position:
        //         Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        //             .animate(CurvedAnimation(
        //       parent: animationController,
        //       curve: Curves.easeInOut,
        //     )),
        //     child: child,
        //   ),
        // );

        // Scale In
        // return ScaleTransition(
        //   key: GlobalKey(),
        //   scale:
        //     Tween<double>(begin: 0.0, end: 1.0)
        //       .animate(CurvedAnimation(
        //         parent: animationController,
        //         curve: Curves.easeInOut,
        //       )),
        //   alignment: const Alignment(-1, 0),
        //   child: child,
        // );

        // Expand In
        Animation<double> rotation =
            Tween<double>(begin: pi/2, end: 0).animate(CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ));
        return MatrixTransition(
            key: GlobalKey(),
            animation: rotation,
            onTransform: Matrix4.rotationX,
            alignment: Alignment.topCenter,
            child: Container(
              color: Colors.blue[200],
              child: child),
            );

        // Fade In
        // Animation<double> opacity =
        //     Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        //   parent: animationController,
        //   curve: Curves.easeInOut,
        // ));
        // return FadeTransition(
        //   key: GlobalKey(),
        //   opacity: opacity,
        //   child: child);
        
        // Rotate In
        // Animation<double> turns =
        //     Tween<double>(begin: 0.25, end: 0).animate(CurvedAnimation(
        //   parent: animationController,
        //   curve: Curves.easeOut,
        // ));
        // return RotationTransition(
        //   key: GlobalKey(),
        //   turns: turns,
        //   alignment: const Alignment(1, 1),
        //   child: Container(color: Colors.red[200], child: child),
        // );
        
      },
      
      buildRemoveAnimationWidget: (animationController, child) {
        // Slide Out Upward
        // return ClipRect(
        //   key: GlobalKey(),
        //   child: SlideTransition(
        //     position:
        //         Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1))
        //             .animate(CurvedAnimation(
        //       parent: animationController,
        //       curve: Curves.easeInOut,
        //     )),
        //     child: child,
        //   ),
        // );

        // Scale Out
        // return ScaleTransition(
        //   key: GlobalKey(),
        //   scale:
        //     Tween<double>(begin: 1, end: 0)
        //       .animate(CurvedAnimation(
        //         parent: animationController,
        //         curve: Curves.easeInOut,
        //       )),
        //   alignment: const Alignment(0, -1),
        //   child: Container(
        //     color: Colors.red[200],
        //     child: child),
        // );

        // Shrink Out
        Animation<double> rotation =
            Tween<double>(begin: 0, end: pi/2).animate(CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ));
        return MatrixTransition(
            key: GlobalKey(),
            animation: rotation,
            onTransform: Matrix4.rotationX,
            alignment: Alignment.topCenter,
            child: Container(
              color: Colors.red[200],
              child: child),
            );

        // Fade Out
        // Animation<double> opacity =
        //     Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
        //   parent: animationController,
        //   curve: Curves.easeInOut,
        // ));
        // return FadeTransition(
        //   key: GlobalKey(),
        //   opacity: opacity,
        //   child: child);

        // Rotate Out
        // Animation<double> turns =
        //     Tween<double>(begin: 0, end: 0.25).animate(CurvedAnimation(
        //   parent: animationController,
        //   curve: Curves.easeIn,
        // ));
        // return RotationTransition(
        //   key: GlobalKey(),
        //   turns: turns,
        //   alignment: const Alignment(1, 1),
        //   child: Container(color: Colors.red[200], child: child),
        // );
        
      },
      children: [
        for (int i = 0; i < _items.length; ++i)
          ListTile(
              key: GlobalKey(),
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
              icon: const Icon(Icons.arrow_upward),
              onPressed: () {
                animatedReorderableListView.move(4, 1);
              }),
          IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: () {
                animatedReorderableListView.move(1, 4);
              }),
          IconButton(
              icon: const Icon(Icons.swap_vert),
              onPressed: () {
                animatedReorderableListView.swap(1, 4);
              }),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              animatedReorderableListView.insert(1, 'New Item');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              animatedReorderableListView.removeAt(1);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              Set<int> indexes = {
                for (int i = 0; i < _items.length; ++i)
                  if (i % 2 == 1) i
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
