function scheduleControl(){
	if( $('page_status_id').value == 100) { 
		$('published_at').show(); 
	} else { 
		$('published_at').hide();
	}
}