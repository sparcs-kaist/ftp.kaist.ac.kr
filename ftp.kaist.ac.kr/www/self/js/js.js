jQuery(function($){

var activeItem = null;

function eventRef(e){
	return $('<a>').attr('href', e.href).append(
		$('<time>').attr('datetime', e.timestamp).text(e.timestamp)
	);
}

function updateStatus(){
	$.getJSON("/geoul/status.json", function(s){
		var pkgs = s.package;
		$('#contents a').each(function(){
			var pkg = pkgs[this.id];
			if(pkg == null) return;
			
			var $li = $(this).parent();
			var statDisp = $li.find('.status').html('');
			
			var $e;
			
			$li.removeClass();
			statDisp.append($('<h2>').text(pkg.name));
			
			// Links
			if(pkg.link != null){
				$e = $('<p class="links">');
				for(var i in pkg.link) $e.append(
					$("<a>").attr('href', pkg.link[i].href).text(pkg.link[i].rel)
				);
				statDisp.append($e);
			}
			
			// Mirroring
			if(pkg.sync != null && pkg.sync.source != null){
				$e = $("<p>").text("Mirroring from ").append($("<b>").text(pkg.sync.source));
				
				if(pkg.sync.frequency) $e.append($("<br>")).append("Updates every ").append($("<b>").text(
					prettyPeriod(pkg.sync.frequency).replace(/^(a|an) /, '')
				));
				
				statDisp.append($e);
			}else{
				statDisp.append($('<p>').text("Original Content"));
				$li.addClass('original');
			}
			
			// Status
			var st = pkg.status;
			if(st.updated){
				statDisp.append($('<p>').text("Last Updated ").append(eventRef(st.updated)));
				$li.addClass("updated");
			}
			if(st.failed){
				statDisp.append($('<p>').text("Failed ").append(
					$('<b>').text(st.failed.count==1?"a":st.failed.count)
				).append(" recent update"+(st.failed.count==1?"":"s")+", ").append(eventRef(st.failed)));
				$li.addClass("failed");
			}
			if(st.updating){
				statDisp.append($('<p>').text("Update in progress since ").append(eventRef(st.updating)));
				$li.addClass('updating');
			}
			
			// Feeds
			statDisp.append($('<p>').append($('<img src=".self/img/feed-icon-12x12.png" alt="News Feed of">')).append(
				$('<a>').attr('href', '/geoul/pkgs/'+this.id+'/news.feed').text('all updates')
			).append(", ").append(
				$('<a>').attr('href', '/geoul/pkgs/'+this.id+'/problems.feed').text('only problematic ones')
			));
			
			$li.data('img-loaded', false);
			$li.unbind('mouseenter').hover(function(){
				var $this = $(this);
				if(!$this.data('img-loaded')){
					var id = $this.find('a').attr('id');
					$this.data('img-loaded', true);
					$this.find('.status').append(
						$('<img alt="network usage">').attr('src', '/geoul/pkgs/'+id+'/usage.png')
					).append($('<br>')).append(
						$('<img alt="disk usage">').attr('src', '/geoul/pkgs/'+id+'/du.png')
					);
				}
			});
		});
		if(jQuery.fn.prettyDate) $('.status time').prettyDate();
	});
}

(function initStatus(){
	$('#contents a').each(function(){
		$(this.parentNode).append($('<div>').addClass('status'));
	});
	$('#contents li').click(function(){
		if(this == activeItem){
			$(this).removeClass('active');
			activeItem = null;
		}else{
			$(this).addClass('active');
			if(activeItem != null) $(activeItem).removeClass('active');
			activeItem = this;
		}
	});
	updateStatus();
	setInterval(updateStatus, 60*1000);
}());

});
