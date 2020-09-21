using Toybox.Application as App;
using Toybox.WatchUi as Ui;

module Settings {


	var displayDial = false;
	var displayMinute = false;
	var precision = false;
	var displayBattery = false;
	var showNotifications = true;

	var brightColor = false;
	var darkColor = false;


	function load() {
		var app = App.getApp();
		var predifinedBrightColors = [
			0xFFFFFF, // White
			0xFFE000, // Yellow
			0x00BFFF, // Blue
			0x7FFF00, // Green
			0xFF0000, // Red
			0x000000  // Black
		];
		var predifinedDarkColors = [
			0x000000, // Black
			0xD04000, // Brown
			0x000080, // Blue
			0x008000, // Green
			0x800000, // Red
			0xFFFFFF  // White
		];

		displayDial = app.getProperty("DisplayDial");
		displayMinute = app.getProperty("DisplayMinute");
		precision = app.getProperty("Precision");
		displayBattery = app.getProperty("DisplayBattery");
		showNotifications = app.getProperty("ShowNotifications");

		var predifinedBrightColor = app.getProperty("PredifinedBrightColor");
		if(predifinedBrightColor > 0) {
			brightColor = predifinedBrightColors[predifinedBrightColor-1];
			app.setProperty("BrightColor", brightColor.format("%06X"));
		} else {
			brightColor = app.getProperty("BrightColor").toNumberWithBase(0x10);
		}

		var predifinedDarkColor = app.getProperty("PredifinedDarkColor");
		if(predifinedDarkColor > 0) {
			darkColor = predifinedDarkColors[predifinedDarkColor-1];
			app.setProperty("DarkColor", darkColor.format("%06X"));
		} else {
			darkColor = app.getProperty("DarkColor").toNumberWithBase(0x10);
		}
	}
}
