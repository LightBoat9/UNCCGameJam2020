extends PanelContainer

var text_log: Array = []

func add_log(text: String, wait:=false) -> void:
	if wait:
		owner.wait_enter = true
		
	text_log.append(text)
	update_label()
	
func update_label() -> void:
	var s = ""
	
	var from = max(0, text_log.size() - 5)
	
	for i in range(from, text_log.size()):
		s += "%s\n" % text_log[i]
	
	if owner.wait_enter:
		s += "<Enter>"
	
	$Label.text = s
