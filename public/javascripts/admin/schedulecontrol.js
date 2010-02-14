/* requires prototype.js */

Event.observe(window, 'load', function() {
	ScheduleControl();
});

function  ScheduleControl(){
	
	if( $('page_status_id').value >= 90) { 
		$('published_at').show(); 
	} else { 
		$('published_at').hide();
	}
}