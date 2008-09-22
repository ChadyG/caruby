## Cellular Automata Engine
## Chad Godsey
## Sept 3, 2008

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
	

end