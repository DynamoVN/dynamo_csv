# DynamoCsv

A high-performance Ruby gem for querying CSV files using column headers and values. This gem provides an efficient way to search through CSV files using multiple criteria.

## Features

- Simple and intuitive query interface
- Support for multiple search criteria
- Performance optimized for large CSV files
- Comprehensive benchmarking tools
- Error handling for common scenarios

## Installation

### Option 1: Using Bundler

1. Add this line to your application's Gemfile:

```ruby
gem 'dynamo_csv'
```

2. Execute:
```bash
$ bundle install
```

### Option 2: Manual Installation

Install the gem directly:

```bash
$ gem install dynamo_csv
```

## Usage

### Basic Query Examples

```ruby
require 'dynamo_csv'

# Query by single column
results = DynamoCsv::Query.query_csv(
  'path/to/file.csv',
  { 'Occupation' => 'Designer' }
)

# Query by multiple columns
results = DynamoCsv::Query.query_csv(
  'path/to/file.csv',
  { 
    'City' => 'Los Angeles',
    'Occupation' => 'Designer'
  }
)

# Process results
results.each do |row|
  puts "Name: #{row['Name']}"
  puts "Age: #{row['Age']}"
  puts "Occupation: #{row['Occupation']}"
  puts "City: #{row['City']}"
  puts "Salary: #{row['Salary']}"
  puts "---"
end
```

### Supported Column Names

The following columns are supported in your CSV files:
- Name
- Age
- Occupation
- City
- Salary

## Running Benchmarks

The gem includes a comprehensive benchmarking suite that tests performance across different file sizes and query types.

### Setup Benchmarks

1. Clone the repository:
```bash
$ git clone https://github.com/yourusername/dynamo_csv.git
$ cd dynamo_csv
```

2. Install dependencies:
```bash
$ bundle install
```

3. Run the benchmark script:
```bash
$ ruby benchmark/performance_test.rb
```

### Benchmark Scenarios

The benchmark tests include:
1. Single column query (Occupation)
2. Two-column query (City + Occupation)
3. Age-based query
4. Exact name match

### Understanding Benchmark Results

The benchmark will test against different file sizes:
- 100_data.csv (100 rows)
- 10k_data.csv (10,000 rows)
- medium_data.csv (50,000 rows)
- large_data.csv (100,000 rows)

Example benchmark output:
```
Running benchmarks...
================================================================================
Testing 100_data.csv with Single column (Occupation)... Done!
Testing 100_data.csv with Two columns (City + Occupation)... Done!
...

Detailed Benchmark Results:
================================================================================
File Size | Query Scenario | Rows | Average Time (s) | Iterations/s
--------------------------------------------------------------------------------
100_data  | Single column |   100 |         0.0012 |      833.33
100_data  | Two columns  |   100 |         0.0015 |      666.67
...

Benchmark Summary Table:
+------------------------------------------------------------------+
| File Size | Query Scenario | Row Count | Avg Time (s) | Performance Rating |
+------------------------------------------------------------------+
| 100_data  | Single column |      100 |      0.0012 | Excellent         |
...
```

Performance Ratings:
- Excellent: > 500 iterations/second
- Very Good: > 100 iterations/second
- Good: > 10 iterations/second
- Fair: > 1 iteration/second
- Slow: ≤ 1 iteration/second

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the MIT License.

## Code of Conduct

Everyone interacting in the DynamoCsv project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/dynamo_csv/blob/master/CODE_OF_CONDUCT.md).
