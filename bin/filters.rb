module Filters
  
  # =================
  # = CommonFilters =
  # =================
  module CommonFilters
    def sample_length
      puts "DATA*** #{@samples.length}"
    end
    
    def where(key, value)
      SampleSet.new_like(self).add_samples(@samples.select{|s| s.data[key] == value})
    end
    
    def where_including_other_sensors(sensor, key, value)
      # Exercise for the reader...
      self
    end
    
    def split_on(sensor, key, value)
      result = []
      match = false
      ss = SampleSet.new_like(self)
      @samples.each do |s|
        ss ||= SampleSet.new_like(self)
        
        # Include any samples from other sensors as long as we are matching on the sensor we are spitting on.
        ss.add_samples(s) and next if s.sensor != sensor && match
                
        if s.data[key] == value
          ss.add_samples(s) 
          match = true
        else
          (result << ss and ss = nil) if match == true
          match = false
        end
      end
      result
    end
    
    def print_data
      @samples.each{|s| puts s.data.inspect}
    end
  end
  
  # ===================
  # = SoloShotFilters =
  # ===================
  module SoloShotFilters
    include CommonFilters

    def split_on_recording
      split_on(Highlighter::SoloShotSensor, :recording, 1)
    end
    
    def tagged(tagID)
      # Exercise for the reader make a where_including_other_sensors and use that instead.
      where(:tag, tagID)
    end
  end
  
  # ==============
  # = WooFilters =
  # ==============
  module WooFilters   
    include CommonFilters 
    def woo_test
      puts "WOODATA*** #{@samples.length}"
    end
  end
  
end