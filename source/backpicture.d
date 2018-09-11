//#Not used I don't think
import base;

struct BackPicture {
	string _fileName;
	Vector2f _pos;
	Sprite _spr;

	//#Not used I don't think
	void clearPic() {
		_spr = null;
	}

	void load(string fileName0) {
		if (fileName0 == "") {
			_spr = null;
			return;
		}

		import std.path : buildPath;

		// load a image file for object
		string fileNameTmp = buildPath("backPictures", fileName0);
		auto texture = new Texture;
		if (! texture.loadFromFile(fileNameTmp)) { // load off program root folder
			throw new Exception(fileNameTmp ~ " not load");
		}
		_fileName = fileName0;
		_spr = new Sprite(texture);
		_pos = Vector2f((g_global.windowWidth - _spr.getGlobalBounds().width) / 2,
								(g_global.windowHeight - _spr.getGlobalBounds().height) / 2);
		_spr.position = _pos;
	}

	void draw() {
		if (_spr)
			g_window.draw(_spr);
	}
}
