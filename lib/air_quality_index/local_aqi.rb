class AirQualityIndex::LocalAQI

  attr_accessor :zip_code, :todays_index, :current_location_city, :current_location_state, :current_aqi, :current_ozone, :current_health_msg, :current_aqi_msg, :current_ozone_msg, :current_aqi_timestamp, :today_aqi, :today_aqi_msg, :tomorrow_aqi, :tomorrow_aqi_msg, :today_ozone, :tomorrow_ozone

  def call
    self.zip_code_grabber
    self.aqi_scraper(self.zip_code)
    self.local_aqi_return(self.local_aqi_index)
  end

  # grab zip code from user
  def zip_code_grabber

    puts "Please enter your 5-digit zip code:"
    @zip_code = nil

    while !self.is_zip_code?(self.zip_code)
      self.zip_code = gets.chomp
    end

    #return zip_code
    self.zip_code.to_i
  end

  #check to see if zip code is valid

  def is_zip_code?(user_zip)
    if user_zip == nil
      false
    else
      user_zip.size == 5 && user_zip.to_i.to_s == user_zip && user_zip != nil
    end
  end

  #scrape AQI webpage based on submitted zip code

  def aqi_scraper(zip_code)
  @doc = Nokogiri::HTML(open("https://airnow.gov/index.cfm?action=airnow.local_city&zipcode=#{zip_code}"))
  end

  def doc
    @doc
  end

  def timestamp
    timestamp = self.doc.search("td.AQDataSectionTitle").css("small").text.split(" ")
    timestamp[0].capitalize!
    timestamp = timestamp.join(" ")
    timestamp
  end

  #assign scraped information

  def local_aqi_index

    # binding.pry

    #store location information
    self.current_location_city = self.doc.search(".ActiveCity").text.strip
    self.current_location_state = self.doc.search("a.Breadcrumb")[1].text.strip

    # binding.pry

    #store current aqi/ozone data
    self.current_aqi = '135'
    self.current_aqi_msg = self.doc.search("td.AQDataPollDetails")[3].text.strip
    self.current_ozone = '13'
    self.current_ozone_msg = self.doc.search("td.AQDataPollDetails")[1].text.strip
    self.current_health_msg = self.doc.search("td.HealthMessage")[0].text.strip


    #Extract time from site
    self.current_aqi_timestamp = self.timestamp

    # binding.pry

    self.doc.search("td.HealthMessage")[0].text.strip

    #store todays forecast data
    self.today_aqi = self.doc.search("td.AQDataPollDetails")[7].text.strip
    self.today_aqi_msg = 'None'
    self.today_ozone = self.doc.search("td.AQDataPollDetails")[5].text.strip

    #store tomorrows forecast data

    self.tomorrow_aqi = self.doc.search("td.AQDataPollDetails")[11].text.strip
    self.tomorrow_aqi_msg = 'None'
    self.tomorrow_ozone = self.doc.search("td.AQDataPollDetails")[9].text.strip

    #return self
    self
  end

  #return output message with scraped information

  def local_aqi_return(local_aqi)

    puts <<-DOC

    Current Conditions in #{local_aqi.current_location_city}, #{local_aqi.current_location_state} (#{local_aqi.current_aqi_timestamp}):

    AQI - #{local_aqi.current_aqi} (#{local_aqi.current_aqi_msg})
    Ozone - #{local_aqi.current_ozone} (#{local_aqi.current_ozone_msg})

    #{local_aqi.current_health_msg}

    Today's Forecast in #{local_aqi.current_location_city}, #{local_aqi.current_location_state}

    AQI - #{local_aqi.today_aqi}
    Ozone - #{local_aqi.today_ozone}
    Health Message - #{local_aqi.today_aqi_msg}


    Tomorrow's Forecast in #{local_aqi.current_location_city}, #{local_aqi.current_location_state}

    AQI - #{local_aqi.tomorrow_aqi}
    Ozone - #{local_aqi.tomorrow_ozone}
    Health Message - #{local_aqi.tomorrow_aqi_msg}
    DOC

  end
end
