import base;

class BackPictureMan {
	BackPicture[] _backPics;
	size_t _selection;

	void add(string name) {
		_backPics ~= BackPicture();
		_backPics[$ - 1]._fileName = name;
		_backPics[$ - 1].load(name);
	}

	auto getNameByIndex(size_t index) {
		if (index >= _backPics.length)
			throw new Exception("Invalid value");
		return _backPics[index]._fileName;
	}

	BackPicture select(size_t index) {
		if (index >= _backPics.length)
			throw new Exception("Invalid value");

		_selection = index;
		g_global.backPicture._fileName = getNameByIndex(index);

		return _backPics[_selection];
	}

	void draw() {
		_backPics[_selection].draw;
	}

/+	
	// a forward range
	@property bool empty() { return _backPics.length == 0; }
	@property ref auto front() { return _backPics[0]; }
	void popFront() { _backPics = _backPics[1 .. $]; }
	auto save() { return _backPics; }
	+/
}
