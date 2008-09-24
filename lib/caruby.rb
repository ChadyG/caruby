## = caruby - Cellular Automata Engine
## == Author
## Chad Godsey
## Sept 3, 2008
## == License
## CARuby is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## CARuby is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
##
## == Usage documentation
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
## == TODO:
##	* friendly .each accessor to cells in a grid { |x,y| stuff }
##	* Transition lookup stuff
##
## == Revision history
##   9-3: creation
##   9-10:  DSL rebuild
##   9-15:  Grids, Cells
##   9-16: Input from strings, started Transitions
##   9-17: Transitions, StateManager, rdoc, Cell functionality
##   9-22: Transition lookup
=begin
require File.join(File.expand_path(File.dirname(__FILE__)), "", "Cell")
require File.join(File.expand_path(File.dirname(__FILE__)), "", "State")
require File.join(File.expand_path(File.dirname(__FILE__)), "", "Transition")
require File.join(File.expand_path(File.dirname(__FILE__)), "", "Input")
=end
require 'Cell'
require 'State'
require 'Transition'
require 'Input'

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
		
		## =DSL methods
		
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
			@grids[name] = Array.new(options[:width]) { |x| Array.new(options[:height]) { |y| y = Cell.new(name, options)}}
		end
		
		## Define a Transition
		## From defines the starting state.
		## string is a formula for reactant onto product.
		## GRID:STATE[-=+]amount [ + GRID:STATE[-=+]amount ] -> GRID:STATE[-=+]amount
		def transition(from, string)
			@transitions << Transition.new(from, string)
		end
		
		##
		## =Public Methods
		##
		
		## Tell if there exists a transition for given cell+input
		## Note, better to use NextState and test for false
		def NextState?(cell, input)
			trans = @transitions.select { |t| t.match(cell,input) }
			true if trans
			false
		end
		
		## Find next state for cell+input pair and return the last found
		## returns false when no transition is found
		def NextState(cell, input)
			trans = @transitions.select { |t| t.match(cell,input) }
			if trans.size > 1
			#	raise "Multiple transitions matched!"
			end
			return trans[-1] unless trans.empty?
			#will only occur with incomplete transition tables
			return false
		end
		
	end

end
