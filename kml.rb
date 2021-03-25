# Generate a KML file to draw circles corresponding to planet orbits
# if sun was represented by the Science World Dome (Vancouver, BC).
#
# The Science World Dome seems to be about 42m.
#
# http://www.swedensolarsystem.se/en/

# Distance in meters from Science World
PLANETS = {
  Mercury: 1_746, # diameter: 15cm
  Venus: 3_262,   # diameter: 37cm
  Earth: 4_512,   # diameter: 38cm
  Mars: 6_874,    # diameter: 20cm
  Jupiter: 23_473,  # diameter: 431cm
  Saturn: 43_035,   # diameter: 364cm
  Uranus: 86_571,   # diameter: 154cm
  Neptune: 135_616  # diameter: 149cm
}

SCIENCE_WORLD_COORDINATES = [49.273251, -123.103767].reverse

def circle_coordinates(radius:, points: 100)
  (0..points).map do |n|
    angle = n.to_f / points * 2.0 * Math::PI
    [radius * Math::cos(angle), radius * Math::sin(angle)]
  end
end

# https://gis.stackexchange.com/questions/2951/algorithm-for-offsetting-a-latitude-longitude-by-some-amount-of-meters
def offset(lat_long, x_y_in_meters)
  lat, long = lat_long
  x, y = x_y_in_meters
  [ lat + y / (111111.0 * Math::cos(lat)), long + x / 111111.0 ]
end

def kml_circle(name:, radius:)
  coordinates = circle_coordinates(radius: radius).map { |x_y| offset(SCIENCE_WORLD_COORDINATES, x_y) }
  <<~XML
    <Placemark>
      <name>#{name}</name>
      <visibility>1</visibility>
      <Style>
        <geomColor>ff0000ff</geomColor>
        <geomScale>1</geomScale>
      </Style>
      <LineString>
        <coordinates>
          #{coordinates.map { |lat, long| [lat, long, 0].join(',') }.join(' ')}
        </coordinates>
      </LineString>
    </Placemark>
  XML
end

kml_placemarks = PLANETS.map do |name, radius|
  kml_circle(name: name, radius: radius)
end

xml = <<~XML
  <?xml version="1.0" encoding="UTF-8"?>
  <kml xmlns="http://www.opengis.net/kml/2.2">
    <Folder>
      <name>KML Circle Generator Output</name>
      <visibility>1</visibility>
      #{kml_placemarks.join("\n")}
    </Folder>
  </kml>
XML

puts xml
