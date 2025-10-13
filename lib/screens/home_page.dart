import 'package:combine_maker/screens/create_outfit_page.dart';
import 'package:flutter/material.dart';
import 'package:combine_maker/models/outfit.dart';
import 'package:combine_maker/widgets/image_from_path.dart';
import 'package:combine_maker/models/image_library.dart';

class HomePage extends StatefulWidget {
  final AppState appState;
  final ImageLibraryState imageLibraryState;
  const HomePage({super.key, required this.appState, required this.imageLibraryState});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kombinlerim'),
      ),
      body: ValueListenableBuilder<List<Outfit>>(
        valueListenable: widget.appState,
        builder: (context, outfits, _) {
          if (outfits.isEmpty) {
            return const Center(child: Text('Henüz kombin oluşturmadınız.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: outfits.length,
            itemBuilder: (context, index) {
              final outfit = outfits[index];
              final firstWithImage = outfit.items.firstWhere(
                (i) => i.imagePath != null,
                orElse: () => const ClothingItem(category: 'Özet'),
              );
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ImageFromPath(path: firstWithImage.imagePath, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        outfit.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Düzenle',
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateOutfitPage(
                                  appState: widget.appState,
                                  libraryState: widget.imageLibraryState,
                                  editing: outfit,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'Sil',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Kombin silinsin mi?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
                                  FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
                                ],
                              ),
                            );
                            if (ok == true) {
                              widget.appState.deleteOutfit(outfit.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateOutfitPage(appState: widget.appState, libraryState: widget.imageLibraryState)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
