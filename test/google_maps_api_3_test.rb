
$: << File.dirname(__FILE__)
require 'test_helper'

begin
  require 'json'
rescue LoadError
  # do nothing
end

class GoogleMapsApi3Tests < Test::Unit::TestCase
  include TestHelper

  def setup
    Geos::GoogleMaps.use_api(3)

    @point = Geos.read(POINT_EWKB)
    @polygon = Geos.read(POLYGON_EWKB)
  end

  def test_to_g_lat_lng
    assert_equal("new google.maps.LatLng(10.01, 10.0)", @point.to_g_lat_lng)
    assert_equal("new google.maps.LatLng(10.01, 10.0, true)", @point.to_g_lat_lng(:no_wrap => true))
  end

  def test_to_g_lat_lng_bounds_string
    assert_equal('((10.0100000000,10.0000000000), (10.0100000000,10.0000000000))', @point.to_g_lat_lng_bounds_string)
    assert_equal('((0.0000000000,0.0000000000), (5.0000000000,5.0000000000))', @polygon.to_g_lat_lng_bounds_string)
  end

  def test_to_g_geocoder_bounds_api3
    assert_equal('10.010000,10.000000|10.010000,10.000000', @point.to_g_geocoder_bounds)
    assert_equal('0.000000,0.000000|5.000000,5.000000', @polygon.to_g_geocoder_bounds)
  end

  def test_to_jsonable
    assert_equal({
      :type => "point",
      :lat => 10.01,
      :lng => 10.0
    }, @point.to_jsonable)

    assert_equal({
      :type => "polygon",
      :polylines => [{
        :points => "??_ibE_ibE_~cH_~cH_hgN_hgN~po]~po]",
        :bounds => {
          :sw => [ 0.0, 0.0 ],
          :ne => [ 5.0, 5.0 ]
        },
        :levels=>"BBBBB"
      }],
      :options => {},
      :encoded => true
    }, @polygon.to_jsonable)
  end

  if defined?(JSON)
    def test_to_g_polygon
      assert_equal(
        %{new google.maps.Polygon({"paths": [new google.maps.LatLng(0.0, 0.0), new google.maps.LatLng(1.0, 1.0), new google.maps.LatLng(2.5, 2.5), new google.maps.LatLng(5.0, 5.0), new google.maps.LatLng(0.0, 0.0)]})},
        @polygon.to_g_polygon
      )

      assert_equal(
        "new google.maps.Polygon({\"strokeColor\": \"#b00b1e\", \"strokeWeight\": 5, \"strokeOpacity\": 0.5, \"fillColor\": \"#b00b1e\", \"map\": map, \"paths\": [new google.maps.LatLng(0.0, 0.0), new google.maps.LatLng(1.0, 1.0), new google.maps.LatLng(2.5, 2.5), new google.maps.LatLng(5.0, 5.0), new google.maps.LatLng(0.0, 0.0)]})",
        @polygon.to_g_polygon(
          :stroke_color => '#b00b1e',
          :stroke_weight => 5,
          :stroke_opacity => 0.5,
          :fill_color => '#b00b1e',
          :map => 'map'
        )
      )
    end

    def test_to_g_polygon_with_multi_polygon
      multi_polygon = Geos.read(
        'MULTIPOLYGON(
          ((0 0, 0 5, 5 5, 5 0, 0 0)),
          ((10 10, 10 15, 15 15, 15 10, 10 10)),
          ((20 20, 20 25, 25 25, 25 20, 20 20))
        )'
      )
      options = {
        :stroke_color => '#b00b1e',
        :stroke_weight => 5,
        :stroke_opacity => 0.5,
        :fill_color => '#b00b1e',
        :map => 'map'
      }

      assert_equal(
        ["new google.maps.Polygon({\"strokeColor\": \"#b00b1e\", \"strokeWeight\": 5, \"strokeOpacity\": 0.5, \"fillColor\": \"#b00b1e\", \"map\": map, \"paths\": [new google.maps.LatLng(0.0, 0.0), new google.maps.LatLng(5.0, 0.0), new google.maps.LatLng(5.0, 5.0), new google.maps.LatLng(0.0, 5.0), new google.maps.LatLng(0.0, 0.0)]})",
 "new google.maps.Polygon({\"strokeColor\": \"#b00b1e\", \"strokeWeight\": 5, \"strokeOpacity\": 0.5, \"fillColor\": \"#b00b1e\", \"map\": map, \"paths\": [new google.maps.LatLng(10.0, 10.0), new google.maps.LatLng(15.0, 10.0), new google.maps.LatLng(15.0, 15.0), new google.maps.LatLng(10.0, 15.0), new google.maps.LatLng(10.0, 10.0)]})",
 "new google.maps.Polygon({\"strokeColor\": \"#b00b1e\", \"strokeWeight\": 5, \"strokeOpacity\": 0.5, \"fillColor\": \"#b00b1e\", \"map\": map, \"paths\": [new google.maps.LatLng(20.0, 20.0), new google.maps.LatLng(25.0, 20.0), new google.maps.LatLng(25.0, 25.0), new google.maps.LatLng(20.0, 25.0), new google.maps.LatLng(20.0, 20.0)]})"],
        multi_polygon.to_g_polygon(
          :stroke_color => '#b00b1e',
          :stroke_weight => 5,
          :stroke_opacity => 0.5,
          :fill_color => '#b00b1e',
          :map => 'map'
        )
      )

      assert_equal(
        "new google.maps.Polygon({\"strokeColor\": \"#b00b1e\", \"strokeWeight\": 5, \"strokeOpacity\": 0.5, \"fillColor\": \"#b00b1e\", \"map\": map, \"paths\": [[new google.maps.LatLng(0.0, 0.0), new google.maps.LatLng(5.0, 0.0), new google.maps.LatLng(5.0, 5.0), new google.maps.LatLng(0.0, 5.0), new google.maps.LatLng(0.0, 0.0)], [new google.maps.LatLng(10.0, 10.0), new google.maps.LatLng(15.0, 10.0), new google.maps.LatLng(15.0, 15.0), new google.maps.LatLng(10.0, 15.0), new google.maps.LatLng(10.0, 10.0)], [new google.maps.LatLng(20.0, 20.0), new google.maps.LatLng(25.0, 20.0), new google.maps.LatLng(25.0, 25.0), new google.maps.LatLng(20.0, 25.0), new google.maps.LatLng(20.0, 20.0)]]})",
        multi_polygon.to_g_polygon({
          :stroke_color => '#b00b1e',
          :stroke_weight => 5,
          :stroke_opacity => 0.5,
          :fill_color => '#b00b1e',
          :map => 'map'
        }, {
          :single => true
        })
      )

      assert_equal(
        "new google.maps.Polygon({\"strokeColor\": \"#b00b1e\", \"strokeWeight\": 5, \"strokeOpacity\": 0.5, \"fillColor\": \"#b00b1e\", \"map\": map, \"paths\": [[new google.maps.LatLng(0.0, 0.0), new google.maps.LatLng(5.0, 0.0), new google.maps.LatLng(5.0, 5.0), new google.maps.LatLng(0.0, 5.0), new google.maps.LatLng(0.0, 0.0)], [new google.maps.LatLng(10.0, 10.0), new google.maps.LatLng(15.0, 10.0), new google.maps.LatLng(15.0, 15.0), new google.maps.LatLng(10.0, 15.0), new google.maps.LatLng(10.0, 10.0)], [new google.maps.LatLng(20.0, 20.0), new google.maps.LatLng(25.0, 20.0), new google.maps.LatLng(25.0, 25.0), new google.maps.LatLng(20.0, 25.0), new google.maps.LatLng(20.0, 20.0)]]})",
        multi_polygon.to_g_polygon_single(
          :stroke_color => '#b00b1e',
          :stroke_weight => 5,
          :stroke_opacity => 0.5,
          :fill_color => '#b00b1e',
          :map => 'map'
        )
      )
    end

    def test_to_g_polyline
      assert_equal(
        "new google.maps.Polyline({\"path\": [new google.maps.LatLng(0.0, 0.0), new google.maps.LatLng(1.0, 1.0), new google.maps.LatLng(2.5, 2.5), new google.maps.LatLng(5.0, 5.0), new google.maps.LatLng(0.0, 0.0)]})",
        @polygon.to_g_polyline
      )

      assert_equal(
        "new google.maps.Polyline({\"strokeColor\": \"#b00b1e\", \"strokeWeight\": 5, \"strokeOpacity\": 0.5, \"map\": map, \"path\": [new google.maps.LatLng(0.0, 0.0), new google.maps.LatLng(1.0, 1.0), new google.maps.LatLng(2.5, 2.5), new google.maps.LatLng(5.0, 5.0), new google.maps.LatLng(0.0, 0.0)]})",
        @polygon.to_g_polyline(
          :stroke_color => '#b00b1e',
          :stroke_weight => 5,
          :stroke_opacity => 0.5,
          :map => 'map'
        )
      )
    end

    def test_to_g_marker
      marker = @point.to_g_marker

      lat, lng, json = if marker =~ /^new\s+
        google\.maps\.Marker\(\{
          "position":\s*
          new\s+google\.maps\.LatLng\(
            (\d+\.\d+),\s*
            (\d+\.\d+)
          \)
        \}\)
        /x
        [ $1, $2, $3 ]
      end

      assert_in_delta(lng.to_f, 10.00, 0.000001)
      assert_in_delta(lat.to_f, 10.01, 0.000001)
    end


    def test_to_g_marker_with_options
      marker = @point.to_g_marker({
        :raise_on_drag => true,
        :cursor => 'test'
      }, {
        :escape => %w{ position }
      })

      json = if marker =~ /^new\s+
        google\.maps\.Marker\((
          \{[^}]+\}
        )/x
        $1
      end

      assert_equal(
        { "raiseOnDrag" => true, "cursor" => 'test' },
        JSON.load(json).reject { |k, v|
          %w{ position }.include?(k)
        }
      )
    end

    def test_to_g_json_point
      assert_equal(
        { :coordinates => [ 10.0, 10.01, 0 ] },
        @point.to_g_json_point
      )
    end

    def test_to_g_lat_lon_box
      assert_equal(
        { :east => 5.0, :west => 0.0, :north => 5.0, :south => 0.0},
        @polygon.to_g_lat_lon_box
      )
    end
  end
end
