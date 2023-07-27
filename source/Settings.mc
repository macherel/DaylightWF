using Toybox.Application as App;
using Toybox.WatchUi as Ui;
import Toybox.System;

module Settings {

	var centeredDisplay = true;
	var flip = false;
	var displayDial = 3;
	var displayMinute = 0;
	var displaySeconds = 0;
	var hoursPrecision = false;
	var precision = false;
	var northDetail = :NONE;
	var eastDetail = :NONE;
	var southDetail = :NONE;
	var westDetail = :NONE;
	var dateFormat = 0;
	var timeFormat = 0;
	var batteryDetails = 0;
	var showNotifications = true;
	var showDisconnected = false;
	var showIcons = true;

	var brightColor = false;
	var darkColor = false;
	var hoursColor = false;
	var minutesColor = false;
	var secondsColor = false;
	var batteryColor = false;


	function load() {
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

		centeredDisplay = Ui.loadResource(Rez.Strings.centeredDisplay).equals("true");
		flip = getProperty("Flip");
		displayDial = getProperty("DisplayDial");
		displayMinute = getProperty("DisplayMinute");
		displaySeconds = getProperty("DisplaySeconds");
		hoursPrecision = getProperty("HoursPrecision");
		precision = getProperty("Precision");
		northDetail = getDetail(getProperty("NorthDetail"));
		eastDetail = getDetail(getProperty("EastDetail"));
		southDetail = getDetail(getProperty("SouthDetail"));
		westDetail = getDetail(getProperty("WestDetail"));
		dateFormat = getProperty("DateFormat");
		timeFormat = getProperty("TimeFormat");
		batteryDetails = getProperty("BatteryDetails");
		showNotifications = getProperty("ShowNotifications");
		showDisconnected = getProperty("ShowDisconnected");	
		showIcons = getProperty("ShowIcons");		

		if(batteryDetails < 0) {
			batteryDetails = 0;
		}

		var predifinedBrightColor = getProperty("PredifinedBrightColor");
		if(predifinedBrightColor > 0) {
			brightColor = predifinedBrightColors[predifinedBrightColor-1];
		} else {
			brightColor = getProperty("BrightColor").toNumberWithBase(0x10);
		}
		setProperty("BrightColor", brightColor.format("%06X"));

		var predifinedDarkColor = getProperty("PredifinedDarkColor");
		if(predifinedDarkColor > 0) {
			darkColor = predifinedDarkColors[predifinedDarkColor-1];
		} else {
			darkColor = getProperty("DarkColor").toNumberWithBase(0x10);
		}
		setProperty("DarkColor", darkColor.format("%06X"));

		var predifinedHoursColor = getProperty("PredifinedHoursColor");
		if(predifinedHoursColor > 0) {
			hoursColor = predifinedBrightColors[predifinedHoursColor-1];
		} else if(predifinedHoursColor < 0) {
			hoursColor = brightColor;
		} else {
			hoursColor = getProperty("HoursColor").toNumberWithBase(0x10);
		}
		setProperty("HoursColor", hoursColor.format("%06X"));

		var predifinedMinutesColor = getProperty("PredifinedMinutesColor");
		if(predifinedMinutesColor > 0) {
			minutesColor = predifinedBrightColors[predifinedMinutesColor-1];
		} else if(predifinedMinutesColor < 0) {
			minutesColor = brightColor;
		} else {
			minutesColor = getProperty("MinutesColor").toNumberWithBase(0x10);
		}
		setProperty("MinutesColor", minutesColor.format("%06X"));

		var predifinedSecondsColor = getProperty("PredifinedSecondsColor");
		if(predifinedSecondsColor > 0) {
			secondsColor = predifinedBrightColors[predifinedSecondsColor-1];
		} else if(predifinedSecondsColor < 0) {
			secondsColor = null;
		} else {
			secondsColor = getProperty("SecondsColor").toNumberWithBase(0x10);
		}
		setProperty("SecondsColor", secondsColor==null?"":secondsColor.format("%06X"));

		var predifinedBatteryColor = getProperty("PredifinedBatteryColor");
		if(predifinedBatteryColor > 0) {
			batteryColor = predifinedBatteryColors[predifinedBatteryColor-1];
		} else if(predifinedBatteryColor == -1) {
			batteryColor = brightColor;
		} else if(predifinedBatteryColor == -2) {
			batteryColor = darkColor;
		} else {
			batteryColor = getProperty("BatteryColor").toNumberWithBase(0x10);
		}
		setProperty("BatteryColor", batteryColor.format("%06X"));
	}

	function getProperty(name) {
		return App.getApp().getProperty(name);
	}

	function setProperty(name, value) {
		App.getApp().setProperty(name, value);
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
