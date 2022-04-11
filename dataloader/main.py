import os
import sys
import py2neo
import logging
import json

log = logging.getLogger(__name__)
log.addHandler(logging.StreamHandler())
log.setLevel(logging.DEBUG)

if __name__ == "__main__":
    SCRIPT_DIR = os.path.dirname(
        os.path.realpath(os.path.join(os.getcwd(), os.path.expanduser(__file__)))
    )
    PARENT_DIR = os.path.join(SCRIPT_DIR, "..")
    sys.path.append(os.path.normpath(PARENT_DIR))

cypher_files = [
    "load_data_observational.cypher",
    "load_data_interventional.cypher",
    "load_data_expanded_access.cypher",
]

neo4j_config_str = os.getenv("NEO4J", '{"host":"localhost"}')
neo4j_config_dict = json.loads(neo4j_config_str)
ENV = os.getenv("ENV", "prod")


def parse_cypher_file(path: str):
    """Returns a list of cypher queries in a file. Comments (starting with "//") will be filtered out and queries needs to be seperated by a semilicon

    Arguments:
        path {str} -- Path to the cypher file

    Returns:
        [str] -- List of queries
    """

    def chop_comment(line):
        # this function removes inline comments
        comment_starter = "//"
        possible_quotes = ["'", '"']
        # a little state machine with two state varaibles:
        in_quote = False  # whether we are in a quoted string right now
        quoting_char = None
        backslash_escape = False  # true if we just saw a backslash
        comment_init = ""
        for i, ch in enumerate(line):
            if not in_quote:
                if ch == comment_starter[len(comment_init)]:
                    comment_init += ch
                else:
                    # reset comment starter detection
                    comment_init = ""
                if comment_starter == comment_init:
                    # a comment started, just return the non comment part of the line
                    comment_init = ""
                    return line[: i - (len(comment_starter) - 1)]
                if ch in possible_quotes:
                    # quote is starting
                    comment_init = ""
                    quoting_char = ch
                    in_quote = True
            else:
                if ch in quoting_char:
                    # quotes is ending
                    in_quote = False
                    quoting_char = None
        return line

    queries = []
    with open(path) as f:
        query = ""
        for line in f:
            line = chop_comment(line)
            line = line.rstrip()
            if line == "":
                # empty line
                continue
            if not line.endswith("\n"):
                query += "\n"
            query += line
            if line.endswith(";"):

                query = query.strip(";")
                queries.append(query)
                query = ""

    return queries


if __name__ == "__main__":
    graph = py2neo.Graph(**neo4j_config_dict)
    for file in cypher_files:
        file_path = os.path.join(SCRIPT_DIR, file)
        queries = parse_cypher_file(file_path)
        for q in queries:
            log.info("\nRun query \n'{}'".format(q))
            tx = graph.begin()
            tx.run(q)
            tx.commit()
