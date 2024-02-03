import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterapp/src/features/makereviews/application/caching_search_engine.dart';
import 'package:flutterapp/src/features/makereviews/domain/cse_results.dart' as cse;
import 'package:flutterapp/src/features/makereviews/presentation/caching_network_image.dart';


class ImagePopUp extends StatefulWidget {
  final String query;
  final Function(String) onImageSelected;
  const ImagePopUp({super.key, required this.query, required this.onImageSelected});

  @override
  State<ImagePopUp> createState() => _ImagePopUpState();
}

class _ImagePopUpState extends State<ImagePopUp> {
  final CachingSearchEngine _engine = CachingSearchEngine();
  var _items = <cse.Item>[];

  @override 
  void initState() {
    super.initState();
    search(widget.query);
  }

  @override 
  void didUpdateWidget(covariant ImagePopUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      search(widget.query);
    }
  }

  Future search(String q) async {
    var res = await _engine.imageSearch(q);
    var items = res.items;
    if (items != null && items.isNotEmpty) {
      setState(() => _items = items);
    }

  }

  @override
  Widget build(BuildContext context) {
    print('items are $_items');
    return AlertDialog( 
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SizedBox( 
        height: 300,
        child: Column( 
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [ 
            for (var item in _items) 
              Expanded( 
                child: Padding( 
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect( 
                    borderRadius: BorderRadius.circular(10),
                    child: GestureDetector( 
                      onTap: () {
                        widget.onImageSelected(item.link!);
                        Navigator.of(context).pop();
                      },
                      child: CachingNetworkImage(item.link!),
                    )
                  )
                )
              )
          ]
        )
      )
    );
  }
}