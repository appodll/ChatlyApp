import 'dart:async';
import 'dart:io';

import 'package:chatapp/Controller/ProfileController.dart';
import 'package:chatapp/Controller/groupElementController.dart';
import 'package:chatapp/Controller/messageController.dart';
import 'package:chatapp/Controller/permission.dart';
import 'package:chatapp/Controller/statusController.dart';
import 'package:chatapp/Model/AudioItem.dart';
import 'package:chatapp/Screen/Chats_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MessageScreen extends StatefulWidget {
  final profile_image;
  final name;
  final void Function()? send_message;
  final sender_id;
  final receiver_id;
  final status;
  final token;
  const MessageScreen(
      {@required this.profile_image,
      @required this.name,
      required this.send_message,
      required this.sender_id,
      required this.receiver_id,
      required this.status,
      required this.token
      });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  final ScrollController _scrollController = ScrollController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder(); // audionu veritabanina atmak icin kullaniyorum (elleme)
  final _messagecontroller = Get.put(Messagecontroller());
  ///////////////////////////////////////
  bool _isAutoScroll = true;
  double _iconPosition = 0.0;
  Timer? _timer;
  bool _isRecording = false;
  String? filePath;
  File? audioFile;
  //////////////////////////////////////
  DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  /////////////////////////////////////
  bool isPLaying = false;
  final AudioPlayer audioPlayer = AudioPlayer();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  ////////////////////////////////////

  final message_controller = Get.put(Messagecontroller());
  
  Future<void> init()async{
    final profile_controller = Get.put(Profilecontroller());
    final group_controller = Get.put(Groupelementcontroller());
    await profile_controller.my_account_info();
    await group_controller.all_friends(int.parse(profile_controller.my_id.value));
    _messagecontroller.get_message_init(widget.sender_id, widget.receiver_id);
  }
  
  void _playSound(String url) async {
    await _stopAllPlayers();

    await audioPlayer.setAsset(url);
    audioPlayer.play();
  }


  Future<void> _stopAllPlayers() async {
    await audioPlayer.stop();

  }

  Future<void> startRecording() async {
    
    String fileName = DateTime.now().millisecondsSinceEpoch.toString(); 
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    filePath = '$tempPath/$fileName.wav';

    await _recorder.openRecorder();
    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV
    );
    audioFile = File(filePath!);

  
  }
  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
    _messagecontroller.send_message_sound(widget.sender_id, widget.receiver_id,DateTime.now().toString(),"SOUND",audioFile);
    print('Kayıt Dosya Yolu: $filePath');
  }
  
   void _startRecordingAnimation() {
    _isRecording = true;
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _iconPosition = _iconPosition == 0.0 ? -10.0 : 0.0;
      });
    });
  }

  void _stopRecordingAnimation() {
    _isRecording = false;
    _timer?.cancel();
    setState(() {
      _iconPosition = 0.0; 
    });
  }

  @override
  void initState() {
    super.initState();
    Statuscontroller().set_receiver_status(widget.sender_id, widget.receiver_id, "online");
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;
        if (!isTop) {
          _isAutoScroll = true;
        }
      } else {
        _isAutoScroll = false;
      }
    });
    init();
  }

  @override
  void dispose() {
    Statuscontroller().set_receiver_status(widget.sender_id, widget.receiver_id, "offline");
    audioPlayer.dispose();
    _recorder.closeRecorder();
    _timer?.cancel();
    _scrollController.dispose();
    init();
    super.dispose();
  }



  Widget build(BuildContext context) {
    final _messagecontroller = Get.put(Messagecontroller());
    final _permission = Get.put(PermissionController());
    final _status = Get.put(Statuscontroller());
    
    return Scaffold(
      
        backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          width: Get.width - 20,
          child: Row(
            children: [
              Container(
                width: Get.width - 70,
                child: Obx(
                  () => TextField(
                    maxLines: null,
                    minLines: 1,
                    controller: _messagecontroller.message_controller.value,
                    decoration: InputDecoration(
                        hintStyle: GoogleFonts.montserrat(
                            fontSize: 17, fontWeight: FontWeight.w500),
                        suffixIcon: Container(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(onTap: () async{
                                File? selectFile;
                                final picker = await ImagePicker().pickImage(source: ImageSource.gallery);
                                if (picker != null){
                                    selectFile = File(picker.path);
                                    _messagecontroller.send_message_file(widget.sender_id, widget.receiver_id, DateTime.now().toString(), "IMAGE", selectFile);
                                  }
                              }, child: Icon(Icons.image)),
                              SizedBox(
                                width: 10,
                              ),
                              
                              InkWell(
                              onTap: (){
                                if (_isRecording) {
                                    _stopRecordingAnimation();
                                    stopRecording();
                                  }
                              },
                                onLongPress: () async{
                                  _permission.requestPermission();
                                  final prefs = await SharedPreferences.getInstance();
                                  if (!_isRecording && prefs.getBool("permission") == true) {
                                    startRecording();
                                    _startRecordingAnimation();
                                  } else {
                                    stopRecording();
                                    _stopRecordingAnimation();
                                  }
                                }, child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                  height: 25,
                                  width: 25,
                                  transform: Matrix4.translationValues(0.0, _iconPosition, 0.0),
                                  child: Icon(Icons.mic, size: 25,))),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                        ),
                        filled: true,
                        fillColor: Color.fromRGBO(241, 244, 255, 1),
                        hintText: "Type message ...",
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 3, 0, 182))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.transparent))),
                  ),
                ),
              ),
              IconButton(
                  onPressed: widget.send_message,
                  icon: Icon(Icons.send_rounded))
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.off(Chats(),
                              transition: Transition.leftToRight,
                              duration: Duration(milliseconds: 500));
                        },
                        icon: Icon(Icons.arrow_back_rounded)),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(widget.profile_image),
                              fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(10)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.name,
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        widget.status == "online"?Text(widget.status):Row(
                          children: [
                            Text("last seen ", style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),),
                            DateTime.parse(widget.status).day == today.day && DateTime.parse(widget.status).month == today.month && DateTime.parse(widget.status).year == today.year ? Row(children: [
                              Text("Today "),
                              Text("${DateTime.parse(widget.status).hour}:"),
                              Text("${DateTime.parse(widget.status).minute}"),
                            ],): Row(children: [
                              Text("${DateTime.parse(widget.status).day}."),
                              Text("${DateTime.parse(widget.status).month}."),
                              Text("${DateTime.parse(widget.status).year} "),
                              Text("${DateTime.parse(widget.status).hour}:"),
                              Text("${DateTime.parse(widget.status).minute}"),
                            ],)
                          ],
                        ) //////////////////////////////////status//////////////////////////////
                      ],
                    ),
                    Spacer(),
                    
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _messagecontroller.get_messages(
                      widget.sender_id, widget.receiver_id),
                  builder: (context, snapshot) {
                    
                    final data = snapshot.data!;
                    if (snapshot.hasData || snapshot.data!.isNotEmpty || snapshot.data != null){
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Future.delayed(Duration(seconds: 1),(){
                          _status.message_status(widget.sender_id, widget.receiver_id); 
                        });
                        });
                      
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty || snapshot.data == null) {
                      return Center(child: Text('No messages yet'));
                    }
                    if (_isAutoScroll) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 100), 
                              curve: Curves.easeInOut,
                            );
                          }
                        });
                  }
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: data.length,
                      itemBuilder: (context, index) {

                        bool isLastMessage = index == data.length - 1;
                        return int.parse(data[index]['sender_id'].toString()) == widget.receiver_id
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20,),
                                data[index]['message_type'] == "SOUND"?Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AudioPlayerWidget(
                                      icon_color: Colors.white,
                                      slider_color: Colors.white.withOpacity(0.8),
                                      overlay_color: Colors.white.withOpacity(0.1),
                                      container_color: Color.fromRGBO(3, 0, 182, 0.75),
                                      active_track_color: Colors.white,
                                                                       audioUrl: "https://appoaep.space/get_message_sound?sender_id=${widget.sender_id}&&receiver_id=${widget.receiver_id}&&sound_path=${data[index]['message']}",
                                                                       )],
                                ):data[index]['message_type'] == 'IMAGE'?Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  
                                   children: [
                                    GestureDetector(
                                      onTap: (){
                                        Get.to(
                                          PhotoView(imageProvider: NetworkImage("https://appoaep.space/get_file_message?sender_id=${widget.sender_id}&receiver_id=${widget.receiver_id}&filename=${data[index]['message']}"),
                                          backgroundDecoration: BoxDecoration(color: Colors.black),
                                          minScale: PhotoViewComputedScale.contained,
                                          maxScale: PhotoViewComputedScale.covered * 2,
                                          ),
                                        );
                                        
                                        },
                                      child: Container(
                                      height: 250,
                                      width: 250,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(image: NetworkImage("https://appoaep.space/get_file_message?sender_id=${widget.sender_id}&receiver_id=${widget.receiver_id}&filename=${data[index]['message']}"))
                                        ,borderRadius: BorderRadius.circular(10),
                                      ),
                                      ),
                                    )],
                                 ):Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 20),
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(212, 1, 51, 214),
                                          borderRadius: BorderRadius.circular(10),
                                          shape: BoxShape.rectangle
                                        ),
                                        child: (data[index]['message'].startsWith('http://') 
                                        || data[index]['message'].startsWith('https://')?TextButton(onPressed: ()async{
                                          await launchUrlString(data[index]['message']);
                                        }, child: Text(data[index]['message'],style: GoogleFonts.montserrat(
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white
                                        ),)):Text(data[index]['message'],
                                        
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          
                                      
                                        ),)),
                                                                          ),
                                    )],
                                    
                                    
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 22),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          
                                          Text("${DateTime.parse(data[index]['created_at_message']).hour.toString()}:",),
                                          Text(data[index]['created_at_message'].toString().substring(14,16)),
                                          
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5,),
                                    if (isLastMessage) SizedBox(height: 80)
                                    
                                    ],
                            )
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                 data[index]['message_type'] == "SOUND"?Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                   children: [
                                    Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                     children: [
                                      InkWell(
                                        onLongPress: (){
                                          showDialog(
                                                      context: context, 
                                                      builder: (context) => SimpleDialog(
                                                        backgroundColor: Colors.white,
                                                        title: Text("Are you sure to delete the message?"),
                                                        children: [
                                                          TextButton(onPressed: (){
                                                            _messagecontroller.deleted_message(data[index]['created_at_message'], widget.sender_id, widget.receiver_id);
                                                            Get.back();
                                                          }, child: Text("Delete message", style: TextStyle(
                                                            color: Colors.black
                                                          ),)),
                                                          
                                                        ],
                                                      ),);
                                        },
                                        child: AudioPlayerWidget(
                                          icon_color: Colors.black.withOpacity(0.8),
                                          slider_color: Colors.black.withOpacity(0.8),
                                          overlay_color: Color.fromRGBO(3, 0, 182, 0.1),
                                          container_color: Colors.black.withOpacity(0.07),
                                          active_track_color: Color.fromARGB(255, 3, 0, 182),
                                                                           audioUrl: "https://appoaep.space/get_message_sound?sender_id=${widget.sender_id}&&receiver_id=${widget.receiver_id}&&sound_path=${data[index]['message']}",
                                                                           ),
                                      )],
                                   ),
                                   data[index]['status'] == "waiting"? Icon(Icons.timelapse_rounded): Icon(Icons.check_circle_outline_rounded, color: Color.fromARGB(255, 3, 0, 182),)
                                   ],
                                 )
                                   :data[index]['message_type'] == "IMAGE"?Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                     children: [
                                      Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                     children: [
                                      InkWell(
                                        onLongPress: (){
                                          showDialog(
                                                      context: context, 
                                                      builder: (context) => SimpleDialog(
                                                        backgroundColor: Colors.white,
                                                        title: Text("Are you sure to delete the message?"),
                                                        children: [
                                                          TextButton(onPressed: (){
                                                            _messagecontroller.deleted_message(data[index]['created_at_message'], widget.sender_id, widget.receiver_id);
                                                            Get.back();
                                                          }, child: Text("Delete message", style: TextStyle(
                                                            color: Colors.black
                                                          ),)),
                                                          
                                                        ],
                                                      ),);
                                        },
                                        child: GestureDetector(
                                          onTap: (){
                                            Get.to(
                                              PhotoView(imageProvider: NetworkImage("https://appoaep.space/get_file_message?sender_id=${widget.sender_id}&receiver_id=${widget.receiver_id}&filename=${data[index]['message']}"),
                                              backgroundDecoration: BoxDecoration(color: Colors.black),
                                              minScale: PhotoViewComputedScale.contained,
                                              maxScale: PhotoViewComputedScale.covered * 2,),
                                            );
                                          },
                                          child: Container(
                                          height: 250,
                                          width: 250,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(image: NetworkImage("https://appoaep.space/get_file_message?sender_id=${widget.sender_id}&receiver_id=${widget.receiver_id}&filename=${data[index]['message']}"))
                                            ,borderRadius: BorderRadius.circular(10),
                                          ),
                                          ),
                                        ),
                                      )],
                                                                      ),
                                                                      
                                    data[index]['status'] == "waiting"? Icon(Icons.timelapse_rounded): Icon(Icons.check_circle_outline_rounded, color: Color.fromARGB(255, 3, 0, 182),),
                                    ],
                                   ):Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                     children: [
                                      Row(
                                                                     mainAxisAlignment: MainAxisAlignment.end,
                                                                     children: [
                                                                       Flexible(
                                          child: InkWell(
                                            onLongPress: (){
                                              showDialog(
                                                      context: context, 
                                                      builder: (context) => SimpleDialog(
                                                        backgroundColor: Colors.white,
                                                        title: Text("Are you sure to delete the message?"),
                                                        children: [
                                                          TextButton(onPressed: (){
                                                            _messagecontroller.deleted_message(data[index]['created_at_message'], widget.sender_id, widget.receiver_id);
                                                            Get.back();
                                                          }, child: Text("Delete message", style: TextStyle(
                                                            color: Colors.black
                                                          ),)),
                                                          
                                                        ],
                                                      ),);
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(left: 40),
                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(10),
                                                shape: BoxShape.rectangle
                                              ),
                                              child: data[index]['message'].startsWith('http://') 
                                            || data[index]['message'].startsWith('https://')?TextButton(onPressed: ()async{
                                              await launchUrlString(data[index]['message']);
                                            }, child: Text(data[index]['message'],style: GoogleFonts.montserrat(
                                              decoration: TextDecoration.underline,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600
                                            ),)):Text(data[index]['message'],
                                              
                                              style: GoogleFonts.montserrat(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                
                                            
                                              ),)),
                                          ),
                                        ),
                                        SizedBox(width: 20,)
                                                                     ],
                                                                   ),
                                      data[index]['status'] == "waiting"? Icon(Icons.timelapse_rounded): Icon(Icons.check_circle_outline_rounded, color: Color.fromARGB(255, 3, 0, 182),)],
                                   ),
                              Container(
                                      
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          
                                          Text("${DateTime.parse(data[index]['created_at_message']).hour.toString()}:",),
                                          Text(data[index]['created_at_message'].toString().substring(14,16)),
                                          SizedBox(width: 19,),
                                        ],
                                      ),
                                    ),
                              SizedBox(height: 5,),
                              if (isLastMessage) SizedBox(height: 80)
                              ],
                            );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
