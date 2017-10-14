//#not work!
import base;

class Picture {
private:
	string _name;
	Sprite _spr;
	Pict _picCase;
	bool _hide;
public:
	@property {
		string name() { return _name; }
		void name(in string name0) { _name = name0; }

		Sprite spr() { return _spr; }

		Pict picCase() { return _picCase; }
		void picCase(in Pict picCase0) { _picCase = picCase0; }

		bool hide() { return _hide; }
		void hide(in bool hide0) { _hide = hide0; }
	}

	this(in string name, in Texture texture) {
		_hide = false;
		_picCase = Pict.stopped;
		_name = name;
		
		// Setup picture let sprite object using texture object
		_spr = new Sprite(texture);
		_spr.position = Vector2f((g_global.windowWidth - _spr.getGlobalBounds().width) / 2, -_spr.getGlobalBounds().height); // up out of sight
	}
	
	void process() {
		if (_picCase == Pict.up) {
			_spr.position = Vector2f(_spr.position.x, _spr.position.y - g_global.pictureUpStep);
			//_spr.position = Vector2f(_spr.position.x + g_global.pictureUpStep, _spr.position.y); //#not work! 2/2
		}
	}

	bool outOfBounds() {
		return (_spr.position.y > g_global.windowHeight || _spr.position.y + _spr.getGlobalBounds().height < 0);
	}

	void draw() {
		if (! outOfBounds && ! _hide) {
			//import std.range;

			//foreach(x; iota(0, g_global.windowWidth, _spr.getGlobalBounds().width))
			//	_spr.position = Vector2f(x, _spr.position.y),
				g_window.draw(_spr);
		}
	}
	
	override string toString() {
		import std.stdio;

		return _name;
	}
}
