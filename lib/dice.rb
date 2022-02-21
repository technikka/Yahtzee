# frozen_string_literal: true

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
