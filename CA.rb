## Cellular Automata Engine
## Chad Godsey
## Sept 3, 2008
##
## Usage documentation
## Normally you will want to provide a .rb file describing an Automaton to build from
## Use the following format to do so
##
##	Automaton.create :NAME do
##		state :INIT, :color => [0,0,0]
##		state :S1, :color => [255,0,0]
##		state :S2, :color => [255,0,0]
##		grid :FIELD1, :width => 32, :height => 32
##		transition "FIELD1:INIT", " -> FIELD1:S1"
##		transition "FIELD1:S1", "FIELD1:S1+3 -> FIELD1:S1"
##	end
##
## This creates an automaton with two state, one grid, and two transitions
##
## TODO:
##	* output string of surrounding inputs for cells
##	* friendly .each accessor to cells in a grid { |x,y| stuff }
##	* Transition lookup stuff
##
## Revision history
##   9-3: creation
##   9-10:  DSL rebuild
##   9-15:  Grids, Cells
##   9-16: Input from strings, started Transitions
##   9-17: Transitions, StateManager, rdoc, Cell functionality

module CellularAutomata
	##
	## Holds general information and manages states
	class Automaton		
		attr_reader :grids, :states, :transitions
		
		## =Static Members
		class << self
			## Load a ruby file defining an Automaton
			## see CellularAutomata for file format
			def load(dsl)
				instance_eval(File.read(dsl), dsl)
			end
			
			## Create an Automaton using a block to define
			def create(name, &block)
				ca = Automaton.new
				ca.instance_eval(&block)
				ca
			end
		end
		
		## =Instance Members
		
		## Standard initialization
		def initialize
			@states = []
			@grids = {}
			@transitions = []
		end
		
		## = DSL methods
		
		## Build a state
		## name is the identifier, see State for options
		def state(name, options = nil)
			options.merge!( {:identifier => name.to_s} )
			@states << StateManager.add(options)
		end
		
		## Create a grid of cells to simulate with
		## Name gives the identifier
		## options as follows
		## * Width
		## * Height
		def grid(name, options = nil)
			@grids[name] = Array.new(options[:width]) { |x| Array.new(options[:height]) { |y| y = Cell.new(options)}}
		end
		
		## Define a Transition
		## From defines the starting state.
		## string is a formula for reactant onto product.
		## GRID:STATE[-=+]amount [ + GRID:STATE[-=+]amount ] -> GRID:STATE[-=+]amount
		def transition(from, string)
			@transitions << Transition.new(from, string)
		end
		
		##
		## = Public Methods
		##
		
		def NextState?(input = nil)
			true if @transitions[@current][input]
			false
		end
		
		def NextState(input = nil)
			n = @transitions[@current][input]
			return n unless n.nil?
			#will only occur with incomplete transition tables
			return false
		end
		
		def NextState!(input = nil)
			t = @transitions[@state][input]
			unless t.nil?
				t.action.call
				@state.exit
				@state = t.next
				@state.enter
			end
			#will only occur with incomplete transition tables
			return false
		end
	end

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
		
		## Build an array of Strings representing the surrounding reactants of this Cell
		## Will not generate field names, this is reserved for implementation specific code.
		def surround
			#build a string for reactants
			states = @reactants.uniq
			amounts = states.map {|s| (@reactants.select { |r| r==s }).size }
			@surround = states.zip amounts
			reagents = @surround.map {|s| s[0].to_s+"="+s[1].to_s}
		end
		
		## Reset reactants array
		def reset
			@reactants = []
		end
		
		## Update this Cell to a new State
		def set(state)
			@state = state
			@reactants = []
		end
	end
	
	##
	## Provide singleton access to a set of States
	class StateManager
		
		class << self
			@@states = []
		
			## Attempt to add a State
			## Does not add if one already exists.  If one exists, attempt to refine its data,
			## Returns new State, or current one.
			def add(options)
				s = State.new(options)
				old = @@states.index(s)
				unless old
					@@states << s 
					return s
				end
				@@states[old].refine!(options)
			end
		
			## Check to see if State already exists
			def include?(state)
				@@states.include?(state)
			end
		
		end
	end
	
	##
	## holds information on a single state
	class State
		attr_reader :identifier
		attr_accessor :color
		
		## Create a new State based on given parameters
		## * identifier => name of state
		## * color => color to draw as
		def initialize(options)
			@identifier, @color =  options[:identifier], options[:color]
		end
		
		## Begin accessors
		
		## Assignment
		## assigns identifier and color of other State to current
		## returns self
		def self=(other)
			@identifier, @color = other.identifier, other.color
			self
		end
		
		## Equality
		## if the identifers are the same, then the states are equal
		def ==(other)
			@identifier == other.identifier
		end
		
		## Attempt to redefine state
		## will only override current color using options
		def refine!(options)
			@color = options[:color] if options[:color]
			self
		end
		
		##Gives a hexidecimal value for color property
		def hexColor
			if @color
				return ("0xFF"+@color[0].to_s(16).ljust(2,'0')+@color[1].to_s(16).ljust(2,'0')+@color[2].to_s(16).ljust(2,'0')).to_i(16)
			end
			0xFF000000
		end
		
		## Begin Automaton calls
		
		
		def enter
			@enter.call if @enter
		end
		
		def exit
			@exit.call if @exit
		end
	end
	
	##
	## Holds Transitions in a table
	class TransitionTable
		#TODO: optimise transitions later
	end
	
	
	##
	## maps state+input -> state
	class Transition
		attr_reader :inputs
		
		## Create a Transition
		## from defines the starting State
		## string is a formula for reactant onto product
		## GRID:STATE[-=+]amount [ + GRID:STATE[-=+]amount ] -> GRID:STATE[-=+]amount
		def initialize(from, string)
			tokens = string.split
			map = tokens.index('->')
			ins = tokens.values_at(0...map).delete_if {|x| x == '+'}
			outs = tokens.values_at((map+1)..-1)
			@inputs = ins.collect { |x| Input.new(x) }
			@output = outs.collect { |x| Input.new(x) }
			@action
			@nextState = @output.collect { |x| StateManager.add({:identifier => x.identifier}) }
			@initialReactant = Input.new(from)
			@fromState = StateManager.add( {:identifier => @initialReactant.identifier} )
		end
		
		## Determine if given State and Inputs match this Transition
		def match(state, inputs)
			if state == @fromState && (@inputs.delete_if { |x| inputs.include x }).empty?
				return true
			end
			false
		end
		
		
		def action
			@action.call if @action
		end
		
		## = Virtual accessors
		
		## Return the starting State
		def from
			@fromState
		end
		
		## Return the end State
		def to
			@toState
		end
	end
	
	##
	## describe input and specify special attributes
	class Input
		#GRID:NAME[-=+]AMOUNT
		attr_reader :grid, :identifier, :amount, :relative
		
		## String is of the following form
		## GRID:NAME[-=+]AMOUNT
		## where GRID: and [-=+]amount are optional
		def initialize(string)
			@grid = /(.*):/.match(string)[1] if /(.*):/.match(string)
			if @grid
				@identifier = /:([^-=+]*)/.match(string)[1] if /:([^-=+]*)/.match(string)
			else
				@identifier = /([^-=+]*)/.match(string)[1] if /([^-=+]*)/.match(string)
			end
			@amount = /[-=+](.*)/.match(string)[1] if /[-=+](.*)/.match(string)
			@relative = /([-=+])/.match(string)[1] if /([-=+])/.match(string)
		end
		
		## Test for equality
		## GRID adjective determines if an input is specific to one grid, 
		## so if the current does not have this modifier it can be equal to an input in any grid.
		def ==(other)
			if @grid
				@identifier == other.identifier && @relative == other.relative && @amount == other.amount
			else
				@identifier == other.identifier && @relative == other.relative && @amount == other.amount
			end
		end
	end

end


#Test ourself if this is the current file and not an include
if __FILE__ == $0
	myca = CellularAutomata::Automaton.load('dsl_0.rb')
	#puts myca.inspect
	
	1.upto(5) { myca.grids[:PLAYER1][0][0].addSurround "P1" }
	1.upto(7) { myca.grids[:PLAYER1][0][0].addSurround "P2" }
	myca.grids[:PLAYER1][0][0].surround
	puts "\n " + myca.grids[:PLAYER1][0][0].surround.join(" + ")
	puts "\n " + myca.grids[:PLAYER1][0][0].inspect
	myca.grids[:PLAYER1][0][0].set(myca.states[0])
	puts "\n " + myca.grids[:PLAYER1][0][0].state.hexColor.to_s(16)
end