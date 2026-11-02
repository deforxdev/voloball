class_name MenuCopy










const SUB: = {

	"online": "play matches worldwide", 
	"local": "play matches locally", 
	"practice": "freeplay, tutorials, guides", 
	"controllers": "config devices & local coop", 
	"settings": "controls, video, audio", 


	"quick_match": "find any online match available", 
	"server_browser": "online servers with custom rules", 
	"custom_lobby": "host your own lobby with custom rules", 
	"direct_join": "connect by ip address", 


	"custom_match": "pick the rules, sets and stage", 

	"local_standard": "play on this computer", 
	"host_lan": "host a lobby for players on your network", 
	"join_lan": "join a lan lobby by address", 


	"freeplay": "practice in the open court", 
	"how_to_play": "volleyball & game rules", 


	"find_match": "queue up", 


	"crowd_noise": "the arena reacts to the rally", 
	"player_voices": "grunts and callouts", 


	"sprint_toggle": "on: tap sprint to keep running. off: hold it down", 
	"sprint_double_tap": "on: double tap a movement key to sprint. off: only the sprint key does", 
	"invert_cam_y": "action camera: push up to look down", 
	"invert_cam_x": "action camera: push right to look left", 
	"aim_assist": "keeps your cursor close to the court and auto aims on attacks", 
	"set_assist": "your sets always land in the hitting spot by the net. your aim only picks left or right", 
	"camera_shake": "impacts rattle the view", 
	"camera_fov_fx": "the view widens when you sprint", 
	"last_touch": "reveal who touched the ball last with an outline", 
	"reach_marker": "shows when a ball is grabbable", 
	"control_hints": "the button prompts in the corner of your screen", 
	"in_game_chat": "show the chat panel", 
	"chat_filter": "censor inappropriate chat content", 
	"pad_when_unfocused": "your controller keeps working when another window is in front", 
	"fade_scoreboard": "fade the scoreboard out while the ball is in play", 
	"chat_bubbles": "speech bubbles over heads in freeplay", 
	"own_name": "display your own username during gameplay", 
	"rally_names": "hide every player's username while the ball is in play", 
	"rally_titles": "hide every player's title while the ball is in play", 
	"hardware_cursor": "aim with the real pointer at its own speed; mouse sensitivity only applies to the in-game cursor", 
	"save_replays": "writes a file after each match", 


	"vsync": "off uncaps the frame rate, may tear", 
	"reflections": "the mirrored court floor", 
	"hair_physics": "hair and accessories swing as you move. off saves some performance", 
	"show_fps": "frame rate readout", 
}


static func sub(key: String) -> String:
	return String(SUB.get(key, ""))
