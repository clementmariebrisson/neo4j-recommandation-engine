<h1 align=center>NEO4J recommandation engine</h1>

<h2>Dataset Description:</h2>
Database containing reviews of beers by people. The dataset contains 1.5 million reviews. Different criteria are evoked with a note going from 0 to 5, other specificities are present like the style of the beer. 

<h2>Description of the database functioning:</h2>
The Neo4j base is used to recommend beers according to our tastes and the reviews made by the members of the base. There are 3 types of nodes and 2 types of relationships:

* Nodes
    * Reviewer
    * Review
    * Beers
* Relationships
    * Reviewer ↔ Review
    * Review ↔ Beers

Each Reviewer can rate beers via a Review, with the graph thus obtained we can query the database to know which beers are the most rated, the best rated or find the beers that match specific criteria.

<h2>Benchmark</h2> 
The file <i>Rapport Neo4J.docx</i> is a benchmark wrote in french about the NEO4J software. 

<h2>Beer recommandation</h2>

NEO4J is widely used to make recommendations. So we wanted to test this functionality. We started from the NEO4J documentation which is very detailed, then we adapted the codes to our use case.

We built the algorithm to find the similar beers of a given beer. To establish whether a beer is similar to another, we chose to proceed in steps. 
1. First, We select the beers that have been rated by users who have reviewed a given beer. 
2. Then, among the beers we have, we keep only the beers with a rating at least equal to 4/5.
3. Thus, we have a list of beers similar to our beer. We then sort the beers according to the number of times they appear in the list.
4. The beers on the top of the list are those which are recommanded.
