require 'spec_helper'

describe Reconfig::RedisClient do
  let(:type_mapper) { Reconfig::TypeMapper.new }
  let(:connection) { double(:connection) }

  subject do
    Reconfig::RedisClient.new
  end

  before(:each) { subject.stub(:connection).and_return(connection) }

  describe '#fetch_by_type' do

    it 'gets a string value' do
      allow(connection).to receive(:get).with('Gin').and_return('Tonic')
      subject.fetch_by_type('Gin', type_mapper.string).should eq 'Tonic'
    end

    it 'gets an integer value' do
      allow(connection).to receive(:get).with('Bubbles').and_return('7')
      subject.fetch_by_type('Bubbles', type_mapper.integer).should be 7
    end

    it 'gets a float value' do
      allow(connection).to receive(:get).with('Stars').and_return('7.0')
      subject.fetch_by_type('Stars', type_mapper.float).should eq 7.0
    end

    it 'gets a hash value' do
      allow(connection).to receive(:hgetall).with('Months').and_return({ january: 1, february: 2 })
      subject.fetch_by_type('Months', type_mapper.hash).should eq({ january: 1, february: 2 })
    end

    it 'gets a list value' do
      allow(connection).to receive(:lrange).with('PescatarianSleepAid', 0, -1).and_return(['One Fish', 'Two Fish'])
      subject.fetch_by_type('PescatarianSleepAid', type_mapper.list).should eq(['One Fish', 'Two Fish'])
    end

    it 'gets a set value' do
      set = Set.new(['A', 'B', 'AB', 'O'])
      allow(connection).to receive(:smembers).with('BloodTypes').and_return(set)
      subject.fetch_by_type('BloodTypes', type_mapper.set).should eq(set)
    end

    it 'raises an error for an unknown type' do
      expect { subject.fetch_by_type('Betty', 'Boop') }.to raise_error(UnknownTypeException)
    end
  end

  describe '#set_by_type' do

    context 'with a string' do
      it 'sets the existing key' do
        connection.should_not_receive(:del).with('Frank')
        connection.should_receive(:set).with('Frank', 'Ocean')
        subject.set_by_type('Frank', 'Ocean')
      end
    end

    context 'with an integer' do
      it 'sets the existing key' do
        connection.should_not_receive(:del).with('Bubbles')
        connection.should_receive(:set).with('Bubbles', 7)
        subject.set_by_type('Bubbles', 7)
      end
    end

    context 'with a float' do
      it 'sets the existing key' do
        connection.should_not_receive(:del).with('pi')
        connection.should_receive(:set).with('pi', 3.14)
        subject.set_by_type('pi', 3.14)
      end
    end

    context 'with an hash' do
      it 'deletes the existing hash, sets the hash' do
        hash = { javascript: 1, chris: 0 }
        connection.should_receive(:del).with('life')
        connection.should_receive(:hmset).with('life', *hash.to_a.flatten)
        subject.set_by_type('life', hash)
      end
    end

    context 'with an array' do
      it 'deletes the existing list, pushes all values' do
        values = ['Jack', 'Jill']
        connection.should_receive(:del).with('Chillins')
        connection.should_receive(:rpush).with('Chillins', *values)
        subject.set_by_type('Chillins', values)
      end
    end

    context 'with a set' do
      it 'deletes the existing set, adds all values' do
        set = Set.new(['A', 'B', 'AB', 'O'])
        connection.should_receive(:del).with('BloodTypes')
        connection.should_receive(:sadd).with('BloodTypes', *set)
        subject.set_by_type('BloodTypes', set)
      end
    end
  end

  describe 'respond_to?' do
    let(:connection) { double(:connection, zadd: true, rpop: false, evalsha: 'whatever') }

    it 'returns true for underlying redis commands' do
      [:zadd, :rpop, :evalsha].each do |redis_command|
        subject.respond_to?(redis_command).should be true
      end
    end

    it 'returns false for arbitrary methods' do
      subject.respond_to?(:bacon).should be false
    end
  end

  describe 'method_missing' do
    let(:connection) { double(:connection, zadd: true) }

    it 'passes methods to the underlying redis connection' do
      connection.should_receive(:zadd).with('key', 'a', 'b', 'c')
      subject.zadd('key', 'a', 'b', 'c')
    end
  end
end