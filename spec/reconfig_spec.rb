require 'spec_helper'

describe Reconfig do
  let(:redis_client) { Redis.new }

  after(:each) do
    Reconfig.instance_variable_set(:@configuration, nil)
    Reconfig.instance_variable_set(:@namespaces, nil)
  end

  describe '.configure' do
    it 'sets prefix and meta_key' do
      Reconfig.configure do |config|
        config.prefix = 'Re'
        config.meta_key = 'Cola'
      end

      Reconfig.prefix.should eq 'Re'
      Reconfig.meta_key.should eq 'Cola'
    end

    describe 'setting namespaces' do
      before(:each) do
        Reconfig.configure do |config|
          config.namespaces = [:circle, :square]
        end
      end

      it 'generates namespaces for the passed in options' do
        Reconfig[:circle].meta_key.should eq 'reconf:circle'
        Reconfig[:square].meta_key.should eq 'reconf:square'
      end

      it 'adds the keys to the meta_key' do
        redis_client.smembers('reconf:_meta').should eq ['square', 'circle']
      end
    end
  end

  describe '#method_missing' do
    before(:each) do
      Reconfig.configure do |config|
        config.namespaces = [:circle, :square]
      end
    end

    it 'delegates to stored namespaces by key' do
      Reconfig.circle.should_not be_nil
    end
  end

  describe '#refresh' do
    before(:each) do
      Reconfig.configure do |config|
        config.namespaces = [:gold, :silver]
      end
    end

    it 'adds new namespaces and deletes old ones' do
      Reconfig.gold.should_not be_nil
      redis_client.srem('reconf:_meta', 'gold')
      Reconfig.refresh
      expect{ Reconfig.gold }.to raise_error(NoMethodError)
      Reconfig[:gold].should be_nil
    end

  end

end