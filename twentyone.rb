require 'pry'

SUITS = %w(clubs spades hearts diamonds)
FACES = (2..10).to_a + %w(jack queen king ace)
STANDARD_DECK = FACES.product SUITS
DEALER_LIMIT = 17
GAME_LIMIT = 21 # note I assumed 21 when writing add_aces method; would need modification if GAME_LIMIT is adjusted to any other value
GAME_NAME = "Twenty One"

def prompt(msg)
  puts "=> #{msg}"
end

def title
  system 'clear'
  puts GAME_NAME.center 40, '-'
end

def new_deck
  STANDARD_DECK.shuffle
end

def initial_deal(deck)
  player = []
  computer = []
  2.times do
    player << deck.pop
    computer << deck.pop
  end
  return player, computer
end

def show_player_turn(player_cards, computer_cards)
  title
  prompt "You have #{score player_cards} with:"
  show_all player_cards
  prompt 'Computer shows:'
  show_hidden computer_cards
end

def show_dealer_turn(player_cards, computer_cards)
  title
  prompt "You have #{score player_cards} with:"
  show_all player_cards
  prompt "Computer has #{score computer_cards} with:"
  show_all computer_cards
end

def show_all(cards)
  cards.each_with_index do |card, index|
    card_label(index + 1)
    show card
  end
end

def card_label(number)
  print "Card #{number}: "
end

def show_hidden(cards)
  card_label 1
  show cards[0]
  card_label 2
  show %w(? ?)
end

def show(card)
  puts "#{card[0]} of #{card[1]}"
end

def hit?
  prompt "Hit or stay? 'h' for hit and 's' for stay."
  answer = gets.chomp.downcase
  unless %w(h s).include?(answer)
    prompt 'Invalid. Try again.'
    answer = hit_or_stay
  end
  answer == 'h'
end

def stay?
  !hit?
end

def score(hand)
  summation = 0

  hand.each do |card|
    if ace? card
      # do nothing
    elsif (2..10).to_a.include? card[0]
      summation += card[0]
    else
      summation += 10
    end
  end

  add_aces summation, number_of_aces(hand)
end

def add_aces(summation, num_aces)
  if num_aces > 0
    if summation + 11 + num_aces - 1 > GAME_LIMIT
      summation += num_aces
    else
      summation += 11 + num_aces - 1
    end
  end
  summation
end

def number_of_aces(hand)
  hand.count { |card| ace?(card) }
end

def ace?(card)
  card.include? 'ace'
end

def twenty_one?(hand)
  score(hand) == GAME_LIMIT
end

def bust?(hand)
  score(hand) > GAME_LIMIT
end

def bust_or_21?(hand)
  bust?(hand) || twenty_one?(hand)
end

def deal_card(hand, deck)
  hand << deck.pop
end

def dealer_done?(hand)
  score(hand) >= DEALER_LIMIT
end

def play_again?
  3.times { prompt 'X' * 40 }
  prompt "Would you like to play again? 'y' for yes."
  answer = gets.chomp.downcase
  %(y yes).include? answer
end

def detect_result(player_cards, computer_cards)
  player_total = score player_cards
  computer_total = score computer_cards

  if player_total > GAME_LIMIT
    :player_busted
  elsif player_total == GAME_LIMIT
    :player_twenty_one
  elsif computer_total > GAME_LIMIT
    :computer_busted
  elsif player_total == computer_total
    :tie
  elsif player_total > computer_total
    :player_wins
  else
    :computer_wins
  end
end

def declare_winner(player, computer)
  show_dealer_turn player, computer
  case detect_result(player, computer)
  when :player_busted
    prompt "You busted with #{score player}."
  when :player_twenty_one
    prompt "Twenty One! You win!."
  when :computer_busted
    prompt "Computer busted with #{score computer}. You win!"
  when :tie
    prompt "Tie! #{score player} v. #{score computer}."
  when :player_wins
    prompt "You win! #{score player} v. Computer's #{score computer}."
  when :computer_wins
    prompt "You lose. #{score player} v. Computer's #{score computer}."
  end
end

# 1. Initialize deck
# 2. deal 2 cards
# 3. ask player hit/stay? check if broke or 21 else loop
# 4. if stay deal to dealer until score 17 or greater or bust
# 5. determine winner
# 6. ask player to play again

loop do
  deck = new_deck

  player, computer = initial_deal deck
  show_player_turn player, computer

  until bust_or_21?(player) || stay?
    deal_card(player, deck)
    show_player_turn player, computer
  end

  unless bust_or_21?(player)
    until dealer_done?(computer)
      deal_card(computer, deck)
      show_dealer_turn player, computer
    end
  end

  declare_winner player, computer

  break unless play_again?
end

system 'clear'
prompt "Thank you for playing #{GAME_NAME}."
prompt 'Have a great day!'
