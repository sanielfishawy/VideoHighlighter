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
      @samples.sort!{|a,b| a.time_stamp <=> b.time_stamp}
      self
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
  
end

include Highlighter
ss = SampleSet.new([SoloShotSensor, WooSensor]);
Importer.new(SoloShotSensor, "../data/input/solo.csv", ss).import
assets = ss.split_on_recording
assets.each{|a| puts a.samples.length}
kon_footage = assets.last.tagged(100)
puts kon_footage.samples.length


