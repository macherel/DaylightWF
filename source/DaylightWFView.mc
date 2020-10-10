using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time.Gregorian as Calendar;

class DaylightWFView extends WatchUi.WatchFace {

	var bluetoothOff = null;

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
		if(Graphics has :BufferedBitmap) { // check to see if device has BufferedBitmap enabled
			bluetoothOff = new Graphics.BufferedBitmap({
				:bitmapResource=>bluetoothOff
			});
		}
		setLayout(Rez.Layouts.WatchFace(dc));
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

		Settings.load();
		var displayMinute = Settings.displayMinute;
		var precision = Settings.precision?2:1;
		var diplayDate = Settings.displayDate;
		var dateFormat = Settings.dateFormat;
		var displayBattery = Settings.displayBattery;
		var displayDial = Settings.displayDial;
		var showNotifications = Settings.showNotifications;
		var showDisconnected = Settings.showDisconnected;
		var brightColor = Settings.brightColor;
		var darkColor = Settings.darkColor;
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
			d = (clockTime.min % (60/precision) * 60 + clockTime.sec) / (10/precision);
			displayArc(dc, cx, cy, r, precision==1 || clockTime.min<30, d, brightColor, darkColor, true);
			r = r * (1.0 - (displayMinute+1.0)/100.0);
		}
		// Draw hours arc
		if(r > 0) {
			d = (clockTime.hour % 12 * 60 + clockTime.min) / 2;
			displayArc(dc, cx, cy, r, clockTime.hour<12, d, brightColor, darkColor, true);
			// Display Battery info
			if(displayBattery) {
				var systemStats = System.getSystemStats();
				if(systemStats has :charging && systemStats.charging) {
					// Draw charging arc
					displayArc(dc, cx, cy, r * ((100-systemStats.battery)/100), clockTime.hour<12, d, 0x444444, false);
				} else {
					dc.setColor(darkColor,darkColor);
					dc.fillCircle(cx, cy, r * ((100-systemStats.battery)/100));
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
				if(Graphics has :BufferedBitmap) { // check to see if device has BufferedBitmap enabled
					bluetoothOff.setPalette([darkColor, brightColor, -1]);
				}
				dc.drawBitmap(x, y, bluetoothOff);
			}
		}

		// Draw Dial
		if(displayDial) {
			drawDial(dc, r);
		}

		if(Settings.displayDate) {
			dc.setColor(brightColor,darkColor);
			drawDate(dc);
		} 
	}

	function displayArc(dc, cx, cy, r, clockwised, degree, brightColor, darkColor, border) {
		dc.setPenWidth(r);
		if(border) {
			dc.setColor(darkColor, darkColor);
			dc.fillCircle(cx, cy, r+1);
		}
		dc.setColor(brightColor, darkColor);
		if(degree != 0 || !clockwised) {
			dc.drawArc(cx, cy, r/2, clockwised?Graphics.ARC_CLOCKWISE:Graphics.ARC_COUNTER_CLOCKWISE, 90, 90-degree);
		} else {
			dc.setPenWidth(1);
			dc.drawLine(cx, cy, cx, cy-r);
		}
	}


	// Draw the watch dial
	function drawDial(dc, dialRadius) {
		for (var j = 2; j >= 0; j -= 2) {
			dc.setColor(
				j>0?Settings.darkColor:Settings.brightColor,
				j>0?Settings.darkColor:Settings.brightColor
			);
			for (var i = 0; i < 3; i += 1) {
				var angle = i * 2 * Math.PI / 12;
				var scale = 0;
				if (i % 3 == 0) {
					dc.setPenWidth(3+j);
				}
				else {
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

	function drawDate(dc) {
		var dcWidth = dc.getWidth();
		var dcHeight = dc.getHeight();
		var x = dcWidth / 2;
		var y = dcHeight * 3/4;
		var dateFormat = "";
		var infoFormat = Time.FORMAT_SHORT;
		switch(Settings.dateFormat) {
			case 1022: // MM/DD
				dateFormat = " $1$/$2$ ";
				infoFormat = Time.FORMAT_SHORT;
				break;
			case 1031: // MMM DD
				dateFormat = " $1$ $2$ ";
				infoFormat = Time.FORMAT_MEDIUM;
				break;
			case 2022: // DD/MM
				dateFormat = " $2$/$1$ ";
				infoFormat = Time.FORMAT_SHORT;
				break;
			case 2031: // DD MMM
				dateFormat = " $2$ $1$ ";
				infoFormat = Time.FORMAT_MEDIUM;
				break;
		}
		var now = Time.now();
		var dateInfo = Calendar.info(now, infoFormat);
		var month = dateInfo.month;
		var day = dateInfo.day;
		if(infoFormat == Time.FORMAT_SHORT) {
			month = month.format("%02d");
			day = day.format("%02d");
		}

		var date = Lang.format(dateFormat, [month, day]);
		dc.drawText(x, y, Graphics.FONT_XTINY, date, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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
