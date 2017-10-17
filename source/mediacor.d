//#has to be lowercase in folder
import base;

/// Media Cordinator
class MediaCor {
	Media[] _mediaLst;
	string[] _lots;

	void selectMedia(string[] elms) {
		if (elms.length == 2) {
			import std.path : dirSeparator;

			string name = elms[1];
			
			import std.ascii : isDigit;
			if (name[0].isDigit) {
				try {
					if (name == "")
						throw new Exception("Out of bounds");
					name = getStrFromNum(name.to!ubyte);
				} catch(Exception e) {
					jx.addToHistory("Invalid picture value!");
				}
			}
			if (getName(name) != "") {
				activate(name, Pict.up);
				info.picName = name;
				
				foreach(med; _mediaLst)
					if (med.name == name && med.sound)
						med.sound.play;
				jx.addToHistory(name.to!dstring ~ " - media loaded");
			} else {
				jx.addToHistory("Some error!");
			}
		}
	}

	void listMediaFiles(InputJex jx) {
		foreach(aline; ["",
				"List of picture names:"])
			jx.addToHistory(aline.to!dstring);
		
		foreach(i, pic; this.save.enumerate)
			jx.addToHistory(i.to!dstring ~ ") " ~ pic.name.to!dstring);
		jx.addToHistory("");
	}

	void listMediaLots(InputJex jx, bool toScreen = true) {
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
		foreach(string entry; dirEntries("media", "*", SpanMode.shallow)) {
			if (isDir(entry)) {
				_lots ~= entry.split(dirSeparator)[1];
				if (toScreen)
					jx.addToHistory(text(i, ") ", _lots[$ - 1]).to!dstring);
				i += 1;
			}
		}
	}

	void selectMediaLot(InputJex jx, in string[] elm, in bool toString = false) {
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
		loadMediaLot(toString);
	}

	void loadMediaLot(in bool toScreen = false) {
		import std.path : buildPath, dirSeparator;
		import std.file;
		import std.string;
		import std.stdio : writeln, writef;

		_mediaLst.length = 0;
		string[] picList;
		foreach(string name; dirEntries(buildPath("media", g_global.pictureLot), "*.{png,jpg}", SpanMode.shallow)) {
			picList ~= name;
			if (! toScreen)
				writeln(name);
			
			// load a image file for object
			auto texture = new Texture;
			if (! texture.loadFromFile(name)) { // load off program root folder
				throw new Exception(name ~ " not load");
			}
			auto nm = name.split(dirSeparator)[2]; //media[0]/odds[1]/name[2]
			import std.algorithm : until;

			Audio audio = null;
			auto nameWithOutExt = name.until(".").to!dstring;
			foreach(ext; ".wav .ogg"d.split) //#has to be lowercase in folder
				if ((nameWithOutExt ~ ext).exists) {
					audio = new Audio(nameWithOutExt ~ ext);
					if (! audio)
						jx.addToHistory(nameWithOutExt ~ ext, " - found, but failed to load.");
				}
			add(nm[0 .. $ - 4], new Media(nm, texture, audio));
			if (toScreen) {
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
		foreach(ref med; this.save) {
			if (med.name == name) {
				med.picCase = picCase;
				med.hide = false;
				med.spr.position = Vector2f((g_global.windowWidth - med.spr.getGlobalBounds().width) / 2, g_global.windowHeight);
				//pic.spr.position = Vector2f(-pic.spr.getGlobalBounds().width, 0);
			}
		}
	}
	
	void add(string name, Media med) {
 		_mediaLst ~= med;
		_mediaLst[$ - 1].name = name;
	}

	// Is name in pic's? If it is, return the name else return an empty string
	string getName(in string name) {
		foreach(med; this.save)
			if (med.name == name)
				return name;
		return "";
	}

	string getStrFromNum(in ubyte select) {
		if (select < _mediaLst.length)
			return _mediaLst[select].toString;
		else
			return "";
	}

	/// Show all pictures in folder but moving them up and up
	void show() {
		float y = g_global.windowHeight;
		foreach(med; this.save) {
			med.hide = false;
			med.spr.position = Vector2f(med.spr.position.x, y);
			med.picCase = Pict.up;
			y += med.spr.getGlobalBounds().height;
		}
	}

	void process() {
		foreach(med; this.save)
			med.process;
	}
	
	void hideAll() {
		foreach(med; this.save)
			med.hide = true;
	}
	
	void draw() {
		foreach(med; this.save)
			med.draw;
	}
		
	// a forward range
	@property bool empty() { return _mediaLst.length == 0; }
	@property ref auto front() { return _mediaLst[0]; }
	void popFront() { _mediaLst = _mediaLst[1 .. $]; }
	auto save() { return _mediaLst; }
}
