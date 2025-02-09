require 'benchmark'
require 'benchmark/ips'
require_relative '../lib/dynamo_csv'

# Note: This is sample data generation for testing purposes
def generate_sample_csv(file_name, rows)
  CSV.open(file_name, 'w') do |csv|
    csv << ['Name', 'Age', 'City', 'Occupation']
    rows.times do |i|
      csv << [
        "Person#{i}",
        rand(18..80).to_s,
        ['New York', 'London', 'Tokyo', 'Paris'].sample,
        ['Engineer', 'Teacher', 'Doctor', 'Artist'].sample
      ]
    end
  end
end

# Generate test files
{
  '100_data.csv' => 100,
  '10k_data.csv' => 10_000,
  'medium_data.csv' => 50_000,
  'large_data.csv' => 100_000
}.each do |file, rows|
  generate_sample_csv(file, rows)
end

# Benchmark tests
files = ['100_data.csv', '10k_data.csv', 'medium_data.csv', 'large_data.csv']

# Create different query scenarios based on actual data structure
queries = [
  {
    name: "Single column (Occupation)",
    query: { 'Occupation' => 'Designer' }
  },
  {
    name: "Two columns (City + Occupation)",
    query: { 'City' => 'Los Angeles', 'Occupation' => 'Designer' }
  },
  {
    name: "Age range check",
    query: { 'Age' => '53' }
  },
  {
    name: "Name exact match",
    query: { 'Name' => 'Trina Sanford' }
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
  puts sprintf("%-9s | %-14s | %5d | %14.4f | %11.2f", 
    r[:file], r[:scenario], r[:rows], r[:avg_time], r[:ips])
end

# Print ASCII table
puts "\nBenchmark Summary Table:"
puts "+" + "-" * 86 + "+"
puts "| File Size | Query Scenario | Row Count | Avg Time (s) | Iterations/s | Performance Rating |"
puts "+" + "-" * 86 + "+"

results.each do |r|
  # Calculate performance rating
  rating = case
  when r[:ips] > 500 then "Excellent"
  when r[:ips] > 100 then "Very Good"
  when r[:ips] > 10  then "Good"
  when r[:ips] > 1   then "Fair"
  else "Slow"
  end

  puts sprintf("| %-9s | %-14s | %9d | %11.4f | %11.2f | %-17s |",
    r[:file], r[:scenario], r[:rows], r[:avg_time], r[:ips], rating)
end

puts "+" + "-" * 86 + "+"
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