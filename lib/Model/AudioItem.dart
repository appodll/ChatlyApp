import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final container_color;
  final active_track_color;
  final overlay_color;
  final icon_color;
  final slider_color;

  AudioPlayerWidget({
    required this.icon_color,
    required this.slider_color,
    required this.overlay_color,
    required this.audioUrl,
    required this.container_color,
    required this.active_track_color,
  });

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool isPlaying = false;
  bool _isThumbPressed = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.setUrl(widget.audioUrl).then((_) {
      setState(() {
        _duration = _audioPlayer.duration ?? Duration.zero;
      });
    });

    _audioPlayer.positionStream.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    _audioPlayer.playerStateStream.listen((PlayerState state) {
      setState(() {
        isPlaying = state.playing;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _seek(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    Duration remaining = _duration - _position;
    String formatTime(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String minutes = twoDigits(duration.inMinutes.remainder(60));
      String seconds = twoDigits(duration.inSeconds.remainder(60));
      return "$minutes:$seconds";
    }

    return Row(
      children: [
        SizedBox(width: 15),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: widget.container_color,
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: widget.active_track_color,
                    inactiveTrackColor: widget.slider_color,
                    thumbColor: Colors.white,
                    overlayColor: widget.overlay_color,
                    trackHeight: 4.0,
                    thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: _isThumbPressed ? 8.0 : 12.0),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
                  ),
                  child: Slider(
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    value: _position.inSeconds.toDouble(),
                    onChanged: (value) {
                      _seek(Duration(seconds: value.toInt()));
                    },
                    onChangeStart: (double value) {
                      setState(() {
                        _isThumbPressed = true;
                      });
                    },
                    onChangeEnd: (double value) {
                      setState(() {
                        _isThumbPressed = false;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _playPause,
                  iconSize: 25,
                  color: widget.icon_color,
                ),
            
                
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                  formatTime(remaining),
                  style: TextStyle(color: Colors.black),
                ),
            )
            ],
          ),
        ),
        SizedBox(width: 15),
      ],
    );
  }
}
