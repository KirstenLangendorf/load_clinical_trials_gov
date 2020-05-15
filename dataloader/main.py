import os
import sys
import py2neo

if __name__ == "__main__":
    SCRIPT_DIR = os.path.dirname(
        os.path.realpath(os.path.join(os.getcwd(), os.path.expanduser(__file__)))
    )
    SCRIPT_DIR = os.path.join(SCRIPT_DIR, "..")
    sys.path.append(os.path.normpath(SCRIPT_DIR))

dataset_path = os.path.join(SCRIPT_DIR,"../dataset")

download_dummy_function(dataset_path)


neo4j_url = os.getenv('GC_NEO4J_URL', 'bolt://localhost:7687')
neo4j_user = os.getenv('GC_NEO4J_USER', 'neo4j')
neo4j_pw = os.getenv('GC_NEO4J_PASSWORD', 'test')
ENV = os.getenv('ENV', 'prod')

graph = py2neo.Graph(neo4j_url, user=neo4j_user, password=neo4j_pw)

dummy_data = data_parsing_dummy_function(dataset_path)

for dd in dummy_data:
    # just an bad example :) dont do it like this
    graph.run("CREATE (n:Person { name: '"+dd.name+"', title: '"+dd.title+"' })")