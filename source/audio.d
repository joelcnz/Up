import base;

class Audio {
private:
	dstring _fileName;
	SoundBuffer _soundBuf;
	Sound _sound;
public:
	auto fileName() { return _fileName; }

	this(dstring fileName0) {
		_fileName = fileName0;
		_soundBuf = new SoundBuffer;
		import std.conv: to;

		_soundBuf.loadFromFile(_fileName.to!string);
		_sound = new Sound;
		_sound.setBuffer(_soundBuf);
	}
	
	void play() {
		_sound.play;
	}
}