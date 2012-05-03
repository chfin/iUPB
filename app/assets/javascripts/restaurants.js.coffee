@iUPB.Restaurant = {}

@iUPB.Restaurant.updateMenus = (date)->
	url = "/restaurants/index.json"
	if(date)
		url += "?date="+date.format("dd-mm-yyyy")
	$.xhrPool.abortAll() # we don't care about old pending requests when a new menu is requested
	$.retrieveJSON(url, (json, status) ->
		$("#menus").empty()
		got_any = false;
		$.each(json, ->
			got_any = true;
			menu = $(this)[0].menu
			item = $("<li>")
			item.append($("<h3>").text(menu.description))
			if(menu.name)
				item.append($("<p>").html("<strong>" + menu.name + "</strong>"))
			if(menu.type)
				item.append($("<p>").html("<i>" + menu.type + "</i>"))
			sd = $('<p id="side_dishes">')
			$.each(menu.side_dishes, (index, value) ->
				sd.html(sd.html() + "&#8226; " + value +  "<br/>")
				return
			)
			item.append(sd)
			if(menu.price)
				item.append($("<p>").text(menu.price))
			if(menu.counter)
				item.append($("<p>").text(menu.counter))
				
			$("#menus").append(item)
			return
		)
		$("#day_title").text(date.format("ddd, dd.mm."))
		if(!got_any)
			item = $("<li>")
			item.append($("<h3>").text("---"));
			$("#menus").append(item)
		
		$("#menus").listview('refresh')
		return
	)

@iUPB.Restaurant.loadNextDay = (today) ->
		day = new Date(today.getTime() + (24 * 60 * 60 * 1000));
		window.iUPB.Restaurant.updateMenus(day);
		return day

@iUPB.Restaurant.loadPrevDay = (today) ->
	day = new Date(today.getTime() - (24 * 60 * 60 * 1000));
	window.iUPB.Restaurant.updateMenus(day);
	return day