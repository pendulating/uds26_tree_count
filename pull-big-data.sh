# Street Flooding Project 
# Developer: Matt Franchi, @mattwfranchi 
# Cornell Tech 

# This script pulls the necessary geographic datasets for the creation of our analysis dataframe. 

# Create data directory
mkdir -p big_data




# need to page through this api endpoint using offset, LIMIT rows at a time
OFFSET=0
LIMIT=50000

# NYCOpenData: Forestry Tree Points (https://data.cityofnewyork.us/resource/hn5i-inap.geojson)
forestry_tree_points="https://data.cityofnewyork.us/resource/hn5i-inap.geojson"

while true; 
do
    wget -O big_data/forestry_tree_points_${OFFSET}.geojson "${forestry_tree_points}?\$limit=${LIMIT}&\$offset=${OFFSET}"
    # count features in the GeoJSON response (not lines)
    FEATURE_COUNT=$(jq '.features | length' big_data/forestry_tree_points_${OFFSET}.geojson)
    echo "Offset ${OFFSET}: got ${FEATURE_COUNT} features"
    if [ "$FEATURE_COUNT" -lt "$LIMIT" ]; then
        break
    fi
    OFFSET=$((OFFSET+LIMIT))
done

# merge all paged GeoJSON files into a single FeatureCollection
jq -s '{type: "FeatureCollection", features: [.[].features[]]}' big_data/forestry_tree_points_*.geojson > big_data/forestry_tree_points.geojson

# delete the intermediate files
rm big_data/forestry_tree_points_*.geojson


