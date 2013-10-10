require 'spec_helper'

describe Reconfig::Namespace do
  let(:type_mapper) { Reconfig::TypeMapper.new }
  let(:fake_redis) { Redis.new }

  subject do
    Reconfig::Namespace.new('Meta:World:Peace')
  end

  describe '#initialize' do
    it 'sets the meta key' do
      subject.meta_key.should eq 'Meta:World:Peace'
    end

    it 'sets a default for the prefix' do
      subject.options[:prefix].should eq 'Meta:World:Peace:'
    end
  end

  describe '#config' do
    it 'defaults to an empty hash' do
      subject.config.should eq Hash.new
    end

    it 'stores a value' do
      subject[:gin] = 'St. George'
      fake_redis.get('Meta:World:Peace:gin').should eq 'St. George'
    end

    it 'stores a value\'s key and type in the meta key' do
      subject[:gin] = 'St. George'
      key_type = fake_redis.zrange('Meta:World:Peace', 0, -1, with_scores: true).first
      key_type.first.should eq 'Meta:World:Peace:gin'
      key_type.last.should eq type_mapper.string
    end

    it 'fetchs configuration values from the meta key' do
      fake_redis.zadd('Meta:World:Peace', type_mapper.integer, 'Crisco')
      fake_redis.set('Meta:World:Peace:Crisco', 17)
      subject['Crisco'].should eq 17
    end

    it 'only loads the config once' do
      subject.config.should eq Hash.new
      fake_redis.zadd('Meta:World:Peace', type_mapper.integer, 'Crisco')
      fake_redis.set('Meta:World:Peace:Crisco', 17)
      subject['Crisco'].should be_nil
    end
  end

  describe '#refresh' do
    before(:each) do
      fake_redis.zadd('Meta:World:Peace', type_mapper.integer, 'Crisco')
      fake_redis.set('Meta:World:Peace:Crisco', 17)
    end

    it 'refreshes configuration values' do
      subject['Crisco'].should be 17
      fake_redis.set('Meta:World:Peace:Crisco', 42)
      subject.refresh
      subject['Crisco'].should be 42
    end
  end
end