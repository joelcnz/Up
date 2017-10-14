//#what about remove?
//#not used yet, for input text opposite of colour here
public {
	import std.conv : to;
	import std.range : enumerate;

	import dsfml.graphics;
	import dsfml.audio;
	
	import jec,
		   bible.base,
		   jmisc,
		   dini.dini;

	import setup, upwords, pictureman, picture, audio, setfile, backpictureman, backpicture;
}

enum Pict {up, stopped, remove} //#what about remove?
enum Moving {moving, stopped}

alias jx = g_inputJex;

struct Info {
	string bibleRef,
		bookNum,
		picName,
		soundName,
		numOfVerses,
		fps,
		fontSize,
		colour;
}
Info info;

struct Global {
	SetFile settings;

	string pictureLot; // picture folder name

	int windowWidth, windowHeight;

	PictureMan pictureMan;
	Picture picture;

	BackPictureMan backPictures;
	BackPicture backPicture;

	float pictureUpStep = 1;
	float textUpStepSize = 1;

	int chunkSize;
	int fps;

	string[] fontList;
	string currentFontFileName;
	int fontSize;
	Color verseTxtColour,
		  backGroundColour,
		  inputColour; //#not used yet, for input text opposite of colour here
	
	string[] addsLines;

	void saveAddsLines() {
		import std.stdio;
		auto f = File("addsnotes.txt", "w");
		foreach(line; addsLines)
			f.writeln(line);
	}
	
	Message[] messages;
	Audio[] sounds;
}
Global g_global;

struct Message {
	static int _index;
	string _fileName;
	string _text;
}
