using Toybox.Application as App;
using Toybox.WatchUi as Ui;

module Settings {


	var displayDial = false;
	var displayMinute = 0;
	var precision = false;
	var northDetail = :NONE;
	var eastDetail = :NONE;
	var southDetail = :NONE;
	var westDetail = :NONE;
	var dateFormat = 0;
	var batteryDetails = 0;
	var showNotifications = true;
	var showDisconnected = false;
	var showIcons = true;

	var brightColor = false;
	var darkColor = false;
	var hoursColor = false;
	var minutesColor = false;
	var batteryColor = false;


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
		var predifinedBatteryColors = [
			0xFFFFFF, // White
			0x808080, // Gray
			0x000000  // Black
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
		northDetail = getDetail(app.getProperty("NorthDetail"));
		eastDetail = getDetail(app.getProperty("EastDetail"));
		southDetail = getDetail(app.getProperty("SouthDetail"));
		westDetail = getDetail(app.getProperty("WestDetail"));
		dateFormat = app.getProperty("DateFormat");
		batteryDetails = app.getProperty("BatteryDetails");
		showNotifications = app.getProperty("ShowNotifications");
		showDisconnected = app.getProperty("ShowDisconnected");	
		showIcons = app.getProperty("ShowIcons");		

		if(batteryDetails < 0) {
			batteryDetails = 0;
		}

		var predifinedBrightColor = app.getProperty("PredifinedBrightColor");
		if(predifinedBrightColor > 0) {
			brightColor = predifinedBrightColors[predifinedBrightColor-1];
		} else {
			brightColor = app.getProperty("BrightColor").toNumberWithBase(0x10);
		}
		app.setProperty("BrightColor", brightColor.format("%06X"));

		var predifinedDarkColor = app.getProperty("PredifinedDarkColor");
		if(predifinedDarkColor > 0) {
			darkColor = predifinedDarkColors[predifinedDarkColor-1];
		} else {
			darkColor = app.getProperty("DarkColor").toNumberWithBase(0x10);
		}
		app.setProperty("DarkColor", darkColor.format("%06X"));

		var predifinedHoursColor = app.getProperty("PredifinedHoursColor");
		if(predifinedHoursColor > 0) {
			hoursColor = predifinedBrightColors[predifinedHoursColor-1];
		} else if(predifinedHoursColor < 0) {
			hoursColor = brightColor;
		} else {
			hoursColor = app.getProperty("HoursColor").toNumberWithBase(0x10);
		}
		app.setProperty("HoursColor", hoursColor.format("%06X"));

		var predifinedMinutesColor = app.getProperty("PredifinedMinutesColor");
		if(predifinedMinutesColor > 0) {
			minutesColor = predifinedBrightColors[predifinedMinutesColor-1];
		} else if(predifinedMinutesColor < 0) {
			minutesColor = brightColor;
		} else {
			minutesColor = app.getProperty("MinutesColor").toNumberWithBase(0x10);
		}
		app.setProperty("MinutesColor", minutesColor.format("%06X"));

		var predifinedBatteryColor = app.getProperty("PredifinedBatteryColor");
		if(predifinedBatteryColor > 0) {
			batteryColor = predifinedBatteryColors[predifinedBatteryColor-1];
		} else if(predifinedBatteryColor == -1) {
			batteryColor = brightColor;
		} else if(predifinedBatteryColor == -2) {
			batteryColor = darkColor;
		} else {
			batteryColor = app.getProperty("BatteryColor").toNumberWithBase(0x10);
		}
		app.setProperty("BatteryColor", batteryColor.format("%06X"));
	}
	
	function getDetail(detail) {
		switch(detail) {
			case 1:
				return :DATE;
			case 2:
				return :TIME;
			case 3:
				return :HEART_RATE;
			case 4:
				return :STEPS;
			case 5:
				return :CALORIES;
		}
		return :NONE;
	}
}
