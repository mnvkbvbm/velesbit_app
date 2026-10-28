import 'package:flutter/material.dart';

class GuideCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<GuideItem> items;

  GuideCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class GuideItem {
  final String title;
  final String description;

  GuideItem({required this.title, required this.description});
}

class UserGuideScreen extends StatefulWidget {
  const UserGuideScreen({super.key});

  @override
  State<UserGuideScreen> createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends State<UserGuideScreen> {
  String _searchQuery = '';

  final List<GuideCategory> _categories = [
    GuideCategory(
      title: 'Üyelik & Güvenlik',
      icon: Icons.verified_user_outlined,
      color: Colors.teal,
      items: [
        GuideItem(
          title: 'E-posta & Çift Şifreli Kayıt',
          description: 'E-posta adresiniz ve şifrenizi iki defa girerek güvenli şekilde üye olabilirsiniz.',
        ),
        GuideItem(
          title: 'Beni Hatırla Özelliği',
          description: 'Giriş ekranındaki "Beni Hatırla" seçeneği ile uygulamayı her açtığınızda otomatik giriş yapılır.',
        ),
        GuideItem(
          title: 'Şifremi Unuttum',
          description: 'Şifrenizi unuttuğunuzda e-posta adresinize sıfırlama yönergeleri gönderilir.',
        ),
      ],
    ),
    GuideCategory(
      title: 'Profil & Bisiklet Garajı',
      icon: Icons.person_outline,
      color: Colors.indigo,
      items: [
        GuideItem(
          title: 'Kişisel Bilgiler & Kan Grubu',
          description: 'Ad soyad, telefon ve acil durumlarda kritik öneme sahip kan grubu bilginizi profilinizden güncelleyebilirsiniz.',
        ),
        GuideItem(
          title: 'Çoklu Bisiklet Türü Seçimi',
          description: 'MTB, Yol (Road), Gravel, E-Bike, E-Gravel, Şehir, Katlanır ve Tur bisikleti türlerinden kullandığınız tüm modelleri seçebilirsiniz.',
        ),
      ],
    ),
    GuideCategory(
      title: 'Canlı GPS Sürüş Takibi',
      icon: Icons.directions_bike,
      color: const Color(0xFF00A896),
      items: [
        GuideItem(
          title: 'Sürüş Modları (Yalnız Sür vs Canlı Paylaş)',
          description: 'Sürüşe başlamadan önce yalnız sürebilir veya sürüşünüzü takım arkadaşlarınızla 48 saat boyunca canlı paylaşabilirsiniz.',
        ),
        GuideItem(
          title: 'Tam Ekran Harita & Yüzen Dashboard',
          description: 'Harita ekranı tam boyuta genişler; Mesafe, Anlık Hız, Ortalama Hız, Süre, Dinlenme Süresi, Kalori ve Yokuş verileri harita üzerinde şık kartlarda görünür.',
        ),
        GuideItem(
          title: 'Gerçek GPS Sensör Takibi',
          description: 'Sadece siz hareket ettiğinizde haritada iz çizgisi çizilir. Sabit durduğunuzda hızınız 0.0 km/s kalır.',
        ),
        GuideItem(
          title: 'Şehir & Uydu Harita Katmanları',
          description: 'Harita üzerinden Şehir haritası ile Cadde, Sokak, Mahalle ve Köy isimli Hibrit Uydu haritası arasında tek tıkla geçiş yapabilirsiniz.',
        ),
        GuideItem(
          title: 'Konum Butonu & Kesintisiz Arka Plan',
          description: 'Konum butonuna basarak anlık GPS konumunuza odaklanabilir, sekmeler arası gezinseniz dahi sürüşünüzü arka planda kaydetmeye devam edebilirsiniz.',
        ),
        GuideItem(
          title: 'Sürüş İptal Et / Kaydet',
          description: 'Sürüşü bitirirken isterseniz başlık ve bisiklet seçip kaydedebilir, isterseniz kaydetmeden tek tıkla iptal edebilirsiniz.',
        ),
      ],
    ),
    GuideCategory(
      title: 'Sensörlü Kaza & Düşme Algılama',
      icon: Icons.warning_amber_rounded,
      color: Colors.redAccent,
      items: [
        GuideItem(
          title: 'İvmeölçer ile Darbe Algılama',
          description: 'Sürüş esnasında 3.2g üzerindeki sert düşme ve çarpışmalar telefon sensörleri tarafından anında algılanır.',
        ),
        GuideItem(
          title: '30 Saniyelik Alarm & Titreşim Sayacı',
          description: 'Kaza anında yüksek sesli alarm çalar. 30 saniye içinde "BEN İYİYİM" butonuna basılırsa alarm iptal edilir.',
        ),
        GuideItem(
          title: 'Takıma Otomatik İmdat Çağrısı',
          description: '30 saniye içinde yanıt verilmezse gruptaki tüm arkadaşlara kaza konumu ve bildirimi düşer. Arkadaşlar tek tıkla kaza yerine navigasyon başlatabilir.',
        ),
      ],
    ),
    GuideCategory(
      title: 'Ücretsiz Bisiklet Navigasyonu',
      icon: Icons.navigation_outlined,
      color: Colors.blue.shade700,
      items: [
        GuideItem(
          title: 'Adres & Mekan Arama (Nominatim)',
          description: 'Kredi kartı ve API key gerektirmeyen %100 ücretsiz arama ile Kadıköy Sahil, Belgrad Ormanı vb. mekanları kolayca aratabilirsiniz.',
        ),
        GuideItem(
          title: 'Haritaya Basılı Tutma (Mahalle, Köy & Rakım)',
          description: 'Haritada bir yere basılı tutarak o noktanın Mahalle, İlçe, Köy, Şehir adını, deniz seviyesinden yüksekliğini (Rakım) ve mesafesini görebilirsiniz.',
        ),
        GuideItem(
          title: 'Bisiklet Rota Hesabı & Türkçe Sesli Navigasyon',
          description: 'Bulunduğunuz konumdan hedefe bisiklete özel adımlı rota çizilir ve "200 metre sonra sağa dönün" gibi Türkçe sesli yönlendirmeler yapılır.',
        ),
      ],
    ),
    GuideCategory(
      title: 'Gruplar, Takımlar & Dernekler',
      icon: Icons.groups_outlined,
      color: Colors.purple.shade700,
      items: [
        GuideItem(
          title: 'Topluluk Kurma & Katılma',
          description: 'Takım, Dernek, Ekip veya Topluluk isimleriyle gruplar oluşturabilir ve üye olabilirsiniz.',
        ),
        GuideItem(
          title: '48 Saatlik Canlı Takım Yayınları',
          description: 'Sürüşünü canlı paylaşan arkadaşlarınızı haritadan canlı takip edebilir, yayınları 48 saat boyunca grup sayfasında izleyebilirsiniz.',
        ),
      ],
    ),
    GuideCategory(
      title: 'Geçmiş Sürüşler & İstatistikler',
      icon: Icons.history,
      color: Colors.orange.shade800,
      items: [
        GuideItem(
          title: 'Toplam İstatistik Raporu',
          description: 'Kat ettiğiniz toplam mesafe, toplam sürüş sayısı, toplam süre ve tırmandığınız toplam yokuş yüksekliğini görebilirsiniz.',
        ),
        GuideItem(
          title: 'Sürüş Detay Haritası',
          description: 'Geçmiş sürüşlerinizin harita izini, ortalama hızını ve performans detaylarını dilediğiniz zaman inceleyebilirsiniz.',
        ),
      ],
    ),
  ];

  List<GuideCategory> get _filteredCategories {
    if (_searchQuery.trim().isEmpty) return _categories;

    final q = _searchQuery.toLowerCase();
    final result = <GuideCategory>[];

    for (final cat in _categories) {
      final matchingItems = cat.items.where((item) {
        return item.title.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q) ||
            cat.title.toLowerCase().contains(q);
      }).toList();

      if (matchingItems.isNotEmpty) {
        result.add(
          GuideCategory(
            title: cat.title,
            icon: cat.icon,
            color: cat.color,
            items: matchingItems,
          ),
        );
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Rehberi & Özellikler'),
      ),
      body: Column(
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(20),
            color: theme.colorScheme.primary.withOpacity(0.08),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                      child: Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Velesbit Kullanım Rehberi',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Uygulamanın tüm özelliklerini ve ipuçlarını burada bulabilirsiniz.',
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Özellik veya konu ara (örn: Kaza, Navigasyon, Uydu)...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // Categories List
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 56, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text(
                          'Aradığınız konuyla ilgili özellik bulunamadı.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: index == 0,
                          leading: CircleAvatar(
                            backgroundColor: category.color.withOpacity(0.12),
                            child: Icon(category.icon, color: category.color),
                          ),
                          title: Text(
                            category.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: category.color,
                            ),
                          ),
                          subtitle: Text(
                            '${category.items.length} özellik',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          children: category.items.map((item) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                leading: Icon(Icons.check_circle_outline, color: category.color, size: 20),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    item.description,
                                    style: TextStyle(color: Colors.grey[800], fontSize: 12.5, height: 1.3),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
