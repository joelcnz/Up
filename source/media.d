//#not work!
//# pos -= etc. not work!
import base;

class Media {
private:
	string _name;
	Image mSpr;
	//SDL_Texture* _spr;
	//SDL_Rect mRect;
	JSound _sound;
	Pict _picCase;
	bool _hide;
public:
	@property {
		string name() { return _name; }
		void name(in string name0) { _name = name0; }

		auto pos() { return mSpr.pos; }
		void pos(Point pos0) { mSpr.pos = pos0; } // mRect.x = cast(int)pos0.X; mRect.y = cast(int)pos0.Y; }

		void rect(SDL_Rect r) { mSpr.mRect = r; }
		auto rect() { return mSpr.mRect; }

		JSound sound() { return _sound; }

		Pict picCase() { return _picCase; }
		void picCase(in Pict picCase0) { _picCase = picCase0; }

		bool hide() { return _hide; }
		void hide(in bool hide0) { _hide = hide0; }
	}

	this(in string name, SDL_Texture* texture, in SDL_Rect rect, JSound sound) {
		_hide = false;
		_picCase = Pict.stopped;
		_name = name;
		//_spr = texture;
		//mRect = rect;
		mSpr = Image(texture, rect); //.mImg = texture;
		//mSpr.mReleaseMemory = false;
		
		/+
		// Setup picture let sprite object using texture object
		_spr = new Sprite(texture);
		_spr.position = Vector2f((g_global.windowWidth - _spr.getGlobalBounds().width) / 2, -_spr.getGlobalBounds().height); // up out of sight
		+/
/+
		_pos = Vector2f((g_global.windowWidth - _spr.getGlobalBounds().width) / 2,
								(g_global.windowHeight - _spr.getGlobalBounds().height) / 2);
+/
		_sound = sound;
	}
	
	void process() {
		if (_picCase == Pict.up) {
			//_spr.position = Vector2f(_spr.position.x + g_global.pictureUpStep, _spr.position.y); //#not work!
			//mRect = SDL_Rect(mRect.x, cast(int)(mRect.y - g_global.pictureUpStep), mRect.w, mRect.h);
			with(mSpr) {
				pos = Point(pos.X, pos.Y - g_global.pictureUpStep);
				//pos -= Point(0, g_global.pictureUpStep); //# pos -= etc. not work!
			}
		}
	}

	bool outOfBounds() {
		return (mSpr.pos.Y > g_global.windowHeight || mSpr.pos.Y + mSpr.mRect.h < 0);
	}

	void draw() {
		if (! outOfBounds && ! _hide) {
			//g_window.draw(_spr);
			//SDL_RenderCopy(gRenderer, mSpr.mImg, null, &mSpr.mRect);
			mSpr.draw;
		}
	}
	
	override string toString() {
		return _name;
	}

	void close() {
		//SDL_DestroyTexture(mSpr.mImg);
	}
}
