import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:msagetrader/forms/task_form.dart';
import 'package:msagetrader/models/task.dart';
import 'package:msagetrader/providers/tasks.dart';
import 'package:msagetrader/utils/snacks.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class TasksTab extends StatefulWidget {
  @override
  _TasksTabState createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  bool _isInit = true;
  int longPressedId;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        final _ta = Provider.of<Tasks>(context, listen: false);
        if (_ta.hasMoreData()) {
          cpiMsgSnackBar(
              context, "fetching ---", Theme.of(context).primaryColor, 1);
          _ta.fetchTasks(loadMore: true);
        } else {
          doneMsgSnackBar(context, "No more data to load", Colors.orange, 1);
        }
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<Tasks>(context, listen: false).fetchTasks();
    }
    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _tasks = Provider.of<Tasks>(context);
    List<Task> tasks = _tasks.tasks;

    return Container(
      child: _tasks.loading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            )
          : RefreshIndicator(
              onRefresh: () =>
                  Provider.of<Tasks>(context, listen: false).fetchTasks(),
              child: tasks.length > 0
                  ? StaggeredGridView.countBuilder(
                      controller: scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      itemCount: tasks.length,
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (context, index) => GestureDetector(
                        child: TaskItem(
                            tasks: tasks,
                            index: index,
                            deleteIndex: longPressedId),
                        onTap: () => navigateToPage(
                          context,
                          TaskForm(newTask: false, taskID: tasks[index].uid),
                        ),
                        onLongPressStart: (_) {
                          setState(() {
                            longPressedId = index;
                          });
                        },
                        onLongPress: () => showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                "Warning",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                "You are about to delete this Task. Note that this action is irrevesibe. Are you sure about this?",
                              ),
                              actions: [
                                TextButton(
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _tasks.deleteById(tasks[index].uid);
                                  },
                                ),
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    setState(() {
                                      longPressedId = null;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        onLongPressEnd: (_) {
                          setState(() {
                            longPressedId = null;
                          });
                        },
                      ),
                      staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5.0,
                    )
                  : ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            SizedBox(height: 50),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 40),
                                child: Text(
                                  "Call them Tasks, call them Notes :) Whatever suits you best. \n\nAdd some tasks",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      scrollDirection: Axis.vertical,
                    ),
            ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final int index;
  final int deleteIndex;
  final List<Task> tasks;

  const TaskItem({
    Key key,
    @required this.tasks,
    @required this.index,
    @required this.deleteIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Task task = tasks[index];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: deleteIndex == index
              ? Colors.red
              : Theme.of(context).primaryColor.withOpacity(0.7),
          width: 1,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              task.title,
              style: Theme.of(context).textTheme.headline3.copyWith(
                    fontWeight: FontWeight.w800,
                    color: deleteIndex == index
                        ? Colors.red
                        : Colors.grey.shade800,
                  ),
            ),
            Divider(color: Theme.of(context).primaryColor),
            Text(
              task.description,
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: deleteIndex == index
                        ? Colors.red
                        : Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
