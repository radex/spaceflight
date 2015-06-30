require 'nokogiri'
require 'date'

html = Nokogiri::HTML IO.read 'wiki/2015.html'

# find the main table
table = html.css('table.wikitable').find { |table|
  table.css('tr').first.to_s.match /Rocket.*Launch site.*LSP/m
}

# ignore header and month dividers
rows = table.css('tr').drop(3).reject { |row| row.at_css('td')['colspan'] == "7" }

# group rows by launch
launches_html = []
rows.each_with_index { |row, index|
  if (rowspan = row.at_css('td')['rowspan'].to_i) > 0
    launches_html << rows[index...index+rowspan]
  end
}

# launch model structs

Payload = Struct.new(:name, :countries, :operator, :orbit, :function, :decay, :outcome)
Rocket = Struct.new(:name, :countries)
LaunchSite = Struct.new(:name, :countries)
LaunchServiceProvider = Struct.new(:name, :country)
Launch = Struct.new(:date, :rocket, :launch_site, :lsp, :payloads, :remarks)

# parse launch data

def flags cell
  cell.css('.flagicon > a').map { |a| a['title'] }.to_s
end

launches = launches_html.map do |rows|
  info_row = rows[0]
  
  begin
    date = DateTime.parse(info_row.css('td')[0].content)
  rescue ArgumentError
    puts 'Bad date, skipping' 
    next
  end
  
  if date > DateTime.now
    puts 'Future date, skipping'
    next
  end
  
  rocket_name = info_row.css('td')[1].content.strip
  rocket_country = flags(info_row.css('td')[1])
  rocket = Rocket.new(rocket_name, rocket_country)
  
  launch_site_name = info_row.css('td')[2].content.strip
  launch_site_country = flags(info_row.css('td')[2])
  launch_site = LaunchSite.new(launch_site_name, launch_site_country)
  
  lsp_name = info_row.css('td')[3].content.strip
  lsp_country = flags(info_row.css('td')[3])
  lsp = LaunchServiceProvider.new(lsp_name, lsp_country)
  
  puts date.strftime('%e %b %Y %H:%M')
  puts rocket
  puts launch_site
  puts lsp
  
  rows.shift
  
  if last_cell = rows.last.css('td')[0] and last_cell['colspan'] == '6'
    remarks = last_cell.content
    rows.pop
  end
  
  payloads = rows.map do |sat|
    name     = sat.css('td')[0].content.strip
    country  = flags(sat.css('td')[0])
    operator = sat.css('td')[1].content.strip
    orbit    = sat.css('td')[2].content.strip
    function = sat.css('td')[3].content.strip
    decay    = sat.css('td')[4].content.strip
    outcome  = sat.css('td')[5].content.strip
    payload  = Payload.new(name, country, operator, orbit, function, decay, outcome)
    puts payload
    payload
  end
  
  puts remarks
  puts
  
  launch = Launch.new(date, rocket, launch_site, lsp, payloads, remarks)
end

launches.reject! &:nil?