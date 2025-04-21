extends Node

signal start_drag
signal stop_drag
var can_drag: bool = true
var can_drop: bool = false

var item_being_dragged: InvSlot
var dragged_inv_origin
var dragged_slot_index
