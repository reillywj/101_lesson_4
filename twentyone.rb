require 'pry'

SUITS = %w(clubs spades hearts diamonds)
FACES = (2..10).to_a + %w(jack queen king ace)
STANDARD_DECK = []
DEALER_LIMIT = 17
GAME_LIMIT = 21
GAME_NAME = "Twenty One"

SUITS.each do |suit|
  FACES.each do |face|
    STANDARD_DECK << [face, suit]
  end
end

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
  cards.each do |card|
    show card
  end
end

def show_hidden(cards)
  show cards[0]
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

  show_dealer_turn player, computer
  if bust? player
    prompt "You busted with #{score player}."
  elsif twenty_one? player
    prompt "Twenty One! You win!."
  elsif bust? computer
    prompt "Computer busted with #{score computer}. You win!"
  elsif score(player) == score(computer)
    prompt "Tie! #{score player} v. #{score computer}."
  elsif score(player) > score(computer)
    prompt "You win! #{score player} v. Computer's #{score computer}."
  else
    prompt "You lose. #{score player} v. Computer's #{score computer}."
  end

  break unless play_again?
end

system 'clear'
prompt "Thank you for playing #{GAME_NAME}."
prompt 'Have a great day!'
