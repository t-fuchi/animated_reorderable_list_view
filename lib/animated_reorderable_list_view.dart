// ignore_for_file: invalid_use_of_protected_member

library animated_reorderable_list_view;

import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedReorderableListView extends ReorderableListView {
  final State state;
  final List<Object> items;
  final List<Widget> children;
  late final Widget Function(AnimationController, Widget)?
      buildInsertAnimationWidget;
  late final Widget Function(AnimationController, Widget)?
      buildRemoveAnimationWidget;
  final AnimationController animationController;

  static List<Function(AnimationController, Widget)?> buildList = [];

  AnimatedReorderableListView({
    super.key,
    required this.state,
    required this.items,
    required this.animationController,
    required this.children,
    required super.onReorder,
    buildInsertAnimationWidget,
    buildRemoveAnimationWidget,
  }) : super(children: process(animationController, children)) {
    if (buildInsertAnimationWidget == null) {
      this.buildInsertAnimationWidget =
          (AnimationController animationController, Widget child) {
        return SlideTransition(
          key: GlobalKey(),
          position:
              Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .animate(CurvedAnimation(
            parent: animationController,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      };
    } else {
      this.buildInsertAnimationWidget = buildInsertAnimationWidget;
    }
    if (buildRemoveAnimationWidget == null) {
      this.buildRemoveAnimationWidget =
          (AnimationController animationController, Widget child) {
        return SlideTransition(
          key: GlobalKey(),
          position:
              Tween<Offset>(begin: Offset.zero, end: const Offset(1.0, 0.0))
                  .animate(CurvedAnimation(
            parent: animationController,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      };
    } else {
      this.buildRemoveAnimationWidget = buildRemoveAnimationWidget;
    }
  }

  static List<Widget> process(
      AnimationController animationController, List<Widget> children) {
    if (buildList.isEmpty) {
      buildList = List.generate(children.length, (_) => null);
    }
    for (int i = 0; i < children.length; ++i) {
      if (buildList[i] != null) {
        children[i] = buildList[i]!(animationController, children[i]);
      }
    }
    return children;
  }

  void insert(int index, Object item,
      [Widget Function(Widget widget)? buildItem]) {
    if (0 <= index && index <= items.length) {
      animationController.reset();
      items.insert(index, item);
      buildList = List.generate(items.length, (_) => null);
      if (buildItem == null) {
        buildList[index] = buildInsertAnimationWidget;
      } else {
        buildList[index] =
            (c, w) => buildInsertAnimationWidget!(c, buildItem(w));
      }
      Animation<Offset> downAnimation =
          Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero)
              .animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ));
      for (int i = index + 1; i < items.length; ++i) {
        buildList[i] = (animationController, widget) => SlideTransition(
              key: GlobalKey(),
              position: downAnimation,
              child: widget,
            );
      }
      state.setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        void listener(AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            animationController.removeStatusListener(listener);
            for (int i = 0; i < buildList.length; ++i) {
              buildList[i] = null;
            }
            state.setState(() {});
          }
        }

        animationController.addStatusListener(listener);
        animationController.forward();
      });
    }
  }

  void removeAt(int index, [Widget Function(Widget widget)? buildItem]) {
    if (0 <= index && index < children.length) {
      animationController.reset();
      if (buildItem == null) {
        buildList[index] = buildRemoveAnimationWidget;
      } else {
        buildList[index] =
            (c, w) => buildRemoveAnimationWidget!(c, buildItem(w));
      }
      Animation<Offset> upAnimation =
          Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -1.0))
              .animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ));
      for (int i = index + 1; i < children.length; ++i) {
        buildList[i] = (animationController, widget) => SlideTransition(
              key: GlobalKey(),
              position: upAnimation,
              child: widget,
            );
      }
      state.setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        void listener(AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            animationController.removeStatusListener(listener);
            items.removeAt(index);
            children.removeAt(index);
            for (int i = 0; i < buildList.length; ++i) {
              buildList[i] = null;
            }
            state.setState(() {});
          }
        }

        animationController.addStatusListener(listener);
        animationController.forward();
      });
    }
  }

  void removeItemsAt(Set<int> indexes,
      [Widget Function(Widget widget)? buildItem]) {
    if (indexes.isEmpty) return;
    animationController.reset();
    int count = 0;
    for (int index = 0; index < children.length; ++index) {
      if (indexes.contains(index)) {
        count += 1;
        if (buildItem == null) {
          buildList[index] = buildRemoveAnimationWidget;
        } else {
          buildList[index] =
              (c, w) => buildRemoveAnimationWidget!(c, buildItem(w));
        }
      } else if (0 < count) {
        Animation<Offset> upAnimation =
            Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -1.0 * count))
                .animate(CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ));
        buildList[index] = (animationController, widget) => SlideTransition(
              key: GlobalKey(),
              position: upAnimation,
              child: widget,
            );
      }
    }
    state.setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          animationController.removeStatusListener(listener);
          for (int index in (indexes.toList()..sort()).reversed.toList()) {
            children.removeAt(index);
            items.removeAt(index);
          }
          for (int i = 0; i < buildList.length; ++i) {
            buildList[i] = null;
          }
          state.setState(() {});
        }
      }

      animationController.addStatusListener(listener);
      animationController.forward();
    });
  }

  void move(int fromIndex, int toIndex,
      [Widget Function(Widget widget)? buildItem]) {
    if (fromIndex < 0 ||
        toIndex < 0 ||
        children.length <= fromIndex ||
        children.length <= toIndex) {
      return;
    }

    animationController.reset();
    if (toIndex < fromIndex) {
      // move up
      Animation<Offset> downAnimation =
          Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1))
              .animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ));
      for (int i = toIndex; i < fromIndex; ++i) {
        buildList[i] = (animationController, widget) => SlideTransition(
              key: GlobalKey(),
              position: downAnimation,
              child: widget,
            );
      }
      Animation<Offset> slideUpAnimation = Tween<Offset>(
              begin: Offset.zero,
              end: Offset(0, -(fromIndex - toIndex).toDouble()))
          .animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ));
      buildList[fromIndex] = (c, w) => SlideTransition(
          key: GlobalKey(),
          position: slideUpAnimation,
          child: Material(
              elevation: 4, child: buildItem == null ? w : buildItem(w)));
    }
    // fromIndex < toIndex
    else {
      // move down
      items.insert(toIndex, items.removeAt(fromIndex));
      Animation<Offset> upAnimation =
          Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ));
      for (int i = fromIndex; i < toIndex; ++i) {
        buildList[i] = (animationController, widget) => SlideTransition(
              key: GlobalKey(),
              position: upAnimation,
              child: widget,
            );
      }
      Animation<Offset> slideDownAnimation = Tween<Offset>(
              begin: Offset(0, -(toIndex - fromIndex).toDouble()),
              end: Offset.zero)
          .animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ));
      buildList[toIndex] = (c, w) => SlideTransition(
          key: GlobalKey(),
          position: slideDownAnimation,
          child: Material(
              elevation: 4, child: buildItem == null ? w : buildItem(w)));
    }
    state.setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          animationController.removeStatusListener(listener);
          if (toIndex < fromIndex) {
            items.insert(toIndex, items.removeAt(fromIndex));
          }
          for (int i = 0; i < buildList.length; ++i) {
            buildList[i] = null;
          }
          state.setState(() {});
        }
      }

      animationController.addStatusListener(listener);
      animationController.forward();
    });
  }

  void swap(int i1, int i2, [Widget Function(Widget widget)? buildItem]) {
    if (0 <= i1 &&
        i1 < children.length &&
        0 <= i2 &&
        i2 < children.length &&
        i1 != i2) {
      animationController.reset();
      int minIndex = min(i1, i2);
      int maxIndex = max(i1, i2);
      items.insert(maxIndex - 1, items.removeAt(minIndex));
      var downAnimation = const AlwaysStoppedAnimation(Offset(0, 1));
      for (int i = minIndex; i < maxIndex - 1; ++i) {
        buildList[i] = (c, w) => SlideTransition(
            key: GlobalKey(), position: downAnimation, child: w);
      }
      var slideDownAnimation = Tween<Offset>(
              begin: Offset(0, -(maxIndex - minIndex - 1).toDouble()),
              end: const Offset(0, 1))
          .animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ));
      buildList[maxIndex - 1] = (c, w) => SlideTransition(
            key: GlobalKey(),
            position: slideDownAnimation,
            child: Material(elevation: 4, child: w),
          );
      var slideUpAnimation = Tween<Offset>(
              begin: Offset.zero,
              end: Offset(0, -(maxIndex - minIndex).toDouble()))
          .animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ));
      buildList[maxIndex] = (c, w) => SlideTransition(
            key: GlobalKey(),
            position: slideUpAnimation,
            child: Material(elevation: 4, child: w),
          );

      state.setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        void listener(AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            animationController.removeStatusListener(listener);
            items.insert(minIndex, items.removeAt(maxIndex));
            animationController.reset();
            for (int i = 0; i < buildList.length; ++i) {
              buildList[i] = null;
            }
            state.setState(() {});
          }
        }

        animationController.addStatusListener(listener);
        animationController.forward();
      });
    }
  }
}
