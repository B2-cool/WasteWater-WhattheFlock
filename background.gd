extends ParallaxBackground

enum bgTimes {DAY, NIGHT}
enum cityLevels {ONE, TWO, THREE}

@export var time = bgTimes.DAY

@export var city = cityLevels.ONE

@export var dayTexture : Texture2D
@export var nightTexture : Texture2D

@export var dayCity1 : Texture2D
@export var dayCity2 : Texture2D
@export var dayCity3 : Texture2D

@export var nightCity1 : Texture2D
@export var nightCity2 : Texture2D
@export var nightCity3 : Texture2D

@onready var bgTimesSprites = {
	bgTimes.DAY:dayTexture,
	bgTimes.NIGHT:nightTexture
	}

@onready var citySprites = {
	bgTimes.DAY:{
		cityLevels.ONE:dayCity1,
		cityLevels.TWO:dayCity2,
		cityLevels.THREE:dayCity3
	},
	bgTimes.NIGHT:{
		cityLevels.ONE:nightCity1,
		cityLevels.TWO:nightCity2,
		cityLevels.THREE:nightCity3
	},
}

func _ready():
	

	$BackgroundTexture.texture = bgTimesSprites[time]
	$"City Layer/TextureRect".texture = citySprites[time][city]
