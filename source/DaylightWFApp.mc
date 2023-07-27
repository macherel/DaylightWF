using Toybox.Application;
using Toybox.WatchUi;

class DaylightWFApp extends Application.AppBase {

	var view;

	function initialize() {
		AppBase.initialize();
		Settings.load();
	}

	// onStart() is called on application start up
	function onStart(state) {
	}

	// onStop() is called when your application is exiting
	function onStop(state) {
	}

	// Return the initial view of your application here
	function getInitialView() {
		view = new DaylightWFView();
		return [ view ];
	}

	// New app settings have been received so trigger a UI update
	function onSettingsChanged() {
		Settings.load();
		view.init();
		WatchUi.requestUpdate();
	}

}