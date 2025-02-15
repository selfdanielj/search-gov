require 'spec_helper'

describe RequestDrilldown do
  subject(:drilldown) { described_class.new(true, '') }

  describe '#docs' do
    subject(:docs) { drilldown.docs }

    it 'queries Elasticsearch with the expected options' do
      expect(Es::ELK.client_reader).to receive(:search).
        with({
               index: 'human-logstash-*',
               body: '',
               size: 10_000,
               sort: '@timestamp:asc'
             })
      docs
    end

    context 'when results are present' do
      let(:drilldown_queries_response) do
        JSON.parse(read_fixture_file('/json/rtu_dashboard/drilldown_queries.json'))
      end

      before do
        allow(Es::ELK.client_reader).to receive(:search).
          and_return(drilldown_queries_response)
      end

      it 'returns the _source for each hit' do
        expect(docs.count).to eq 10
        expect(docs.first['params']['query']).to eq('fashion psychology')
      end
    end

    context 'when something goes wrong' do
      before do
        allow(Es::ELK.client_reader).to receive(:search).
          and_raise(StandardError.new('search failure'))
        allow(Rails.logger).to receive(:error)
      end

      it 'returns an empty array' do
        expect(docs).to eq([])
      end

      it 'logs the error' do
        docs
        expect(Rails.logger).to have_received(:error).
          with('Error extracting drilldown hits:', instance_of(StandardError))
      end
    end
  end
end
