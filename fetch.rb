require "selenium-webdriver"

STDOUT.sync = true

def NoSuchElementError
  puts 'I am before the raise.'  
  raise 'An error has occured'  
  puts 'I am after the raise'  
end

driver = Selenium::WebDriver.for :firefox
driver.navigate.to "http://www.mvma.ca/resources/animal-owners/find-veterinarian"
#driver.get "http://www.mvma.ca/resources/animal-owners/find-veterinarian"

member = driver.find_element(:id, 'edit-type')
member.send_keys "Member"

submit = driver.find_element(:id, 'edit-submit-find-a-veterinarian')
submit.click


sleep 3
#npage = driver.find_element(:link_text, 'next ›')

page=1
while 1==1 do
    #npage.click

    #td = driver.find_elements(:class, 'views-field views-field-title')
    ahref = driver.find_elements(:css, 'tbody td a')
    n=1
    for e in ahref
        sleep 0.7
        puts "#{page}.#{n}"
        puts e.attribute('href')
        sleep 1.5
        n += 1
    end
    
    sleep 1

    npage = driver.find_element(:partial_link_text, 'next ').click

    page += 1

    sleep 3
end


#puts driver.title

driver.quit

