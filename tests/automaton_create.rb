require 'rubygems'
require 'caruby'

#Try making a cellular automata and print out inspection data

myca = CellularAutomata::Automaton.load('dsl_0.rb')
puts myca.inspect
	
1.upto(5) { myca.grids[:PLAYER1][0][0].addSurround myca.states[0] }
1.upto(7) { myca.grids[:PLAYER1][0][0].addSurround myca.states[1] }
myca.grids[:PLAYER1][0][0].surround
puts "\n " + myca.grids[:PLAYER1][0][0].inspect
myca.grids[:PLAYER1][0][0].set(myca.states[0])
puts "\n " + myca.grids[:PLAYER1][0][0].state.hexColor.to_s(16)
	
puts "\n" + myca.transitions[0].inspect
