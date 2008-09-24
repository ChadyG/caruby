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
	## describe input and specify special attributes
	class Input
		#GRID:NAME[-=+]AMOUNT
		attr_reader :grid, :identifier, :amount, :relative
		
		## String is of the following form
		## GRID:NAME[-=+]AMOUNT
		## where GRID: and [-=+]amount are optional
		def initialize(string)
			@grid = /(.*):/.match(string)[1].to_sym if /(.*):/.match(string)
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
			ret = true
			ret &= @grid == other.grid if other.grid
			ret &= @identifier == other.identifier
			if other.relative == '='
				ret &= @amount == other.amount
			elsif other.relative == '-'
				ret &= @amount < other.amount
			elsif other.relative == '+'
				ret &= @amount >= other.amount
			end
			ret
		end
	end

end