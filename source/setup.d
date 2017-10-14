import base;

struct Setup {
	void process() {
		with(g_global) {
			currentFontFileName = "Dancing.ttf";
			fontSize = 70;
			chunkSize = 40;
			fps = 60;
			verseTxtColour = Color(255,180,0);

			backPicture.load("barry1.png");

			// load from HDD
			settings.setIniFileName("settingfiles/settings.ini");
			settings.load();
		}
	}
}
