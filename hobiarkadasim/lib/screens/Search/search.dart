import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobiarkadasim/bloc/search_cubit.dart';
import 'package:hobiarkadasim/constants/app_colors.dart';
import 'package:hobiarkadasim/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/category_with_name.dart';
import '../../models/user_hobby.dart';
import '../../models/user_info.dart';
import '../Profile/user_profile.dart';
import 'package:hobiarkadasim/models/user_search_view.dart';

class SearchView extends StatefulWidget {
  final UserInformation userInformation;
  final List<HobbyCategory> category;

  const SearchView(
      {super.key, required this.userInformation, required this.category});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with SearchViewMixin {
  @override
  void initState() {
    userInformation = widget.userInformation;
    category = widget.category;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(context, userInformation, category),
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return buildScaffold(context);
        },
      ),
    );
  }
}

mixin SearchViewMixin {
  List<String> avatars = [
    'assets/man.png',
    'assets/human.png',
    'assets/man1.png',
    'assets/woman2.png',
    'assets/man2.png',
    'assets/woman3.png',
    'assets/man3.png',
    'assets/woman4.png',
    'assets/woman5.png',
    'assets/woman6.png',
  ];
  late UserInformation userInformation;
  late List<HobbyCategory> category;

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context),
      body: bodyWidget(context),
    );
  }

  AppBar appBarWidget(BuildContext context) {
    return AppBar(
      title: const Text("Arama",
          style: TextStyle(color: Colors.black, fontSize: 24)),
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black),
          // Filtreleme butonu
          onPressed: () async {
            // Filtreleme ile ilgili işlemler burada
            print("Filtreleme butonuna tıklandı");
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                List<HobbyCategory> selectedCategories = [];
                return FilterWidget(
                  selectedCategories: selectedCategories,
                  categories: category,
                );
              },
            ).then((value) {
              print((value as List<HobbyCategory>).length);
              if (value != null && (value as List<HobbyCategory>).isNotEmpty) {
                context.read<SearchCubit>().getMatchesFilter(value);
              }
            });
          },
        ),
      ],
    );
  }

  Padding bodyWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: SingleChildScrollView(
        child: Column(
          children: context.watch<SearchCubit>().isLoading
              ? [const Center(child: CircularProgressIndicator())]
              : context.watch<SearchCubit>().userSearchView.isEmpty
                  ? [const Center(child: Text("Eşleşen bir kullanıcı bulunamadı."))]
                  : context
                      .watch<SearchCubit>()
                      .userSearchView
                      .map((userSearchView) {
                      return userWidget(context, userSearchView);
                    }).toList(),
        ),
      ),
    );
  }

  Widget userWidget(BuildContext context, UserSearchView userSearchView) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfile(
              userSearchView: userSearchView,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: Ink(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Image.asset(
                          avatars[userSearchView.userInformation.avatarId],
                          height: 45,
                          width: 45,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      userSearchView.userInformation.desc,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 ),
              child: Text("Ortak Hobileriniz",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 3,
                runSpacing: 3,
                children: userSearchView.userHobbyModel.categories.map((word) {
                  return ChoiceChip(
                    selectedColor: Colors.white,
                    checkmarkColor: Colors.black,
                    label: Text(
                      word.name,
                      style: const TextStyle(
                          color: Colors.black,fontWeight: FontWeight.bold),
                    ),
                    selected: true,
                    showCheckmark: true,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterWidget extends StatefulWidget {
  const FilterWidget({
    super.key,
    required this.selectedCategories,
    required this.categories,
  });

  final List<HobbyCategory> selectedCategories;
  final List<HobbyCategory> categories;

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  RoundedRectangleBorder customShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: customShape,
      title: const Text('Kategorileri Seçin'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.categories.map((category) {
          return CheckboxListTile(
            title: Text(category.name),
            value: widget.selectedCategories.contains(category),
            onChanged: (bool? value) {
              setState(() {
                if (value != null) {
                  if (value) {
                    widget.selectedCategories.add(category);
                  } else {
                    widget.selectedCategories.remove(category);
                  }
                }
              });
            },
          );
        }).toList(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(widget.selectedCategories);
          },
          child: const Text('Tamamla'),
        ),
      ],
    );
  }
}
