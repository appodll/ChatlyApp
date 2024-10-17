import 'dart:convert';
import 'package:chatapp/Controller/messageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';

class AllFriendsModel extends StatefulWidget {
  final String name;
  final String profile_image;
  final int sender_id;
  final int receiver_id;
  final String bio;
  final status_icon;
  final last_message;
  final last_message_name;
  const AllFriendsModel({
    super.key,
    required this.name,
    required this.profile_image,
    required this.sender_id,
    required this.receiver_id,
    required this.bio,
    required this.status_icon,
    required this.last_message,
    required this.last_message_name
  });

  @override
  State<AllFriendsModel> createState() => _AllFriendsModelState();
}

class _AllFriendsModelState extends State<AllFriendsModel> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Container(
              child: Row(
                children: [
                  Stack(
                    children: [
                      InkWell(
                        onLongPress: () {
                          Get.to(PhotoView(
                              imageProvider: NetworkImage(
                                  "https://appoaep.space/get_profile_image?email=${widget.profile_image}")));
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            image: DecorationImage(image: NetworkImage(
                                "https://appoaep.space/get_profile_image?email=${widget.profile_image}"), fit: BoxFit.cover)
                          ),
                          
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: widget.status_icon,
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: GoogleFonts.montserrat(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.bio.isNotEmpty ? "Bio: ${widget.bio}" : "Bio: Empty",
                        style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      widget.last_message.isNotEmpty
                          ? ( widget.last_message.toString().endsWith(".jpg") 
                              ? Row(
                                  children: [
                                    Text("${widget.last_message_name}: ", style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500)),
                                    Icon(Icons.photo),
                                    Text("Photo", style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500)),
                                  ],
                                )
                              : widget.last_message.toString().endsWith(".wav") 
                                ? Row(
                                  children: [
                                    Text("${widget.last_message_name}: ", style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500)),
                                    Icon(Icons.audiotrack_rounded),
                                    Text("Sound", style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500)),
                                  ],
                                )
                                : widget.last_message.length > 20?Text("${widget.last_message_name}: ${widget.last_message.toString().substring(0,20)}...",style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500),):Text(
                                    "${widget.last_message_name}: ${widget.last_message}",
                                    style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500),
                                  ))
                          : Text("message: Empty", style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500)),
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 7),
        ],
      );
  }
}
