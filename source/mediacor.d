//#not sure
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
				
				foreach(med; this.save)
					if (med.name == name && med.sound.mSnd)
						med.sound.play;
				jx.addToHistory(name ~ " - media loaded");
			} else {
				jx.addToHistory("Some error!");
			}
		}
	}

	void listMediaFiles(InputJex jx) {
		foreach(aline; ["",
				"List of picture names:"])
			jx.addToHistory(aline);
		
		foreach(i, pic; this.save.enumerate)
			jx.addToHistory(i, ") ", pic.name);
		jx.addToHistory("");
	}

	void listMediaLots(InputJex jx, bool toScreen = true) {
		import std.path : dirSeparator;
		import std.file : dirEntries, SpanMode, isDir;
		import std.range : array;
		import std.conv : to, text;
		import std.string : split;
		import std.algorithm : sort;

		_lots.length = 0;
		if (toScreen)
			jx.addToHistory(""),
			jx.addToHistory("Up pictures lots list: (to do)");
		int i;
		foreach(string entry; dirEntries("media", "*", SpanMode.shallow).array.sort!"a < b") {
			if (entry.isDir) {
				_lots ~= entry.split(dirSeparator)[1];
				if (toScreen)
					jx.addToHistory(i, ") ", _lots[$ - 1]);
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
		import std.file : dirEntries, SpanMode;
		import std.string;
		import std.stdio : writeln, writef;
		import std.range : array;
		import std.algorithm : sort;

		_mediaLst.length = 0;
		string[] picList;
		foreach(string name; dirEntries(buildPath("media", g_global.pictureLot), "*.{png,jpg,jpeg,bmp}", SpanMode.shallow)
																								.array.sort!"a < b") {
			picList ~= name;
			if (! toScreen)
				writeln(name);
			/+
			// load a image file for object
			auto texture = new Texture;
			if (! texture.loadFromFile(name)) { // load off program root folder
				throw new Exception(name ~ " not load");
			}
			+/
			auto nm = name.split(dirSeparator)[2]; //media[0]/odds[1]/name[2]
			import std.string : toStringz;
			auto surface = IMG_Load(name.toStringz);
			scope(exit)
				SDL_FreeSurface(surface);
			if (surface is null) {
				import std.conv : to;
				throw new Exception("Surface '" ~ name ~ "' load failed: " ~ IMG_GetError().fromStringz.to!string );
			}
			auto texture = SDL_CreateTextureFromSurface( gRenderer, surface );
			if (! texture)
				throw new Exception("Texture create failier.");
			auto rect = SDL_Rect((SCREEN_WIDTH - surface.w) / 2, SCREEN_HEIGHT, surface.w, surface.h);

			import std.algorithm : until;
			import std.file : exists;

			JSound audio;
			auto nameWithOutExt = name.until(".").to!string;
			foreach(ext; ".wav .ogg".split) //#has to be lowercase in folder
				if ((nameWithOutExt ~ ext).exists) {
					audio = JSound(nameWithOutExt ~ ext);
					if (! audio.mSnd)
						jx.addToHistory(nameWithOutExt ~ ext, " - found, but failed to load.");
				}
			add(nm.stripExtension, new Media(nm, texture, rect, audio));
			if (toScreen) {
				jx.addToHistory(nm.until("."));
//#not sure
				SDL_SetRenderDrawColor(gRenderer, 0x00, 0x00, 0x00, 0x00);
				SDL_RenderClear(gRenderer);

				jx.draw;
				
				SDL_RenderPresent(gRenderer);

				SDL_Delay(2);
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
				//med.rect = SDL_Rect((g_global.windowWidth - med.rect.w) / 2, g_global.windowHeight);
				med.pos = Point((g_global.windowWidth - med.rect.w) / 2, g_global.windowHeight);
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
		//g_showing = true;
		float y = g_global.windowHeight;
		foreach(med; this.save) {
			med.hide = false;
			med.pos = Point(med.pos.X, y); //SDL_Rect(med.rect.x, cast(int)y, med.rect.w, med.rect.h);
			//med.mSpr.pos = Point(med.mSpr.pos.X, y);
			med.picCase = Pict.up;
			y += med.rect.h;
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

	void close() {
		foreach(m; this) {
			m.close;
		}
	}
}
