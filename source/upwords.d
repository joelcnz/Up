//#work here, add verse ref at end too
//#out line
//#What's this?
//#I don't know

debug = 4;

import std.stdio;
import std.algorithm;
import base;

/**
	Main class - verse range, or other text going up the screen
*/
class Up {
private:
	JText mTxt;
	int _fontHeight;
	bool _flaggedForDeletion;
public:
	@property {
		/// main text getter
		auto txt() { return mTxt; }
		/// main text setter
		void txt(JText txt0) { mTxt.close; mTxt = txt0; }
		
		/// font height
		auto fontHeight() { return _fontHeight; }
		
		/// Set to be removed
		auto flaggedForDeletion() { return _flaggedForDeletion; }
	}
	
	/// Main constructor
	this(string txt, Point pos) {
		//const fontSize = 25;
		//assert(jtextMakeFont(g_global.currentFontFileName, fontSize), "error making font");
		//mixin(trace("pos.Xi", "pos.Yi"));
		mTxt = JText(txt, SDL_Rect(/* dummy */ 0,pos.Yi, 1,1), SDL_Color(0,0,0,0),
			g_global.fontSize, g_global.currentFontFileName);

//		_font.loadFromFile(g_global.currentFontFileName);
		//_fontHeight = g_global.fontSize;
		_fontHeight = mTxt.mSize.Yi;
		
		//import std.conv : to;
		//_fontHeight = g_fontHeight;
		//_txt = new Text(txt.to!dstring, _font, fontHeight);
		//_txt = new Text(txt.to!dstring, _font, _fontHeight);
		//_txt.position = Vector2f((g_global.windowWidth - _txt.getGlobalBounds().width) / 2, pos.y);
		//_txt.setColor = Color(255,200,64);
		//_txt.setColor = g_global.verseTxtColour; //Color(255,180,0);
		mTxt.pos = Point((g_global.windowWidth - mTxt.mRect.w) / 2, pos.Y);
		mTxt.colour = g_global.verseTxtColour;
	}
	
	/// Set colour
	void setColour(SDL_Color color) {
		g_global.verseTxtColour = color;
	}
	
	/// Load font
	void loadFont(in string fileName) {
//this(string message, SDL_Rect r, SDL_Color col = SDL_Color(255,180,0,0xFF), int fontSize = 15,
//        string fileName = "DejaVuSans.ttf") {
		mTxt = JText("", SDL_Rect(0,0,0,0), SDL_Color(0,0,0,0), 15, fileName);
		//if (! font.loadFromFile(fileName)) {
		//	import std.conv : text;
		//	throw new Exception(text("Font fail - ", fileName));
		//}
	}
	
	/// Process (change position of Up object text)
	void process() {
		with(mTxt) {
			//mRect = SDL_Rect(mRect.x, cast(int)(mRect.y - g_global.textUpStepSize), mRect.w, mRect.h);
			//pos = Point(mPos.X, mPos.Y - g_global.textUpStepSize);
			//writeln(pos.X, " ", pos.Y);
			//if (mRect.y + mRect.h + _font.getLineSpacing(_fontHeight) < 0) {
			mPos.Y -= g_global.textUpStepSize;
			if (mRect.y + mRect.h + 20 < 0) {
				_flaggedForDeletion = true;
			}
		}
	}
	
	/// Draw stuff
	void draw() {
		//#out line
		{
			immutable orgColour = mTxt.colour;
			immutable orgPos = mTxt.pos;
			mTxt.colour = SDL_Color(0,0,0, 0xFF);
			scope(exit)
				mTxt.colour = orgColour,
				mTxt.pos = orgPos;
			float posx = mTxt.mRect.x - 1,
				posy = mTxt.mRect.y - 1;
			foreach(y; 0 .. 3)
				foreach(x; 0 .. 3) {
					if (! (x == 1 && y == 1)) {
						mTxt.pos = Point(posx + x, posy + y);
						mTxt.draw(gRenderer);
					}
				}
		}

		mTxt.draw(gRenderer);
	}
}

//#What's this?
/// Make up message
void doMessage(ref Up[] ups, in string fileName) {
//	import std.string;
	import std.conv : to;

/+
	string[] txts;
	foreach(line; File(fileName).byLine) {
		txts ~= wrap(line, g_global.chunkSize, null, null, 4).to!string;
	}
+/
	import std.range : enumerate;

	foreach(y, line; File(fileName).byLine.enumerate) {
//	foreach(y, line; txts) {
		//auto chunk = wrap(line, g_global.chunkSize, null, null, 4).to!string;
		//mixin(trace("chunk"));
		ups ~= new Up(line.to!string,
					  Point(/* dummy */ 0, g_global.windowHeight + y * g_global.fontSize));
	}

}

///
auto doReferance(ref Up[] ups, in string reference, in string text = "") {
	import std.stdio : writef;
	import std.string : split, indexOf, wrap;

	string str;
	if (text == "") {
		with(g_bible) {
			//#work here, add verse ref at end too
			str = argReference( reference.split ) ~ " - "; // ~ "\n" ~ getRef(reference.split); //argReferenceToArgs(reference) );
			import std.algorithm : canFind;
			if (str.canFind("->"))
				str ~= str[0 .. str.indexOf("->")];
			else
				str = ""; // get rid of the dash
		}
	} else {
		str = text;
	}

	if (! str.length) {
		writeln("No text!");

		return -1;
	}
	auto lines = str.split("\n");
	string[] txts;
	
	//foreach(const txt; lines[0 .. text == "" ? $ - 1 : $]) { //#I don't know
	foreach(const txt; lines) {
		txts ~= wrap(txt, g_global.chunkSize, null, null, 4).split("\n");
	}
	import std.conv : to;

	int start;
	if (ups.length && ups[$ - 1].mTxt.mRect.y > g_global.windowHeight)
		// put at the bottom of the last line
		start = cast(int)(ups[$ - 1].mTxt.mRect.y + g_global.fontSize * 2);
	else
		// plop below the screen
		start = g_global.windowHeight;

	// Add each line to ups
	float ypos = start;
	foreach(i, txt; txts) {
		ups ~= new Up(txt, Point(/* dummy: */ 0, ypos)); //start + i * g_global.fontSize));
		if (txt != "") {
			//ypos += g_global.fontSize;
			//int w, h;
			//assert(TTF_SizeText(ups[$ - 1].mFont, txt.toStringz, &w, &h) == 0);
			//mixin(trace("h"));
			ypos += ups[$ - 1].fontHeight;
		}
	}

	ups = ups.remove!(up => up.flaggedForDeletion);

	return 0;
}
