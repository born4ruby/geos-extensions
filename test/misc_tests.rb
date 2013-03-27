
$: << File.dirname(__FILE__)
require 'test_helper'

class GeosMiscTests < MiniTest::Unit::TestCase
  include TestHelper

  def initialize(*args)
    @polygon = Geos.read(POLYGON_WKB)
    @point = Geos.read(POINT_WKB)
    super(*args)
  end

  def write(g)
    g.to_wkt(:rounding_precision => 0)
  end

  def test_sanity_of_test_geometries
    %w{
      POINT_WKT
      POINT_EWKT
      POINT_WKB
      POINT_WKB_BIN
      POINT_EWKB
      POINT_EWKB_BIN
      POINT_G_LAT_LNG
      POINT_G_LAT_LNG_URL_VALUE
      POLYGON_WKT
      POLYGON_EWKT
      POLYGON_WKB
      POLYGON_WKB_BIN
      POLYGON_EWKB
      POLYGON_EWKB_BIN
      POLYGON_WITH_INTERIOR_RING
      LINESTRING_WKT
      GEOMETRYCOLLECTION_WKT
      MULTIPOINT_WKT
      MULTIPOLYGON_WKT
      MULTILINESTRING_WKT
      BOUNDS_G_LAT_LNG
      BOUNDS_G_LAT_LNG_URL_VALUE
    }.each do |constant_name|
      geom = Geos.read(self.class.const_get(constant_name))
      assert_equal("Valid Geometry", geom.valid_reason)
    end
  end

  def test_upper_left
    assert_equal('POINT (0 2)', write(@polygon.upper_left))
    assert_equal('POINT (10 10)', write(@point.upper_left))

    assert_equal('POINT (0 2)', write(@polygon.northwest))
    assert_equal('POINT (10 10)', write(@point.northwest))

    assert_equal('POINT (0 2)', write(@polygon.nw))
    assert_equal('POINT (10 10)', write(@point.nw))
  end

  def test_upper_right
    assert_equal('POINT (5 2)', write(@polygon.upper_right))
    assert_equal('POINT (10 10)', write(@point.upper_right))

    assert_equal('POINT (5 2)', write(@polygon.northeast))
    assert_equal('POINT (10 10)', write(@point.northeast))

    assert_equal('POINT (5 2)', write(@polygon.ne))
    assert_equal('POINT (10 10)', write(@point.ne))
  end

  def test_lower_left
    assert_equal('POINT (0 0)', write(@polygon.lower_left))
    assert_equal('POINT (10 10)', write(@point.lower_left))

    assert_equal('POINT (0 0)', write(@polygon.southwest))
    assert_equal('POINT (10 10)', write(@point.southwest))

    assert_equal('POINT (0 0)', write(@polygon.sw))
    assert_equal('POINT (10 10)', write(@point.sw))
  end

  def test_lower_right
    assert_equal('POINT (5 0)', write(@polygon.lower_right))
    assert_equal('POINT (10 10)', write(@point.lower_right))

    assert_equal('POINT (5 0)', write(@polygon.southeast))
    assert_equal('POINT (10 10)', write(@point.southeast))

    assert_equal('POINT (5 0)', write(@polygon.se))
    assert_equal('POINT (10 10)', write(@point.se))
  end

  def test_top
    assert_equal(2.5, @polygon.top)
    assert_equal(10.01, @point.top)

    assert_equal(2.5, @polygon.north)
    assert_equal(10.01, @point.north)

    assert_equal(2.5, @polygon.n)
    assert_equal(10.01, @point.n)
  end

  def test_bottom
    assert_equal(0.0, @polygon.bottom)
    assert_equal(10.01, @point.bottom)

    assert_equal(0.0, @polygon.south)
    assert_equal(10.01, @point.south)

    assert_equal(0.0, @polygon.s)
    assert_equal(10.01, @point.s)
  end

  def test_left
    assert_equal(0.0, @polygon.left)
    assert_equal(10.0, @point.left)

    assert_equal(0.0, @polygon.west)
    assert_equal(10.0, @point.west)

    assert_equal(0.0, @polygon.w)
    assert_equal(10.0, @point.w)
  end

  def test_right
    assert_equal(5.0, @polygon.right)
    assert_equal(10.0, @point.right)

    assert_equal(5.0, @polygon.east)
    assert_equal(10.0, @point.east)

    assert_equal(5.0, @polygon.e)
    assert_equal(10.0, @point.e)
  end

  def test_lat_lng
    linestring = Geos.read('LINESTRING(0 0, 20 25)')

    %w{
      lat_lng
      latlng
      latlong
      lat_lon
      latlon
    }.each do |m|
      assert_equal([ 10.01, 10.0 ], @point.send(m))
      assert_equal([ 12.5, 10.0 ], linestring.envelope.send(m))
    end
  end

  def test_lng_lat
    linestring = Geos.read('LINESTRING(0 0, 20 25)')

    %w{
      long_lat
      lnglat
      longlat
      lon_lat
      lonlat
    }.each do |m|
      assert_equal([ 10.0, 10.01 ], @point.send(m))
      assert_equal([ 10.0, 12.5 ], linestring.envelope.send(m))
    end
  end
end
