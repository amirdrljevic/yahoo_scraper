# Simple scraper app in Ruby

This scraper app uses Selenium to scrape the information from the Yahoo Finance website. 

The prerequisites for this script to run are:
* Ruby 3 installed, 
* Google chrome drive,
* Selenium webdriver,  
* Sqlite3

After all the prerequisites have been installed, please run `bundle install`

## Running the script
The script is located in the _app_ folder. Navigate to this folder and run the script with this command:

`ruby yahoo_scraper.rb AMZN` 

_Instead of AMZN you can pass any other stock symbol like TWTR, FB, TSLA, ETSY, etc…_

Please, bear in mind that sometimes, due to slow network connection, script fails. Just rerun the script again in that case. 

The script will scrape the following information, as requested:
* full company name, 
* market cap, 
* year founded, 
* number of employees,
* headquarters city and state. 
* date and time, 
* previous close price and 
* open price 

The information will be stored in a json file and sqlite3 db file. 

> This scraper is maintained on April 18, 2022. any change from Yahoo Finance team to update their website might render this scraper broken.