import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/features/home/providers/home_provider.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersState = ref.watch(characterListProvider);
    
    final scrollController = useScrollController();

    // Hook for adding the pagination listener
    useEffect(() {
      void scrollListener() {
        if (scrollController.position.pixels >= 
            scrollController.position.maxScrollExtent - 200.h) {
          ref.read(characterListProvider.notifier).loadMore();
        }
      }

      scrollController.addListener(scrollListener);
      
      // Cleanup listener on dispose
      return () => scrollController.removeListener(scrollListener);
    }, [scrollController]); 
    return Scaffold(
      appBar: AppBar(
        title: Text('Characters', style: TextStyle(fontSize: 20.sp)),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, size: 24.w),
            onPressed: () {
              // Navigate to Favorites
            },
          )
        ],
      ),
      body: charactersState.when(
        data: (characters) {
          if (characters.isEmpty) {
            return Center(
              child: Text('No characters found', style: TextStyle(fontSize: 16.sp)),
            );
          }
          return Padding(
            padding: EdgeInsets.all(8.w),
            child: GridView.builder(
              controller: scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
              ),
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                          child: Image.network(
                            character.image, 
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              character.name, 
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 14.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              character.status,
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: TextStyle(fontSize: 14.sp)),
        ),
      ),
    );
  }
}