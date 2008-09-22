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

require File.join(File.expand_path(File.dirname(__FILE__)), "", "Cell")
require File.join(File.expand_path(File.dirname(__FILE__)), "", "State")
require File.join(File.expand_path(File.dirname(__FILE__)), "", "Transition")
require File.join(File.expand_path(File.dirname(__FILE__)), "", "Input")

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

end


#Test ourself if this is the current file and not an include
if __FILE__ == $0
	myca = CellularAutomata::Automaton.load('../dsl_0.rb')
	puts myca.inspect
	
	1.upto(5) { myca.grids[:PLAYER1][0][0].addSurround "P1" }
	1.upto(7) { myca.grids[:PLAYER1][0][0].addSurround "P2" }
	myca.grids[:PLAYER1][0][0].surround
	puts "\n " + myca.grids[:PLAYER1][0][0].inspect
	myca.grids[:PLAYER1][0][0].set(myca.states[0])
	puts "\n " + myca.grids[:PLAYER1][0][0].state.hexColor.to_s(16)
end