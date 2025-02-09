# frozen_string_literal: true

require "benchmark"
require "benchmark/ips"
require_relative "../lib/dynamo_csv"

# NOTE: This is sample data generation for testing purposes
def generate_sample_data(index)
  [
    "Person#{index}",
    rand(18..80).to_s,
    ["New York", "London", "Tokyo", "Paris"].sample,
    %w[Engineer Teacher Doctor Artist].sample
  ]
end

def generate_sample_csv(file_name, rows)
  CSV.open(file_name, "w") do |csv|
    csv << %w[Name Age City Occupation]
    rows.times { |index| csv << generate_sample_data(index) }
  end
end

# Generate test files
{
  "100_data.csv" => 100,
  "10k_data.csv" => 10_000,
  "medium_data.csv" => 50_000,
  "large_data.csv" => 100_000
}.each do |file, rows|
  generate_sample_csv(file, rows)
end

# Benchmark tests
files = ["100_data.csv", "10k_data.csv", "medium_data.csv", "large_data.csv"]

# Create different query scenarios based on actual data structure
queries = [
  {
    name: "Single column (Occupation)",
    query: { "Occupation" => "Designer" }
  },
  {
    name: "Two columns (City + Occupation)",
    query: { "City" => "Los Angeles", "Occupation" => "Designer" }
  },
  {
    name: "Age range check",
    query: { "Age" => "53" }
  },
  {
    name: "Name exact match",
    query: { "Name" => "Trina Sanford" }
  }
]

# Store results for table
results = []

puts "\nRunning benchmarks..."
puts "=" * 80

files.each do |file|
  next unless File.exist?(file)

  rows = File.readlines(file).size - 1

  queries.each do |scenario|
    print "Testing #{file} with #{scenario[:name]}... "

    times = 5.times.map do
      Benchmark.measure { DynamoCsv::Query.query_csv(file, scenario[:query]) }.real
    end

    avg_time = times.sum / times.size
    iterations_per_sec = 1.0 / avg_time

    results << {
      file: file,
      scenario: scenario[:name],
      rows: rows,
      avg_time: avg_time,
      ips: iterations_per_sec
    }

    puts "Done!"
  end
end

# Print detailed results
puts "\nDetailed Benchmark Results:"
puts "=" * 100
puts "File Size | Query Scenario | Rows | Average Time (s) | Iterations/s"
puts "-" * 100

results.each do |r|
  puts format("%-<file>9s | %-<scenario>14s | %<rows>5d | %<avg_time>14.4f | %<ips>11.2f",
              file: r[:file],
              scenario: r[:scenario],
              rows: r[:rows],
              avg_time: r[:avg_time],
              ips: r[:ips])
end

# Print ASCII table
puts "\nBenchmark Summary Table:"
puts "+#{"-" * 86}+"
puts "| File Size | Query Scenario | Row Count | Avg Time (s) | Iterations/s | Performance Rating |"
puts "+#{"-" * 86}+"

results.each do |r|
  # Calculate performance rating
  rating = if r[:ips] > 500
             "Excellent"
           elsif r[:ips] > 100
             "Very Good"
           elsif r[:ips] > 10
             "Good"
           elsif r[:ips] > 1
             "Fair"
           else
             "Slow"
           end

  puts format("| %-<file>9s | %-<scenario>14s | %<rows>9d | %<avg_time>11.4f | %<ips>11.2f | %-<rating>17s |",
              file: r[:file],
              scenario: r[:scenario],
              rows: r[:rows],
              avg_time: r[:avg_time],
              ips: r[:ips],
              rating: rating)
end

puts "+#{"-" * 86}+"
puts "\nNotes:"
puts "- Each test runs 5 times per scenario to get average"
puts "- Queries tested:"
queries.each do |q|
  puts "  * #{q[:name]}: #{q[:query].inspect}"
end
puts "\nPerformance Ratings:"
puts "- Excellent: > 500 iterations/second"
puts "- Very Good: > 100 iterations/second"
puts "- Good: > 10 iterations/second"
puts "- Fair: > 1 iteration/second"
puts "- Slow: ≤ 1 iteration/second"
