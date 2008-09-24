## Cellular Automata Engine
## Copyright Chad Godsey
## Sept 3, 2008
##
## This file is part of CARuby.
##
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
## along with CARuby.  If not, see <http://www.gnu.org/licenses/>.

module CellularAutomata
	
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
		def match(cell, inputs)
			if cell.grid == @initialReactant.grid &&
				cell.state == @fromState && 
				(@inputs.reject { |x| inputs.include? x }).empty?
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
			@nextState[0]
		end
	end
	

end