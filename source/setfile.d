// settings file

//#I've opened a issue for the guy that does the dini library. He has said it was tricky and closed the issue
// setExtention should be used for the ".txt"'s
import std.stdio: File, readln, writeln;
import std.string: stripRight, split, format;
import std.conv: to;

import base;

struct SetFile {
//	Ini _file;
	string iniFileName;
	
	
	/+
	fontSize = 70;
	chunkSize = 40;
	fps = 60;
	colour = Color(255,180,0);
	+/
		
	void setIniFileName(in string name) {
		iniFileName = name;
	}

	void load() {
		with(g_global) {
		    // Parse file
		    auto ini = Ini.Parse(iniFileName);

			try {
				currentFontFileName = ini["settings"].getKey("currentFontFileName");
				fontSize = ini["settings"].getKey("fontSize").to!int;
				chunkSize = ini["settings"].getKey("chunkSize").to!int;
				textUpStepSize = ini["settings"].getKey("textUpStepSize").to!float;
				pictureUpStep = ini["settings"].getKey("pictureUpStep").to!float;
				backPicture._fileName = ini["settings"].getKey("backPicture");
				fps = ini["settings"].getKey("fps").to!int;
				pictureLot = ini["settings"].getKey("pictureLot");
			} catch(Exception e) {
				assert(0, text("Error loading configuration file: ", iniFileName));
			}
			try { delay = ini["settings"].getKey("delay").to!int; } catch(Exception e) { writeln("delay not found"); }

			backPicture.load(backPicture._fileName);

			try {
				auto colourString = ini["settings"].getKey("verseTxtColour").split.to!(ubyte[]);
				verseTxtColour = SDL_Color(colourString[0], colourString[1], colourString[2], 0);

				colourString = ini["settings"].getKey("backGroundColour").split.to!(ubyte[]);
				backGroundColour = SDL_Color(colourString[0], colourString[1], colourString[2], 0);

				colourString = ini["settings"].getKey("inputColour").split.to!(ubyte[]);
				inputColour = SDL_Color(colourString[0], colourString[1], colourString[2], 0);
			} catch(Exception e) {
				assert(0, "ini colour change error");
			}

			with(info) {
				fps = g_global.fps.to!string;
				fontName = currentFontFileName;
				fontSize = g_global.fontSize.to!string;
				colour = text("Red: ", verseTxtColour.r,", Green: ", verseTxtColour.g,   ", Blue: ", verseTxtColour.b);
				backColour = text("Red: ", backGroundColour.r,", Green: ", backGroundColour.g,   ", Blue: ", backGroundColour.b);
				inputColour = text("Red: ", g_global.inputColour.r,", Green: ", g_global.inputColour.g,   ", Blue: ", g_global.inputColour.b);
				backPicture = g_global.backPicture._fileName;
				pictureLot = g_global.pictureLot;
				wrapSize = chunkSize.to!string;
				settingFile = iniFileName;
				textUpStepSize = g_global.textUpStepSize.to!string;
				pictureUpStepSize = g_global.pictureUpStep.to!string;
			}
		}
	}
	
	void save() {
		writeln("Saving: ", iniFileName);
		with(g_global) {
			auto _file = File(iniFileName, "w");
			with(_file) {
				writeln("[settings]");
				writefln!"currentFontFileName=%s"(currentFontFileName);
				writefln!           "fontSize=%s"(fontSize);
				writefln!          "chunkSize=%s"(chunkSize);
				writefln!                "fps=%s"(fps);
				writefln!        "backPicture=%s"(backPicture._fileName);
				writefln!      "pictureUpStep=%s"(pictureUpStep);
				writefln!     "textUpStepSize=%s"(textUpStepSize);
				writefln!         "pictureLot=%s"(pictureLot);
				writefln!              "delay=%s"(delay);
				with(verseTxtColour)
					writefln!"verseTxtColour=%s %s %s"(r, g, b);
				with(backGroundColour)
					writefln!"backGroundColour=%s %s %s"(r, g, b);
				with(inputColour)
					writefln!"inputColour=%s %s %s"(r, g, b);

			}
		}
	}
}
