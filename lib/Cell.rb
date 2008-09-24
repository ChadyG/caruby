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
	## Defines a Cell, each cell references a state
	class Cell
		attr_accessor :state, :grid
		
		def initialize(grid, options)
			@state = StateManager.add({:identifier => options[:initialState]})
			@grid = grid
			@reactants = []
		end
		
		## Add a State to the surrounding array for this Cell
		def addSurround(other)
			@reactants << other
			@surround = nil
		end
		
		## Return an array of strings representing the surrounding reactants of this Cell (build it if necessary)
		def surround
			unless @surround
				#grab unique reactants
				cells = @reactants
				#compute amounts
				cells = cells.map { |c| c.grid.to_s + ":" + c.state.identifier }
				states = cells.uniq
				amounts = states.map {|s| (cells.select { |c| c==s }).size }
				@surround = states.zip amounts
				@surround.map! { |i| i.join("=") }
				@surround.map! { |i| Input.new(i) }
			end
			@surround
		end
		
		## Update this Cell to a new State
		def set(state)
			@state = state
			@reactants = []
		end
	end

end