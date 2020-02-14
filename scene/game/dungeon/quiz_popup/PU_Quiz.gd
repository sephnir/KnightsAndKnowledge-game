extends Popup

onready var global = $"/root/Global";
onready var ans_btn = [$Pnl_Bg/Btn_Ans, $Pnl_Bg/Btn_Ans2, 
	$Pnl_Bg/Btn_Ans3, $Pnl_Bg/Btn_Ans4];

var question_id = -1;
var controls = [];
var enemy = null;

var correct_ind = -1;

func activate(enemy, controls):
	self.controls = controls;
	self.enemy = enemy;
	
	for item in controls:
		item.disabled = true;
		
	var question_size = global.topics[enemy.topic].questions.size();
	var question_pick = randi() % question_size; 
	var question = global.topics[enemy.topic].questions[question_pick];
	question_id = question.id;
	setup_qns(question);
	
	popup_centered();
	
func setup_qns(qns):
	$Pnl_Bg/Pnl_Qns/Lbl_Qns.text = qns.question;
	ans_btn.shuffle();
	for i in range(4):
		ans_btn[i].text = qns.answers[i].answer;
		ans_btn[i].meta = qns.answers[i].id;
		if(qns.answers[i].correct):
			correct_ind = qns.answers[i].id;
	
func check_ans(btn):
	if(btn.meta == correct_ind):
		correct();
	else:
		wrong(btn);

func correct():
	for item in controls:
		item.disabled = false;
	for item in ans_btn:
		item.disabled = false;
	visible = false;
	enemy.queue_free();
	
func wrong(btn):
	btn.disabled = true;
