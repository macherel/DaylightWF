using Toybox.Application as App;
using Toybox.WatchUi as Ui;

module Settings {


	var displayDial = false;
	var displayMinute = 0;
	var precision = false;
	var displayDate = false;
	var dateFormat = 0;
	var batteryDetails = 0;
	var showNotifications = true;
	var showDisconnected = false;

	var brightColor = false;
	var darkColor = false;
	var hoursColor = false;
	var minutesColor = false;


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

		////////////////////////////////////////////////////////////////
		// Legacy Settings
		var displayBattery = app.getProperty("DisplayBattery");
		if(displayBattery) {
			app.setProperty("DisplayBattery", false);
			app.setProperty("BatteryDetails", 1);
		}
		////////////////////////////////////////////////////////////////

		displayDial = app.getProperty("DisplayDial");
		displayMinute = app.getProperty("DisplayMinute");
		precision = app.getProperty("Precision");
		displayDate = app.getProperty("DisplayDate");
		dateFormat = app.getProperty("DateFormat");
		batteryDetails = app.getProperty("BatteryDetails");
		showNotifications = app.getProperty("ShowNotifications");
		showDisconnected = app.getProperty("ShowDisconnected");		

		if(batteryDetails < 0) {
			batteryDetails = 0;
		}

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

		var predifinedHoursColor = app.getProperty("PredifinedHoursColor");
		if(predifinedHoursColor > 0) {
			hoursColor = predifinedBrightColors[predifinedHoursColor-1];
			app.setProperty("HoursColor", hoursColor.format("%06X"));
		} else if(predifinedHoursColor < 0) {
			hoursColor = brightColor;
			app.setProperty("HoursColor", hoursColor.format("%06X"));
		} else {
			hoursColor = app.getProperty("HoursColor").toNumberWithBase(0x10);
		}

		var predifinedMinutesColor = app.getProperty("PredifinedMinutesColor");
		if(predifinedMinutesColor > 0) {
			minutesColor = predifinedBrightColors[predifinedMinutesColor-1];
			app.setProperty("MinutesColor", minutesColor.format("%06X"));
		} else if(predifinedMinutesColor < 0) {
			minutesColor = brightColor;
			app.setProperty("MinutesColor", minutesColor.format("%06X"));
		} else {
			minutesColor = app.getProperty("MinutesColor").toNumberWithBase(0x10);
		}
	}
}
