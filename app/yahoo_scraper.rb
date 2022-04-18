require 'selenium-webdriver'
require 'byebug'
require 'json'
require "sqlite3"

# Check if more than 1 arguments were provided
if ARGV.length > 1 
  puts "Too many arguments"
  exit
end

target_asset = ARGV[0]

puts "Working on #{ARGV[0]} ..."

url = "https://finance.yahoo.com/"

driver = Selenium::WebDriver.for :chrome
begin
  driver.get url

  # Find the quote first
  search_input = driver.find_element(css: "input[placeholder='Quote Lookup']")
  search_input.send_keys target_asset, :return
  sleep 6

  # Create an empty hash, to be populated later
  output = {}  

  # Find market cap
  market_cap = driver.find_element(:xpath, '//td[@data-test="MARKET_CAP-value"]').text
  output.store("market_cap", market_cap)

  # Find date and time
  date_time_at_close = driver.find_element(:xpath, '//div[@id="quote-market-notice"]/span').text
  output.store("date_time_at_close", date_time_at_close)

  # Find previous close price
  prev_close_price = driver.find_element(:xpath, '//td[@data-test="PREV_CLOSE-value"]').text
  output.store("prev_close_price", prev_close_price)

  # Find open price
  open_price = driver.find_element(:xpath, '//td[@data-test="OPEN-value"]').text
  output.store("open_price", open_price)  

  # Go to Profile tab
  company_profile = driver.find_element(:xpath, '//li[@data-test="COMPANY_PROFILE"]').click
  sleep 2
  
  # Find company name
  company_name = driver.find_element(:xpath, '//div[@data-test="qsp-profile"]/h3').text
  output.store("company_name", company_name)

  # Find employee number
  employee_number = driver.find_element(:xpath, '//div[@data-test="qsp-profile"]/div/p/span[contains(text(), "Full Time Employees")]/following-sibling::span').text
  output.store("employee_number", employee_number)
  
  # Find Year founded (This is the only field I was able to find this information, so I had to improvise)
  desc_text = driver.find_element(:xpath, '//section[contains(@class,"quote-sub-section Mt(30px)")]' ).text
  desc_index = desc_text.index('was founded')
  desc_reduced = desc_text[desc_index..-1]
  description = desc_reduced.gsub(/[^\d]/,"")
  output.store("year_founded", description)

  # Find headquarters city
  city = driver.find_element(:xpath, '//div[@data-test="qsp-profile"]/div/p').text
  headquarters = city.gsub(/\n/, ' ') 
  output.store("headquarters", headquarters)

  # If a json output file exists, delete it
  File.delete("result_#{ARGV[0]}.json") if File.exist?("result_#{ARGV[0]}.json")

  # Save the hash output into a json file
  File.open("result_#{ARGV[0]}.json","w") do |f|
    f.write(output.to_json)
  end

  # Save the hash outout into an sqlite3 db

  # First, see if the output db file exists, delete it
  File.delete("result_#{ARGV[0]}.db") if File.exist?("result_#{ARGV[0]}.db")

  # Create a database file
  db = SQLite3::Database.new "result_#{ARGV[0]}.db"

  # Create a table
  rows = db.execute <<-SQL
    create table my_table (
      key_col varchar(30),
      val_col varchar(200)
    );
  SQL

  # Insert into table
  output.each do |pair|
    db.execute "insert into my_table values ( ?, ? )", pair
  end

  # byebug
  # x = "amir"
  puts "The script was executed successfully."

ensure
  driver.quit
end

