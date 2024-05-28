import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/models/status_model.dart';

class StatusScreen extends StatefulWidget {
  static const String routeName='/status-screen';
  final Status status;
  const StatusScreen({super.key,required this.status});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final StoryController storyController=StoryController();
  List<StoryItem> storyItems=[];


  @override
  void initState() {
    initStoryPageItems();
    super.initState();
  }

  void initStoryPageItems(){
    for(int i=0;i<widget.status.photoUrl.length;i++){
      storyItems.add(StoryItem.pageImage(url: widget.status.photoUrl[i] , controller: storyController));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: storyItems.isEmpty? const Loader():StoryView(storyItems: storyItems, controller:storyController,onVerticalSwipeComplete: (p0) {
        if(p0==Direction.down){
          Navigator.pop(context);
        }

      },
      onComplete: () => Navigator.pop(context),
      ),
    );
  }
}