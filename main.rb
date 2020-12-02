# frozen_string_literal: true

require './score_card.rb'
require 'pry'

# defines how the player can interact on the CMI
class Instructions
  def initialize; end

  def self.display
    puts "\n ---- Instructions: when prompted to enter a command, please "\
    "enter one from the list below. '**' indicates you should follow the command "\
    'with the dice you want to select, using the corresponding indices (e.g '\
    "'hold 014'). When prompted to apply a score, enter corresponding number "\
    'from score card.'
    puts "\n---- Commands: "
    commands.each { |command| puts command }
  end

  def self.commands
    ['roll: rolls the dice in the left column',
     'roll all: rolls all dice regardless of location',
     'hold **: moves selected dice to the right column to be held',
     'remove **: moves the selected dice from held back into the left column',
     'score **: applies a score and ends the turn',
     'card: displays score card']
  end
end

# defines the players score
class Player < ScoreCard
  attr_accessor :score, :dice, :card
  def initialize(dice)
    @dice = dice
    @card = ScoreCard.new
    @score = card.score
  end

  def prompt_score
    puts "\nWhere would you like to apply a score?"
    input = gets.chomp
    if input == 'card'
      display_score
      puts "\nApply a score: "
      input = gets.chomp
    end
    input.to_i
  end

  def verify_selection(category)
    if send(category + '?')
      send(category)
    else
      puts "You do not have a #{category}. Do you want to take a zero? y/n"
      if gets.chomp == 'y'
        zero(category.to_sym)
      else
        puts 'Where do you want to apply a score?'
        apply_score(gets.chomp.to_i)
      end
    end
  end

  def apply_score(selection)
    if scored?(selection - 1)
      puts "You've already put a score there. Select again: "
      apply_score(gets.chomp.to_i)
    end

    if !(1..6).include?(selection) && !(9..16).include?(selection)
      puts 'Invalid selection. Select again: '
      apply_score(gets.chomp.to_i)
    end

    case selection
    when 1 then score[:ones] = ones
    when 2 then score[:twos] = twos
    when 3 then score[:threes] = threes
    when 4 then score[:fours] = fours
    when 5 then score[:fives] = fives
    when 6 then score[:sixes] = sixes

    when 9 then verify_selection('three_of_kind')
    when 10 then verify_selection('four_of_kind')
    when 11 then verify_selection('full_house')
    when 12 then verify_selection('sm_straight')
    when 13 then verify_selection('lg_straight')
    when 14 then verify_selection('yahtzee')
    when 15 then score[:chance] = chance
    end

    if selection == 16
      if bonus_yahtzee?
        bonus_yahtzee
      elsif yahtzee?
        puts 'You must score a yahtzee before claiming a bonus yahtzee. Select again: '
      else
        puts 'You do not have a yahtzee. Select again: '
        apply_score(gets.chomp.to_i)
      end
    end
    return unless upper_section_complete? || card_complete?

    if upper_section_complete?
      apply_upper_bonus
      apply_total_upper
    else
      apply_total_lower
      apply_grand_total
    end
  end

  def display_score
    i = 1
    puts "\n"
    score.each_pair do |key, value|
      print "[#{i}] " unless (7..8).include?(i) || (17..18).include?(i)
      puts "#{key} : #{value}"
      i += 1
    end
  end
end

# defines the dice
class Dice
  attr_accessor :rolls_remaining, :current_roll
  attr_reader :held

  def initialize
    @current_roll = []
    @held = []
    @rolls_remaining = 3
  end

  MAX_DICE = 5
  FACE_1 = '⚀'
  FACE_2 = '⚁'
  FACE_3 = '⚂'
  FACE_4 = '⚃'
  FACE_5 = '⚄'
  FACE_6 = '⚅'

  def roll
    if current_roll.empty? && held.length == MAX_DICE
      puts "\nYou have all the dice held. Apply a score or put a die back in play."
      return
    elsif current_roll.empty?
      MAX_DICE.times do
        result = rand(1..6)
        current_roll << result
      end
    else
      dice_remaining = current_roll.length
      current_roll.clear
      dice_remaining.times do
        result = rand(1..6)
        current_roll << result
      end
    end
    @rolls_remaining -= 1
  end

  def roll_all
    held.clear
    current_roll.clear
    roll
  end

  def hold(dice)
    dice.each { |num| held << current_roll[num] }
    dice.each { |num| current_roll[num] = nil }
    current_roll.compact!
  end

  def remove(dice)
    dice.each do |num|
      current_roll << held[num]
      held[num] = nil
    end
    held.compact!
  end

  def depict(dice)
    arr = []
    dice.each do |die|
      if die == 1
        arr << FACE_1
      elsif die == 2
        arr << FACE_2
      elsif die == 3
        arr << FACE_3
      elsif die == 4
        arr << FACE_4
      elsif die == 5
        arr << FACE_5
      elsif die == 6
        arr << FACE_6
      end
    end
    arr
  end

  def display
    puts "\n"
    current_roll.each_index { |index| print "#{index} " }
    print '     '
    held.each_index { |index| print "#{index} " }
    puts "\n#{format(depict(current_roll))}   |  #{format(depict(held))}\n"
  end

  def format(element)
    element.to_s.gsub(/[",\[\]]/, '"': '', ',': '', '[': '', ']': '')
  end
end

# defines the course of the game
class Game
  attr_reader :dice, :score_card, :player, :scored
  def initialize
    @dice = Dice.new
    @player = Player.new(dice)
    Instructions.display
    player.display_score
    until player.card_complete? do turn end
    player.display_score
    puts "\n*** Your final score is #{player.score[:grand_total]} ***"
  end

  def turn
    @scored = false
    dice.rolls_remaining = 3
    puts "\nNew turn. Rolling dice ..."
    dice.roll_all
    dice.display
    loop do
      puts "\nCommand: "
      command
      puts '*** YAHTZEE! ***' if player.yahtzee?

      break if dice.rolls_remaining.zero? ||
               scored == true
    end
    player.apply_score(player.prompt_score) if scored == false
  end

  def command
    invalid_command = "\nInvalid command. Commands are 'roll', "\
     "'roll all', 'hold **', 'remove **', 'card' or 'score **'."
    input_valid = true
    input = gets.chomp

    loop do
      if input == 'roll'
        dice.roll
      elsif input == 'roll all'
        dice.roll_all
      elsif input.include?('hold')
        begin
          dice.hold(verify_input('hold', format_input(input, 'hold')))
        rescue NoMethodError
          puts invalid_command and input_valid = false
        end
      elsif input.include?('remove')
        dice.remove(verify_input('remove', format_input(input, 'remove')))
      elsif input == 'card'
        player.display_score
      elsif input.include?('score')
        begin
          player.apply_score(input.delete_prefix!('score').strip!.to_i)
          @scored = true
        rescue NoMethodError
          puts invalid_command and input_valid = false
        end
      else
        puts invalid_command and input_valid = false
      end

      break dice.display if input_valid
    end
  end

  def verify_input(keyword, selection)
    range = dice.current_roll.length if keyword == 'hold'
    range = dice.held.length if keyword == 'remove'

    until selection.all?(0...range)
      puts 'Invalid selection. Reselect dice: '
      selection = gets.chomp.split('').map!(&:to_i)
    end
    selection
  end

  def format_input(command, prefix)
    command.delete_prefix!(prefix).strip!
    dice = command.split('').map!(&:to_i)
    dice
  end
end

game = Game.new
