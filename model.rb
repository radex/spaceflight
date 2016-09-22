require 'json'

# launch model structs

Payload = Struct.new(:name, :country, :operator, :orbit, :function, :decay, :outcome)
Rocket = Struct.new(:name, :country)
LaunchSite = Struct.new(:name, :country)
LaunchServiceProvider = Struct.new(:name, :country)
Launch = Struct.new(:date, :rocket, :launch_site, :lsp, :payloads, :remarks)

# generate

class Struct
  def to_map
    map = Hash.new
    self.members.each { |m| map[m] = self[m] }
    map
  end

  def to_json(*a)
    to_map.to_json(*a)
  end
end

# load

class Launch
  def self.from_json json
    l = Launch.new *json.values
    l.rocket = Rocket.new *l.rocket.values
    l.launch_site = LaunchSite.new *l.launch_site.values
    l.lsp = LaunchServiceProvider.new *l.lsp.values
    l.payloads = l.payloads.map { |p| Payload.new *p.values }
    l
  end
end