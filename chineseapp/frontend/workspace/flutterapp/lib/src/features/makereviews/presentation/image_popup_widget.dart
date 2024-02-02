import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/makereviews/application/get_images_controller.dart';

class ImagePopUp extends ConsumerStatefulWidget {
  final String query;
  final Function(String) onImageSelected;
  const ImagePopUp({super.key, required this.query, required this.onImageSelected});

  @override
  ConsumerState<ImagePopUp> createState() => _ImagePopUpState();
}

class _ImagePopUpState extends ConsumerState<ImagePopUp> {
  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(searchResultsProvider(widget.query));

    return AlertDialog( 
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SizedBox( 
        height: 300,
        child: searchResultsAsync.when( 
          data: (searchResults) {
            return Row( 
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: searchResults.take(3).map((searchResult) {
                final imageLink = searchResult.getContextLink();
                return Expanded( 
                  child: Padding( 
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect( 
                      borderRadius: BorderRadius.circular(10),
                      child: GestureDetector( 
                        onTap: () {
                          widget.onImageSelected(imageLink);
                          Navigator.of(context).pop();
                        },
                        child: Image.network(
                          imageLink!,
                          fit: BoxFit.cover,
                        ),
                      )
                    ) 
                  )
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        )
      )
    );
  }
}