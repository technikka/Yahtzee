# frozen_string_literal: true

require './spec/spec_helper'

describe 'ScoreCard' do
  let(:dice) { instance_double('Dice') }
  let(:scorecard) { ScoreCard.new(dice) }

  describe '#all_dice' do
    it 'returns all 5 dice' do
      allow(dice).to receive(:current_roll).and_return([3, 1, 2])
      allow(dice).to receive(:held).and_return([6, 6])

      expect(scorecard.all_dice).to eq([3, 1, 2, 6, 6])
    end
  end

  describe '#scored?' do
    before { scorecard.instance_variable_set(:@score, { ones: 4, twos: 6, threes: 9, fours: nil }) }

    it 'returns true if player has already scored in specified row' do
      expect(scorecard.scored?(1)).to be(true)
    end

    it 'returns false if the category is open to scoring' do
      expect(scorecard.scored?(3)).to be(false)
    end
  end

  describe '#card_complete?' do
    it 'returns true if every category has been scored' do
      allow(scorecard).to receive(:lower_section_complete?).and_return(true)
      allow(scorecard).to receive(:upper_section_complete?).and_return(true)

      expect(scorecard.card_complete?).to be(true)
    end
  end

  describe '#zero' do
    it 'scores 0 points in specified category' do
      expect { scorecard.zero(:yahtzee) }.to change { scorecard.score[:yahtzee] }.to(0)
    end
  end

  describe '#ones' do
    it 'scores 1 point for each die displaying a one' do
      allow(scorecard).to receive(:all_dice).and_return([1, 1, 3, 1, 5])

      expect(scorecard.ones).to eq(3)
    end
  end

  describe '#ones' do
    it 'scores 1 point for each die displaying a one' do
      allow(scorecard).to receive(:all_dice).and_return([1, 1, 3, 1, 5])

      expect(scorecard.ones).to eq(3)
    end
  end

  describe '#twos' do
    it 'scores 2 points for each die displaying a two' do
      allow(scorecard).to receive(:all_dice).and_return([2, 1, 2, 1, 5])

      expect(scorecard.twos).to eq(4)
    end
  end

  describe '#threes' do
    it 'scores 3 points for each die displaying a three' do
      allow(scorecard).to receive(:all_dice).and_return([1, 3, 3, 1, 3])

      expect(scorecard.threes).to eq(9)
    end
  end

  describe '#fours' do
    it 'scores 4 points for each die displaying a four' do
      allow(scorecard).to receive(:all_dice).and_return([1, 4, 3, 1, 4])

      expect(scorecard.fours).to eq(8)
    end
  end

  describe '#fives' do
    it 'scores 5 points for each die displaying a five' do
      allow(scorecard).to receive(:all_dice).and_return([5, 5, 5, 1, 5])

      expect(scorecard.fives).to eq(20)
    end
  end

  describe '#sixes' do
    it 'scores 6 points for each die displaying a six' do
      allow(scorecard).to receive(:all_dice).and_return([6, 6, 5, 1, 5])

      expect(scorecard.sixes).to eq(12)
    end
  end

  describe '#upper_section_complete?' do
    before { scorecard.instance_variable_set(:@score, { ones: 4, twos: 6, threes: 9, fours: 8, fives: 20, sixes: 18 }) }

    it 'returns true if the upper section has all been scored' do
      expect(scorecard.upper_section_complete?).to be(true)
    end
  end

  describe '#bonus_upper_section?' do
    before { scorecard.instance_variable_set(:@score, { ones: 4, twos: 6, threes: 9, fours: 12, fives: 20, sixes: 18 }) }

    it 'returns true if the total points in the upper section is >= 63' do
      expect(scorecard.bonus_upper_section?).to be(true)
    end
  end

  describe '#apply_upper_bonus' do
    context 'when player has earned the upper bonus' do
      it 'scores 35 points on the scorecard' do
        allow(scorecard).to receive(:bonus_upper_section?).and_return(true)

        expect { scorecard.apply_upper_bonus }.to change { scorecard.score[:upper_bonus] }.to(35)
      end
    end
    context 'when player has not earned the upper bonus' do
      it 'scores a 0 in the upper bonus category on scorecard' do
        allow(scorecard).to receive(:bonus_upper_section?).and_return(false)

        expect { scorecard.apply_upper_bonus }.to change { scorecard.score[:upper_bonus] }.to(0)
      end
    end
  end

  describe '#total_upper' do
    before { scorecard.instance_variable_set(:@score, { ones: 4, twos: 6, threes: 9, fours: 12, fives: 20, sixes: 18, upper_bonus: 0 }) }

    it 'returns the total points scored in the upper section' do
      expect(scorecard.total_upper).to eq(69)
    end
  end

  describe '#apply_total_upper' do
    it 'inserts the total upper score on the scorecard' do
      allow(scorecard).to receive(:total_upper).and_return(62)

      expect { scorecard.apply_total_upper }.to change { scorecard.score[:upper_total] }.to(62)
    end
  end

  describe '#three_of_kind?' do
    it 'returns true if dice include 3 of the same type' do
      allow(scorecard).to receive(:all_dice).and_return([6, 6, 6, 3, 2])

      expect(scorecard.three_of_kind?).to be(true)
    end
  end

  describe '#three_of_kind' do
    it 'scores the total of all dice in the three of a kind category' do
      allow(scorecard).to receive(:all_dice).and_return([6, 6, 6, 3, 2])

      expect { scorecard.three_of_kind }.to change { scorecard.score[:three_of_kind] }.to(23)
    end
  end

  describe '#four_of_kind?' do
    it 'returns true if dice include 4 of the same type' do
      allow(scorecard).to receive(:all_dice).and_return([6, 6, 6, 6, 4])

      expect(scorecard.four_of_kind?).to be(true)
    end
  end

  describe '#four_of_kind' do
    it 'scores the total of all dice in the four of a kind category' do
      allow(scorecard).to receive(:all_dice).and_return([6, 6, 6, 6, 4])

      expect { scorecard.four_of_kind }.to change { scorecard.score[:four_of_kind] }.to(28)
    end
  end

  describe '#full_house?' do
    it 'returns true if player has 3 of same type and 2 of another same type' do
      allow(scorecard).to receive(:all_dice).and_return([6, 6, 6, 3, 3])

      expect(scorecard.full_house?).to be(true)
    end
  end

  describe '#full_house' do
    it 'scores 25 points in the full house category' do
      expect { scorecard.full_house }.to change { scorecard.score[:full_house] }.to(25)
    end
  end

  describe '#sm_straight?' do
    it 'returns true if the dice include 4 consequtive numbers' do
      allow(scorecard).to receive(:all_dice).and_return([2, 2, 3, 4, 5])

      expect(scorecard.sm_straight?).to be(true)
    end
  end

  describe '#sm_straight' do
    it 'scores 30 points in the small straight category' do
      expect { scorecard.sm_straight }.to change { scorecard.score[:sm_straight] }.to(30)
    end
  end

  describe '#lg_straight?' do
    it 'returns true if the dice display all consecutive numbers' do
      allow(scorecard).to receive(:all_dice).and_return([6, 2, 3, 4, 5])

      expect(scorecard.lg_straight?).to be(true)
    end
  end

  describe '#lg_straight' do
    it 'scores 40 points in the large straight category' do
      expect { scorecard.lg_straight }.to change { scorecard.score[:lg_straight] }.to(40)
    end
  end

  describe '#yahtzee?' do
    it 'returns true if all the dice are of the same type' do
      allow(scorecard).to receive(:all_dice).and_return([4, 4, 4, 4, 4])

      expect(scorecard.yahtzee?).to be(true)
    end
  end

  describe '#yahtzee' do
    it 'scores 50 points in the yahtzee category' do
      expect { scorecard.yahtzee }.to change { scorecard.score[:yahtzee] }.to(50)
    end
  end

  describe '#chance' do
    it 'inserts the total of all the dice in the chance category' do
      allow(scorecard).to receive(:all_dice).and_return([6, 2, 3, 4, 5])

      expect { scorecard.chance }.to change { scorecard.score[:chance] }.to(20)
    end
  end

  describe '#bonus_yahtzee?' do
    before { scorecard.instance_variable_set(:@score, { yahtzee: 50 }) }
    it 'returns true if a yahtzee has been rolled and player has' \
        'already scored in the yahtzee category' do
      allow(scorecard).to receive(:yahtzee?).and_return(true)

      expect(scorecard.bonus_yahtzee?).to be(true)
    end
  end

  describe '#bonus_yahtzee' do
    context 'when it is the first bonus yahtzee' do
      it 'scores 100 points in the bonus yahtzee category' do
        expect { scorecard.bonus_yahtzee }.to change { scorecard.score[:bonus_yahtzee] }.to(100)
      end
    end

    context 'when there is already a score in the bonus yahtzee category' do
      before { scorecard.instance_variable_set(:@score, { bonus_yahtzee: 100 }) }
      it 'adds an additional 100 points' do
        expect { scorecard.bonus_yahtzee }.to change { scorecard.score[:bonus_yahtzee] }.to(200)
      end
    end
  end

  describe '#lower_section_complete?' do
    before { scorecard.instance_variable_set(:@score, { three_of_kind: 20, four_of_kind: 26, full_house: 25, sm_straight: 30, lg_straight: 40, yahtzee: 0, chance: 12 }) }
    it 'returns true if there is a score in every category of the lower section' do
      expect(scorecard.lower_section_complete?).to be(true)
    end
  end

  describe '#total_lower' do
    before { scorecard.instance_variable_set(:@score, { three_of_kind: 20, four_of_kind: 26, full_house: 25, sm_straight: 30, lg_straight: 40, yahtzee: 0, chance: 12, bonus_yahtzee: nil }) }
    it 'changes bonus yahtzee score to 0 if nil' do
      expect { scorecard.total_lower }.to change { scorecard.score[:bonus_yahtzee] }.to(0)
    end

    it 'totals all the scores in the lower section' do
      expect(scorecard.total_lower).to eq(153)
    end
  end

  describe '#apply_total_lower' do
    it 'inserts the lower total into that row on the score card' do
      allow(scorecard).to receive(:total_lower).and_return(180)

      expect { scorecard.apply_total_lower }.to change { scorecard.score[:lower_total] }.to(180)
    end
  end

  describe '#grand_total' do
    before { scorecard.instance_variable_set(:@score, { lower_total: 200, upper_total: 100 }) }
    it 'returns the total of upper and lower sections' do
      expect(scorecard.grand_total).to eq(300)
    end
  end

  describe '#apply_grand_total' do
    it 'inserts the grand total into the scorecard' do
      allow(scorecard).to receive(:grand_total).and_return(400)

      expect { scorecard.apply_grand_total }.to change { scorecard.score[:grand_total] }.to(400)
    end
  end
end
