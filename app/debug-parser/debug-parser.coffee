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
      items = YarnDebugStoryParser.parse(text)

      node_template = """
                      <div id="<%- title %>">
                        <h1><%- title %></h1>
                        <p><% 
                          _.forEach(items, function(item) {
                            if (item.type == 'link') {
                              %><a href="#"><%- item.value %></a><%
                            } else {
                              %><%- item.value %><%
                            }
                          });
                        %></p>
                      </div>
                      """
      page += _.template(node_template)(title: title, items: items)
    return page

this.Yarn.DebugParser = DebugParser
