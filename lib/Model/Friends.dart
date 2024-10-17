import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Friend extends StatelessWidget {
  final name;
  final profile_image;
  const Friend({super.key, @required this.profile_image, @required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 15,),
        Column(
        children: [
          Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(image: NetworkImage(profile_image), fit: BoxFit.cover,)
              ),
            ),
          Text(name, style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 14
          ),)
        ],
      )],
    );
  }
}