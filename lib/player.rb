# frozen_string_literal: true

# defines the players score
class Player < ScoreCard
  attr_accessor :score, :dice, :card

  def initialize(dice)
    @dice = dice
    @card = ScoreCard.new(dice)
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
