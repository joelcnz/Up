import base;

struct BackPicture {
	string _fileName;
	SDL_Rect _pos;
	SDL_Texture* _spr;

	~this() {
		close;
	}

	void  close() {
		if (_spr !is null)
			SDL_DestroyTexture(_spr);
	}

	void load(string fileName0) {
		if (_spr !is null)
			close;
		if (fileName0 == "") {
			import jmisc;
			mixin(jecho("return;"));
		}

		import std.path : buildPath;

	/+
		// load a image file for object
		string fileNameTmp = buildPath("backPictures", fileName0);
		auto texture = new Texture;
		if (! texture.loadFromFile(fileNameTmp)) { // load off program root folder
			throw new Exception(fileNameTmp ~ " not load");
		}
		_fileName = fileName0;
		_spr = new Sprite(texture);
	+/
		import std.string : toStringz;
		immutable name = buildPath("backPictures", fileName0);
		auto surface = IMG_Load(name.toStringz);
		if (surface is null) {
			import std.conv : to;
			throw new Exception("Surface '" ~ name ~ "' load failed: " ~ IMG_GetError().to!string );
		}
		scope(exit)
			SDL_FreeSurface(surface);
		_spr = SDL_CreateTextureFromSurface( gRenderer, surface );
		if (! _spr)
			throw new Exception(name ~ " - not load!");
/+
		_pos = Vector2f((g_global.windowWidth - _spr.getGlobalBounds().width) / 2,
								(g_global.windowHeight - _spr.getGlobalBounds().height) / 2);
+/
		_pos = SDL_Rect((g_global.windowWidth - surface.w) / 2, (g_global.windowHeight - surface.h) / 2,
			surface.w, surface.h);
	}

	void draw() {
		SDL_RenderCopy(gRenderer, _spr, null, &_pos);
	}
}
