# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe DynamoCsv::Query do
  let(:csv_content) do
    <<~CSV
      Name,Age,City
      John,30,New York
      Jane,25,Boston
      John,35,Chicago
    CSV
  end

  let(:csv_file) do
    file = Tempfile.new(['test', '.csv'])
    file.write(csv_content)
    file.close
    file
  end

  after do
    csv_file.unlink
  end

  describe '.query_csv' do
    it 'returns matching rows' do
      results = described_class.query_csv(csv_file.path, { 'Name' => 'John', 'Age' => '30' })
      expect(results.length).to eq(1)
      expect(results.first['City']).to eq('New York')
    end

    it 'returns empty array when no matches found' do
      results = described_class.query_csv(csv_file.path, { 'Name' => 'NotFound' })
      expect(results).to be_empty
    end

    it 'raises error for invalid column headers' do
      expect {
        described_class.query_csv(csv_file.path, { 'InvalidColumn' => 'Value' })
      }.to raise_error(DynamoCsv::Error, /Invalid column headers/)
    end

    it 'raises error for non-existent file' do
      expect {
        described_class.query_csv('nonexistent.csv', { 'Name' => 'John' })
      }.to raise_error(DynamoCsv::Error, /File not found/)
    end
  end
end
