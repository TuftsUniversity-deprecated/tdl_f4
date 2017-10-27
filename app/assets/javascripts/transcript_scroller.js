var TranscriptScroller = function(player) {

  var thePlayer = player;
  var currentlyHighlightedDiv = null;
  var lastSeconds = -1;

  return {
    scrollTranscript: function(seconds) {
      var seconds = Math.floor(seconds);  // round down to nearest second

      // Only proceed if the time is different than when this function was last called.
      // The player calls this method several times a second;  rounding the position to the nearest
      // second insures that this event is processed at most once per second.
      // Note that the comparison with lastSeconds is != instead of > because the player may have been
      // moved backwards either with the player's << button or in response to a click on an earlier timestamp
      // in the transcript.

      if (seconds != lastSeconds) {
        lastSeconds = seconds;

        var div = null;

        // Search backwards to find the first div that would contain the transcript at timepoint "seconds".
        while (div == null & seconds > -1) {
          div = document.getElementById("chunk" + seconds);
          seconds -= 1;
        }

        // Found the right div -- scroll to it and highlight it if it isn't already highlighted
        if (div != null && div != currentlyHighlightedDiv) {
          if (currentlyHighlightedDiv != null) {
            currentlyHighlightedDiv.style.backgroundColor = 'white';
          }

          currentlyHighlightedDiv = div;
          currentlyHighlightedDiv.style.backgroundColor = '#F1F7FF';
          currentlyHighlightedDiv.scrollIntoView(true);
        }
      }
    },

    jumpPlayerTo: function(seconds) {
      thePlayer.currentTime = seconds;
    }
  };
}
