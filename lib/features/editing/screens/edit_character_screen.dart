import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/models/character_model.dart';
import 'package:rickandmorty/features/editing/providers/local_edits_provider.dart';

class EditCharacterScreen extends HookConsumerWidget {
  final Character character;

  const EditCharacterScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    
    // Initialize controllers with current values (either API or previously edited)
    final nameController = useTextEditingController(text: character.name);
    final statusController = useTextEditingController(text: character.status);
    final speciesController = useTextEditingController(text: character.species);
    final typeController = useTextEditingController(text: character.type);
    final genderController = useTextEditingController(text: character.gender);
    final originController = useTextEditingController(text: character.originName);
    final locationController = useTextEditingController(text: character.locationName);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Character',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
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
                
                await ref.read(localEditsProvider.notifier).saveEdit(character.id, edits);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Character updated locally!')),
                  );
                }
              }
            },
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
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
              _buildTextField('Name', nameController, Icons.person),
              _buildTextField('Status', statusController, Icons.info_outline),
              _buildTextField('Species', speciesController, Icons.fingerprint),
              _buildTextField('Type', typeController, Icons.category),
              _buildTextField('Gender', genderController, Icons.wc),
              _buildTextField('Origin', originController, Icons.public),
              _buildTextField('Location', locationController, Icons.location_on),
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
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.camera_alt, color: Colors.white, size: 20.w),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
