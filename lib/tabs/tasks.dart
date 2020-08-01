import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:msagetrader/forms/task_form.dart';
import 'package:msagetrader/models/task.dart';
import 'package:msagetrader/providers/tasks.dart';
import 'package:msagetrader/utils/utils.dart';
import 'package:provider/provider.dart';

class TasksTab extends StatefulWidget {
  @override
  _TasksTabState createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  bool _isInit = true;

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
  Widget build(BuildContext context) {
    final _tasks = Provider.of<Tasks>(context);
    List<Task> tasks = _tasks.tasks;

    return Container(
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 4,
        itemCount: tasks.length,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) => GestureDetector(
          child: TaskItem(tasks: tasks, index: index),
          onTap: () => navigateToPage(
            context,
            TaskForm(newTask: false, taskID: tasks[index].id),
          ),
        ),
        staggeredTileBuilder: (index) => StaggeredTile.fit(2),
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 5.0,
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final int index;
  final List<Task> tasks;

  const TaskItem({
    Key key,
    @required this.tasks,
    @required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Task task = tasks[index];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
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
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade800,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              task.description,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
