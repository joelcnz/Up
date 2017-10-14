import base;

class BackPictureMan {
	BackPicture[] _backPics;
	size_t _selection;

	void add(string name) {
		_backPics ~= BackPicture();
		_backPics[$ - 1].load(name);
	}

	BackPicture select(size_t index) {
		if (index > _backPics.length)
			throw new Exception("Invalid value");

		_selection = index;

		return _backPics[_selection];
	}

	void draw() {
		g_window.draw(_backPics[_selection]._spr);
	}
	
	// a forward range
	@property bool empty() { return _backPics.length == 0; }
	@property ref auto front() { return _backPics[0]; }
	void popFront() { _backPics = _backPics[1 .. $]; }
	auto save() { return _backPics; }
}
