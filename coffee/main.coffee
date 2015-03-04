

class Edge
  constructor: (@source, @dest) ->

class Graph
  constructor: (@nodes = {}, @edges = {}) ->
    # TODO: some validation of the types!
    #
    # @nodes: dict of {node_id: node_text}
    # @edges: [Edge]


class Parser
  compile_graph: (nodes) ->
    # Parses the nodes to figure out what the set of edges is,
    # and returns a graph of the nodes + edges.
    edges = compile_edges(nodes)
    return new Graph(nodes, edges)

  compile_page: (nodes) ->
    # Parses the nodes, and builds the finished single page app from them.
    # Returns the text of this page? Renders it into a passed-in element?
    # Who knows, let's figure that out later!
    throw 'NotImplementedError'

  compile_edges: (nodes) ->
    throw 'NotImplementedError'


window.test_nodes =
  start: 'Hello! I am the first node. Go to the [second] one.'
  second: 'Hi! Second node here. Go to the [third]!'
  third: "That's all folks."


class DebugParser extends Parser
  compile_edges: (nodes) ->
    brace_regex = /\[[^[]+\]/
    edges = []
    _.each nodes, (text, source_node_id) ->
      dest_node_ids = _.map text.match(brace_regex), (link) ->
        _.trim(link, '[]')

      for dest_node_id in dest_node_ids
        edges.push(new Edge(source_node_id, dest_node_id))

    return edges

window.DebugParser = DebugParser
