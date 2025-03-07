import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  final List<String> _sounds = [
    'sounds/اتعب القلب فرقاك غريب ال مخلص.mp3',
    'sounds/شيلة لا تتصل وتقول ودي اشوفك.mp3',
    'sounds/بدر العزي في غربتي.mp3',
    'sounds/عبدالله ال فروان طال السهر.mp3',
    'sounds/عبدالله ال فروان اسهر وياطيفك.mp3',
    'sounds/شيلة تمنيت العمر .mp3',
    'sounds/_ياعرب_حنيت_نادر_الشراري_حصريا2022.mp3',
    'sounds/_طغاة_الحسن_عبدالله_ال_فروان_حصريا2022.mp3',
    'sounds/_فيني_مايكفيني_بدر_العزي_حصريا2022.mp3',
    'sounds/_خاين_ضميرم_بدر_العزيجمعة_العريمي2021.mp3',
  ];

  List<Duration> _soundDurations = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _loadDurations();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    _player.onDurationChanged.listen((Duration d) {
      setState(() => _duration = d);
    });

    _player.onPositionChanged.listen((Duration p) {
      setState(() => _position = p);
    });

    _player.onPlayerComplete.listen((_) {
      setState(() {
        _position = Duration.zero;
        isPlaying = false;
      });
    });
  }

  Future<void> _loadDurations() async {
    List<Duration> durations = [];
    for (var sound in _sounds) {
      final player = AudioPlayer();
      await player.setSource(AssetSource(sound));
      Duration? duration = await player.getDuration();
      durations.add(duration ?? Duration.zero);
      player.dispose();
    }

    setState(() {
      _soundDurations = durations;
    });
  }

  Future<void> _togglePlay() async {
    if (isPlaying) {
      await _player.pause();
    } else {
      if (_position == Duration.zero) {
        await _player.play(AssetSource(_sounds[_currentIndex]));
      } else {
        await _player.resume();
      }
    }
    setState(() => isPlaying = !isPlaying);
  }

  Future<void> _seekTo(Duration position) async {
    await _player.seek(position);
    setState(() => _position = position);
  }

  void _nextSound() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _sounds.length;
    });
    _player.play(AssetSource(_sounds[_currentIndex]));
  }

  void _previousSound() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _sounds.length) % _sounds.length;
    });
    _player.play(AssetSource(_sounds[_currentIndex]));
  }

  void _playSound(int index) {
    setState(() {
      _currentIndex = index;
      isPlaying = true;
    });
    _player.play(AssetSource(_sounds[index]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "زوامل الشيخ مقبل طلان",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 10,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _sounds.length,
                      itemBuilder: (context, index) {
                        String title = _sounds[index]
                            .split('/')
                            .last
                            .replaceAll('.mp3', '');
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
                            leading: Icon(Icons.music_note,
                                size: 34, color: Colors.deepPurple),
                            title: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            subtitle: Text(
                              _soundDurations.isNotEmpty
                                  ? _soundDurations[index].toString().split('.')[0]
                                  : 'جاري التحميل...',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: IconButton(
                              onPressed: () => _playSound(index),
                              icon: Icon(
                                isPlaying && _currentIndex == index
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 35,
                                color: isPlaying && _currentIndex == index
                                    ? Colors.deepPurple
                                    : Colors.black,
                              ),
                            ),
                            onTap: () => _playSound(index),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Text(
                    _sounds[_currentIndex]
                        .split('/')
                        .last
                        .replaceAll('.mp3', ''),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 8),
                  Slider(
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    value: _position.inSeconds.toDouble(),
                    onChanged: (value) => _seekTo(Duration(seconds: value.toInt())),
                    activeColor: Colors.deepPurple,
                    inactiveColor: Colors.grey[300],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _position.toString().split('.')[0],
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          _duration.toString().split('.')[0],
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.skip_previous, size: 35),
                        color: Colors.deepPurple,
                        onPressed: _previousSound,
                      ),
                      SizedBox(width: 30),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 35,
                            color: Colors.white,
                          ),
                          onPressed: _togglePlay,
                        ),
                      ),
                      SizedBox(width: 30),
                      IconButton(
                        icon: Icon(Icons.skip_next, size: 35),
                        color: Colors.deepPurple,
                        onPressed: _nextSound,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 230,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Center(
              child: Text(
                "زوامر الشاعر مقبل طلان",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.share, color: Colors.deepPurple),
            title: Text('مشاركة التطبيق'),
            onTap: () {
              // إضافة فعل للمشاركة هنا
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.deepPurple),
            title: Text('معلومات عن التطبيق'),
            onTap: () {
              // إضافة فعل للمعلومات هنا
            },
          ),
        ],
      ),
    );
  }
}

