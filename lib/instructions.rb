# frozen_string_literal: true

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
