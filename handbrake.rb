#!/usr/bin/ruby

require "enumerator"

mode = "auto" # auto | movie | tv

# config
$handbrake_bin = "~/bin/handbrake"
$input_device = "/dev/disk1"
$output_dir = "~/Movies"
$output_format = "m4v"

# greatest allowed pct. difference between two longest titles on a tv disc
$max_tv_title_differential = 0.1
$min_tv_duration = 540 # 20 minutes

$handbrake_opts = [
  "-i " + $input_device,
  "--preset Default",
  "--native-language eng",
]

def eject_dvd
  system("drutil eject")
  $?.exitstatus == 0
end

def get_dvd_label
  `/sbin/mount | /usr/bin/grep #{$input_device}`.gsub(/.*(\/Volumes\/.*) \(.*/, '\1').chop().split('/').last()
end

def get_rip_mode
  durations = get_titles.collect { |title|
    title[:duration]
  }.sort.reverse

  if durations.length > 1 && (1 - (durations[1].to_f / durations[0].to_f)) <= $max_tv_title_differential
    mode = "tv"
  else
    mode = "movie"
  end
end

def get_episode_titles
  get_titles().find_all { |title|
    title[:duration] > $min_tv_duration
  }
end

def get_output_file
  index = 0
  begin
    output_file = File.expand_path($output_dir) + "/" + get_dvd_label() + "-" + (index += 1).to_s + "." + $output_format
  end while File.exists?(output_file)
  output_file
end

def get_titles
  titles = []
  title = nil

  # `cat ~/tv.txt`.each_line do |line|
  rip(["--title 0"], true).each_line do |line|
    if title && line.match(/^[^\s]/)
      titles << title
      title = nil
    end

    if matches = line.match(/^\+\s+title\s+(\d+)/)
      title = { :number => matches[1].to_i }
    elsif matches = line.match(/\s+duration:\s([\d:]+)/):
      title[:duration] = parse_duration matches[1]
    end
  end

  titles
end

def parse_duration(str)
  values = [
    { :s => 1 },
    { :m => 60 },
    { :h => 3600 },
    { :d => 86400 }
  ]

  str.split(':').reverse.to_enum(:each_with_index).collect do |chunk, index|
    chunk.to_i * values[index].values.first
  end.inject do |sum, seconds|
    sum + seconds
  end
end

def rip(opts = [], return_output = false)
  command = [
    "/opt/local/bin/nice -n 20",
    File.expand_path($handbrake_bin),
    $handbrake_opts,
    opts
  ]

  command = command.flatten.join(' ')

  puts "Running: #{command}"

  if return_output
    `#{command} 2>&1`
  else
    system(command)
  end
end


begin
  if mode == "auto"
    mode = get_rip_mode
  end

  if mode == "movie"
    rip [
      "--longest",
      "-o \"#{get_output_file()}\""
    ]
  elsif mode == "tv"
    get_episode_titles.each do |title|
      rip [
        "--title #{title[:number]}",
        "-o \"#{get_output_file()}\""
      ]
    end
  end
rescue
  nil
end

eject_dvd()
