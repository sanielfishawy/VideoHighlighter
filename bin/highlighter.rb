#!/usr/bin/env ruby
puts "#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"


module Highlighter
  
  require_relative './filters'
  require 'pp'
  
  require "csv"
  
  # ===========
  # = Sensors =
  # ===========
  class Sensor
    @parameters = []
    @csv_index = {}
    
    def self.parameters
      @parameters
    end
    
    def self.csv_index
      @csv_index
    end
    
    # Override this method in a subclass to convert from the timestamp from that sensor to a normalized_time_stamp
    def self.normalized_time_stamp(data)
      data[:time]
    end
  end
  
  class SoloShotSensor < Sensor    
    @parameters = [:tag, :recording, :time, :lat, :lon, :altitude, :accel]
    @csv_index = {
      tag: 0,
      recording: 1,
      time: 2,
      lat: 3,
      lon: 4,
      altitude: 5,
      accel: 6
    }
    
  end
  
  class WooSensor < Sensor
    @parameters = [:altitude, :lat, :long]
  end
  
  # ==========
  # = Sample =
  # ==========
  class Sample
    attr_accessor :sensor, :time_stamp, :data
    
    def initialize(sensor=Sensor, data={})
      @sensor = sensor
      @data = {}
      @sensor.parameters.each do |p|
        raise "Parameter #{p} missing from data #{data.inspect}" unless data[p]
        @data[p] = data[p]
      end
      @time_stamp = @sensor.normalized_time_stamp(data)
    end
  end
  
  # =============
  # = SampleSet =
  # =============
  class SampleSet
    attr_accessor :samples, :sensors
    
    include Filters::CommonFilters
    
    def initialize(sensors)
      @sensors = Array sensors
      @samples = []
      @sensors.each do |s|
        extend Filters::SoloShotFilters if s == Highlighter::SoloShotSensor
        extend Filters::WooFilters if s == Highlighter::WooSensor
      end
    end
    
    def self.new_like(sample_set)
      new(sample_set.sensors)
    end
    
    def add_samples(sample)
      @samples += Array sample
# assume they are in time_stamp order
#     @samples.sort!{|a,b| a.time_stamp <=> b.time_stamp}
      self
    end
    
    def num_samples()
      @samples.length
    end
    
    def duration()
      @samples.last.time_stamp - @samples.first.time_stamp
    end
    
    def get_FCP_XML()
      printf('Start %d; Duration %d', @samples.first.time_stamp, self.duration )
    end
    
  end
  
  # ============
  # = Importer =
  # ============
  class Importer
    attr_accessor :sensor, :csv_files, :sample_set
    
    def initialize(sensor, csv_files, sample_set)
      @sensor = sensor
      @csv_files = Array csv_files
      @sample_set = sample_set
    end
    
    def import
      csv_files.each do |f|
        CSV.parse(strip_nulls(f),  converters: :numeric, headers: true) do |row|
          data = {}
          @sensor.csv_index.keys.each{|k| data[k] = row[@sensor.csv_index[k]]}
          @sample_set.add_samples Sample.new(@sensor, data)
        end
      end
      @sample_set
    end  
    
    def strip_nulls(f)
      contents = ""
      File.open(f) { |f|
        contents = f.read
        contents.gsub!(/\0/, '')      
      }
      contents
    end
  end
  
  # ==============
  # = VideoAsset =
  # ==============

  class VideoAsset
    attr_accessor :file_path, :asset, :clips
    
    def initialize(file_path, asset)
    end
    
    def add_clips(clips)
      @clips += Array clips
    end
    
    def deduped_clips
      
    end
    
    def normalize_time
    end
    
  end
  
  # =======================
  # = VideoFileAssociater =
  # =======================
  
  class VideoFileAssociater
    attr_accessor :video_directory, :assets, :video_file
    
    def initialize(assets, video_directory)
      @assets = assets
      @video_directory = video_directory
    end
    
    def get_video_assets
      # somehow get the files from the directory in variable files in time order
      files.map_with_index{|f,i|  VideoAsset.new(f, @assets[i])}
    end
        
    
  end
  
  # ================
  # = XMLConverter =
  # ================
  
  class XMLConverter
    
    # remember to use deduped clips from VideoAsset
    
    
  end
  
  module SampleSetUtilities
    
    def merge(ss1, ss2)
    end
    
  end
  
end

include Highlighter
input_file_name = '/Users/kon/GitHub/VideoHighlighter/data/input/solo.csv'
ss = SampleSet.new([SoloShotSensor, WooSensor]);
#Importer.new(SoloShotSensor, "../data/input/solo.csv", ss).import
puts input_file_name
Importer.new(SoloShotSensor, input_file_name, ss).import

puts "1"
assets = ss.split_on_recording


video_assets = VideoFileAssociater.new(assets, "path/to/video_dir").get_video_assets

# add the clips
va_w_clips = video_assets.map{|va| va.add_clips(va.asset.split_on_woo_jumps)}

# find the longest recording
longest_length = assets.first.samples.length
longest_footage = assets.first

assets.each{|a| 
  puts "length: ", a.num_samples
  puts "duration: ",a.duration
  if a.samples.length > longest_length 
    longest_length = a.samples.length
    longest_footage = a
  end

}


# find the longest recording
longest_length = assets.first.samples.length
longest_footage = assets.first

assets.each{|a| 
  puts "length: ", a.num_samples
  puts "duration: ",a.duration
  if a.samples.length > longest_length 
    longest_length = a.samples.length
    longest_footage = a
  end

}



object = assets.map {|a| {video_asset: a, clips: a.jumps}}


assets.each{|a| puts a.samples.length}


# find the longest recording
longest_length = assets.first.samples.length
longest_footage = assets.first

assets.each{|a| 
  puts "length: ", a.num_samples
  puts "duration: ",a.duration
  if a.samples.length > longest_length 
    longest_length = a.samples.length
    longest_footage = a
  end

}




# find the longest recording
longest_length = assets.first.samples.length
longest_footage = assets.first

assets.each{|a| 
  puts "length: ", a.num_samples
  puts "duration: ",a.duration
  if a.samples.length > longest_length 
    longest_length = a.samples.length
    longest_footage = a
  end

}




kon_footage = assets.last.tagged(100)
puts "2"
puts kon_footage
puts kon_footage.samples.length
puts "Duration in sensor time: "
puts kon_footage.duration
puts "FCP XML"
puts longest_footage.get_FCP_XML


