using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;

class DaylightWFView extends WatchUi.WatchFace {

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
		var displayBattery = Settings.displayBattery;
		var displayDial = Settings.displayDial;
		var showNotifications = Settings.showNotifications;
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

		// Draw Dial
		if(displayDial) {
			drawDial(dc, r);
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
	        	j>0?Graphics.COLOR_BLACK:Graphics.COLOR_LT_GRAY,
	        	j>0?Graphics.COLOR_BLACK:Graphics.COLOR_LT_GRAY
        	);
	        for (var i = 0; i < 3; i += 1) {
	        	var angle = i * 2 * Math.PI / 12;
	            if (i % 3 == 0) {
	                dc.setPenWidth(3+j);
	            }
	            else {
	                dc.setPenWidth(1+j);
	            }
	
	            var cos = Math.cos(angle);
	            var sin = Math.sin(angle);
	
	            var x1 = cos * dialRadius * 0.95;
	            var y1 = sin * dialRadius * 0.95;
	            var x2 = cos * dialRadius * 1.05;
	            var y2 = sin * dialRadius * 1.05;

	            dc.drawLine(cx + x1, cy + y1, cx + x2, cy + y2);
	            dc.drawLine(cx - x1, cy - y1, cx - x2, cy - y2);
	            dc.drawLine(cx - y1, cy + x1, cx - y2, cy + x2);
	            dc.drawLine(cx + y1, cy - x1, cx + y2, cy - x2);
            }
        }
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

}
