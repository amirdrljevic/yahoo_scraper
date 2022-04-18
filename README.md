# Simple scraper app in Ruby

This scraper app uses Selenium to scrape the information from the Yahoo Finance website. 

The prerequisites for this script to run are:
* Ruby 3 installed, 
* Selenium webdriver,  
* Sqlite3

Run the script with this command:

`ruby yahoo_scraper.rb AMZN` 

_Instead of AMZN you can pass any other stock symbol like TWTR, FB, TSLA, ETSY, etc…_

The script will scrape the following information, as requested:
* full company name, 
* market cap, 
* year founded, 
* number of employees,
* headquarters city and state. 
* date and time, 
* previous close price and 
* open price 
