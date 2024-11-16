require 'rails_helper'
require 'sidekiq/testing' 

Sidekiq::Testing.inline!

RSpec.describe ImportProductsJob, type: :job do
  let(:payload) do
    JSON(
      File.read('spec/fixtures/sample_payload.json').encode('UTF-8', 'ISO-8859-1')
    )
  end

  describe '#perform' do
    it 'converts the hash of products to a query and the executes it' do
      expect_any_instance_of(ImportProductsJob)
        .to receive(:collection_to_query).and_call_original

      expect(ActiveRecord::Base)
        .to receive(:connection).and_call_original

      # The database connection adapter should be changed
      # were the reference database to be another
      expect_any_instance_of(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
        .to receive(:execute).and_call_original

      ImportProductsJob.new.perform(payload)
    end
  end
end
