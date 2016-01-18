require 'pry'

PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
def prompt(msg)
  puts "=> #{msg}"
end

def display_board(brd)
  space = ' '.center(5)
  blank_line = space + '|' + space + '|' + space
  divider = '-' * 5 + '+' + '-' * 5 + '+' + '-'*5

  puts blank_line 
  puts display_marker_line [brd[1], brd[2], brd[3]]
  puts blank_line
  puts divider
  puts blank_line
  puts display_marker_line [brd[4], brd[5], brd[6]]
  puts blank_line
  puts divider
  puts blank_line
  puts display_marker_line [brd[7], brd[8], brd[9]]
  puts blank_line
end

def display_marker_line(marked_line)
  marked_line[0].center(5) + '|' + marked_line[1].center(5) + '|' + marked_line[2].center(5)
end

def initialize_board
  new_board = {}
  (1..9).each { |number| new_board[number] = "[#{number}]"}
  new_board
end

def player_places_piece!(brd)
  square = ''
  loop do
    prompt "Choose a square (1-9):"
    square = gets.chomp.to_i
    break if empty_squares(brd).include? square
    prompt 'Sorry, invalid choice.'
  end
  brd[square] = PLAYER_MARKER
end

def empty_squares(brd)
  brd.keys.select{|num| ![PLAYER_MARKER, COMPUTER_MARKER].include?(brd[num])}
end

board = initialize_board
display_board board

player_places_piece! board
display_board board

