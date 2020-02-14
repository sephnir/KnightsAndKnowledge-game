extends Button

var meta = -1;

func _on_Btn_Ans_button_up():
	find_parent("PU_Quiz").check_ans(self);
