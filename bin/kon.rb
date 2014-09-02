require 'csv'
recording_start_time = Array.new
recording_end_time = Array.new
recording_duration = Array.new
recording = 0
max_alt = 0
max_acc = 0
start_counts = 0

altIndex = 5
accIndex = 6
recIndex = 1
timeIndex = 2

CSV.foreach('/Volumes/Seagate Slim/VG30_083014.csv',  converters: :numeric) do |row|
  if( row[1] == 1 && recording == 0 )
    recording_start_time << row[2]
    recording = 1
  elsif( row [1] == 0 && recording == 1)
    recording_end_time << row[2]
    recording = 0
    recording_duration << recording_end_time[-1] - recording_start_time[-1]
  end
end

puts "Start times"
puts recording_start_time
puts "End times"
puts recording_end_time
puts "Durations"
puts recording_duration