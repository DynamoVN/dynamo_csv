# frozen_string_literal: true

require_relative "dynamo_csv/version"
require 'csv'

module DynamoCsv
  class Error < StandardError; end

  class Query
    def self.query_csv(file_path, query_hash)
      # Validate inputs
      raise Error, "File path cannot be empty" if file_path.nil? || file_path.empty?
      raise Error, "Query hash cannot be empty" if query_hash.nil? || !query_hash.is_a?(Hash)
      raise Error, "File not found: #{file_path}" unless File.exist?(file_path)

      results = []
      headers = nil

      CSV.foreach(file_path, headers: true) do |row|
        if headers.nil?
          headers = row.headers
          validate_query_headers(query_hash.keys, headers)
        end

        if matches_criteria?(row, query_hash)
          results << row.to_h
        end
      end

      results
    end

    private

    def self.validate_query_headers(query_keys, file_headers)
      invalid_headers = query_keys.reject { |key| file_headers.include?(key) }
      unless invalid_headers.empty?
        raise Error, "Invalid column headers in query: #{invalid_headers.join(', ')}"
      end
    end

    def self.matches_criteria?(row, query_hash)
      query_hash.all? do |column, value|
        row[column].to_s.strip == value.to_s.strip
      end
    end
  end
end
