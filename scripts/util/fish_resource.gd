extends Resource

class_name FishResource

@export var name : String #Choose Fishes Name
@export var image : Texture #Apply Fishes Image
@export var value : int = 1 #Change Fishes worth on catch
@export var weight : int = 1 #Change Fishes Weight
@export var correct_inputs : Array[String] = ["Left","Right","Up","Down"] #Change the input pattern for fish
@export var time : float #Change the countdown timer per Fish

var current_inputs : Array[String] #Resets Input array on minigame reset

func intialize():
	current_inputs = correct_inputs #Resets Input array on minigame reset
