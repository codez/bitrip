// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function write_frame(content) {
	frame = parent.preview
	doc = frame.document;
	if(frame.contentDocument)
        doc = frame.contentDocument; // For NS6
    else if(frame.contentWindow)
        doc = frame.contentWindow.document; // For IE5.5 and IE6
	doc.open();
	doc.writeln(content);
	doc.close();
}

function submit_form(url, target) {
	form = document.forms[0];
	form.action = url;
	form.target = target;
	return form.submit();
}