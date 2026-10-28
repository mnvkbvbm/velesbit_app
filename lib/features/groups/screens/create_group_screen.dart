import 'package:flutter/material.dart';
import '../../../core/models/group_model.dart';
import '../../../core/services/app_state.dart';

class CreateGroupScreen extends StatefulWidget {
  final AppState appState;

  const CreateGroupScreen({super.key, required this.appState});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  GroupType _selectedType = GroupType.ekip;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.appState.createGroup(
        name: _nameController.text.trim(),
        type: _selectedType,
        description: _descriptionController.text.trim(),
        city: _cityController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${_nameController.text.trim()}" grubu başarıyla oluşturuldu!'),
          backgroundColor: Colors.teal,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Grup Oluştur'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                        child: Icon(
                          Icons.groups_rounded,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Takım, Dernek veya Ekip Kur',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Diğer bisikletçilerle buluşun, birlikte rotalar planlayın.',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Group Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Grup / Takım / Ekip Adı',
                  prefixIcon: Icon(Icons.group_work_outlined),
                  hintText: 'Örn: Kadıköy Pedal Ekibi',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Lütfen grup adını giriniz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Group Type Selector
              DropdownButtonFormField<GroupType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Grup Türü',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: GroupType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // City
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Şehir / Bölge',
                  prefixIcon: Icon(Icons.location_city_outlined),
                  hintText: 'Örn: İstanbul',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Lütfen şehir veya bölge giriniz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Grup Açıklaması ve Amacı',
                  prefixIcon: Icon(Icons.description_outlined),
                  hintText: 'Grubunuzun sürüş tarzı, haftalık buluşma zamanları veya hedefleri...',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Lütfen kısa bir açıklama yazınız.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Grubu Oluştur ve Yayınla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
