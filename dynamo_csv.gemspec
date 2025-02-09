# frozen_string_literal: true

require_relative "lib/dynamo_csv/version"

Gem::Specification.new do |spec|
  spec.name = "dynamo_csv"
  spec.version = DynamoCsv::VERSION
  spec.authors = ["DynamoVN"]
  spec.email = ["tran.huu.thang@moneyforward.co.jp"]

  spec.summary       = "A Ruby gem for querying CSV files"
  spec.description   = "Query CSV files using a hash of column headers and values"
  spec.homepage      = "https://github.com/DynamoVN/dynamo_csv"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.glob("{lib,spec}/**/*") + %w[README.md LICENSE.txt]
end
