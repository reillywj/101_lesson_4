require 'pry'

PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
WINNING_COMBOS = [(1..3).to_a, (4..6).to_a, (7..9).to_a, [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7], [1, 3, 7, 9]]
WINNING_GAMES = 5
GAMEPLAY = "CHOOSE"

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
  best_moves = computer_best_moves brd
  threats = immediate_threats brd
  possible_squares = empty_squares brd
  square = if !best_moves.empty?
             best_moves.sample
           elsif !threats.empty?
             threats.sample
           elsif possible_squares.include? 5
             5
           else
             empty_squares(brd).sample
           end
  brd[square] = COMPUTER_MARKER
end

def empty_squares(brd)
  brd.keys.select { |num| ![PLAYER_MARKER, COMPUTER_MARKER].include?(brd[num]) }
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def markers_same?(brd, combo, marker)
  brd.values_at(*combo).count(marker) == combo.size && brd[combo[0]] == marker
end

def marker_won?(brd, marker)
  answer = false
  WINNING_COMBOS.each { |combo| answer ||= markers_same?(brd, combo, marker) }
  answer
end

def initialize_score
  { player: 0, computer: 0 }
end

def current_score(scr)
  "#{scr[:player]} to #{scr[:computer]}"
end

def immediate_threats(brd)
  # cycle through combos, if count is 2 and no computer marker, add space to threats
  threats = []
  WINNING_COMBOS.each do |combo|
    if brd.values_at(*combo).count(PLAYER_MARKER) == combo.size - 1 &&
       brd.values_at(*combo).count(COMPUTER_MARKER) == 0
      threats << brd.select { |key, marker| marker != PLAYER_MARKER && combo.include?(key) }.keys
    end
  end
  threats.flatten
end

def computer_best_moves(brd)
  best_moves = []
  WINNING_COMBOS.each do |combo|
    if brd.values_at(*combo).count(COMPUTER_MARKER) == combo.size - 1 &&
       brd.values_at(*combo).count(PLAYER_MARKER) == 0
      best_moves << brd.select { |key, marker| marker != COMPUTER_MARKER && combo.include?(key) }.keys
    end
  end
  best_moves.flatten
end

def ask_player_to_choose_first_player
  player_first = true
  prompt "Pick who goes first: 1 = Player and 2 = Computer"
  answer = gets.chomp
  if answer == '1'
    player_first = true
  elsif answer == '2'
    player_first = false
  else
    prompt "Invalid entry."
    player_first = ask_player_to_choose_first_player
  end
  player_first
end

def someone_won?(brd)
  marker_won?(brd, PLAYER_MARKER) || marker_won?(brd, COMPUTER_MARKER)
end

def gameover?(brd)
  someone_won?(brd) || board_full?(brd)
end

def display_board_and_score(brd, scr)
  display_board brd
  prompt current_score scr
end

# Run
loop do
  score = initialize_score
  loop do
    player_first = true
    if GAMEPLAY.downcase == 'choose'
      player_first = ask_player_to_choose_first_player
    end
    board = initialize_board

    loop do
      display_board_and_score board, score
      player_first ? player_places_piece!(board) : computer_places_piece!(board)
      break if gameover? board
      display_board_and_score board, score
      player_first ? computer_places_piece!(board) : player_places_piece!(board)
      break if gameover? board
    end

    display_board board

    if marker_won?(board, PLAYER_MARKER)
      prompt "YOU WON!"
      score[:player] += 1
    elsif marker_won? board, COMPUTER_MARKER
      prompt "You lost to the computer!"
      score[:computer] += 1
    else
      prompt "Tie game."
    end
    sleep 1
    prompt current_score score
    break if score.values.include? WINNING_GAMES
  end

  if score[:player] > score[:computer]
    prompt "You defeated the computer: #{current_score score}."
  else
    prompt "You lost to the computer: #{current_score score}."
  end

  prompt "Play again? (y or n)"
  answer = gets.chomp
  break unless %(y yes).include? answer.downcase
end
prompt 'Thank you for playing Tic-Tac-Toe!'
