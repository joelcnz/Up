import base;

class Audio {
private:
	string _fileName;
	SoundBuffer _soundBuf;
	Sound _sound;
public:
	auto fileName() { return _fileName; }

	this(dstring fileName0) {
		_fileName = fileName0;
		_soundBuf = new SoundBuffer;
		_soundBuf.loadFromFile(_fileName);
		_sound = new Sound;
		_sound.setBuffer(_soundBuf);
	}
	
	void play() {
		_sound.play;
	}
}