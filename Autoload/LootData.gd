extends Node

const loot_file_path : String  = "res://Data/loot.json"

var tier_1 : Array = []
var tier_2 : Array = []
var tier_3 : Array = []
var tier_4 : Array = []


func _init():
	var loot_data : Dictionary = load_file_data(loot_file_path)
	for item in loot_data:
		for key in loot_data[item]:
			match key:
				"attribute":
					loot_data[item][key] = int(loot_data[item][key])
				"drop_type":
					pass # ignored, no parse needed
				"scene":
					loot_data[item][key] = load(loot_data[item][key])
				"texture":
					loot_data[item][key] = load(loot_data[item][key])
				"tier":
					loot_data[item][key] = int(loot_data[item][key])
				"type":
					loot_data[item][key] = int(loot_data[item][key])
				"value":
					loot_data[item][key] = float(loot_data[item][key])
		
		
		match loot_data[item]["tier"]:
			1:
				loot_data[item].erase("tier")
				tier_1.append(loot_data[item])
			2:
				loot_data[item].erase("tier")
				tier_2.append(loot_data[item])
			3:
				loot_data[item].erase("tier")
				tier_3.append(loot_data[item])
			4:
				loot_data[item].erase("tier")
				tier_4.append(loot_data[item])


func load_file_data(file_path : String) -> Dictionary:
	var data_file = File.new()
	data_file.open(file_path, File.READ)
	var data_JSON = JSON.parse(data_file.get_as_text())
	data_file.close()
	return data_JSON.result


var item : Dictionary = {
	"scene": 1,
	"type": 1
}


var upgrade : Dictionary = {
	"scene": 1,
	"type": 1
}


var auto : Dictionary = {
	"attribute": 1,
	"type": 1,
	"value": 1
}
