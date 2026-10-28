import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/app_state.dart';
import '../../../core/services/github_update_service.dart';
import '../../guide/screens/user_guide_screen.dart';
import '../../guide/widgets/update_dialog.dart';
import '../../ride/widgets/crash_countdown_dialog.dart';

class ProfileScreen extends StatefulWidget {
  final AppState appState;

  const ProfileScreen({super.key, required this.appState});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late String _selectedBloodGroup;
  late List<String> _selectedBikeTypes;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  void _initFields() {
    final user = widget.appState.currentUser;
    _fullNameController = TextEditingController(text: user.fullName);
    _phoneController = TextEditingController(text: user.phone);
    _selectedBloodGroup = user.bloodGroup;
    _selectedBikeTypes = List.from(user.bikeTypes);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_selectedBikeTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir bisiklet türü seçin.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.appState.updateProfile(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      bloodGroup: _selectedBloodGroup,
      bikeTypes: _selectedBikeTypes,
    );

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil bilgileriniz başarıyla güncellendi.'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _showTestCrashDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return CrashCountdownDialog(
          onCancelled: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Test kaza alarmı iptal edildi.'),
                backgroundColor: Colors.teal,
              ),
            );
          },
          onConfirmed: () {
            widget.appState.reportCrashIncident(
              latitude: widget.appState.currentLat,
              longitude: widget.appState.currentLng,
              address: 'Caddebostan Sahil Yolu (Test Konumu)',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kaza bildirimi gruptaki arkadaşlara iletildi!'),
                backgroundColor: Colors.redAccent,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _checkGithubUpdate(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('GitHub güncellemeleri kontrol ediliyor...'),
        duration: Duration(seconds: 1),
      ),
    );

    final releaseInfo = await GithubUpdateService.checkForUpdates();

    if (!context.mounted) return;

    if (releaseInfo != null && releaseInfo.hasUpdate) {
      showDialog(
        context: context,
        builder: (dialogContext) => UpdateDialog(releaseInfo: releaseInfo),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uygulamanız en güncel sürümde! (v1.0.0)'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.appState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Profili Düzenle',
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'İptal',
              onPressed: () {
                _initFields();
                setState(() {
                  _isEditing = false;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Avatar Card Header
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                      child: Icon(
                        Icons.directions_bike,
                        size: 52,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.fullName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Chip(
                      avatar: const Icon(Icons.bloodtype, color: Colors.white, size: 18),
                      label: Text(
                        'Kan Grubu: ${user.bloodGroup}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Colors.redAccent.shade200,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Profile Information Form / Cards
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kişisel Bilgiler',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Divider(height: 24),

                    // Ad Soyad
                    if (_isEditing)
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Ad Soyad',
                          prefixIcon: Icon(Icons.person_outlined),
                        ),
                      )
                    else
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(Icons.person, color: theme.colorScheme.primary),
                        ),
                        title: const Text('Ad Soyad'),
                        subtitle: Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Telefon
                    if (_isEditing)
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telefon Numarası',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      )
                    else
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(Icons.phone, color: theme.colorScheme.primary),
                        ),
                        title: const Text('Telefon'),
                        subtitle: Text(
                          user.phone,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Kan Grubu
                    if (_isEditing) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedBloodGroup,
                        decoration: const InputDecoration(
                          labelText: 'Kan Grubu',
                          prefixIcon: Icon(Icons.bloodtype_outlined),
                        ),
                        items: UserModel.availableBloodGroups.map((bg) {
                          return DropdownMenuItem(value: bg, child: Text(bg));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedBloodGroup = val;
                            });
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Safety & Crash Detection Protection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(
                          'Güvenlik & Kaza Algılama',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.redAccent,
                      title: const Text('Sensörlü Kaza / Düşme Algılama', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Düşme ve çarpışma anında telefon otomatik algılayıp takıma haber verir.'),
                      value: widget.appState.crashProtectionEnabled,
                      onChanged: (val) {
                        widget.appState.setCrashProtectionEnabled(val);
                      },
                    ),
                    const SizedBox(height: 10),

                    // Test Crash System Button
                    OutlinedButton.icon(
                      onPressed: () {
                        _showTestCrashDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                      icon: const Icon(Icons.warning_amber_rounded),
                      label: const Text('Kaza Algılama Alarmını Test Et'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bicycle Types Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pedal_bike, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Sahip Olduğu Bisiklet Türleri',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    if (_isEditing) ...[
                      Text(
                        'Kullandığınız türleri işaretleyin (Birden fazla seçebilirsiniz):',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: UserModel.availableBikeTypes.map((bike) {
                          final isSelected = _selectedBikeTypes.contains(bike);
                          return FilterChip(
                            label: Text(bike),
                            selected: isSelected,
                            selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                            checkmarkColor: theme.colorScheme.primary,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedBikeTypes.add(bike);
                                } else {
                                  _selectedBikeTypes.remove(bike);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.bikeTypes.map((bike) {
                          return Chip(
                            avatar: Icon(
                              _getIconForBike(bike),
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                            label: Text(bike),
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User Manual & Guide Card
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  child: Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary),
                ),
                title: const Text('Kullanıcı Rehberi & Özellikler', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Uygulamanın tüm özelliklerini ve rehberini inceleyin.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserGuideScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // GitHub Update Check Card
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.withOpacity(0.15),
                  child: const Icon(Icons.system_update_rounded, color: Colors.indigo),
                ),
                title: const Text('Uygulama Güncellemesi', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('GitHub üzerinden en yeni sürümü kontrol et ve indir.'),
                trailing: const Icon(Icons.system_update_alt_rounded, color: Colors.indigo),
                onTap: () => _checkGithubUpdate(context),
              ),
            ),
            const SizedBox(height: 24),

            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Değişiklikleri Kaydet'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    widget.appState.logout();
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    'Oturumu Kapat',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  IconData _getIconForBike(String bike) {
    if (bike.contains('E-Bike') || bike.contains('E-Gravel')) {
      return Icons.electric_bike;
    } else if (bike.contains('Yol')) {
      return Icons.directions_bike;
    } else if (bike.contains('MTB')) {
      return Icons.terrain;
    }
    return Icons.pedal_bike;
  }
}
