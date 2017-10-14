import base;

/// Handle going up pictures
class PictureMan {
	Picture[] _pics;
	string[] _lots;

	void selectPicture(string[] elms) {
		if (elms.length == 2) {
			import std.path : dirSeparator;

			string name = elms[1];
			
			import std.ascii : isDigit;
			if (name[0].isDigit) {
				try {
					name = getStrFromNum(name.to!ubyte);
					if (name == "")
						throw new Exception("Out of bounds");
				} catch(Exception e) {
					jx.addToHistory("Invalid picture value!");
				}
			}
			if (getName(name) != "") {
				activate(name, Pict.up);
				info.picName = name;
				
				foreach(sound; g_global.sounds) {
					import std.string : split;
					auto audioName = sound.fileName.split(dirSeparator)[1];
					if (audioName == name ~ ".wav") {
						sound.play;
					}
				}
				jx.addToHistory(name.to!dstring ~ " - picture loaded");
			} else {
				jx.addToHistory("Some error!");
			}
		}
	}

	void listPictureFiles(InputJex jx) {
		foreach(aline; ["",
				"List of picture names:"])
			jx.addToHistory(aline.to!dstring);
		
		foreach(i, pic; this.save.enumerate)
			jx.addToHistory(i.to!dstring ~ ") " ~ pic.name.to!dstring);
		jx.addToHistory("");
	}

	void listPictureLots(InputJex jx, bool toScreen = true) {
		import std.path : dirSeparator;
		import std.file;
		import std.range;
		import std.conv : to, text;
		import std.string : split;

		_lots.length = 0;
		if (toScreen)
			jx.addToHistory(""d),
			jx.addToHistory("Up pictures lots list: (to do)"d);
		int i;
		foreach(string entry; dirEntries("pictures", "*", SpanMode.shallow)) {
			if (isDir(entry)) {
				_lots ~= entry.split(dirSeparator)[1];
				if (toScreen)
					jx.addToHistory(text(i, ") ", _lots[$ - 1]).to!dstring);
				i += 1;
			}
		}
	}

	void selectPictureLot(InputJex jx, in string[] elm, in bool toString = false) {
		ubyte selectNum;
		import std.stdio;

		try {
			if (elm.length == 2)
				selectNum = elm[1].to!ubyte;
		} catch(Exception e) {
			jx.addToHistory("Invalid data"d);
		}
		if (selectNum < _lots.length) {
			import std.conv : to, text;

			g_global.pictureLot = _lots[selectNum];
			jx.addToHistory(text(g_global.pictureLot, " selected").to!dstring);
		} else {
			jx.addToHistory("Invalid data"d);
		}
		loadPictureLot(toString);
	}

	void loadPictureLot(in bool toScreen = false) {
		import std.path : buildPath, dirSeparator;
		import std.file;
		import std.string;
		import std.stdio : writeln, writef;

		_pics.length = 0;
		string[] picList;
		foreach(string name; dirEntries(buildPath("pictures", g_global.pictureLot), "*.{png,jpg}", SpanMode.shallow)) {
			picList ~= name;
			if (! toScreen)
				writeln(name);
			
			// load a image file for object
			auto texture = new Texture;
			if (! texture.loadFromFile(name)) { // load off program root folder
				throw new Exception(name ~ " not load");
			}
			auto nm = name.split(dirSeparator)[2]; //pictures[0]/odds[1]/name[2]
			add(nm[0 .. $ - 4], new Picture(nm, texture));
			if (toScreen) {
				import std.algorithm : until;
				jx.addToHistory(nm.until(".").to!dstring);

				g_window.clear;
				jx.draw;
				g_window.display;
			}
			debug(5) writeln('"', nm, '"');
		}
		writeln;
	}

	void activate(string name, Pict picCase) {
		foreach(ref pic; this.save) {
			if (pic.name == name) {
				pic.picCase = picCase;
				pic.hide = false;
				pic.spr.position = Vector2f((g_global.windowWidth - pic.spr.getGlobalBounds().width) / 2, g_global.windowHeight);
				//pic.spr.position = Vector2f(-pic.spr.getGlobalBounds().width, 0);
			}
		}
	}
	
	void add(string name, Picture pic) {
 		_pics ~= pic;
		_pics[$ - 1].name = name;
	}

	// Is name in pic's? If it is, return the name else return an empty string
	string getName(in string name) {
		foreach(pic; this.save)
			if (pic.name == name)
				return name;
		return "";
	}

	string getStrFromNum(in ubyte select) {
		if (select < _pics.length)
			return _pics[select].toString;
		else
			return "";
	}

	/// Show all pictures in folder but moving them up and up
	void show() {
		float y = g_global.windowHeight;
		foreach(p; this.save) {
			p.hide = false;
			p.spr.position = Vector2f(p.spr.position.x, y);
			p.picCase = Pict.up;
			y += p.spr.getGlobalBounds().height;
		}
	}

	void process() {
		foreach(pic; this.save)
			pic.process;
	}
	
	void hideAll() {
		foreach(pic; this.save)
			pic.hide = true;
	}
	
	void draw() {
		foreach(pic; this.save)
			pic.draw;
	}
		
	// a forward range
	@property bool empty() { return _pics.length == 0; }
	@property ref auto front() { return _pics[0]; }
	void popFront() { _pics = _pics[1 .. $]; }
	auto save() { return _pics; }
}
