##	CA DSL Test Implementation v0
## Chad Godsey
## Sept 10, 2008

Automaton.create :Prototype do

	state :INIT, :color => [0,0,0]
	state :EMPTY, :color => [0,0,0]
	state :FLESH, :color => [255,0,0]
	state :VIRUS1, :color => [0,250,0]
	state :VIRUS2, :color => [0,150,0]
	state :VIRUS3, :color => [0,50,0]
	state :DECAY, :color => [0,0,255]

	state :P1, :color => [255,0,255]
	state :P2, :color => [0,255,255]

	## Grids
	
	grid :PLAYER1, :width => 32, :height => 32
	grid :FIELD, :width => 32, :height => 32
	grid :PLAYER2, :width => 32, :height => 32

	## Transitions
	
	#Player one field
	transition "PLAYER1:VIRUS1", "PLAYER1:VIRUS2+3 -> PLAYER1:VIRUS2" 
	transition "PLAYER1:VIRUS1", "VIRUS2+3 -> VIRUS2"
	transition "PLAYER1:VIRUS2", "VIRUS3+3 -> VIRUS3"
	transition "PLAYER1:VIRUS3", "DECAY+3 -> DECAY"
	transition "PLAYER1:VIRUS3", "EMPTY+3 -> DECAY"
	transition "PLAYER1:DECAY", "EMPTY+3 -> EMPTY"
	transition "PLAYER1:EMPTY", "VIRUS1+3 -> VIRUS1"

	#Empty decay
	transition "PLAYER1:VIRUS2", "EMPTY+3 -> VIRUS3"
	transition "PLAYER1:VIRUS3", "EMPTY+3 -> DECAY"

	#Suffocation
	transition "PLAYER1:VIRUS1", "VIRUS1+6 -> VIRUS2"
	transition "PLAYER1:VIRUS2", "VIRUS2+6 -> VIRUS3"
	transition "PLAYER1:VIRUS3", "VIRUS3+6 -> DECAY"
	transition "PLAYER1:DECAY", "DECAY+6 -> EMPTY"


	#Player two field
	transition "PLAYER2:VIRUS1", "VIRUS2+3 -> VIRUS2"
	transition "PLAYER2:VIRUS2", "VIRUS3+3 -> VIRUS3"
	transition "PLAYER2:VIRUS3", "DECAY+3 -> DECAY"
	transition "PLAYER2:VIRUS3", "EMPTY+3 -> DECAY"
	transition "PLAYER2:DECAY", "EMPTY+3 -> EMPTY"
	transition "PLAYER2:EMPTY", "VIRUS1+3 -> VIRUS1"

	#Empty decay
	transition "PLAYER2:VIRUS2", "EMPTY+3 -> VIRUS3"
	transition "PLAYER2:VIRUS3", "EMPTY+3 -> DECAY"

	#Suffocation
	transition "PLAYER2:VIRUS1", "VIRUS1+6 -> VIRUS2"
	transition "PLAYER2:VIRUS2", "VIRUS2+6 -> VIRUS3"
	transition "PLAYER2:VIRUS3", "VIRUS3+6 -> DECAY"
	transition "PLAYER2:DECAY", "DECAY+6 -> EMPTY"


	#Playing field
	transition "FIELD:FLESH", "PLAYER1:DECAY -> P1"

	transition "FIELD:FLESH", "PLAYER2:DECAY -> P2"

	#Round it out
	transition "FIELD:P1", "P2+5 -> P2"
	transition "FIELD:P2", "P1+5 -> P1"
end