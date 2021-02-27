using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time.Gregorian as Calendar;

class DaylightWFView extends WatchUi.WatchFace {

	var bluetoothOff = null;
	var heartRateIco = null;
	var stepsIco = null;
	var caloriesIco = null;

	var radius = 0;
	var cx = 0;
	var cy = 0;

	function initialize() {
		WatchFace.initialize();
	}

	// Load your resources here
	function onLayout(dc) {
		var dcWidth = dc.getWidth();
		var dcHeight = dc.getHeight();

		radius = dcWidth<dcHeight?dcWidth/2:dcHeight/2;
		cx = dcWidth/2;
		cy = dcHeight/2;

		bluetoothOff = WatchUi.loadResource(Rez.Drawables.BluetoothOff);
		heartRateIco = WatchUi.loadResource(Rez.Drawables.HeartRate);
		stepsIco = WatchUi.loadResource(Rez.Drawables.Steps);
		caloriesIco = WatchUi.loadResource(Rez.Drawables.Calories);
		if(Graphics has :BufferedBitmap) { // check to see if device has BufferedBitmap enabled
			bluetoothOff = new Graphics.BufferedBitmap({
				:bitmapResource=>bluetoothOff
			});
			heartRateIco = new Graphics.BufferedBitmap({
				:bitmapResource=>heartRateIco
			});
			stepsIco = new Graphics.BufferedBitmap({
				:bitmapResource=>stepsIco
			});
			caloriesIco = new Graphics.BufferedBitmap({
				:bitmapResource=>caloriesIco
			});
		}
		applyPalette();
	}
	
	function applyPalette() {
		if(Graphics has :BufferedBitmap) { // check to see if device has BufferedBitmap enabled
			bluetoothOff.setPalette([Settings.darkColor, Settings.brightColor, Graphics.COLOR_TRANSPARENT]);
			heartRateIco.setPalette([Settings.darkColor, Settings.brightColor, Graphics.COLOR_TRANSPARENT]);
			stepsIco.setPalette([Settings.darkColor, Settings.brightColor, Graphics.COLOR_TRANSPARENT]);
			caloriesIco.setPalette([Settings.darkColor, Settings.brightColor, Graphics.COLOR_TRANSPARENT]);
		}
	}

	// Called when this View is brought to the foreground. Restore
	// the state of this View and prepare it to be shown. This includes
	// loading resources into memory.
	function onShow() {
	}

	// Update the view
	function onUpdate(dc) {
		// Call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);

		var displayMinute = Settings.displayMinute;
		var hoursPrecision = Settings.hoursPrecision?2:1;
		var precision = Settings.precision?2:1;
		var dateFormat = Settings.dateFormat;
		var displayDial = Settings.displayDial;
		var showNotifications = Settings.showNotifications;
		var showDisconnected = Settings.showDisconnected;
		var brightColor = Settings.brightColor;
		var darkColor = Settings.darkColor;
		var hoursColor = Settings.hoursColor;
		var minutesColor = Settings.minutesColor;
		var batteryColor = Settings.batteryColor;
		// Get the current time and format it correctly
		var clockTime = System.getClockTime();

		// Update the view
		var dcWidth = dc.getWidth();
		var dcHeight = dc.getHeight();
		var r = radius;

		var d = 0;
		dc.setColor(brightColor, darkColor);
		dc.clear();

		// Draw minutes arc
		if(displayMinute > 0) {
			d = (clockTime.min % (60/precision) * 60 + clockTime.sec) / (10 / precision);
			displayArc(dc, cx, cy, r, precision==1 || clockTime.min<30, d, minutesColor, darkColor, true);
			r = r * (1.0 - (displayMinute+1.0)/100.0);
		}
		// Draw hours arc
		if(r > 0) {
			d = (clockTime.hour % (24/hoursPrecision) * 60 + clockTime.min) / (4/hoursPrecision);
			displayArc(dc, cx, cy, r, clockTime.hour<12, d, hoursColor, darkColor, true);
			// Display Battery info
			if(Settings.batteryDetails > 0) {
				var systemStats = System.getSystemStats();
				if(systemStats has :charging && systemStats.charging) {
					// Draw charging arc
					displayArc(dc, cx, cy, r * ((100-systemStats.battery)/100), clockTime.hour<12, d, 0x404040, darkColor, false);
				} else {
					dc.setColor(darkColor,darkColor);
					dc.fillCircle(cx, cy, r * ((100-systemStats.battery)/100));
				}
				dc.setPenWidth(1);
				dc.setColor(batteryColor,darkColor);
				for(var i=1; i<Settings.batteryDetails; i++) {
					var l = 1.0 * i * (100/Settings.batteryDetails);
					dc.drawCircle(cx, cy, r * ((100-l)/100));
				}
			}
		}
		
		// Show notifications
		if(showNotifications) {
			var deviceSettings = System.getDeviceSettings();
			if(deviceSettings.notificationCount > 0) {
				dc.setColor(darkColor,darkColor);
				dc.fillCircle(cx, cy, 12);
				dc.setColor(brightColor,darkColor);
				dc.drawText(
					dc.getWidth() / 2,
					dc.getHeight() / 2,
					Graphics.FONT_XTINY,
					" " + deviceSettings.notificationCount + " ",
					Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
				);
			}
		}

		if(showDisconnected) {
			var deviceSettings = System.getDeviceSettings();
			if(!deviceSettings.phoneConnected) {
				var x = (dc.getWidth() - 24) / 2;
				var y = (dc.getHeight() - 24) / 2;
				dc.drawBitmap(x, y, bluetoothOff);
			}
		}

		// Draw Dial
		if(displayDial > 0) {
			drawDial(dc, r);
		}

		drawDetail(dc, Settings.northDetail, :NORTH, darkColor, brightColor, hoursColor, clockTime.hour);
		drawDetail(dc, Settings.eastDetail,  :EAST,  darkColor, brightColor, hoursColor, clockTime.hour);
		drawDetail(dc, Settings.southDetail, :SOUTH, darkColor, brightColor, hoursColor, clockTime.hour);
		drawDetail(dc, Settings.westDetail,  :WEST,  darkColor, brightColor, hoursColor, clockTime.hour);
	}

	function displayArc(dc, cx, cy, r, clockwised, degree, brightColor, darkColor, border) {
		if(r<1) {
			return;
		}
		dc.setPenWidth(r);
		if(border) {
			dc.setColor(darkColor, darkColor);
			dc.fillCircle(cx, cy, r+1);
		}
		dc.setColor(brightColor, darkColor);
		if(degree != 0 || !clockwised) {
			var start = 90;
			if(Settings.flip) {
				start += 180;
			}
			dc.drawArc(cx, cy, r/2, clockwised?Graphics.ARC_CLOCKWISE:Graphics.ARC_COUNTER_CLOCKWISE, start, start-degree);
		} else {
			dc.setPenWidth(1);
			if(Settings.flip) {
				dc.drawLine(cx, cy, cx, cy+r);
			} else {
				dc.drawLine(cx, cy, cx, cy-r);
			}
		}
	}


	// Draw the watch dial
	function drawDial(dc, dialRadius) {
		for (var j = 2; j >= 0; j -= 2) {
			dc.setColor(
				j>0?Settings.darkColor:Settings.brightColor,
				j>0?Settings.darkColor:Settings.brightColor
			);
			var detail = Settings.displayDial;
			for (var i = 0; i < detail; i += 1) {
				var angle = i * 2 * Math.PI / (4*detail);
				var scale = 0;
				if (i % 5 == 0) {
					dc.setPenWidth(3+j);
				} else {
					dc.setPenWidth(2+j);
					scale = 0.02;
				}
	
				var cos = Math.cos(angle);
				var sin = Math.sin(angle);
	
				var x1 = cos * dialRadius * 0.95 * (1+scale);
				var y1 = sin * dialRadius * 0.95 * (1+scale);
				var x2 = cos * dialRadius * 1.05 * (1-scale);
				var y2 = sin * dialRadius * 1.05 * (1-scale);

				dc.drawLine(cx + x1, cy + y1, cx + x2, cy + y2);
				dc.drawLine(cx - x1, cy - y1, cx - x2, cy - y2);
				dc.drawLine(cx - y1, cy + x1, cx - y2, cy + x2);
				dc.drawLine(cx + y1, cy - x1, cx + y2, cy - x2);
			}
		}
	}

	function drawDetail(dc, detail, position, darkColor, brightColor, hoursColor, hour) {
		switch(detail) {
			case :DATE:
				drawText(dc, getDate(), null, position, darkColor, brightColor, hoursColor, hour);
				break;
			case :TIME:
				drawText(dc, getTime(), null, position, darkColor, brightColor, hoursColor, hour);
				break;
			case :HEART_RATE:
				if(ActivityMonitor has :getHeartRateHistory) {
					var hrIterator = ActivityMonitor.getHeartRateHistory(1, true);
					var sample = hrIterator.next();
					if (null != sample && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
						drawText(dc, sample.heartRate, heartRateIco, position, darkColor, brightColor, hoursColor, hour);
					}
				}
				break;
			case :STEPS:
				drawText(dc, ActivityMonitor.getInfo().steps, stepsIco, position, darkColor, brightColor, hoursColor, hour);
				break;
			case :CALORIES:
				drawText(dc, ActivityMonitor.getInfo().calories, caloriesIco, position, darkColor, brightColor, hoursColor, hour);
				break;
		}
	}

	function getDate() {
		var dateFormat = "";
		var infoFormat = Time.FORMAT_SHORT;
		switch(Settings.dateFormat) {
			case 1004: // dd DD
				dateFormat = "$4$ $3$";
				infoFormat = Time.FORMAT_MEDIUM;
				break;
			case 1022: // MM/DD
				dateFormat = "$2$/$3$";
				infoFormat = Time.FORMAT_SHORT;
				break;
			case 1031: // MMM DD
				dateFormat = "$2$ $3$";
				infoFormat = Time.FORMAT_MEDIUM;
				break;
			case 2022: // DD/MM
				dateFormat = "$3$/$2$";
				infoFormat = Time.FORMAT_SHORT;
				break;
			case 2031: // DD MMM
				dateFormat = "$3$ $2$";
				infoFormat = Time.FORMAT_MEDIUM;
				break;
		}
		var now = Time.now();
		var dateInfo = Calendar.info(now, infoFormat);
		var year = dateInfo.year;
		var month = dateInfo.month;
		var day = dateInfo.day;
		var dayOfWeek = dateInfo.day_of_week;
		if(infoFormat == Time.FORMAT_SHORT) {
			month = month.format("%02d");
			day = day.format("%02d");
		}

		return Lang.format(dateFormat, [year, month, day, dayOfWeek]);
	}

	function getTime() {
		var clockTime = System.getClockTime();
		var hour = clockTime.hour.format("%02d");
		var min = clockTime.min.format("%02d");

		return hour + ":" + min;
	}

	function drawText(dc, text, icon, position, darkColor, brightColor, hoursColor, hour) {
		var border = dc.getWidth() * Settings.displayMinute / 200;
		var dcWidth = dc.getWidth() - 2 * border;
		var dcHeight = dc.getHeight() - 2 * border;
		var x = dcWidth / 2;
		var y = dcHeight / 2;
		var foreground = brightColor;
		var background = darkColor;
		switch(position) {
			case :NORTH:
				if(6 <= hour && hour < 18) {
					foreground = darkColor;
					background = hoursColor;
				} else {
					foreground = brightColor;
					background = darkColor;
				}
				y = dcHeight / 4;
				break;
			case :EAST:
				if(3 <= hour && hour < 15) {
					foreground = darkColor;
					background = hoursColor;
				} else {
					foreground = brightColor;
					background = darkColor;
				}
				x = dcWidth * 3 / 4;
				break;
			case :SOUTH:
				if(6 <= hour && hour < 18) {
					foreground = darkColor;
					background = hoursColor;
				} else {
					foreground = brightColor;
					background = darkColor;
				}
				y = dcHeight * 3 / 4;
				break;
			case :WEST:
				if(9 <= hour && hour < 21) {
					foreground = darkColor;
					background = hoursColor;
				} else {
					foreground = brightColor;
					background = darkColor;
				}
				x = dcWidth / 4;
				break;
		}
		text = " " + text + " ";
		var textDimensions = dc.getTextDimensions(text, Graphics.FONT_XTINY);
		x += border;
		y += border;
		if(Settings.showIcons && icon != null) {
			x += 8;
			if(Graphics has :BufferedBitmap) { // check to see if device has BufferedBitmap enabled
				icon.setPalette([background, foreground, Graphics.COLOR_TRANSPARENT]);
			}
			dc.setColor(background, background);
			dc.fillRectangle(x - (textDimensions[0] / 2) - 16, y - (textDimensions[1] / 2) + 1, 16, textDimensions[1]);
			dc.drawBitmap(x - (textDimensions[0] / 2) - 16, y - 8, icon);
		}
		dc.setColor(foreground, background);
		dc.drawText(x, y, Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	// Called when this View is removed from the screen. Save the
	// state of this View here. This includes freeing resources from
	// memory.
	function onHide() {
	}

	// The user has just looked at their watch. Timers and animations may be started here.
	function onExitSleep() {
	}

	// Terminate any active timers and prepare for slow updates.
	function onEnterSleep() {
	}

	function darken(color) {
		var r = ((color>>16 % 256) * 0.8).toLong();
		var g = ((color>> 8 % 256) * 0.8).toLong();
		var b = ((color>> 0 % 256) * 0.8).toLong();
		return r<<16 + g<<8 + b;
	}
}
