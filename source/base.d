//#not used yet, for input text opposite of colour here
public {
	import std.conv : to;
	import std.range : enumerate;

	import jecsdl,
		   bible,
		   jmisc,
		   dini.dini;

	import fsetup, upwords, mediacor, media, audio, setfile, backpictureman, backpicture;
}

enum Pict {up, stopped}
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
	int delay = 50;

	SetFile settings;

	string pictureLot; // picture folder name

	int windowWidth, windowHeight;

	MediaCor mediaCor;
	Media media;

	BackPictureMan backPictures;
	BackPicture backPicture;

	float pictureUpStep = 1;
	float textUpStepSize = 1;

	int chunkSize;
	int fps;

	string[] fontList;
	string currentFontFileName;
	int fontSize;
	SDL_Color verseTxtColour,
		  backGroundColour,
		  inputColour; //#not used yet, for input text opposite of colour here
	
	string[] addsLines;
	string[] settingFileNames;
	Message[] messages;

	void saveAddsLines() {
		import std.stdio;
		auto f = File("addsnotes.txt", "w");
		foreach(line; addsLines)
			f.writeln(line);
	}
}
Global g_global;

struct Message {
//	static int _index;
	string _fileName;
	string _text;
}
