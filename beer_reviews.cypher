//  ▬▬▬▬▬▬ Adding apoc procedures ▬▬▬▬▬▬
    // To check neo4j version :
    call dbms.components() yield name, versions, edition unwind versions as version return name, version, edition;
    //Download jar file from https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/4.4.0.8 
    //Place into your $NEO4J_HOME/plugins folder.

//  ▬▬▬▬▬▬ Adding beer_reviews.csv to project from VM ▬▬▬▬▬▬ 
dowload file from https://www.kaggle.com/datasets/rdoume/beerreviews
use pscp to load file on 10.8.2.35 with user:user0
change directory file to : file:/var/lib/neo4j/import/beer_reviews.csv


// NEO4J Memory Configuration :
cd /etc/neo4j
neo4j-admin memrec --memory=4G
"""
 # Based on the above, the following memory settings are recommended:
    dbms.memory.heap.initial_size=2g
    dbms.memory.heap.max_size=2g
    dbms.memory.pagecache.size=512m
"""
// → modification of neo4j.conf

//  ▬▬▬▬▬▬ Reviews ▬▬▬▬▬▬
    // Creating the table
LOAD CSV WITH HEADERS FROM 'file:///beer_reviews.csv' AS row
    WITH
        toIntegerOrNull(row.brewery_id) as brewery_id,
        toIntegerOrNull(row.beer_beerid) as beer_beerid,
        toStringOrNull(row.review_profilename) as review_profilename,
        toIntegerOrNull(row.review_palate) as review_palate,
        toIntegerOrNull(row.review_appearance) as review_appearance,
        toIntegerOrNull(row.review_aroma) as review_aroma,
        toIntegerOrNull(row.review_overall) as review_overall,
        toIntegerOrNull(row.review_taste) as review_taste
    RETURN 
        brewery_id,
        beer_beerid,
        review_palate,
        review_profilename,
        review_appearance,
        review_aroma,
        review_overall,
        review_taste
    LIMIT 5;

    // Creating nodes for the graph
LOAD CSV WITH HEADERS FROM 'file:///beer_reviews.csv' AS row
    WITH
        toInteger(row.brewery_id) as brewery_id,
        toInteger(row.beer_beerid) as beer_beerid,
        toInteger(row.review_palate) as review_palate,
        toString(row.review_profilename) as review_profilename,
        toInteger(row.review_appearance) as review_appearance,
        toInteger(row.review_aroma) as review_aroma,
        toInteger(row.review_overall) as review_overall,
        toInteger(row.review_taste) as review_taste
    WHERE brewery_id >=24 and brewery_id<26 and review_profilename is not null
    MERGE (r:Reviews {brewery_id: brewery_id, beer_beerid: beer_beerid, review_profilename: review_profilename})
    SET 
        r.brewery_id = brewery_id,
        r.beer_beerid = beer_beerid,
        r.review_palate = review_palate,
        r.review_profilename = review_profilename,
        r.review_appearance = review_appearance,
        r.review_aroma = review_aroma,
        r.review_overall = review_overall,
        r.review_taste = review_taste
    RETURN 
        count(r);

    // To displays created nodes
MATCH (n)
RETURN n


//  ▬▬▬▬▬▬ REVIEWER ▬▬▬▬▬▬
    // Creating the table
LOAD CSV WITH HEADERS FROM 'file:///beer_reviews.csv' AS row
    WITH
        toStringOrNull(row.review_profilename) as review_profilename
    RETURN 
        DISTINCT review_profilename
    LIMIT 5;

    // Creating nodes for the graph
LOAD CSV WITH HEADERS FROM 'file:///beer_reviews.csv' AS row
    WITH
        toString(row.review_profilename) as review_profilename
    WHERE review_profilename is not null and substring(toLower(review_profilename), 1, 1) in ['a', 'b']
    MERGE (r:Reviewer {review_profilename: review_profilename})
        SET
            r.review_profilename = review_profilename
    RETURN COUNT(r);


//['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm']


// ▬▬▬▬▬▬ Beers and Breweries ▬▬▬▬▬▬

LOAD CSV WITH HEADERS FROM 'file:///beer_reviews.csv' AS row
    WITH
        toIntegerOrNull(row.brewery_id) as brewery_id,
        toIntegerOrNull(row.beer_beerid) as beer_beerid,
        toStringOrNull(row.brewery_name) as brewery_name,
        toStringOrNull(row.beer_name) as beer_name,
        toStringOrNull(row.beer_style) as beer_style,
        toIntegerOrNull(row.beer_abv) as beer_abv
    RETURN
        brewery_id,
        beer_beerid,
        brewery_name,
        beer_name,
        beer_style,
        beer_abv
    LIMIT 5;
 


LOAD CSV WITH HEADERS FROM 'file:///beer_reviews.csv' AS row
    WITH
        toInteger(row.brewery_id) as brewery_id,
        toInteger(row.beer_beerid) as beer_beerid,
        toString(row.brewery_name) as brewery_name,
        toString(row.beer_name) as beer_name,
        toString(row.beer_style) as beer_style,
        toInteger(row.beer_abv) as beer_abv
    WHERE brewery_id < 25
    MERGE (b:Beers {brewery_id: brewery_id, beer_beerid:beer_beerid})
    SET 
        b.brewery_id = brewery_id,
        b.beer_beerid = beer_beerid,
        b.brewery_name = brewery_name,
        b.beer_name = beer_name,
        b.beer_style = beer_style,
        b.beer_abv = beer_abv
    RETURN 
        count(b);








// Creating relations between Beers and reviews:

LOAD CSV WITH HEADERS FROM 'file:///beer_reviews.csv' AS row

             WITH toInteger(row.brewery_id) AS brewery_id, toInteger(row.beer_beerid) AS beer_beerid, toString(row.review_profilename) AS review_profilename
             MATCH (p:Reviewer {review_profilename: review_profilename})
             MATCH (o:Beers {brewery_id: brewery_id, beer_beerid: beer_beerid})
             MERGE (o)-[rel:CONTAINS {review_profilename: review_profilename}]->(p)
             RETURN count(rel);


####################################################################################################################################
############################################################## A TESTER ############################################################
####################################################################################################################################

// Creating relations between Review and Reviewer:

LOAD CSV WITH HEADERS FROM 'file:///beer_reviews.csv' AS row
    WITH toInteger(row.brewery_id) AS brewery_id, toInteger(row.beer_beerid) AS beer_beerid, toString(row.review_profilename) AS review_profilename
    MATCH (p:Reviewer {review_profilename: review_profilename})
    MATCH (o:Reviews {review_profilename: review_profilename, brewery_id: brewery_id, beer_beerid: beer_beerid})
    MERGE (o)-[rel:did_a_review {review_profilename: review_profilename}]->(p)
    RETURN count(rel);


// Creating relations between Reviews and Beers:
// ►►► OK
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///beer_reviews.csv' AS row
    WITH toInteger(row.brewery_id) AS brewery_id, toInteger(row.beer_beerid) AS beer_beerid, toString(row.review_profilename) AS review_profilename
    MATCH (p:Reviews {review_profilename: review_profilename})
    MATCH (o:Beers {brewery_id: brewery_id, beer_beerid: beer_beerid})
    MERGE (o)-[rel:reviewed {review_profilename: review_profilename}]->(p)
    RETURN count(rel);