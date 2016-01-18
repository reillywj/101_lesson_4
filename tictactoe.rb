require 'pry'

PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
WINNING_COMBOS = [(1..3).to_a, (4..6).to_a, (7..9).to_a, [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7], [1, 3, 7, 9]]
def prompt(msg)
  puts "=> #{msg}"
end

# rubocop:disable Metrics/AbcSize
def display_board(brd)
  system 'clear'
  puts "You're #{PLAYER_MARKER}. Computer is #{COMPUTER_MARKER}."
  space = ' '.center(5)
  blank_line = space + '|' + space + '|' + space + "\n"
  divider = '-' * 5 + '+' + '-' * 5 + '+' + '-' * 5 + "\n"
  new_line = blank_line + divider + blank_line
  puts blank_line
  puts display_marker_line brd.values_at(1, 2, 3)
  puts new_line
  puts display_marker_line brd.values_at(4, 5, 6)
  puts new_line
  puts display_marker_line brd.values_at(7, 8, 9)
  puts blank_line
end
# rubocop:enable Metrics/AbcSize

def display_marker_line(marked_line)
  marked_line[0].center(5) + '|' + marked_line[1].center(5) + '|' + marked_line[2].center(5)
end

def initialize_board
  new_board = {}
  (1..9).each { |number| new_board[number] = "[#{number}]" }
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

def computer_places_piece!(brd)
  square = empty_squares(brd).sample
  brd[square] = COMPUTER_MARKER
end

def empty_squares(brd)
  brd.keys.select { |num| ![PLAYER_MARKER, COMPUTER_MARKER].include?(brd[num]) }
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def markers_same?(brd, combo, marker)
  result = brd.values_at(*combo).count(marker) == combo.size
  # combo.each_index do |index|
  #   result = brd[combo[index]] == brd[combo[index + 1]] if (index < combo.size - 1) && result
  # end
  result && brd[combo[0]] == marker
end

def marker_won?(brd, marker)
  answer = false
  WINNING_COMBOS.each { |combo| answer ||= markers_same?(brd, combo, marker) }
  answer
end

# Run
loop do
  board = initialize_board
  loop do
    display_board board
    player_places_piece! board
    break if marker_won?(board, PLAYER_MARKER) || board_full?(board)
    computer_places_piece! board
    break if marker_won?(board, COMPUTER_MARKER) || board_full?(board)
  end

  display_board board

  if marker_won?(board, PLAYER_MARKER)
    prompt "YOU WON!"
  elsif marker_won? board, COMPUTER_MARKER
    prompt "You lost to the computer!"
  else
    prompt "Tie game."
  end
  prompt "Play again? (y or n)"
  answer = gets.chomp
  break unless %(y yes).include? answer.downcase
end

prompt 'Thank you for playing Tic-Tac-Toe!'
