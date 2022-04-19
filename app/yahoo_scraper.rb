require 'selenium-webdriver'
require 'byebug'
require 'sqlite3'

# Take user input:
start_date = ''
end_date = ''
tickers = ''

while(start_date.empty?)
  puts "Please type start date (ex. YYYY/MM/DD)"
  start_date = gets.chomp
end

while(end_date.empty?)
  puts "Please type end date (ex. YYYY/MM/DD)"
  end_date = gets.chomp 
end

while(tickers.empty?) 
  puts "Please type one or more tickers, separated by space"
  tickers = gets.chomp
end

# Create the DB
# First, check if the output db file exists, delete it
File.delete("YahooFinance.db") if File.exist?("YahooFinance.db")

# Create a database file
db = SQLite3::Database.new "YahooFinance.db"

# Create tables
rows = db.execute <<-SQL
  create table companies (
    company_id varchar(30) PRIMARY KEY,
    full_name varchar(200),
    market_cap varchar(100),
    previous_close varchar(100),
    year_founded varchar(100),
    employee_number varchar(100),
    headquarters varchar(200)
  );
SQL

rows = db.execute <<-SQL
  create table historical_data (
    company_id varchar(30),
    date_hd varchar(100),
    open_price varchar(200),
    close_price varchar(100),
    FOREIGN KEY(company_id) REFERENCES companies(company_id)
  );
SQL

#####################################################################################
tickers_array = tickers.upcase.split(" ")

tickers_array.each do |ticker| 

  target_asset = ticker

  puts "Working on #{target_asset} ..."

  url = "https://finance.yahoo.com/"

  driver = Selenium::WebDriver.for :chrome
  begin
    driver.get url
    sleep 15

    # Find the quote first
    search_input = driver.find_element(css: "input[placeholder='Quote Lookup']")
    search_input.send_keys target_asset, :return
    sleep 15

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
    sleep 15
    
    # Find company name
    company_name = driver.find_element(:xpath, '//div[@data-test="qsp-profile"]/h3').text
    output.store("company_name", company_name)

    # Find employee number
    employee_number = driver.find_element(:xpath, '//div[@data-test="qsp-profile"]/div/p/span[contains(text(), "Full Time Employees")]/following-sibling::span').text
    output.store("employee_number", employee_number)
    
    # Find Year founded (This is the only field I was able to find this information, so I had to improvise)
    # This one is tricky, I need find a better way to scrape this information. FB ticker shows the bug
    desc_text = driver.find_element(:xpath, '//section[contains(@class,"quote-sub-section Mt(30px)")]' ).text
    desc_index = desc_text.index('was founded')
    desc_reduced = desc_text[desc_index..-1]
    description = desc_reduced.gsub(/[^\d]/,"")
    output.store("year_founded", description)

    # Find headquarters city
    city = driver.find_element(:xpath, '//div[@data-test="qsp-profile"]/div/p').text
    headquarters = city.gsub(/\n/, ' ') 
    output.store("headquarters", headquarters)



  # Insert into table
  db.execute("INSERT INTO companies 
              (company_id, full_name, market_cap, previous_close, year_founded, employee_number, headquarters) 
              VALUES (?, ?, ?, ?, ?, ?, ?)", [target_asset, company_name, market_cap, prev_close_price, description, employee_number, headquarters])


   #byebug
   #x = "amir"
  puts "The script for #{target_asset} was executed successfully."

  ensure
    driver.quit
  end
end

puts "The script has successfully scraped info for #{tickers}"
