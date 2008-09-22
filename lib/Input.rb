## Cellular Automata Engine
## Chad Godsey
## Sept 3, 2008

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