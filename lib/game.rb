# frozen_string_literal: true

# defines the course of the game
class Game
  attr_reader :dice, :score_card, :player, :scored

  def initialize
    set_up
    # should be scorecard.complete?
    turn until player.card_complete?
    game_over
  end

  def set_up
    @dice = Dice.new
    @player = Player.new(dice)
    Instructions.display
    player.display_score
  end

  def turn
    reset_turn_vars
    roll_dice
    player_command
    return unless scored == false

    player.apply_score(player.prompt_score)
  end

  def reset_turn_vars
    @scored = false
    dice.rolls_remaining = 3
  end

  def roll_dice
    puts "\nNew turn. Rolling dice ..."
    dice.roll_all
    dice.display
  end

  def player_command
    loop do
      puts "\nCommand: "
      command
      puts '*** YAHTZEE! ***' if player.yahtzee?

      break if dice.rolls_remaining.zero? ||
               scored == true
    end
  end

  def command(input = gets.chomp)
    key = helpers.keys.select { |k| input.include?(k) }[0]
    if key
      helpers[key].call(input)
    else
      display_invalid_command
      command
    end
    dice.display
  end

  def helpers
    { 'roll all' => proc { dice.roll_all },
      'roll' => proc { dice.roll },
      'card' => proc { player.display_score },
      'hold' => proc { |input| hold_command(input) },
      'remove' => proc { |input| remove_command(input) },
      'score' => proc { |input| score_command(input) } }
  end

  def hold_command(input)
    dice.hold(verify_input('hold', format_input(input, 'hold')))
  rescue NoMethodError
    display_invalid_command
    command
  end

  def remove_command(input)
    dice.remove(verify_input('remove', format_input(input, 'remove')))
  end

  def score_command(input)
    player.apply_score(input.delete_prefix!('score').strip!.to_i)
    @scored = true
  rescue NoMethodError
    display_invalid_command
    command
  end

  def display_invalid_command
    puts "\nInvalid command. Commands are 'roll', "\
     "'roll all', 'hold **', 'remove **', 'card' or 'score **'."
  end

  def verify_input(keyword, selection)
    range = dice.current_roll.length if keyword == 'hold'
    range = dice.held.length if keyword == 'remove'

    # comparing length to guard against selection being a word being passed
    # in as [0,0,0] and if the player selects the same dice to be held
    # multiple times.
    until selection.all?(0...range) && selection.uniq.length == selection.length
      puts 'Invalid selection. Reselect dice: '
      selection = gets.chomp.split('').map!(&:to_i)
    end
    selection
  end

  def format_input(command, prefix)
    command.delete_prefix!(prefix).strip!
    command.split('').map!(&:to_i)
  end
end

def game_over
  player.display_score
  puts "\n*** Your final score is #{player.score[:grand_total]} ***"
end
