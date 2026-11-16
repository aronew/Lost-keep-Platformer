extends Interactable
## The handle of something Kleo can lift (a Carriable is its parent): using it
## picks the thing up.


func can_interact(kleo: Node) -> bool:
	return get_parent().call("can_lift", kleo)


func interact(kleo: Node) -> void:
	get_parent().call("lift", kleo)
