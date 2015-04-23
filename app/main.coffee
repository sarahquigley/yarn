class Edge
  constructor: (@source, @destination) ->

class Graph
  constructor: (@nodes = {}, @edges = []) ->
    # TODO: some validation of the types!
    #
    # @nodes: dict of {node_id: node_text}
    # @edges: [Edge]

  edges_by_node: (node_id) ->
    return _.where(@edges, {source: node_id})


class Parser
  compile_graph: (nodes) ->
    # Parses the nodes to figure out what the set of edges is,
    # and returns a graph of the nodes + edges.
    edges = @compile_edges(nodes)
    return new Graph(nodes, edges)

  compile_page: (nodes) ->
    # Parses the nodes, and builds the finished single page app from them.
    # Returns the text of this page? Renders it into a passed-in element?
    # Who knows, let's figure that out later!
    throw 'NotImplementedError'

  compile_edges: (nodes) ->
    throw 'NotImplementedError'

this.Yarn ||= {}
this.Yarn.Edge = Edge
this.Yarn.Graph = Graph
this.Yarn.Parser = Parser
