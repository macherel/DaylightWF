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
	var minutesRadius = 0;
	var hoursRadius = 0;
	var cx = 0;
	var cy = 0;
	var dx = 0;
	var dy = 0;

	function initialize() {
		WatchFace.initialize();
	}

	private function createBufferedBitmap(bitmapResource as WatchUi.BitmapResource or Graphics.BitmapReference) {
		var options = {
			:bitmapResource=>bitmapResource
		};
		if (Graphics has :createBufferedBitmap) {
			return Graphics.createBufferedBitmap(options).get();
		} else {
			return new Graphics.BufferedBitmap(options);
		}
	}

	// Load your resources here
	function onLayout(dc) {
		var dcWidth = dc.getWidth();
		var dcHeight = dc.getHeight();

		radius = dcWidth<dcHeight?dcWidth/2:dcHeight/2;
		cx = dcWidth/2;
		cy = dcHeight/2;
		if(!Settings.centeredDisplay) {
			dx = radius - cx;
			dy = radius - cy;
			cx = radius;
			cy = radius;
		}

		bluetoothOff = WatchUi.loadResource(Rez.Drawables.BluetoothOff);
		heartRateIco = WatchUi.loadResource(Rez.Drawables.HeartRate);
		stepsIco = WatchUi.loadResource(Rez.Drawables.Steps);
		caloriesIco = WatchUi.loadResource(Rez.Drawables.Calories);
		if(Graphics has :BufferedBitmap) { // check to see if device has BufferedBitmap enabled
			bluetoothOff = createBufferedBitmap(bluetoothOff);
			heartRateIco = createBufferedBitmap(heartRateIco);
			stepsIco = createBufferedBitmap(stepsIco);
			caloriesIco = createBufferedBitmap(caloriesIco);
		}
		init();
	}
	
	function init() {
		var displayMinute = Settings.displayMinute;
		minutesRadius = displayMinute ? radius : 0;
		hoursRadius = displayMinute ? radius * (1.0 - (displayMinute+1.0)/100.0) : radius;
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

		var hoursPrecision = Settings.hoursPrecision?2:1;
		var precision = Settings.precision?2:1;
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
		var minutesAngle = 0;
		var minutesclockwised = precision==1 || clockTime.min<30;
		var hoursAngle = 0;
		var hoursclockwised = hoursPrecision==1 || clockTime.hour<12;
		dc.setColor(brightColor, darkColor);
		dc.clear();

		// Draw minutes arc
		if(minutesRadius > 0) {
			minutesAngle = (clockTime.min % (60/precision) * 60 + clockTime.sec) / (10 / precision);
			displayArc(dc, cx, cy, minutesRadius, minutesclockwised, minutesAngle, minutesColor, darkColor, true);
			// Display seconds
			if(Settings.displaySeconds == 1) {
				drawSeconds(dc, clockTime.sec, minutesRadius, minutesAngle, minutesclockwised, minutesColor, darkColor);
			}
		}
		// Draw hours arc
		if(hoursRadius > 0) {
			hoursAngle = (clockTime.hour % (24/hoursPrecision) * 60 + clockTime.min) / (4/hoursPrecision);
			displayArc(dc, cx, cy, hoursRadius, hoursclockwised, hoursAngle, hoursColor, darkColor, true);
			// Display Battery info
			if(Settings.batteryDetails > 0) {
				var systemStats = System.getSystemStats();
				if(systemStats has :charging && systemStats.charging) {
					// Draw charging arc
					displayArc(dc, cx, cy, hoursRadius * ((100-systemStats.battery)/100), clockTime.hour<12, hoursAngle, 0x404040, darkColor, false);
				} else {
					dc.setColor(darkColor,darkColor);
					dc.fillCircle(cx, cy, hoursRadius * ((100-systemStats.battery)/100));
				}
				dc.setPenWidth(1);
				dc.setColor(batteryColor,darkColor);
				for(var i=1; i<Settings.batteryDetails; i++) {
					var l = 1.0 * i * (100/Settings.batteryDetails);
					dc.drawCircle(cx, cy, hoursRadius * ((100-l)/100));
				}
			}
			// Display seconds
			if(Settings.displaySeconds == 2) {
				drawSeconds(dc, clockTime.sec, hoursRadius, hoursAngle, hoursclockwised, hoursColor, darkColor);
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
			drawDial(dc, hoursRadius);
		}

		// Display seconds
		if(Settings.displaySeconds == 3) {
			drawSeconds(dc, clockTime.sec, minutesRadius, minutesAngle, minutesclockwised, minutesColor, darkColor);
			drawSeconds(dc, clockTime.sec, hoursRadius, hoursAngle, hoursclockwised, hoursColor, darkColor);
		}

		drawDetail(dc, Settings.northDetail, :NORTH, darkColor, brightColor, hoursColor, clockTime.hour);
		drawDetail(dc, Settings.eastDetail,  :EAST,  darkColor, brightColor, hoursColor, clockTime.hour);
		drawDetail(dc, Settings.southDetail, :SOUTH, darkColor, brightColor, hoursColor, clockTime.hour);
		drawDetail(dc, Settings.westDetail,  :WEST,  darkColor, brightColor, hoursColor, clockTime.hour);
	}

	function drawSeconds(dc, seconds, secondsRadius, arcAngle, arcClockwised, brightColor, darkColor) {
		dc.setPenWidth(3);
		var angle = Math.PI * 2 * seconds / 60;
		if(Settings.flip) {
			if(angle > Math.PI) {
				angle -= Math.PI;
			} else {
				angle += Math.PI;
			}
		}
		var sin = Math.sin(angle);
		var cos = Math.cos(angle);

		var color = getSecondsColor(seconds*6, arcAngle, arcClockwised, brightColor, darkColor);
		dc.setColor(color, color);
		dc.drawLine(cx, cy, cx + sin * secondsRadius, cy - cos * secondsRadius);
	}

	function getSecondsColor(secondsAngle, arcAngle, clockwised, brightColor, darkColor) {
			var secondsColor = Settings.secondsColor;
			if(secondsColor == null) {
				secondsColor = brightColor;
				if((clockwised && secondsAngle < arcAngle) 
						|| (!clockwised && secondsAngle > arcAngle)) {
					secondsColor = darkColor;
				}
			}
			return secondsColor;
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

		var time = hour + ":" + min;
		if(Settings.timeFormat % 10 != 0) {
			var sec = clockTime.sec.format("%02d");
			time += ":" + sec;
		}
		return time;
	}

	function drawText(dc, text, icon, position, darkColor, brightColor, hoursColor, hour) {
		var delta = radius * (100 - Settings.displayMinute) / 200;
		var x = cx;
		var y = cy;
		switch(position) {
			case :NORTH:
				y -= delta;
				break;
			case :EAST:
				x += delta;
				break;
			case :SOUTH:
				y += delta;
				break;
			case :WEST:
				x -= delta;
				break;
		}
		var foreground = brightColor;
		var background = darkColor;
		if(!Settings.hoursPrecision) {
			hour /= 2;
		}
		var p = position;
		if(Settings.flip){
			switch(position) {
				case :EAST:
					p = :WEST;
					break;
				case :WEST:
					p = :EAST;
					break;
			}
		}
		switch(p) {
			case :NORTH:
				if(6 <= hour && hour < 18) {
					foreground = darkColor;
					background = hoursColor;
				} else {
					foreground = brightColor;
					background = darkColor;
				}
				break;
			case :EAST:
				if(3 <= hour && hour < 15) {
					foreground = darkColor;
					background = hoursColor;
				} else {
					foreground = brightColor;
					background = darkColor;
				}
				break;
			case :SOUTH:
				if(6 <= hour && hour < 18) {
					foreground = darkColor;
					background = hoursColor;
				} else {
					foreground = brightColor;
					background = darkColor;
				}
				break;
			case :WEST:
				if(9 <= hour && hour < 21) {
					foreground = darkColor;
					background = hoursColor;
				} else {
					foreground = brightColor;
					background = darkColor;
				}
				break;
		}
		text = " " + text + " ";
		var textDimensions = dc.getTextDimensions(text, Graphics.FONT_XTINY);
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
