## Cellular Automata Engine
## Chad Godsey
## Sept 3, 2008

module CellularAutomata
	##
	## Defines a Cell, each cell references a state
	class Cell
		attr_accessor :state
		
		def initialize(options)
			@state = StateManager.add({:identifier => options[:initialState]})
			@reactants = []
		end
		
		## Add a State to the surrounding array for this Cell
		def addSurround(other)
			@reactants << other
		end
		
		## Build a String representing the surrounding reactants of this Cell
		def surround
			#build a string for reactants
			states = @reactants.uniq
			amounts = states.map {|s| (@reactants.select { |r| r==s }).size }
			@surround = states.zip amounts
			
			#return something for now
			"PLAYER1:VIRUS1"
		end
		
		## Update this Cell to a new State
		def set(state)
			@state = state
			@reactants = []
		end
	end

end