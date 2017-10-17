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

import jec;
import base;

enum success = 0, failure = -1;
Color oppositeColour;

struct BackBoard {
	bool _power;
	RectangleShape _backBoard;
}

immutable noPower = false;

BackBoard backBoard = {noPower}; //{/* _power */ false};

int main(string[] args) {
	g_checkPoints = false;
	gh(0); // check point
	Setup setup;
	setup.process;
	scope(success) {
		g_global.settings.save();
	}

	jec.setup;
	g_mode = Mode.edit;
	g_terminal = true;

	BibleVersion = "English Standard Version";
	loadXMLFile();
	parseXMLDocument();
	gh(2);

	writeln("\nList of possible video modes:");
	foreach(vid; VideoMode.getFullscreenModes)
		writeln(vid);
	writeln();

	version(none)
		g_window = new RenderWindow(VideoMode.getFullscreenModes[0],
								    "Welcome to Up! Press [System] + [Q] to quit"d);

    //g_window = new RenderWindow(VideoMode(1280, 800),
	g_window = new RenderWindow(VideoMode.getDesktopMode,
							    "Welcome to Up! Press [System] + [Q] to quit"d);
		
	g_window.setFramerateLimit(g_global.fps);

	g_global.windowWidth = g_window.getSize().x; // get screen width
	g_global.windowHeight = g_window.getSize().y; // get screen height

	backBoard._backBoard = new RectangleShape;
	with(backBoard._backBoard) {
		//position = Vector2f(0, 0); //#redundant, I think
		with(g_global)
			size = Vector2f(windowWidth, windowHeight);
		fillColor = Color(0,0,0, 255);
	}
	
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
	g_inputJex.setColour(g_global.inputColour);

	g_global.backPicture.load(g_global.backPicture._fileName);

	Up[] ups;
	bool moving = true;

	g_global.mediaCor = new MediaCor;

	void loadBackPictures() {
		g_global.backPictures = new BackPictureMan;
		string[] backPicList;
		writeln("Background Pictures:");
		foreach(string name; dirEntries("backPictures", "*.{png,jpg}", SpanMode.shallow)) {
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
		foreach(string name; dirEntries("fonts", "*.{ttf}", SpanMode.shallow)) {
			g_global.fontList ~= name;
			writeln(name);
		}
		writeln;
	}

	void loadMessages() {
		g_global.messages.length = 0;
		writeln("Messages:");
		int i;
		foreach(string name; dirEntries("messages", "*.{txt}", SpanMode.shallow)) {
			g_global.messages ~= Message(name, readText(name));
			writeln(name);
			i += 1;
		}
		writeln;
	}

	void loadLittleNotes() {
		//#here - add notes
		writeln("Addsnotes:");
		foreach(line; File("addsnotes.txt").byLine) {
			g_global.addsLines ~= line.to!string;
			writeln(line);
		}
		writeln;
	}

	g_global.mediaCor.listMediaLots(g_inputJex, false);
	g_global.mediaCor.loadMediaLot();
	loadBackPictures;
	loadFontNames;
	loadMessages;
	loadLittleNotes;

	while (g_window.isOpen())
    {
        Event event;

        while(g_window.pollEvent(event))
        {
            if(event.type == event.EventType.Closed)
            {
                g_window.close();
            }
        }

		if ((Keyboard.isKeyPressed(Keyboard.Key.LSystem) || Keyboard.isKeyPressed(Keyboard.Key.RSystem)) &&
			Keyboard.isKeyPressed(Keyboard.Key.Q)) {
			g_window.close;
		}
		
		if (moving) {
			g_global.mediaCor.process;

			foreach(up; ups)
				up.process;

			ups = remove!"a.flaggedForDeletion"(ups);
			
			debug(5) if (ups.length > 0) mixin(traceList("ups[0].txt.getLocalBounds.height g_global.fontSize".split));
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
						g_window.close;
					break;
					case "h", "help":
						foreach(aline; ["",
										"Help:",
										"-h/-help",
										"-h2/help2",
										"-q/-quit/-exit - exit program",
										"<ref> - bring up verse(s)",
										"-cls - clear screen",
										"-stop",
										"-go",
										"-pictures - list pictures",
										"-picture <picture name>",
										"-backPictures",
										"-backPicture #",
										"-reference - add a Bible reference",
										"-references - view verse refs list",
										"-info - information",
										"-fonts - list fonts",
										"-font <font name>",
										"-fontSize #",
										"-wrapSize #",
										"-pictureUpStepSize #",
										"-textUpStepSize #",
										"-fps <frames per second>",
										"-colour <red> <green> <blue> (0 - 100 each)",
										"-colour2 <red> <green> <blue> (0 - 255 each)",
										"-backColour <red> <green> <blue> (0 - 100 each)",
										"-inputColour <red> <green> <blue> (0 - 100 each)",
										"-adds - list of notes",
										"-add <line of text>",
										"-addsList - list notes (for subtract)",
										"-subtract # - remove from add list (to do)",
										"-messages - list messages",
										"-message # - load a message (not working!)",
										"-messageUp - show message",
										"-m/-misc - testing stuff",
										"-show - slide show",
										"-pictureLots - list picture folders",
										"-pictureLot #"])
							addToHistory(aline);
					break;
					case "h2", "help2":
						foreach(aline; ["",
										"Help 2:",
									   	"-h/-help",
										"-h2/-help2",
										"-backBoard/-b - toggle on and off",
										"l, - mouse click for history",
										"*sets - list setting files",
										"*set # - load setting file",
										"*saveSet <file name>",
									 	"* - not in yet"])
							addToHistory(aline);
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
						selectFont(elms);
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
								g_global.verseTxtColour = Color(elms[1].to!ubyte,
														elms[2].to!ubyte,
														elms[3].to!ubyte);
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
						g_window.setFramerateLimit(g_global.fps);
						addToHistory("Frames per second: " ~ g_global.fps.to!string);
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
											fps ~ " - frames per second"
											])
								jx.addToHistory(aline.to!dstring);
					break;
					case "cls":
						jx.clearHistory;
						ups.length = 0;
						g_global.mediaCor.hideAll;
						//g_global.backPicture._fileName = "";
						//g_global.backPicture._spr = null;
					break;
					case "reference":
						auto add = elms[1 .. $].join(" ");
						append("gleaned.txt", add ~ "\n");
						jx.addToHistory(add.to!dstring ~ " - added"d);
					break;
					case "references":
						auto verses = readText("gleaned.txt").split("\n");
						jx.addToHistory("");
						jx.addToHistory("References:");
						int x, y;

						version(none) {
							auto verses = readText("gleaned.txt").split("\n");
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
			while(Mouse.isButtonPressed(Mouse.Button.Left)) {}
		}

		g_window.clear(g_global.backGroundColour);

		g_global.backPicture.draw;

		g_global.mediaCor.draw;

		foreach(up; ups)
			if (up.txt.position.y < g_global.windowHeight)
				up.draw;

		if (backBoard._power == true) {
			g_window.draw(backBoard._backBoard);
		}
		g_inputJex.draw;

        g_window.display;
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

void addToHistory(in string message) {
	jx.addToHistory(message.to!dstring);
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

//#not working
auto doColour(ref Color colour, ubyte[3] rgb) {

	return doColour(colour, format("dummy %s %s %s", rgb[0], rgb[1], rgb[2]).split);
	//return doColour(colour, format("dummy %s %s %s", rgb[0], rgb[1], rgb[2]).split);
}

/++
 + @para - ref Colour (
 + @para - elements
 + 
 + @return - if no exeption thrown
 +/
auto doColour(ref Color colour, string[] elms) {
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
			
			colour = Color(
				getConvert(elms[1]),
				getConvert(elms[2]),
				getConvert(elms[3]));
			
			// check to see if the colour is too gray (invisible effect)
			auto grayAreaCheck(int i) {
				return getConvert(elms[i]) > 128 - 20 && getConvert(elms[i]) < 128 + 20;
			}
			
			if (grayAreaCheck(1)
				&&
				grayAreaCheck(2)
				&&
				grayAreaCheck(3)) {
				oppositeColour = Color.White;
				
			} else {
				invert = true;
				oppositeColour = Color(
					getConvert(elms[1]),
					getConvert(elms[2]),
					getConvert(elms[3])
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
