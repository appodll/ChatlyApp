import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllAccount extends StatelessWidget {
  final name;
  final profile_image;
  final content;
  const AllAccount({super.key, @required this.name, @required this.profile_image, @required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20,),
        Padding(
          padding: EdgeInsets.only(left: 20),
          child: Row(
          children: [
            Container(
              child: Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(       
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(image: NetworkImage(profile_image), fit: BoxFit.cover)
                ),
              ),
            ),
            SizedBox(width: 20,),
            Column(
              children: [
                Text(name, style: GoogleFonts.montserrat(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 3, 7, 83)
              ),),
              Text(content,style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color.fromRGBO(4, 27, 119, 1)
              ),)],
            )
          ],
                ),
        ),
      SizedBox(height: 10,)
      ],
    );
  }
}