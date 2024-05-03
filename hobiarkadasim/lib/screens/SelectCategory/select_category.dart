import 'package:flutter/material.dart';
import 'package:hobiarkadasim/components/bottom_navigation_bar.dart';
import 'package:hobiarkadasim/components/showSnackbar.dart';
import 'package:hobiarkadasim/screens/SelectCategory/select_avatar.dart';
import 'package:hobiarkadasim/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_colors.dart';
import '../../models/category_with_name.dart';

class SelectCategory extends StatefulWidget {
  final List<CategoryWithName> categories;
  final List<HobbyCategory> savedCategories;

  const SelectCategory(
      {super.key, required this.categories, required this.savedCategories});

  @override
  _SelectCategoryState createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  int currentCategoryIndex = 0;
  late List<List<bool>> selectedStatesList;
  late final List<CategoryWithName> categories;
  late final List<HobbyCategory> savedCategories;
  List<String> selectedCategoryId = [];

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  void _initialize() {
    categories = widget.categories;
    selectedStatesList = List.generate(
      categories.length,
      (i) => List.generate(
        categories[i].items.length,
        (index) => false,
      ),
    );

    savedCategories = widget.savedCategories;
    selectedCategoryId = savedCategories.map((e) => e.id).toList();
    // savedCategories listesindeki her bir kategori ID'sine karşılık gelen seçili durumu güncelleyin
    for (var i = 0; i < categories.length; i++) {
      for (var j = 0; j < categories[i].items.length; j++) {
        // Kullanıcının seçtiği kategoriler arasında mı kontrol et
        if (selectedCategoryId.contains(categories[i].items[j].id)) {
          selectedStatesList[i][j] = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold();
  }

  Scaffold buildScaffold() {
    var currentCategory = categories[currentCategoryIndex];
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentCategory.categoryName,
                style: const TextStyle(color: Colors.black, fontSize: 24)),
            const SizedBox(height: 12),
            Text(
                "Lütfen ${currentCategory.categoryName} kategorisine hobilerinizi seçiniz."),
            const SizedBox(height: 24),
            Wrap(
              children: List.generate(currentCategory.items.length, (index) {
                return Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ChoiceChip(
                    label: Text(currentCategory.items[index].name,
                        style: const TextStyle(fontSize: 16)),
                    selected: selectedStatesList[currentCategoryIndex][index],
                    showCheckmark: selectedStatesList[currentCategoryIndex]
                        [index],
                    // Kategori için seçili durum
                    selectedColor: Colors.blue,
                    onSelected: (newstate) => setState(() {
                      if (newstate) {
                        selectedCategoryId.add(currentCategory.items[index].id);
                      } else {
                        selectedCategoryId
                            .remove(currentCategory.items[index].id);
                      }
                      selectedStatesList[currentCategoryIndex][index] =
                          newstate; // Seçim durumu güncellenir
                    }),
                  ),
                );
              }),
            ),
            const Spacer(),
            CategoryNavigationRow(
              showBackButton: currentCategoryIndex > 0,
              // Geri butonu sadece 0 değilse gösterilir
              onBack: previousCategory,
              onNext: nextCategory,
              nextButtonText: currentCategoryIndex == 3
                  ? "Tamamla"
                  : "İlerle", // Şartlı buton ismi
            ),
          ],
        ),
      ),
    );
  }

  void previousCategory() {
    if (currentCategoryIndex > 0) {
      setState(() {
        currentCategoryIndex--; // Geri git
      });
    }
  }

  Future<void> nextCategory() async {
    if (currentCategoryIndex < categories.length - 1) {
      setState(() {
        currentCategoryIndex++; // İlerle
      });
    } else {
      await buttonComplete();
    }
  }

  Future<void> buttonComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('id');
    if (uid != null) {
      UserService service = UserService();
      await service
          .createUserHobby(uid, selectedCategoryId)
          .then((value) async {
        await service.getUserInformation(uid).then((value2) async {
          await service.addUserInformation(value2).then((uinfo) {
            print("işlem tamamlandı");
            print(value2.desc);
            if (value2.desc.isEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectAvatar(
                    userInformation: uinfo,
                  ),
                ), // Avatar seçme sayfasına git
              );
            } else {
              ShowMySnackbar.snackbarShow(context, true,
                  "İşleminiz başarılı bir şekilde tamamlanmıştır");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeTabbarView(),
                ), // Avatar seçme sayfasına git
                (route) => false,
              );
            }
          });
        });
      });
    }
  }
}

class CategoryNavigationRow extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextButtonText; // İleri butonu için metin

  const CategoryNavigationRow({
    super.key,
    required this.showBackButton,
    required this.onBack,
    required this.onNext,
    required this.nextButtonText, // İleri butonu metni dinamik
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (showBackButton)
          Expanded(
            child: ElevatedButton(
              onPressed: onBack,
              child: const Text("Geri"),
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(AppColors
                      .headerTextColor
                      .withOpacity(.6))), // Geri butonu
            ),
          ),
        if (showBackButton) const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: onNext,
            child: Text(nextButtonText), // Dinamik buton metni
          ),
        ),
      ],
    );
  }
}
