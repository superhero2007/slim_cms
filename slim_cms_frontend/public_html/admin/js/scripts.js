function setPath(title,path) {
	var string = title.toLowerCase();
	string = string.replace(/[^a-z0-9\ ]/g,'');
	string = string.replace(/ +/g,'-');
	document.getElementById('path').value = string;
}
function addArticle(form) {
	var params
		= 'page=news&action=article_add'
		+ '&source_id='+escape(form.elements['source_id'].value)
		+ '&title='+escape(form.elements['title'].value)
		+ '&timestamp='+escape(form.elements['timestamp'].value)
		+ '&url='+escape(form.elements['url'].value)
		+ '&synopsis='+escape(form.elements['synopsis'].value)
		+ '&tweet='+(form.elements['tweet'].checked == true ? '1' : '0')
	var http = new XMLHttpRequest();
	http.open("POST", '/admin/index.php', true);
	http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	http.setRequestHeader("Connection", "close");
	http.onreadystatechange = function() {
		if(http.readyState == 4 && http.status == 200) {
			alert(http.responseText);
		}
	}
	http.send(params);
}