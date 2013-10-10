require 'spec_helper'

describe Reconfig::Configuration do
  subject do
    Reconfig::Configuration.new
  end

  describe '#namespaces' do
    it 'memoizes an empty array' do
      subject.namespaces.should eq []
    end
  end

  describe '#meta_key' do
    it 'memoizes to a default key' do
      subject.meta_key.should eq 'reconf:_meta'
    end

    it 'takes into account a previously set prefix' do
      subject.prefix = 'sooooo'
      subject.meta_key.should eq 'sooooo_meta'
    end
  end

  describe '#prefix' do
    it 'memoizes a default prefix' do
      subject.prefix.should eq 'reconf:'
    end
  end

end