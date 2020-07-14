/+
import base;

class Audio {
private:
	string mFileName;
	//SoundBuffer _soundBuf;
	//Sound _sound;
	JSound mSnd;
public:
	auto fileName() { return mFileName; }

	this(string fileName0) {
		mFileName = fileName0;
		/+
		_soundBuf = new SoundBuffer;
		import std.conv: to;

		_soundBuf.loadFromFile(_fileName.to!string);
		_sound = new Sound;
		_sound.setBuffer(_soundBuf);
		+/
		mSnd = JSound(mFileName);
	}
	
	void play() {
		mSnd.play;
	}
}
+/
