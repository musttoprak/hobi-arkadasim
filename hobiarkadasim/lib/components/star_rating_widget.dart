import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class StarRatingWidget extends StatefulWidget {
  int id;
  int? rating;

  StarRatingWidget(this.id,this.rating, {Key? key}) : super(key: key);

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  List<Color> starColors = List.filled(5, Colors.grey);
  double iconSize = 16;

  @override
  void initState() {
    setState(() {
      if (widget.rating != null && widget.rating != 0) {
        starColors = List.generate(
          5,
          (i) => i <= widget.rating!-1 ? Colors.yellow : Colors.grey,
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          5,
          (index) => IconButton(
            constraints: const BoxConstraints(minWidth: 20),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.star),
            iconSize: iconSize,
            onPressed: () => setState(() {
                      starColors = List.generate(
                        5,
                        (i) => i <= index
                            ? Colors.yellow
                            : Colors.grey,
                      );
                    //RouteApiService.changeRatingRoute(widget.id, index + 1);
                    }),
            color: starColors[index],
          ),
        ),
      ),
    );
  }
}
