import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:isolated_flutter/model/photo_model.dart';

class ListPhoto extends StatelessWidget {
  const ListPhoto({super.key, required this.listPhoto});

  final List<Photo> listPhoto;

  @override
  Widget build(BuildContext context) {
    return _buildListPhoto();
  }

  Widget _buildListPhoto() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: listPhoto.length,
      itemBuilder: (context, index) {
        final item = listPhoto[index];
        return Container(
          height: 150,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Image.network(
                item.url,
                width: 100,
                height: 120,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Id: ${item.id}",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: const Color.fromARGB(255, 69, 68, 68),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Flexible(
                      child: Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        "Title: ${item.title}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: const Color.fromARGB(255, 69, 68, 68),
                              fontSize: 13,
                            ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Flexible(
                      child: Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        "Url: ${item.url}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: const Color.fromARGB(255, 69, 68, 68),
                              fontSize: 13,
                            ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
