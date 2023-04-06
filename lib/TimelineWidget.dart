import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'ProcessCard.dart';

class TimelineModel extends ChangeNotifier {
  List<ProcessCard> processCard = [];
  Future<List<ProcessCard>> _getProcess() async {
    List<ProcessCard> processCard = [];

    processCard.add(ProcessCard(Duration(seconds: 10), "Issue Creation",
        "The author creates a new issue.", Icons.adjust_rounded));
    processCard.add(ProcessCard(Duration(seconds: 10), "Topic Approval",
        "The author waist for 3 - 5 days.", Icons.check));
    processCard.add(ProcessCard(Duration(seconds: 10), "Article Writing",
        "The author writes the topic.", Icons.border_color_rounded));
    processCard.add(ProcessCard(Duration(seconds: 10), "PR Creation",
        "The author creates a new Pull Request", Icons.call_merge_rounded));
    processCard.add(ProcessCard(Duration(seconds: 10), "Review Process",
        "This ensure article is correct", Icons.change_circle_rounded));
    processCard.add(ProcessCard(Duration(seconds: 10), "Final Review",
        "The article is polished", Icons.bookmark_add_rounded));
    return processCard;
  }

  Future setup() async {
    processCard = await _getProcess();
    notifyListeners();
  }

  void addProcessCard(
      Duration timestamp, String title, String description, icon) {
    processCard.add(ProcessCard(timestamp, title, description, icon));
    scrollTo(processCard.length - 1, animate: true);
    notifyListeners();
  }

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  void scrollTo(int idx, {bool animate = false}) {
    if (itemScrollController.isAttached == false) {
      return;
    }
    if (animate) {
      itemScrollController.scrollTo(
          index: idx,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic);
      return;
    }
    itemScrollController.jumpTo(index: idx);
  }
}

class TimelineWidget extends StatelessWidget {
  TimelineWidget({
    super.key,
  });

  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.pinkAccent,
    Colors.blue
  ];
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  Widget _buildListItem(
      BuildContext context, int index, List<ProcessCard> processCard) {
    return Container(
        child: Row(children: <Widget>[
      Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 1, right: 0),
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                    color: colors[(index + 1) % 4],
                    borderRadius: BorderRadius.circular(3)),
                child: Icon(
                  Icons.remove,
                  color: Colors.white,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 1, right: 1),
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: colors[(index + 1) % 4],
                    borderRadius: BorderRadius.circular(3)),
                child: Text("5s",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              Container(
                margin: EdgeInsets.only(left: 0, right: 0),
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                    color: colors[(index + 1) % 4],
                    borderRadius: BorderRadius.circular(3)),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            width: 2,
            height: 60,
            color: Colors.black,
          ),
          Container(
            margin: EdgeInsets.only(left: 8, right: 5),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: colors[(index + 1) % 4],
                borderRadius: BorderRadius.circular(50)),
            child: Icon(
              processCard[index].icon,
              color: Colors.white,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 8, right: 5),
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
                color: colors[(index + 1) % 4],
                borderRadius: BorderRadius.circular(3)),
            child: Text(processCard[index].formatTimestamp(),
                style: TextStyle(color: Colors.white)),
          ),
          Container(
            width: 2,
            height: 80,
            color:
                index == processCard.length - 1 ? Colors.white : Colors.black,
          ),
        ],
      ),
      Expanded(
          child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                width: 3,
                color: colors[(index + 1) % 4],
              ),
              left: BorderSide(
                width: 3,
                color: colors[(index + 1) % 4],
              ),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: Colors.black26,
              )
            ]),
        height: 140,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                processCard[index].title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors[(index + 1) % 4],
                ),
              ),
              Text(
                processCard[index].description,
                style: TextStyle(fontSize: 17, letterSpacing: 2),
              )
            ],
          ),
        ),
      ))
    ]));
  }

  @override
  Widget build(BuildContext context) {
    var processCard = context.select((TimelineModel p) => p.processCard);

    return ScrollablePositionedList.builder(
      itemScrollController: context.read<TimelineModel>().itemScrollController,
      itemPositionsListener:
          context.read<TimelineModel>().itemPositionsListener,
      itemCount: context.watch<TimelineModel>().processCard.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildListItem(context, index, processCard);
      },
    );
  }
}
