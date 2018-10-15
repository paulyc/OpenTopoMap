#!/bin/bash

# (c) OpenTopoMap under CC-BY-SA license
# author: Martin Schuetz
# An interactive script for generating worldwide garmin files

ROOT_DIR=/home/otmuser/garmintest
ROOT_DIR=/home/mortl/garminworld

# Programme
SPLITTER_JAR=/usr/src/splitter/splitter.jar
MKGMAP_JAR=/usr/src/mkgmap/mkgmap.jar
POLY24_CMD=$ROOT_DIR/poly24.py

# Temp dirs
SPLITTER_OUTPUT_ROOT_DIR=$ROOT_DIR/out/splitter_out
MKGMAP_OUTPUT_ROOT_DIR=$ROOT_DIR/out/mkgmap_out
MKGMAP_CONTOURS_OUTPUT_ROOT_DIR=$MKGMAP_OUTPUT_ROOT_DIR

# Data dirs
OSM_WORLD_FILE=$ROOT_DIR/bayern-latest.osm.pbf

# Log files
SPLITTER_LOG=$ROOT_DIR/splitter.log
MKGMAP_LOG=$ROOT_DIR/mkgmap.log

# Option files
MKGMAP_OPTS=$ROOT_DIR/git/OpenTopoMap/garmin/opentopomap_options
MKGMAP_STYLE_FILE=$ROOT_DIR/git/OpenTopoMap/garmin/style/opentopomap
MKGMAP_TYP_FILE=$ROOT_DIR/git/OpenTopoMap/garmin/style/typ/OpenTopoMap.typ

#README_FILE=/var/www/otm_garmin/osm/readme.txt
#OSM_DATA_DIR=/var/www/otm_garmin/osm/data
#BOUNDS_DATA_DIR=/usr/src/bounds/bounds
#SEA_DATA_DIR=/usr/src/sea/sea
#WWW_OUT_ROOT_DIR=/var/www/otm_garmin/www/data

echo "******************************************"
echo "*	   This is the generate_garmin skript  "
echo "*                                        "
echo "*  splitter jar: $SPLITTER_JAR           "
echo "*  mkgmap   jar: $MKMAP_JAR              "
echo "*"
echo "*  osm world file: $OSM_WORLD_FILE"
echo "*"  
echo "*  splitter out dir: $SPLITTER_OUTPUT_ROOT_DIR"
echo "*                                        "
echo "o  mkgmaps opts: $MKGMAP_OPTS             "
echo "******************************************"

echo "Press enter to continue"
# temp removed #read continue

if [ ! -d $SPLITTER_OUTPUT_ROOT_DIR ]
then
	mkdir -p $SPLITTER_OUTPUT_ROOT_DIR
fi

if [ ! -d $MKGMAP_OUTPUT_ROOT_DIR ]
then
	mkdir -p $MKGMAP_OUTPUT_ROOT_DIR
fi

#echo "Split World file"
# temp removed #java -jar $SPLITTER_JAR $OSM_WORLD_FILE --output-dir=$SPLITTER_OUTPUT_ROOT_DIR 2>&1 > $SPLITTER_LOG

continents="bayern"
#continents="africa antarctica asia australia-oceania central-america europe north-america south-america"
#continents="australia-oceania"
#continents="africa"
continents="asia"
continents="north-america"
continents="antarctica central-america south-america"
continents="europe"

for continent in $continents
do
	echo "Generate Continent $continent"

	#for polyfile in download.geofabrik.de/europe/germany/bayern/*.poly
	#for polyfile in download.geofabrik.de/europe/germany/bayern/mittelfranken.poly
	
        for polyfile in download.geofabrik.de/$continent/*.poly
        do
		countryname=${polyfile%.*}
		countryname=${countryname##*/}

		echo "Generate $countryname with polyfile $polyfile"

                SPLITTER_OUTPUT_ROOT_DIR="$continent-splitter-out"

		osmpbfs=`$POLY24_CMD $polyfile $SPLITTER_OUTPUT_ROOT_DIR/areas.list`

		mkgmapin=""

		for p in $osmpbfs
		do
#			mkgmapin="${mkgmapin}input-file=$SPLITTER_OUTPUT_ROOT_DIR/$p\n"
			mkgmapin="${mkgmapin}$SPLITTER_OUTPUT_ROOT_DIR/$p "
		done

                echo "mkmapin: $mkgmapin"

		echo -ne $mkgmapin > /tmp/mkgmapopts.txt

#		java -jar $MKGMAP_JAR -c /tmp/mkgmapopts.txt --output-dir=$MKGMAP_OUTPUT_ROOT_DIR -c $MKGMAP_OPTS --style-file=$MKGMAP_STYLE_FILE $MKGMAP_TYP_FILE
#		java -jar $MKGMAP_JAR $mkgmapin --output-dir=$MKGMAP_OUTPUT_ROOT_DIR -c $MKGMAP_OPTS --style-file=$MKGMAP_STYLE_FILE $MKGMAP_TYP_FILE

                MKGMAP_OUTPUT_DIR=$MKGMAP_OUTPUT_ROOT_DIR/$continent/$countryname

                mkdir -p $MKGMAP_OUTPUT_DIR

                echo "mkgmap output dir: $MKGMAP_OUTPUT_DIR"

                rm *.img

		java -jar $MKGMAP_JAR $mkgmapin -c $MKGMAP_OPTS --output-dir=$MKGMAP_OUTPUT_DIR --style-file=$MKGMAP_STYLE_FILE $MKGMAP_TYP_FILE

                mv *.img $MKGMAP_OUTPUT_DIR/.
	done
done