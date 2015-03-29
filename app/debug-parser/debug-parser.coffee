Edge = Yarn.Edge
Parser = Yarn.Parser

class DebugParser extends Parser
  compile_edges: (nodes) ->
    edges = []
    _.each nodes, (text, source_node_id) ->
      node_components = YarnDebugStoryParser.parse(text)

      dest_node_ids = _(node_components)
        .where(type: 'link')
        .pluck('value')
        .value()

      for dest_node_id in dest_node_ids
        edges.push(new Edge(source_node_id, dest_node_id))

    return edges

  compile_page: (nodes) ->
    page = ''
    for title, text of nodes
      node_template = """
                      <h1><%- title %></h1>
                      <p><%- text %></p>
                      """
      page += _.template(node_template)(title: title, text: text)
    return page

this.Yarn.DebugParser = DebugParser
