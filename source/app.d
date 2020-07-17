//#mouse button
//#need equivalent (in two places)
//#do back board later
//#weirdness
//#donkey plops!
//#work point
//#not working
//#redundant, I think
//#verses only work once!
//#here - messages
//#here - add notes
//#need more work
//#what's with isDigit?
//#What ever is this!!!
//#hate this! not sure about this
/++
+/
module main;

//debug = 4;
debug = checkPoints;

import std.math;
import std.stdio;
import std.string;
import std.array : split;
import std.file;
import std.conv;
import std.process;
import std.range;
import std.datetime;
import std.path : buildPath, dirSeparator;
import std.algorithm;
import std.ascii;

import base;

enum success = 0, failure = -1;
SDL_Color oppositeColour;

struct BackBoard {
	bool _power;
	JRectangle _backBoard;
}

immutable noPower = false;

BackBoard backBoard = {noPower}; //{/* _power */ false};

version(unittest) {

} else
int main(string[] args) {
	g_checkPoints = true;

//    SCREEN_WIDTH = 640; SCREEN_HEIGHT = 480;
    //SCREEN_WIDTH = 2560; SCREEN_HEIGHT = 1600;
	SCREEN_WIDTH = 1280; SCREEN_HEIGHT = 768;
    if (setup("Poorly Programmed Producions - Presents: Up",
        SCREEN_WIDTH, SCREEN_HEIGHT,
        SDL_WINDOW_SHOWN
        //SDL_WINDOW_OPENGL
        //SDL_WINDOW_FULLSCREEN_DESKTOP
        //SDL_WINDOW_FULLSCREEN
        ) != 0) {
        writeln("Init failed");
        return 1;
    }

	Setup fsetup;
	fsetup.process;
	scope(success) {
		g_global.settings.save();
	}

    scope(exit)
        SDL_DestroyRenderer(gRenderer),
        SDL_Quit();


//	g_mode = Mode.edit;
	g_terminal = true;

	//immutable BIBLE_VER = "KJV";
	immutable BIBLE_VER = "ASV";
	import std.path : buildPath;
	loadBible(BIBLE_VER, buildPath("..", "BibleLib", "Versions"));
		
	g_global.windowWidth = SCREEN_WIDTH;
	g_global.windowHeight = SCREEN_HEIGHT;

/+
//#do back board later
	backBoard._backBoard = new RectangleShape;
	with(backBoard._backBoard) {
		//position = Vector2f(0, 0); //#redundant, I think
		with(g_global)
			size = Vector2f(windowWidth, windowHeight);
		fillColor = Color(0,0,0, 255);
	}
+/	
/+
	g_font = new Font;
	auto fontName = "fonts/DejaVuSans.ttf";
	int retval = g_font.loadFromFile(fontName);
	if (retval == -1) {
		writeln(fontName, " font not load ", __FILE__, " ", __FUNCTION__, " ", __LINE__);

		return retval;
	}

	int fontSize = 12;
	g_inputJex = new InputJex(
		/* position */ Vector2f(0, g_global.windowHeight - fontSize * 2),
		/* font size */ fontSize,
		/* header */ "-h for help: ",
		/* Type (oneLine, or history) */ InputType.history);
	//g_inputJex.setColour(Color.Black);
+/
	const ifontSize = 12;
	jx = new InputJex(Point(0, SCREEN_HEIGHT - ifontSize - ifontSize), ifontSize, "-h/-h2 for help>",
		InputType.history);

	Up[] ups;
	bool moving = true;

	g_global.mediaCor = new MediaCor;
	scope(exit)
		g_global.mediaCor.close;

	void loadBackPictures() {
		g_global.backPictures = new BackPictureMan;
		string[] backPicList;
		backPicList.length = 0;
		writeln("Background Pictures:");
		foreach(string name; dirEntries("backPictures", "*.{png,jpg}", SpanMode.shallow).array.sort!"a < b") {
			backPicList ~= name;
			writeln(name);
			
			auto nm = name.split(dirSeparator)[1];
			g_global.backPictures.add(nm);
			debug(5) writeln('"', nm, '"');
		}
		writeln;
	}

	void loadFontNames() {
		writeln("Fonts:");
		g_global.fontList.length = 0;
		foreach(string name; dirEntries("fonts", "*.{ttf}", SpanMode.shallow).array.sort!"a < b") {
			g_global.fontList ~= name;
			writeln(name);
		}
		writeln;
	}

	void loadSettingsFileNames() {
		writeln("Settings files names:");

		g_global.settingFileNames.length = 0;
		foreach(string name; dirEntries("settingfiles", "*.{ini}", SpanMode.shallow).array.sort!"a < b") {
			name = name[name.indexOf(`/`) + 1 .. $ - 4];
			g_global.settingFileNames ~= name;
			writeln(name);
		}
		writeln;
	}

	void loadMessages() {
		g_global.messages.length = 0;
		writeln("Messages:");
		int i;
		g_global.messages.length = 0;
		foreach(string name; dirEntries("messages", "*.{txt}", SpanMode.shallow).array.sort!"a < b") {
			g_global.messages ~= Message(name, readText(name));
			writeln(name);
			i += 1;
		}
		writeln;
	}

	void loadLittleNotes() {
		//#here - add notes
		writeln("Addsnotes:");
		g_global.addsLines.length = 0;
		foreach(line; File("addsnotes.txt").byLine) {
			g_global.addsLines ~= line.to!string;
			writeln(line);
		}
		writeln;
	}

	void loadUp() {
		//g_window.setFramerateLimit(g_global.fps); //#need equivalent (in two places)
		g_inputJex.setColour(g_global.inputColour);
		g_global.backPicture.load(g_global.backPicture._fileName);
		loadSettingsFileNames;
		g_global.mediaCor.listMediaLots(g_inputJex, false);
		g_global.mediaCor.loadMediaLot();
		loadBackPictures;
		loadFontNames;
		loadMessages;
		loadLittleNotes;
	}
	loadUp;

	import std.datetime.stopwatch : StopWatch;

	StopWatch timer;

    bool done;
    while(! done) {
            //Handle events on queue
            while( SDL_PollEvent( &gEvent ) != 0 ) {
                //User requests quit
                if (gEvent.type == SDL_QUIT)
                    done = true;
            }

		SDL_PumpEvents();

		if (moving) {
			g_global.mediaCor.process;
			//import std.parallelism;
			//ups.parallel.each!"a.process"; //#weirdness
			ups.each!"a.process";
			ups = ups.remove!"a.flaggedForDeletion";
		}

		jx.process; //#input
		if (jx.button != "") {
			string str;
			foreach(c; jx.button) {
				if (c != ' ')
					str ~= c;
				else
					break;
			}

			debug(5)
				mixin(trace("/* str */"));

			jx.textStr = (str ~ ' ').to!dstring;
			jx.xpos = cast(int)((str ~ ' ').length);
			jx.button = "";
			
		}

		if (g_inputJex.enterPressed) {
			int number;
			jx.enterPressed = false;
			auto line = jx.textStr;
			string sline = line.to!string;
		
			string root;
			string[] elms;

			//If not a command, treat as a Bible reference
			//#verses only work once!
			if (! (jx.textStr.length > 1
					&&
					jx.textStr.startsWith('-'))
					&&
					jx.button == "") {
				if (sline.length) {
					string stg = sline.split[0] ~ ' ';
					if (stg.length && isDigit(stg[0])) //#What ever is this!!!
						stg = "";
					foreach(element; sline.split) {
						if (isDigit(element[0]) || element.startsWith('-')) //#what's with isDigit?
							stg ~= element ~ ' ';
					}
						
					debug(4) mixin(trace("stg"));
					if (doReferance(ups, stg) != 0) {
						writeln("Some thing wrong.");
					} else {
						info.bibleRef = sline;
						info.bookNum = g_bible.bookNumberFromTitle(stg.split[0]).to!string;
						info.numOfVerses = g_bible.numberOfVerses.to!string;
					}
				}
			} else {
				// command list (not a Bible reference)
				int a;
				elms = line.to!string.split;
				root = elms[0].findSplit("-")[2];
				debug mixin(trace("elms", "root"));
				
				switch(root) {
					default: break;
					case "q", "quit", "exit":
						//g_window.close;
						done = true;
					break;
					case "h", "h1", "help":
						{
						foreach(aline; File("help1.txt").byLine)
							addToHistory(aline.to!string);
						}
					break;
					case "h2", "help2":
						{
						foreach(aline; File("help2.txt").byLine)
							addToHistory(aline.to!string);
						}
					break;
					case "cld":
						jx.clearHistory;
					break;
					case "sets":
						showSettingsFileNames;
					break;
					case "set":
						try
							selectSet(elms);
						catch(Exception e) {
							addToHistory("Some error choosing settings");
							break;
						}
						fsetup.process;
						loadUp;
					break;
					case "saveSet":
						try {
							g_global.settings.setIniFileName(buildPath("settingfiles", elms[1]).setExtension(".ini"));
							import std.stdio: File, write;

							File("settingsSelect.ini", "w").write(elms[1]);
							g_global.settings.save();
						} catch(Exception e) {
							addToHistory("Error with saving");
						}
						//saveSet(elms);
					break;
					case "removeSet":
						//#work point
						try {
							removeSettingFileName(getNumSafe(elms[1]));
						} catch(Exception e) {
							addToHistory("Failed!");
						}
					break;
					case "backBoard", "b":
						if (backBoard._power == true) {
							backBoard._power = false; // normal background
//							with(g_global)
//								if (doColour(inputColour, [backGroundColour.r, backGroundColour.g, backGroundColour.b]) == success) {
//										jx.setColour(oppositeColour);
//								}
						}
						else {
							backBoard._power = true; // black background
							if (doColour(g_global.inputColour, "inputColour 100 100 100".split) == success)
								jx.setColour(g_global.inputColour);
						}
						addToHistory(text("backBoard power is ", (backBoard._power == true) ? "on" : "off"));

					break;
					case "fonts":
						listFonts;
					break;
					case "font":
						try { selectFont(elms); } catch(Exception e) { jx.addToHistory("Font failure"); }
					break;
					case "fontSize":
						setFontSize(elms);
					break;
					case "pictureLot":
						g_global.mediaCor.selectMediaLot(jx, elms, true);
					break;
					case "pictureLots":
						g_global.mediaCor.listMediaLots(jx);
						break;
					case "textUpStepSize":
						upStep(elms, g_global.textUpStepSize, jx);
					break;
					case "pictureUpStepSize":
						upStep(elms, g_global.pictureUpStep, jx);
						break;
					case "show":
						g_global.mediaCor.show();
					break;
					case "backPictures":
						listBackPictures;
					break;
					case "backPicture":
						selectBackPicture(elms);
					break;
					case "picture":
						g_global.mediaCor.selectMedia(elms);
					break;
					case "pictures":
						g_global.mediaCor.listMediaFiles(jx);
					break;
					case "wrapSize":
						setWrapSize(elms);
					break;
					case "messages":
						listMessages;
					break;
					//#need more work
					case "message":
						setMessage(elms, ups);
					break;
					case "m", "misc":
						jx.addToHistory("See other terminal"d);
						jview(g_global.mediaCor);
					break;
					case "add":
						addNotesLine(elms);
					break;
					case "adds":
						showTheAddnotes;
					break;
					case "addsList":
						addslist;
					break;
					case "subtract":
						if (elms.length == 1) {
							addToHistory("No operant!");
							break;
						}
						try {
							a = elms[1].to!int;
						} catch(Exception e) {
							addToHistory(text("Invalid input (", elms[1], ")"));
							break;
						}
						with(g_global)
							if (a >= 0 && a < addsLines.length) {
								auto old = addsLines[a];
								addsLines = addsLines[0 .. a] ~ addsLines[a + 1 .. $];
								addToHistory(text("removed: ", old));
								g_global.saveAddsLines;
							} else {
								addToHistory("Out of bounds.");
							}
					break;
					case "colour2":
						if (elms.length == 1 + 3) {
							try {
								g_global.verseTxtColour = SDL_Color(elms[1].to!ubyte,
														elms[2].to!ubyte,
														elms[3].to!ubyte, 255);
							} catch(Exception e) {
								addToHistory("Invalid.");
							}
						} else {
							addToHistory("Wrong number of operants.");
						}
					break;
					case "colour":
						doColour(g_global.verseTxtColour, elms);
					break;
					case "backColour":
						backColour(elms);
					break;
					case "inputColour":
						if (doColour(g_global.inputColour, elms) == success)
							jx.setColour(g_global.inputColour);
					break;
					case "fps":
						if (elms.length == 1) {
							addToHistory("Not right!");
							break;
						}
						try {
							g_global.fps = elms[1].to!int;
						} catch(Exception e) {
							addToHistory(text("Invalid input (", elms[1], ")"));
							break;
						}
						//g_window.setFramerateLimit(g_global.fps); //#need equivalent (in two places)
						addToHistory("*Frames per second: " ~ g_global.fps.to!string);
						info.fps = g_global.fps.to!string;
					break;
					case "info":
						with(info)
							foreach(aline; ["",
											"Info:",
											bibleRef ~ " - Bible reference",
											bookNum ~ " - book number",
											picName ~ " - picture",
											numOfVerses ~ " - number of verses",
											fps ~ " - frames per second",
											fontName ~ " - font name",
											fontSize ~ " - font size",
											colour ~ " - verse text colour",
											backColour ~ " - background colour",
											inputColour ~ " - input colour",
											pictureLot ~ " - picture lot",
											wrapSize ~ " - wrap size",
											settingFile ~ " - setting file name",
											textUpStepSize ~ " - text up step size",
											pictureUpStepSize ~ " - picture up step size"
											])
								jx.addToHistory(aline.to!dstring);
					break;
					case "cls", "clear":
						jx.clearHistory;
						ups.length = 0;
						g_global.mediaCor.hideAll;
						//g_global.backPicture._fileName = "";
						//g_global.backPicture._spr = null;
					break;
					case "reference":
						auto add = elms[1 .. $].join(" ");
						append(buildPath("references", "random.txt"), add ~ "\n");
						jx.addToHistory(add.to!dstring ~ " - added"d);
					break;
					case "references":
						version(none) {
							auto verses = readText("gleaned.txt").split("\n");
							jx.addToHistory("");
							jx.addToHistory("References:");
							int x = 0, y = 0;
							foreach(i, verse; verses) {

							}
						}

						version(all) {
							auto verses = readText(buildPath("references", "random.txt")).split("\n");
							jx.addToHistory("");
							jx.addToHistory("References:");
							string aline;
							foreach(refe; verses) {
								aline ~= format("%-40s", refe);
								a++;
								if (a == 7) {
									addToHistory(aline);
									a = 0;
									aline.length = 0;
								}
							}
							if (a != 0)
								addToHistory(aline);
						}
					break;
					case "stop": moving = false; break;
					case "go": moving = true; break;
				} // switch
			} //else
			jx.textStr = "";
			jx.button("");
			//while(Mouse.isButtonPressed(Mouse.Button.Left)) {} //#mouse button
		}

		with(g_global)
			SDL_SetRenderDrawColor(gRenderer, backGroundColour.r, 
				backGroundColour.g, backGroundColour.b, 0xFF);
		SDL_RenderClear(gRenderer);

		g_global.backPicture.draw;
		g_global.mediaCor.draw;

		foreach(up; ups)
			if (up.txt.mRect.y < g_global.windowHeight)
				up.draw;

		if (backBoard._power == true) {
			//g_window.draw(backBoard._backBoard);
				backBoard._backBoard.draw;
		}
		g_inputJex.draw;

		SDL_RenderPresent(gRenderer);

        if (g_global.delay > timer.peek.total!"msecs")
            SDL_Delay(cast(uint)(g_global.delay - timer.peek.total!"msecs"));
		timer.reset;
		timer.start;
    }
	
	return 0;
}

void upStep(string[] elms, ref float stepTarget, InputJex jx) {
	if (elms.length == 2) {
		float step;
		try {
			step = elms[1].to!float;
			debug(4) {
				mixin(trace("selection"));
				mixin(trace("g_global.backPicture"));
			}
		} catch(Exception e) {
			addToHistory("Invalid picture up step size value!");
			return;
		}
		stepTarget = step;
		addToHistory(text("Picture up step size set to: ", step));
	}
}

void listFonts() {
	foreach(line; ["",
				   "Fonts:"])
		jx.addToHistory(line.to!dstring);
	import std.algorithm: find, until;
	import std.path: dirSeparator;

	foreach(i, aline; g_global.fontList.enumerate) {
		jx.addToHistory(text(i, ") ", aline.find(dirSeparator)[1 .. $].until(".")).to!dstring);
	}
}

void selectFont(string[] elms) {
	ubyte selectNum;
	import std.stdio;
	
	try {
		if (elms.length == 2)
			selectNum = elms[1].to!ubyte;
	} catch(Exception e) {
		jx.addToHistory("Invalid data"d);
		throw new Exception("Invalid data");
	}
	if (selectNum < g_global.fontList.length) {
		g_global.currentFontFileName = g_global.fontList[selectNum];
		addToHistory(format("%s font selected", g_global.currentFontFileName));
	} else {
		addToHistory("Invalid data");
	}
}

void setFontSize(string[] elms) {
	if (elms.length != 2) {
		writeln("Wrong amout of arguments.");
	} else {
		try {
			g_global.fontSize = elms[1].to!int;
		} catch(Exception e) {
			addToHistory(text("Invalid input ", "(", elms[1], ")"));
			return;
		}
		addToHistory(text("Font size: ", g_global.fontSize));
		info.fontSize = g_global.fontSize.to!string;
		
	}
}

auto getNumSafe(string str) {
	ubyte selectNum;
	
	try {
		selectNum = str.to!ubyte;
	} catch(Exception e) {
		jx.addToHistory("Invalid data"d);

		return 0.to!ubyte;
	}

	return selectNum;
}

void selectSet(string[] elms) {
/+
	ubyte selectNum;
	
	try {
		if (elms.length == 2)
			selectNum = elms[1].to!ubyte;
	} catch(Exception e) {
		jx.addToHistory("Invalid data"d);
		return;
	}
	+/
	void error() {
		addToHistory("Invalid data");
	}

	if (elms.length != 2) {
		error;

		return;
	}
	ubyte selectNum = getNumSafe(elms[1]);
	if (selectNum < g_global.settingFileNames.length) {
		import std.path: buildPath;

		File("settingsSelect.ini", "w").write(g_global.settingFileNames[selectNum]);
		addToHistory(format("%s - settings file selected", g_global.settingFileNames[selectNum]));
	} else {
		error;

		return;
	}
}

void listBackPictures() {
	foreach(line; ["",
			"Back ground pictures list:"])
		addToHistory(line);
	foreach(i, back; g_global.backPictures.save.enumerate)
		addToHistory(text(i, ") ", back._fileName));
}

void wrongNumberOfOperants() {
	addToHistory("Wrong number of operants.");
}

void invalidEntry() {
	addToHistory("Invalid entry!");	
}

void gap() {
	addToHistory("");
}

void selectBackPicture(string[] elms) {
	if (elms.length == 2) {
		try {
			auto selection = elms[1].to!int;
			debug(4) {
				mixin(trace("selection"));
				mixin(trace("g_global.backPicture"));
			}
			g_global.backPicture = g_global.backPictures.select(selection);
		} catch(Exception e) {
			jx.addToHistory("Invalid back ground picture value!");
		}
		gap;
	} else {
		wrongNumberOfOperants;
	}
}

void setWrapSize(string[] elms) {
	if (elms.length != 2) {
		wrongNumberOfOperants;
	} else {
		try {
			g_global.chunkSize = elms[1].to!ubyte;
		} catch(Exception e) {
			invalidEntry;
		}
	}
}

void addToHistory(T...)(T args) {// (in string message) {
	import std.typecons: tuple;

	//jx.addToHistory(message.to!dstring);
	jx.addToHistory(tuple(args).expand);
}

void listMessages() {
	if (g_global.messages.length == 0) {
		addToHistory("There is no message files!");
		return;
	}
	gap;
	jx.addToHistory("Messages list:"d);
	import std.algorithm : until;
	foreach(i, message; g_global.messages)
		addToHistory(text(i, ") ", message._fileName.split(dirSeparator)[1].until(".")));
}

void setMessage(string[] elms, ref Up[] ups) {
	if (elms.length == 2) {
		int messageNum;
		try {
			messageNum = elms[1].parse!ubyte;
		} catch(Exception e) {
			invalidEntry;
			return;
		}
		if (messageNum >= g_global.messages.length)
			addToHistory("Out of range!");
		else {
			//doReferance(ups, "", g_global.messages[messageNum]._text);
			doMessage(ups, g_global.messages[messageNum]._fileName);
			addToHistory(text("Text file: ", g_global.messages[messageNum]._fileName));
		}
 	} else {
		wrongNumberOfOperants;
	}
}

void addNotesLine(string[] elms) {
	if (elms.length == 1) {
		elms ~= ""; // for a gap
	}

	auto addNotes = elms[1 .. $].join(" ");
	g_global.addsLines ~= addNotes;
	g_global.saveAddsLines;
}

void showTheAddnotes() {
	gap;
	addToHistory("Notes list:");
	foreach(dline; g_global.addsLines)
		addToHistory(dline);
}

void addslist() {
	gap;
	addToHistory("Notes list:");
	foreach(i, dline; g_global.addsLines)
		addToHistory(text(i, ") ", dline));
}

void showSettingsFileNames() {
	gap;
	addToHistory("Settings file names list:");
	foreach(i, fileName; g_global.settingFileNames)
		addToHistory(text(i, ") ", fileName));
}

//#donkey plops!
void removeSettingFileName(in int nameToRemoveIndex) {
	import std.algorithm : remove;
	import std.file : rhdd = remove;
	import std.path : buildPath;

	string fileName;
	try {
		with(g_global) {
			string toRemove = settingFileNames[nameToRemoveIndex];
			fileName = buildPath("settingfiles", toRemove ~ ".ini");
			rhdd(fileName);
			settingFileNames = settingFileNames.remove!(f => f == toRemove);
			addToHistory(toRemove, " has been removed from disk.");
		}
	} catch(FileException e) {
		addToHistory("File exception: ", fileName);
		throw new FileException(text("File exception: ", fileName));
	}
}

//#not working
auto doColour(ref SDL_Color colour, ubyte[3] rgb) {

	return doColour(colour, format("dummy %s %s %s", rgb[0], rgb[1], rgb[2]).split);
	//return doColour(colour, format("dummy %s %s %s", rgb[0], rgb[1], rgb[2]).split);
}

/++
 + @para - ref Colour (
 + @para - elements
 + 
 + @return - if no exeption thrown
 +/
auto doColour(ref SDL_Color colour, string[] elms) {
	if (elms.length == 1 + 3) {
		
		void check(float num) {
			if (num < 0
				||
				num > 100)
				throw new Exception("Out of bounds");
		}
		
		try {
			foreach(str; elms[1 .. 4])
				check(str.to!float);
			
			bool invert = false;
			auto getConvert(in string data) {
				if (invert)
					return cast(ubyte)(256/100f * (100 - data.to!float));
				else
					return cast(ubyte)(256/100f * data.to!float);
			}
			
			colour = SDL_Color(
				getConvert(elms[1]),
				getConvert(elms[2]),
				getConvert(elms[3]), 255);
			
			// check to see if the colour is too gray (invisible effect)
			auto grayAreaCheck(int i) {
				return getConvert(elms[i]) > 128 - 20 && getConvert(elms[i]) < 128 + 20;
			}
			
			if (grayAreaCheck(1)
				&&
				grayAreaCheck(2)
				&&
				grayAreaCheck(3)) {
				oppositeColour = SDL_Color(255, 255, 255, 255); //.White;
				
			} else {
				invert = true;
				oppositeColour = SDL_Color(
					getConvert(elms[1]),
					getConvert(elms[2]),
					getConvert(elms[3]), 255
				);
			}
		} catch(Exception e) {
			writeln(e.to!string);
			import std.algorithm : findSplit, until;
			addToHistory(text(e.to!string.findSplit(": ")[2].until('\n'),
				" - Invalid colour channel or more."));

			return failure;
		}
	}
	return success;
}

void backColour(string[] elms) {
	if (doColour(g_global.backGroundColour, elms) == success) {
		g_global.inputColour = oppositeColour;
		g_inputJex.setColour(g_global.inputColour);
	}
}
