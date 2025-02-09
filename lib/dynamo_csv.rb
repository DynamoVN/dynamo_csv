# frozen_string_literal: true

require "csv"
require_relative "dynamo_csv/version"

module DynamoCsv
  class Error < StandardError; end

  class Query
    class << self
      def query_csv(file_path, query_hash)
        validate_inputs(file_path, query_hash)
        process_csv(file_path, query_hash)
      end

      private

      def validate_inputs(file_path, query_hash)
        raise Error, "File path cannot be empty" if file_path.nil? || file_path.empty?
        raise Error, "Query hash cannot be empty" if query_hash.nil? || !query_hash.is_a?(Hash)
        raise Error, "File not found: #{file_path}" unless File.exist?(file_path)
      end

      def validate_query_headers(query_keys, file_headers)
        invalid_headers = query_keys.reject { |key| file_headers.include?(key) }
        return if invalid_headers.empty?

        raise Error, "Invalid column headers in query: #{invalid_headers.join(", ")}"
      end

      def process_csv(file_path, query_hash)
        results = []
        headers = nil

        CSV.foreach(file_path, headers: true) do |row|
          if headers.nil?
            headers = row.headers
            validate_query_headers(query_hash.keys, headers)
          end

          results << row.to_h if matches_criteria?(row, query_hash)
        end

        results
      end

      def matches_criteria?(row, query_hash)
        query_hash.all? do |column, value|
          row[column].to_s.strip == value.to_s.strip
        end
      end
    end
  end
end
