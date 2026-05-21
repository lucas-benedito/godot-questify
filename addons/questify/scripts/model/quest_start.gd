class_name QuestStart extends QuestNode


@export var name: String
@export var description: String

## Stable identifier used by QuestManager and WorldState to track this quest.
@export var quest_id: String = ""
## NPC slug that gives this quest (e.g. "bram-aldric"). Empty = no giver NPC.
@export var quest_giver_id: String = ""
## NPC slug that receives quest completion (turn-in NPC). Empty = same as giver.
@export var quest_resolver_id: String = ""


var active: bool


func get_active() -> bool:
	return active


func get_completed() -> bool:
	return active


func serialize() -> Dictionary:
	var data := super()
	data.active = active
	return data


func deserialize(data: Dictionary) -> void:
	super(data)
	active = data.active
