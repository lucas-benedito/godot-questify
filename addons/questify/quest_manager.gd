extends Node


signal condition_query_requested(type: String, key: String, value: Variant, requester: QuestCondition)
signal quest_available(quest: QuestResource)
signal quest_started(quest: QuestResource)
signal quest_objective_added(quest: QuestResource, objective: QuestObjective)
signal quest_objective_completed(quest: QuestResource, objective: QuestObjective)
signal quest_completed(quest: QuestResource)
signal quest_failed(quest: QuestResource)


var _quests: Array[QuestResource] = []
var _quest_update_timer: Timer


func _ready() -> void:
	if QuestifySettings.polling_enabled:
		_add_timer()
		_quest_update_timer.timeout.connect(update_quests)


func start_quest(quest_resource: QuestResource, params: Dictionary = {}) -> void:
	add_quest(quest_resource)
	quest_resource.start(params)


func update_quests():
	for quest in _quests:
		quest.update()


func clear() -> void:
	_quests.clear()


func get_quests() -> Array[QuestResource]:
	return _quests


func get_active_quests() -> Array[QuestResource]:
	var result: Array[QuestResource] = []
	result.assign(_quests.filter(
		func(quest: QuestResource):
			return quest.started and not quest.completed
	))
	return result


func get_completed_quests() -> Array[QuestResource]:
	var result: Array[QuestResource] = []
	result.assign(_quests.filter(
		func(quest: QuestResource):
			return quest.completed
	))
	return result


func get_available_quests() -> Array[QuestResource]:
	var result: Array[QuestResource] = []
	result.assign(_quests.filter(
		func(quest: QuestResource):
			return quest.availability == QuestResource.Availability.AVAILABLE and not quest.started
	))
	return result


func get_locked_quests() -> Array[QuestResource]:
	var result: Array[QuestResource] = []
	result.assign(_quests.filter(
		func(quest: QuestResource):
			return quest.availability == QuestResource.Availability.LOCKED
	))
	return result


func get_failed_quests() -> Array[QuestResource]:
	var result: Array[QuestResource] = []
	result.assign(_quests.filter(
		func(quest: QuestResource):
			return quest.failed
	))
	return result


## Look up a tracked quest by its quest_id string.
func get_quest_by_id(quest_id: String) -> QuestResource:
	for quest in _quests:
		if quest.quest_id == quest_id:
			return quest
	return null


## Mark a quest as available (LOCKED → AVAILABLE). Emits quest_available.
func unlock_quest(quest_id: String) -> void:
	var quest := get_quest_by_id(quest_id)
	if quest:
		quest.make_available()


## Mark a quest as failed. Emits quest_failed.
func fail_quest(quest_id: String) -> void:
	var quest := get_quest_by_id(quest_id)
	if quest:
		quest.fail_quest()


## Add quest to the list without starting it.
func add_quest(quest_resource: QuestResource) -> void:
	_quests.append(quest_resource)


func set_quests(quests: Array[QuestResource]) -> void:
	clear()
	_quests.assign(quests)


func serialize() -> Array:
	var result := []
	for quest in _quests:
		result.append({
			path = quest.get_resource_path(),
			data = quest.serialize(),
		})
	return result


func deserialize(data: Array) -> void:
	clear()
	for serialized_quest in data:
		var quest := load(serialized_quest.path) as QuestResource
		var instance := quest.instantiate()
		instance.deserialize(serialized_quest.data)
		_quests.append(instance)


func toggle_update_polling(value: bool) -> void:
	if QuestifySettings.polling_enabled:
		_quest_update_timer.paused = not value


func _add_timer() -> void:
	_quest_update_timer = Timer.new()
	_quest_update_timer.autostart = true
	_quest_update_timer.wait_time = QuestifySettings.polling_interval
	add_child(_quest_update_timer)
