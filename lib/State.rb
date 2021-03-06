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

end