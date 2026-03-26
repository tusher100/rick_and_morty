import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/models/character_model.dart';
import 'package:rickandmorty/core/widgets/app_text_field.dart';
import 'package:rickandmorty/features/editing/providers/local_edits_provider.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';
import 'package:rickandmorty/core/widgets/rick_and_morty_app_bar.dart';

class EditCharacterScreen extends HookConsumerWidget {
  final Character character;

  const EditCharacterScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final nameController = useTextEditingController(text: character.name);
    final statusController = useTextEditingController(text: character.status);
    final speciesController = useTextEditingController(text: character.species);
    final typeController = useTextEditingController(text: character.type);
    final genderController = useTextEditingController(text: character.gender);
    final originController = useTextEditingController(
      text: character.originName,
    );
    final locationController = useTextEditingController(
      text: character.locationName,
    );


    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: RickAndMortyAppBar(
        character: character,
        title: 'Edit Character',
        showFavorite: false,
        actions: [
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final edits = {
                  'name': nameController.text,
                  'status': statusController.text,
                  'species': speciesController.text,
                  'type': typeController.text,
                  'gender': genderController.text,
                  'originName': originController.text,
                  'locationName': locationController.text,
                };

                await ref
                    .read(localEditsProvider.notifier)
                    .saveEdit(character.id, edits);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Character updated locally!')),
                  );
                }
              }
            },
            child: AppText.bodyLarge(
              'Save',
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageHeader(),
              SizedBox(height: 24.h),
              AppTextField(
                label: 'Name',
                controller: nameController,
                icon: Icons.person,
              ),
              AppTextField(
                label: 'Status',
                controller: statusController,
                icon: Icons.info_outline,
              ),
              AppTextField(
                label: 'Species',
                controller: speciesController,
                icon: Icons.fingerprint,
              ),
              AppTextField(
                label: 'Type',
                controller: typeController,
                icon: Icons.category,
              ),
              AppTextField(
                label: 'Gender',
                controller: genderController,
                icon: Icons.wc,
              ),
              AppTextField(
                label: 'Origin',
                controller: originController,
                icon: Icons.public,
              ),
              AppTextField(
                label: 'Location',
                controller: locationController,
                icon: Icons.location_on,
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildImageHeader() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 60.r,
            backgroundImage: NetworkImage(character.image),
          ),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.camera_alt,
              color: AppColors.cardBackground,
              size: 20.w,
            ),
          ),
        ],
      ),
    );
  }
}
