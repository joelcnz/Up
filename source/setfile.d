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

		    currentFontFileName = ini["settings"].getKey("currentFontFileName");
			fontSize = ini["settings"].getKey("fontSize").to!int;
			chunkSize = ini["settings"].getKey("chunkSize").to!int;
			textUpStepSize = ini["settings"].getKey("textUpStepSize").to!float;
			pictureUpStep = ini["settings"].getKey("pictureUpStep").to!float;
			backPicture._fileName = ini["settings"].getKey("backPicture");
			fps = ini["settings"].getKey("fps").to!int;
			pictureLot = ini["settings"].getKey("pictureLot");

			with(backPicture)
				load(_fileName);


			auto colourString = ini["settings"].getKey("verseTxtColour").split.to!(ubyte[]);
			verseTxtColour = Color(colourString[0], colourString[1], colourString[2]);

			colourString = ini["settings"].getKey("backGroundColour").split.to!(ubyte[]);
			backGroundColour = Color(colourString[0], colourString[1], colourString[2]);

			colourString = ini["settings"].getKey("inputColour").split.to!(ubyte[]);
			inputColour = Color(colourString[0], colourString[1], colourString[2]);
		}
	}
	
	void save() {
		with(g_global) {
			auto _file = File(iniFileName, "w");
			with(_file) {
				writeln("[settings]");
				alias f = format;
				writeln(f("currentFontFileName=%s", currentFontFileName));
				writeln(f(           "fontSize=%s", fontSize));
				writeln(f(          "chunkSize=%s", chunkSize));
				writeln(f(                "fps=%s", fps));
				writeln(f(        "backPicture=%s", backPicture._fileName));
				writeln(f(      "pictureUpStep=%s", pictureUpStep));
				writeln(f(     "textUpStepSize=%s", textUpStepSize));
				writeln(f(         "pictureLot=%s", pictureLot));
				with(verseTxtColour)
					writeln(f("verseTxtColour=%s %s %s", r, g, b));
				with(backGroundColour)
					writeln(f("backGroundColour=%s %s %s", r, g, b));
				with(inputColour)
					writeln(f("inputColour=%s %s %s", r, g, b));

			}
		}
	}
}
