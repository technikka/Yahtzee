# frozen_string_literal: true

# defines the score card
class ScoreCard
  attr_reader :dice, :score

  def initialize(dice)
    @dice = dice
    @score = { ones: nil, twos: nil, threes: nil, fours: nil, fives: nil,
               sixes: nil, upper_bonus: nil, upper_total: nil, three_of_kind: nil,
               four_of_kind: nil, full_house: nil, sm_straight: nil,
               lg_straight: nil, yahtzee: nil, chance: nil, bonus_yahtzee: nil,
               lower_total: nil, grand_total: nil }
  end

  def all_dice
    dice.current_roll + dice.held
  end

  def scored?(index)
    score_array = score.to_a
    !score_array[index][1].nil?
  end

  def card_complete?
    lower_section_complete? && upper_section_complete?
  end

  def zero(selection)
    score[selection] = 0
  end

  # upper section
  def ones
    1 * all_dice.count(1)
  end

  def twos
    2 * all_dice.count(2)
  end

  def threes
    3 * all_dice.count(3)
  end

  def fours
    4 * all_dice.count(4)
  end

  def fives
    5 * all_dice.count(5)
  end

  def sixes
    6 * all_dice.count(6)
  end

  def upper_section_complete?
    [score[:ones], score[:twos], score[:threes],
     score[:fours], score[:fives], score[:sixes]].all?
  end

  def bonus_upper_section?
    (score[:ones] + score[:twos] + score[:threes] +
      score[:fours] + score[:fives] + score[:sixes]) >= 63
  end

  def apply_upper_bonus
    if bonus_upper_section?
      score[:upper_bonus] = 35
    else
      score[:upper_bonus] = 0
    end
  end

  def total_upper
    score[:ones] + score[:twos] + score[:threes] +
      score[:fours] + score[:fives] + score[:sixes] +
      score[:upper_bonus]
  end

  def apply_total_upper
    score[:upper_total] = total_upper
  end

  # lower section
  def three_of_kind?
    !(all_dice.select { |num| all_dice.count(num) >= 3 }).empty?
  end

  def three_of_kind
    score[:three_of_kind] = all_dice.sum
  end

  def four_of_kind?
    !(all_dice.select { |num| all_dice.count(num) >= 4 }).empty?
  end

  def four_of_kind
    score[:four_of_kind] = all_dice.sum
  end

  def full_house?
    !(all_dice.select { |num| all_dice.count(num) == 3 }).empty? &&
      !(all_dice.select { |num| all_dice.count(num) == 2 }).empty?
  end

  def full_house
    score[:full_house] = 25
  end

  def sm_straight?
    sort_slice = all_dice.sort.uniq.slice_when { |i, num| i + 1 != num }
    !(sort_slice.to_a.select { |arr| arr.length >= 4 }).empty?
  end

  def sm_straight
    score[:sm_straight] = 30
  end

  def lg_straight?
    sort_slice = all_dice.sort.uniq.slice_when { |i, num| i + 1 != num }
    !(sort_slice.to_a.select { |arr| arr.length >= 5 }).empty?
  end

  def lg_straight
    score[:lg_straight] = 40
  end

  def yahtzee?
    all_dice.all?(all_dice[0])
  end

  def yahtzee
    score[:yahtzee] = 50
  end

  def chance
    score[:chance] = all_dice.sum
  end

  def bonus_yahtzee?
    yahtzee? && !score[:yahtzee].nil?
  end

  def bonus_yahtzee
    if score[:bonus_yahtzee].nil?
      score[:bonus_yahtzee] = 100
    else
      score[:bonus_yahtzee] += 100
    end
  end

  def lower_section_complete?
    [score[:three_of_kind], score[:four_of_kind], score[:full_house],
     score[:sm_straight], score[:lg_straight], score[:yahtzee],
     score[:chance]].all?
  end

  def total_lower
    score[:bonus_yahtzee] = 0 if score[:bonus_yahtzee].nil?
    score[:three_of_kind] + score[:four_of_kind] + score[:full_house] +
      score[:sm_straight] + score[:lg_straight] + score[:yahtzee] +
      score[:chance] + score[:bonus_yahtzee]
  end

  def apply_total_lower
    score[:lower_total] = total_lower
  end

  def grand_total
    score[:upper_total] + score[:lower_total]
  end

  def apply_grand_total
    score[:grand_total] = grand_total
  end
end
