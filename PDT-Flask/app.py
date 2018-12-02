from flask import Flask
import connection as conn
import json
import geojson
from flask import jsonify
from flask import Flask, render_template
from flask import request,redirect, Response
from flask import jsonify
import psycopg2, urllib, zipfile, os
import psycopg2.extras

app = Flask(__name__)
app.config['DEBUG'] = True

##### Case 1 - Massachusetts % coverage by selected land use type
@app.route('/c1landuse', methods=['GET'])
def c1landuse():

    landUseType = request.args.get('landUseType')

    print("Land use type:", landUseType)
    connection = conn.get_connection()
    connection.execute("""SELECT to_json(land_use_coverage_percentage)::json as land_use_percentage FROM (
SELECT
    a.*,
    b.*,
    a.all_land_area - b.land_use_type_area AS difference,
	(b.land_use_type_area / a.all_land_area) * 100 as land_use_coverage_percentage
from (
	SELECT SUM(ST_Area(ST_Transform(geom,26986))/1000000) as all_land_area from landuse_poly
) a
CROSS JOIN(
	SELECT SUM(ST_Area(ST_Transform(geom,26986))/1000000) as land_use_type_area 
	from landuse_poly
	where lower(lu05_desc) like lower('{0}')
) b
) c;""".format(landUseType))

    rows = connection.fetchall()
    print(rows)
    return jsonify(rows)


@app.route('/getalllandusetypes', methods=['GET'])
def getalllandusetypes():

    connection = conn.get_connection()
    connection.execute("""select array_to_json(array_agg(lu05_desc)) as land_use_types from (
	select distinct lu05_desc from landuse_poly 
) a;""")

    rows = connection.fetchall()
    print(rows)
    return jsonify(rows)

##### Case 3 - Shortest path between two stations
@app.route('/connBetweenTwoStations', methods=['GET'])
def connBetweenTwoStations():

    stationA = request.args.get('stationA')
    stationB = request.args.get('stationB')

    print("Station A:", stationA)
    print("Station B:", stationB)

    connection = conn.get_connection()
    connection.execute("""SELECT row_to_json(fc)
     FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
     FROM (SELECT 'Feature' As type, geometry, row_to_json((0, 0)) As properties
       FROM (
	with init_point AS (
	  	-- get the first point for dijkstra
		select ST_Transform(geom, 26986) as train_node_geom
		from trains_node 
		where lower(station) like lower(%s) limit 1
     ), intersects_train_node_train_arc AS (
		select 
    	source as firstnode_source
  		from trains_arc as ta, init_point as ip
  		where ST_Intersects(ta.geom, ip.train_node_geom)
     ), 
		-- get the second point for dijkstra
	 second_point AS (
		select ST_Transform(geom, 26986) as train_node_geom
		from trains_node 
		where lower(station) like lower(%s) limit 1
	 ), intersects_second_train_node_train_arc AS (
		select 
		target as secondnode_source
  		from trains_arc as secTa, second_point as sp
  		where ST_DWithin(secTa.geom, sp.train_node_geom, 0.1) limit 1
	 ), 
	 -- create the shortest path from first point to second point
	 final_dijkstra AS (
		SELECT d.seq, d.node, d.edge, d.cost, ST_Transform(e.geom, 4326) AS geometry
		FROM  
    		pgr_dijkstra(
    		-- edges
        	'SELECT gid AS id, source, target, length AS cost FROM trains_arc', 
    		-- source node 
			array(SELECT firstnode_source FROM intersects_train_node_train_arc),
    		-- target node                                                                                    
			array(SELECT secondnode_source FROM intersects_second_train_node_train_arc),
        	FALSE
    		) as d                                        
    	JOIN trains_arc AS e ON d.edge = e.gid 
		ORDER BY d.seq
) select ST_AsGeoJSON(ST_Transform(geometry, 4326),15,0)::json AS geometry from final_dijkstra
    ) as lg   ) As f )  As fc;""", (stationA, stationB))
    rows = connection.fetchall()
    print(rows)

    return jsonify(rows)


##### Case 3 - Shortest path between three stations
@app.route('/connBetweenThreeStations', methods=['GET'])
def connBetweenThreeStations():

    stationA = request.args.get('stationA')
    stationB = request.args.get('stationB')
    stationC = request.args.get('stationC')

    print("Station A:", stationA)
    print("Station B:", stationB)
    print("Station C:", stationC)

    connection = conn.get_connection()
    connection.execute("""SELECT row_to_json(fc)
     FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
     FROM (SELECT 'Feature' As type, geometry, row_to_json((0, 0)) As properties
       FROM (
with init_point AS (
	
	  	-- get the first point for dijkstra
		select ST_Transform(geom, 26986) as train_node_geom
		from trains_node 
		where lower(station) like lower(%s) limit 1
     ), intersects_train_node_train_arc AS (
		select 
    	source as firstnode_source
  		from trains_arc as ta, init_point as ip 
  		where ST_DWithin(ta.geom, ip.train_node_geom, 10) limit 1
     ), 
	 
		-- get the second point for dijkstra
	 second_point AS (
		select ST_Transform(geom, 26986) as train_node_geom
		from trains_node 
		where lower(station) like lower(%s) limit 1
	 ), intersects_second_train_node_train_arc AS (
		select 
		source as secondnode_source
  		from trains_arc as secTa, second_point as sp
  		where ST_DWithin(secTa.geom, sp.train_node_geom, 10) limit 1
	 ), 
	 
	 -- create the shortest path from first point to second point
	 final_dijkstra AS (
		SELECT d.seq, d.node, d.edge, d.cost, ST_Transform(e.geom, 4326) AS geometry
		FROM  
    		pgr_dijkstra(
    		-- edges
        	'SELECT gid AS id, source, target, length AS cost FROM trains_arc', 
    		-- source node 
			array(SELECT firstnode_source FROM intersects_train_node_train_arc),
    		-- target node                                                                                    
			array(SELECT secondnode_source FROM intersects_second_train_node_train_arc),
        	FALSE
    		) as d                                        
    	JOIN trains_arc AS e ON d.edge = e.gid 
		ORDER BY d.seq
	  ), 	
	  
	 -- get the third point for second dijkstra |-_-|
	 third_point AS (
		select ST_Transform(geom, 26986) as train_node_geom
		from trains_node 
		where lower(station) like lower(%s) limit 1
	 ), intersects_third_train_node_train_arc AS (
		select 
		target as third_node_source
  		from trains_arc as thirdTa, third_point as tp
  		where ST_DWithin(thirdTa.geom, tp.train_node_geom, 10) limit 1
	 ),
	 
	 -- create the shortest path from first point to second point
	 final_dijkstra_second AS (
		SELECT d.seq, d.node, d.edge, d.cost, ST_Transform(e.geom, 4326) AS geometry
		FROM  
    		pgr_dijkstra(
    		-- edges
        	'SELECT gid AS id, source, target, length AS cost FROM trains_arc', 
    		-- source node 
			array(SELECT secondnode_source FROM intersects_second_train_node_train_arc),
    		-- target node                                                                                    
			array(SELECT third_node_source FROM intersects_third_train_node_train_arc),
        	FALSE
    		) as d                                        
    	JOIN trains_arc AS e ON d.edge = e.gid 
		ORDER BY d.seq
	  ), fin_t AS (
	    select geometry AS geometry from final_dijkstra
        UNION
        select geometry AS geometry from final_dijkstra_second
	  )
    select ST_AsGeoJSON(ST_Transform(geometry, 4326),15,0)::json AS geometry from fin_t
    ) as lg   ) As f )  As fc;""", (stationA, stationB, stationC))
    rows = connection.fetchall()
    print(rows)

    return jsonify(rows)

# MassDEP Oil and/or Hazardous Material Sites with Activity and Use Limitations
@app.route('/hazardousmaterials2', methods=['GET'])
def hazardousmaterials2():

    connection = conn.get_connection()
    connection.execute("""SELECT jsonb_build_object(
  'type',     'FeatureCollection',
  'features', jsonb_agg(feature)
)
FROM (
  SELECT jsonb_build_object(
    'type', 'Feature',
    'id', gid,
    'geometry', ST_AsGeoJSON(ST_Transform(geom,4326))::jsonb,
    'properties', jsonb_strip_nulls(jsonb_build_object(
    'name', name,
    'address', address,
    'town', town
  ))
  ) AS feature
  FROM (
    SELECT name, address, town, geom FROM aul_pt
  ) inputs
) features;""")
    rows = connection.fetchall()
    print(rows)

    return jsonify(rows)


##### Case 5
@app.route('/hazardousmaterials', methods=['GET'])
def hazardousmaterials():

    connection = conn.get_connection()
    connection.execute("""SELECT row_to_json(fc)
     FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
     FROM (SELECT 'Feature' As type, geometry, row_to_json(('name', lg.name, 'town', lg.town)) As properties
       FROM (
	
	SELECT name, address, town, ST_AsGeoJSON(ST_Transform(geom, 4326),15,0)::json AS geometry FROM aul_pt
    ) as lg   ) As f )  As fc;""")
    rows = connection.fetchall()
    print(rows)

    return jsonify(rows)


@app.route('/getallprisonpoints', methods=['GET'])
def getallprisonpoints():
    connection = conn.get_connection()
    connection.execute("""SELECT row_to_json(fc)
     FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
     FROM (SELECT 'Feature' As type, geometry, row_to_json((lg.town, lg.name)) As properties
       FROM (
	SELECT town, name, ST_AsGeoJSON(ST_Transform(geom, 4326),15,0)::json AS geometry FROM prisons
    ) as lg   ) As f )  As fc;""")
    rows = connection.fetchall()
    print(rows)
    return jsonify(rows)


@app.route('/getallrailwaystations', methods=['GET'])
def getallrailwaystations():
    connection = conn.get_connection()
    connection.execute("""SELECT row_to_json(fc)
     FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
     FROM (SELECT 'Feature' As type, geometry, row_to_json((lg.station, 0)) As properties
       FROM (
	SELECT station, ST_AsGeoJSON(ST_Transform(geom, 4326),15,0)::json AS geometry FROM trains_node
    ) as lg   ) As f )  As fc;""")
    rows = connection.fetchall()
    print(rows)
    return jsonify(rows)


##### Case 2 - Find the n nearest stations to selected prison
@app.route('/c2points', methods=['GET'])
def c2points():

    prisonTown = request.args.get('prisonTown')
    stationsNumber = request.args.get('stationsNumber')

    stationsNumber = int(stationsNumber) + 1  # because of initial prison omit

    print("Prison town:", prisonTown)
    print("Stations number:", stationsNumber)

    connection = conn.get_connection()
    connection.execute("""SELECT row_to_json(fc)
     FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
     FROM (SELECT 'Feature' As type, geometry, row_to_json((lg.distance, 0)) As properties
       FROM (
    WITH init_prison AS (
		select ST_Transform(geom, 26986) as geom
		from prisons 
		where lower(town) like lower(%s) limit 1
     ), res AS (
		select ST_Transform(tn.geom, 26986) as geom, st_distance(tn.geom, ip.geom) as distance 
  		from trains_node as tn, init_prison as ip
  		order by tn.geom <#> ip.geom
     )
    SELECT ST_AsGeoJSON(ST_Transform(geom, 4326),15,0)::json AS geometry, distance
    FROM res
    where distance<>0 -- omit initial prison 
    order by distance limit %s
    ) as lg   ) As f )  As fc;""", (prisonTown, str(stationsNumber)))
    rows = connection.fetchall()
    print(rows)
    return jsonify(rows)

@app.route('/getallbiketrails', methods=['GET'])
def getallbiketrails():
    connection = conn.get_connection()
    connection.execute("""SELECT row_to_json(fc)
     FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
     FROM (SELECT 'Feature' As type, geometry, row_to_json((0,0)) As properties
       FROM (
	SELECT ST_AsGeoJSON(ST_Transform(geom, 4326),15,0)::json AS geometry FROM biketrails_arc
    ) as lg   ) As f )  As fc;""")
    rows = connection.fetchall()
    print(rows)
    return jsonify(rows)

@app.route('/getallrivers', methods=['GET'])
def getallrivers():
    connection = conn.get_connection()
    connection.execute("""SELECT row_to_json(fc)
     FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
     FROM (SELECT 'Feature' As type, geometry, row_to_json((0,0)) As properties
       FROM (
	SELECT ST_AsGeoJSON(ST_Transform(geom, 4326),15,0)::json AS geometry FROM census_hydro_arc
    ) as lg   ) As f )  As fc;""")
    rows = connection.fetchall()
    print(rows)
    return jsonify(rows)

##### Case 4 - Cycle route which has the most river intersection
@app.route('/c4lines', methods=['GET'])
def c4lines():
    connection = conn.get_connection()
    connection.execute("""SELECT row_to_json(fc)
     FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
     FROM (SELECT 'Feature' As type, geometry, row_to_json((0, 0)) As properties
       FROM (
with t1 AS (
		select 
		bike_trail_length,
		hydro_trail_length,
		ST_Transform(bike_geom, 4326) as bike_geom,
		ST_Transform(hydro_geom, 4326) as hydro_geom,
		hydro_gid,
		bike_gid
		from hydro_biketrails_intersects
	), river_intersect_count_table AS (
		select bike_gid, count(bike_gid) as bike_gid_count
		from t1
		group by bike_gid
		order by bike_gid_count desc
		limit 1
	), join_table_bike_hydro AS (
		-- here we have the bike trail with the most intersect with rivers
		select geom as geom
		from river_intersect_count_table as ric, biketrails_arc as bta
		JOIN river_intersect_count_table ON (river_intersect_count_table.bike_gid = bta.gid)
	), fin_t AS (
		select hydro_geom as geom
		from t1, river_intersect_count_table
		where t1.bike_gid = river_intersect_count_table.bike_gid
	), fin_join_t AS (
	select geom AS geometry from join_table_bike_hydro
    UNION
    select geom AS geometry from fin_t
	)
	SELECT ST_AsGeoJSON(ST_Transform(geometry, 4326),15,0)::json AS geometry from fin_join_t
    ) as lg   ) As f )  As fc;""")
    rows = connection.fetchall()
    print(rows)
    return jsonify(rows)

#####


##### TEST QUERRIES

@app.route('/')
def hello_world():
    return 'Hello World!'


@app.route('/test1', methods=['GET'])
def test1():
    """c1landuse
    example endpoint
    """
    connection = conn.get_connection()
    # connection.execute("SELECT ST_AsGeoJSON(geom) FROM prisons")
    connection.execute("""SELECT ST_AsGeoJSON(ST_RemoveRepeatedPoints(ST_Transform(e.geom, 4326)))::json AS geometry
    FROM  
    pgr_dijkstra(
    -- edges
        'SELECT gid AS id, source, target, length AS cost FROM trains_arc', 
    -- source node 
        74,
    -- target node                                                                                    
        552, 
        FALSE
    ) as d                                         
    JOIN trains_arc AS e ON d.edge = e.gid 
    ORDER BY d.seq;""")
    rows = connection.fetchall()
    print(rows)

    return jsonify(rows)
    # json_string = json.dumps(rows)
    # g1 = geojson.loads(json_string)
    # return g1
    # return json_string
    # fixed = json_string[2:]
    # fixed = fixed[:-2]
    # print(fixed)
    print("rows was sent")
    # return fixed

    # response = app.response_class(
    #     response=json.dumps(data),
    #     status=200,
    #     mimetype='application/json'
    # )
    # return response

    # this works
    # a = {'name': 'Sarah', 'age': 24, 'isEmployed': True}
    # python2json = json.dumps(a)
    # print(python2json)
    # return python2json

    # return 'Congratulations! Your first endpoint is working'


@app.route('/test2', methods=['GET'])
def test2():
    """
    example endpoint
    """
    connection = conn.get_connection()
    # connection.execute("SELECT ST_AsGeoJSON(geom) FROM prisons")

    connection.execute("""SELECT row_to_json(fc)
 FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
 FROM (SELECT 'Feature' As type, geometry, row_to_json((0, 0)) As properties
   FROM (
SELECT
    d.seq, d.node, d.edge, d.cost, ST_AsGeoJSON(ST_Transform(e.geom, 4326),15,0)::json AS geometry
FROM  
    pgr_dijkstra(
    -- edges
        'SELECT gid AS id, source, target, length AS cost FROM trains_arc', 
    -- source node 
        74,
    -- target node                                                                                    
        552, 
        FALSE
    ) as d                                         
    JOIN trains_arc AS e ON d.edge = e.gid 
ORDER BY d.seq
) as lg   ) As f )  As fc;""")
    rows = connection.fetchall()
    print(rows)

    # return jsonify(rows)
    json_string = json.dumps(rows)
    return json_string

    # g1 = geojson.loads(jsonify(rows))
    # return g1
    # return json_string

    # this works
    # a = {'name': 'Sarah', 'age': 24, 'isEmployed': True}
    # python2json = json.dumps(a)
    # print(python2json)
    # return python2json

    return 'Congratulations! Your first endpoint is working'

@app.route('/test3', methods=['GET'])
def test3():
    """
    example endpoint
    """
    connection = conn.get_connection()
    connection.execute("SELECT ST_AsGeoJSON(ST_Transform(geom, 4326))::json AS geometry FROM prisons")
    # connection.execute("""SELECT ST_AsGeoJSON(ST_SetSRID(ST_Transform(geom, 4326)),26986)::json AS geometry
    # FROM trains_arc where type=1;""")
    rows = connection.fetchall()
    print(rows)

    return jsonify(rows)

@app.route('/test4', methods=['GET'])
def test4():
    """
    example endpoint
    """
    connection = conn.get_connection()
    connection.execute("SELECT ST_AsGeoJSON(ST_Transform(geom, 4326))::json AS geometry FROM trains_arc where type=1;")
    # connection.execute("""SELECT ST_AsGeoJSON(ST_SetSRID(ST_Transform(geom, 4326)),26986)::json AS geometry
    # FROM trains_arc where type=1;""")
    rows = connection.fetchall()
    print(rows)

    return jsonify(rows)

@app.route('/test5', methods=['GET'])
def test5():
    """
    example endpoint
    """

    param1 = request.args.get('param1')
    param2 = request.args.get('param2')

    print("I catch param1:", param1)
    print("I catch param2:", param2)

    connection = conn.get_connection()
    connection.execute("""SELECT row_to_json(fc)
     FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
     FROM (SELECT 'Feature' As type, geometry, row_to_json((0, 0)) As properties
       FROM (
    SELECT
        ST_AsGeoJSON(ST_Transform(geom, 4326),15,0)::json AS geometry
    FROM trains_arc
    ) as lg   ) As f )  As fc;""")
    rows = connection.fetchall()
    print(rows)

    return jsonify(rows)
    # json_string = json.dumps(rows)
    # return json_string


@app.route("/test")
def test():
    return "<strong>It's Alive!</strong>"


# Externally Visible Server
# If you run the server you will notice that the server is only available from your own computer, not from any other in the network. This is the default because in debugging mode a user of the application can execute arbitrary Python code on your computer. If you have debug disabled or trust the users on your network, you can make the server publicly available.
# Just change the call of the run() method to look like this:
# app.run(host='0.0.0.0')
# This tells your operating system to listen on a public IP.

if __name__ == '__main__':
    # app.run()
    app.debug = True
    app.run(host='0.0.0.0')
