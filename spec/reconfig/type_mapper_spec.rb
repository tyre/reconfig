require 'spec_helper'

describe Reconfig::TypeMapper do
  subject do
    Reconfig::TypeMapper.new
  end

  describe '#stored_type' do
    it 'returns 1.0 for a string' do
      subject.stored_type('Aquarius').should eq '1.0'
    end

    it 'returns 2.0 for a fixnum' do
      subject.stored_type(4815162342).should eq '2.0'
    end

    it 'returns 2.0 for a bignum' do
      subject.stored_type(983209180398120983012).should eq '2.0'
    end

    it 'returns 3.0 for a float' do
      subject.stored_type(7.0).should eq '3.0'
    end

    it 'returns 4.0 for a hash' do
      subject.stored_type(walrus: 'bubbles').should eq '4.0'
    end

    it 'returns 5.0 for an array' do
      subject.stored_type(['The Plague', 'The Fall', 'The Stranger']).should eq '5.0'
    end

    it 'returns 6.0 for a set' do
      subject.stored_type(Set.new([1])).should eq '6.0'
    end

    it 'raises an UnknownTypeException for things it cannot handle.' do
      expect { subject.stored_type BasicObject }.to raise_error UnknownTypeException
    end
  end
end