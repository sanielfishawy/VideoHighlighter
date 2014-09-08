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
    
    
    def local_maxima(key, minimum_amplitude, window=10)
      # provide an array of samples that are local maxima
      result = @samples
      result.sort{|a,b| a.data[key] <=> b.data[key]}
    end
    
    def split_and_pad_on_samples(samples, padding={before:5, after:5})
      # provid an array of samplesets from @samples where each is centered on a sample in samples and padded by before and after.
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

    def solo_split_on_recording
      split_on(Highlighter::SoloShotSensor, :recording, 1)
    end
    
    def solo_sort_on_key(key)
      puts "In solo_sort"
      @samples.sort{|a,b| a.data[key] <=> b.data[key]}
    end

    def solo_tagged(tag)
      # Exercise for the reader make a where_including_other_sensors and use that instead.
      where(:tag, tag)
    end
    
    def solo_jumps()
      split_and_pad_on_samples(local_maxima(:altitude, 5))
    end
    
    def solo_accel_highlight( video_asset )
      my_clip = [3,5]
      video_asset.add_clips( my_clip )
      my_clip = [100,5]
      video_asset.add_clips( my_clip )
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