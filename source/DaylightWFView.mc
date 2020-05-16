using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;

class DaylightWFView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
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

		var displayMinute = Application.getApp().getProperty("DisplayMinute");
		var precision = Application.getApp().getProperty("Precision");
		var displayBattery = Application.getApp().getProperty("DisplayBattery");
        // Get the current time and format it correctly
        var clockTime = System.getClockTime();

        // Update the view
		var dcWidth = dc.getWidth();
		var dcHeight = dc.getHeight();
		var r = dcWidth<dcHeight?dcWidth/2:dcHeight/2;
		var cx = dcWidth/2;
		var cy = dcHeight/2;

        var d = 0;
        dc.setColor(0xFFFFFF,0x000000);
		dc.clear();
		if(displayMinute) {
			if(precision) {
				d = (clockTime.min % 30 * 60 + clockTime.sec) / 5;
				displayArc(dc, cx, cy, r, clockTime.min<30, d);
			} else {
				d = (clockTime.min * 60 + clockTime.sec) / 10;
				displayArc(dc, cx, cy, r, true, d);
			}
			r = r * 0.97;
		}
		d = (clockTime.hour % 12 * 60 + clockTime.min) / 2;
        displayArc(dc, cx, cy, r, clockTime.hour<12, d);
		if(displayBattery) {
	        dc.setColor(0x000000,0x000000);
			dc.fillCircle(cx, cy, r * (1-System.getSystemStats().battery/100));
		}
    }

	function displayArc(dc, cx, cy, r, clockwised, degree) {
		dc.setPenWidth(r);
        dc.setColor(0x000000,0x000000);
		dc.fillCircle(cx, cy, r+1);
        dc.setColor(0xFFFFFF,0x000000);
        if(degree != 0 || !clockwised) {
			dc.drawArc(cx, cy, r/2, clockwised?Graphics.ARC_CLOCKWISE:Graphics.ARC_COUNTER_CLOCKWISE, 90, 90-degree);
		} else {
			dc.setPenWidth(1);
			dc.drawLine(cx, cy, cx, cy-r);
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
