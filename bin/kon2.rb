require 'csv'
recording_start_time = Array.new
recording_end_time = Array.new
recording_duration = Array.new
recording = 0
max_alt = 0
max_acc = 0
start_counts = 0

TAGID_INDEX = 0
REC_INDEX = 1
TIME_INDEX = 2
LAT_INDEX = 3
LON_INDEX = 4
ALT_INDEX = 5
ACC_INDEX = 6

CSV.foreach('/Volumes/Seagate Slim/VG30_083014.csv',  converters: :numeric) do |row|
  if( row[REC_INDEX] == 1 && recording == 0 )
    recording_start_time << row[TIME_INDEX]
    recording = 1
  elsif( row [REC_INDEX] == 0 && recording == 1)
    recording_end_time << row[TIME_INDEX]
    recording = 0
    recording_duration << recording_end_time[-1] - recording_start_time[-1]
  end
end

puts "Start times"
puts recording_start_time
puts "End times"
puts recording_end_time
puts "Durations in Seconds"
recording_duration.each { |duration| puts duration/1000 }