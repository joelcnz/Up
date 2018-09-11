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
			import std.path: buildPath;
			import std.file: readText;

			// file contence(sp): settingfiles/settings copy
			settings.setIniFileName(buildPath("settingfiles", readText("settingsSelect.ini")) ~ ".ini");
			settings.load();
		}
	}
}
