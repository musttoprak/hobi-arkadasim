import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobiarkadasim/bloc/add_post_cubit.dart';
import 'package:hobiarkadasim/constants/app_colors.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;

  const StarRating(
      {super.key, required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.yellow,
            size: 35,
          ),
          onPressed: () {
            onRatingChanged(index + 1);
          },
        );
      }),
    );
  }
}

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final TextEditingController _controller =
      TextEditingController(); // Input kontrolü için
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Doğrulama için form anahtarı

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddPostCubit(context, _controller),
      child: BlocBuilder<AddPostCubit, AddPostState>(
        builder: (context, state) {
          return buildSafeArea(context);
        },
      ),
    );
  }

  Widget buildSafeArea(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Post Oluştur",
            style: TextStyle(color: Colors.black,fontSize: 24),
          )),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.headerTextColor,
          border: Border.all(
              color: Colors.white, // Kenar rengi
              width: 2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40.0),
            topRight: Radius.circular(40.0),
          ),
          //
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Oyunu Oynadığın Arkadaşını Seç",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      width: double.infinity, // Tüm genişlik boyunca
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          borderRadius: BorderRadius.circular(24),
                          icon: const Icon(Icons.keyboard_arrow_down_sharp,
                              color: Colors.white),
                          value: context.watch<AddPostCubit>().selectedOption,
                          hint: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Bir arkadaş seçin",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          onChanged: (String? newValue) {
                            context
                                .read<AddPostCubit>()
                                .changeOption(newValue!);
                          },
                          items: context.watch<AddPostCubit>().friends.isEmpty
                              ? null
                              : context
                                  .watch<AddPostCubit>()
                                  .friends
                                  .map((option) {
                                  return DropdownMenuItem<String>(
                                    value: option.uid,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            avatars[option.avatarId],
                                            width: 24,
                                            height: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            option.fullName,
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Arkadaşınla Oynadığın Oyunu Seç",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      width: double.infinity, // Tüm genişlik boyunca
                      child: DropdownButtonHideUnderline(
                        // Alt çizgiyi gizler
                        child: DropdownButton<String>(
                          borderRadius: BorderRadius.circular(24),
                          icon: const Icon(Icons.keyboard_arrow_down_sharp,
                              color: Colors.white),
                          value: context.watch<AddPostCubit>().selectedHobby,
                          hint: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Bir oyun seçin",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          onChanged: (String? newValue) {
                            context
                                .read<AddPostCubit>()
                                .changeHobby(newValue!);
                          },
                          items: context.watch<AddPostCubit>().hobbys.isEmpty
                              ? null
                              : context
                                  .watch<AddPostCubit>()
                                  .hobbys
                                  .map((option) {
                                  return DropdownMenuItem<String>(
                                    value: option.id,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        option.name,
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ),
                                  );
                                }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 8.0),
                    child: Text(
                      "Arkadaşına Puan Ver",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StarRating(
                      rating: context.watch<AddPostCubit>().rating,
                      onRatingChanged: (newRating) {
                        context.read<AddPostCubit>().changeRating(newRating);
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Bu etkinlik hakkında düşüncelerini yaz",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white,width: .5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextFormField(
                          controller: _controller, // TextField kontrolü
                          maxLines: 5, // Birkaç cümle için yeterli alan
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none),
                              hintText:
                                  "Etkinlik hakkındaki düşüncelerini yaz...",
                              hintStyle: const TextStyle(
                                  color: Colors.white, fontSize: 15)),
                          validator: (value) {
                            // Doğrulama kontrolü
                            if (value == null || value.isEmpty) {
                              return "Lütfen doldurunuz."; // Boş bırakmayı önler
                            }
                            return null; // Geçerli ise sorun yok
                          },
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(
                              255, 245, 245, 245), // Beyazımsı renk
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AddPostCubit>().addPost();
                        }
                      },
                      child: const Text(
                        "Oluştur",
                        style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18), // Siyah metin
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
