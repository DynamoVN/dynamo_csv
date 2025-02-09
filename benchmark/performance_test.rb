# frozen_string_literal: true

require "benchmark"
require "benchmark/ips"
require_relative "../lib/dynamo_csv"

# Benchmark tests
files = Dir.glob("benchmark/*.csv").map { |f| File.basename(f) }

# Read sample data from first file to create realistic queries
sample_data = CSV.read("benchmark/#{files.first}", headers: true)
sample_row = sample_data.first.to_h

# Create different query scenarios based on actual data
queries = [
  {
    name: "Single column (Occupation)",
    query: { "Occupation" => sample_row["Occupation"] }
  },
  {
    name: "Two columns (Location + Occupation)",
    query: { 
      "Location" => sample_row["Location"],
      "Occupation" => sample_row["Occupation"]
    }
  },
  {
    name: "Age range check",
    query: { "Age" => sample_row["Age"] }
  },
  {
    name: "Name exact match",
    query: { "Name" => sample_row["Name"] }
  },
  {
    name: "Salary match",
    query: { "Salary" => sample_row["Salary"] }
  }
]

# Store results for table
results = []

puts "\nRunning benchmarks..."
puts "=" * 80

files.each do |file|
  file_path = "benchmark/#{file}"
  next unless File.exist?(file_path)

  rows = File.readlines(file_path).size - 1

  queries.each do |scenario|
    print "Testing #{file} with #{scenario[:name]}... "

    times = 5.times.map do
      Benchmark.measure { DynamoCsv::Query.query_csv(file_path, scenario[:query]) }.real
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
