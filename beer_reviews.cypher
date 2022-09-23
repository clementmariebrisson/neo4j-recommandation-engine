//  ◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘ NEO4J CONFIGURATION ◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘
//  I ▬▬▬▬▬▬ Adding apoc procedures ▬▬▬▬▬▬
    // To check neo4j version :
    call dbms.components() yield name, versions, edition unwind versions as version return name, version, edition;
    """
     If your NEO4J version is  4.1.X then download any 4.1.X apoc package
     Download jar file from https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/tag/4.1.0.12 
     Place into your $NEO4J_HOME/plugins folder. ubuntu : sudo mv /home/user0/apoc-4.1.0.12-all.jar /var/lib/neo4j/plugins/apoc-4.1.0.12-all.jar
     restart NEO4J :  sudo systemctl restart neo4j.service 
     Check if apoc is correctly installed : 
        1. Open NEO4J Desktop 
        2. execute following command : call apoc.help('apoc')
    """

//  II ▬▬▬▬▬▬ Adding beer_reviews.csv to project from VM ▬▬▬▬▬▬ 
dowload file from https://www.kaggle.com/datasets/rdoume/beerreviews
use pscp to load file on 10.8.2.35 with user:user0
change directory file to : file:/var/lib/neo4j/import/beer_reviews.csv


//  III  ▬▬▬▬▬▬ NEO4J Memory Configuration ▬▬▬▬▬▬
cd/etc/neo4j
neo4j-admin memrec --memory=4G
"""
 # Based on the above, the following memory settings are recommended:
    dbms.memory.heap.initial_size=2g
    dbms.memory.heap.max_size=2g
    dbms.memory.pagecache.size=512m
"""
// → modification of neo4j.conf

//  ◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘ NODES CONFIGURATION ◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘ 
//  I. ▬▬▬▬▬▬ Reviews ▬▬▬▬▬▬
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


//  II. ▬▬▬▬▬▬ REVIEWER ▬▬▬▬▬▬
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
        toInteger(row.brewery_id) as brewery_id,
        toString(row.review_profilename) as review_profilename
    WHERE review_profilename is not null and brewery_id < 25 // filtering on brewery id 
    MERGE (r:Reviewer {review_profilename: review_profilename})
        SET
            r.review_profilename = review_profilename
    RETURN COUNT(r);



// III. ▬▬▬▬▬▬ Beers and Breweries ▬▬▬▬▬▬
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

//  ◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘ RELATIONS CONFIGURATION ◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘◘

"""
// Creating relations between Beers and reviews:
LOAD CSV WITH HEADERS FROM 'file:///beer_reviews.csv' AS row

             WITH toInteger(row.brewery_id) AS brewery_id, toInteger(row.beer_beerid) AS beer_beerid, toString(row.review_profilename) AS review_profilename
             MATCH (p:Reviewer {review_profilename: review_profilename})
             MATCH (o:Beers {brewery_id: brewery_id, beer_beerid: beer_beerid})
             MERGE (o)-[rel:CONTAINS {review_profilename: review_profilename}]->(p)
             RETURN count(rel);
"""

// I. ▬▬▬▬▬▬  Creating relations between Review and Reviewer ▬▬▬▬▬▬
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///beer_reviews.csv' AS row
    WITH toInteger(row.brewery_id) AS brewery_id, toInteger(row.beer_beerid) AS beer_beerid, toString(row.review_profilename) AS review_profilename
    MATCH (p:Reviewer {review_profilename: review_profilename})
    MATCH (o:Reviews {review_profilename: review_profilename, brewery_id: brewery_id, beer_beerid: beer_beerid})
    MERGE (o)-[rel:did_a_review {review_profilename: review_profilename}]->(p)
    RETURN count(rel);


// II. ▬▬▬▬▬▬  Creating relations between Reviews and Beers ▬▬▬▬▬▬
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///beer_reviews.csv' AS row
    WITH toInteger(row.brewery_id) AS brewery_id, toInteger(row.beer_beerid) AS beer_beerid, toString(row.review_profilename) AS review_profilename
    MATCH (p:Reviews {brewery_id: brewery_id, beer_beerid: beer_beerid, review_profilename: review_profilename})
    MATCH (o:Beers {brewery_id: brewery_id, beer_beerid: beer_beerid})
    MERGE (o)-[rel:reviewed {brewery_id: brewery_id, beer_beerid: beer_beerid, review_profilename: review_profilename}]->(p)
    RETURN count(rel);



// ▬▬▬▬▬▬  Displaying all relations and nodes ▬▬▬▬▬▬
    // Initial limit of displayed nodes is 300. To change it, run this command :
:config initialNodeDisplay: 1000

    // Command to display all nodes from all relations
MATCH
     p=()-[r:did_a_review]->() , 
     q=()-[s:reviewed]->()
RETURN p,q  
LIMIT 500

    // All reviews from review_profilename: "philbertk" 
MATCH p=(m:Reviews {review_profilename:"philbertk"})<-[:reviewed]-(beer_name)
RETURN beer_name;

    //All beers and reviews done by "philbertk"
MATCH q=()-[s:reviewed]-({review_profilename:"philbertk"}),
     p=()-[t:did_a_review]-({review_profilename:"philbertk"})
RETURN p,q

    // All reviews from 'Widmer Hefeweizen' beer :
MATCH q=()-[s:reviewed]-({beer_name: "Widmer Hefeweizen"})
RETURN q


    // Similar content : →→ NOT WORKING ←←
//MATCH (b:Beers {beer_name: "Widmer Hefeweizen"})<-[:reviewed]-(u:review_profilename)-[:reviewed]->(rec:Beers)
//RETURN rec.beer_name AS recommendation, COUNT(*) AS usersWhoAlsoLiked
//ORDER BY usersWhoAlsoLiked DESC LIMIT 25