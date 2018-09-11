//#work here, add verse ref at end too
//#out line
//#What's this?
//#I don't know

debug = 4;

import std.stdio;
import std.algorithm;
import base;

class Up {
private:
	Text _txt;
	int _fontHeight;
	Font _font;
	bool _flaggedForDeletion;
public:
	@property {
		auto txt() { return _txt; }
		void txt(Text txt0) { _txt = txt0; }
		
		auto fontHeight() { return _fontHeight; }
		
		auto flaggedForDeletion() { return _flaggedForDeletion; }
	}
	
	this(string txt, Vector2f pos) {
		_font = new Font;
		_font.loadFromFile(g_global.currentFontFileName);
		
		_fontHeight = g_global.fontSize;
		
		import std.conv;
		//_fontHeight = g_fontHeight;
		//_txt = new Text(txt.to!dstring, _font, fontHeight);
		_txt = new Text(txt.to!dstring, _font, _fontHeight);
		_txt.position = Vector2f((g_global.windowWidth - _txt.getGlobalBounds().width) / 2, pos.y);
		//_txt.setColor = Color(255,200,64);
		_txt.setColor = g_global.verseTxtColour; //Color(255,180,0);
	}
	
	void setColour(Color color) {
		g_global.verseTxtColour = color;
	}
	
	void loadFont(in string fileName) {
		if (! _font.loadFromFile(fileName)) {
			import std.conv : text;
			throw new Exception(text("Font fail - ", fileName));
		}
	}
	
	void process() {
		with(_txt) {
			position = Vector2f(position.x, position.y - g_global.textUpStepSize);
			if (_txt.position.y + txt.getLocalBounds.height + _font.getLineSpacing(_fontHeight) < 0) {
				_flaggedForDeletion = true;
			}
		}
	}
	
	void draw() {
		//#out line
		{
			auto orgColour = _txt.getColor;
			auto orgPos = _txt.position;
			_txt.setColor = Color(0,0,0);
			scope(exit)
				_txt.setColor = orgColour,
				_txt.position = orgPos;
			float posx = _txt.position.x - 1,
				posy = _txt.position.y - 1;
			foreach(y; 0 .. 3)
				foreach(x; 0 .. 3) {
					_txt.position = Vector2f(posx + x, posy + y);
					g_window.draw(_txt);
				}
		}

		g_window.draw(_txt);
	}
}

//#What's this?
void doMessage(ref Up[] ups, in string fileName) {
//	import std.string;
	import std.conv;

/+
	string[] txts;
	foreach(line; File(fileName).byLine) {
		txts ~= wrap(line, g_global.chunkSize, null, null, 4).to!string;
	}
+/
	import std.range;

	foreach(y, line; File(fileName).byLine.enumerate) {
//	foreach(y, line; txts) {
		//auto chunk = wrap(line, g_global.chunkSize, null, null, 4).to!string;
		//mixin(trace("chunk"));
		ups ~= new Up(line.to!string,
					  Vector2f(/* dummy */ 0, g_global.windowHeight + y * g_global.fontSize));
	}

}

auto doReferance(ref Up[] ups, in string reference, in string text = "") {
	import std.stdio : writef;
	import std.string;

	string str;
	if (text == "") {
		with(g_bible) {
			//#work here, add verse ref at end too
			str = argReference( reference.split ); // ~ "\n" ~ getRef(reference.split); //argReferenceToArgs(reference) );
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
	import std.conv;

	int start;
	if (ups.length
		&&
		ups[$ - 1].txt.position.y > g_global.windowHeight)
		// put at the bottom of the last line
		start = cast(int)(ups[$ - 1].txt.position.y + g_global.fontSize * 2);
	else
		// plop below the screen
		start = g_global.windowHeight;

	// Add each line to ups
	float ypos = start;
	foreach(i, txt; txts) {
		ups ~= new Up(txt, Vector2f(/* dummy: */ 0, ypos)); //start + i * g_global.fontSize));
		if (txt != "")
			ypos += g_global.fontSize;
	}

	ups = ups.remove!(up => up.flaggedForDeletion);

	return 0;
}
