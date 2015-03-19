describe 'Debug Parser', ->
  DebugParser = Yarn.DebugParser
  Edge = Yarn.Edge

  TEST_NODES =
    start: 'Hello! I am the first node. Go to the [second] one. Or the [third] one.'
    second: 'Hi! Second node here. Go to the [third]!'
    third: "That's all folks."

  describe '#compile_page', ->
    it 'should produce a page which contains the start node text', ->
      page = new DebugParser().compile_page(TEST_NODES)
      expect(page).toContain(TEST_NODES['start'])

  describe '#compile_graph', ->
    it 'should parse out both links from the start node', ->
      graph = new DebugParser().compile_graph(TEST_NODES)
      edges = graph.edges_by_node('start')

      expect(edges.length).toEqual(2)
      expect(edges).toContain(new Edge('start', 'second'))
      expect(edges).toContain(new Edge('start', 'third'))

    it 'should parse out the sole link from the second node', ->
      graph = new DebugParser().compile_graph(TEST_NODES)
      edges = graph.edges_by_node('second')

      expect(edges).toEqual([new Edge('second', 'third')])

    it 'should not have any links from the third node', ->
      graph = new DebugParser().compile_graph(TEST_NODES)
      edges = graph.edges_by_node('third')

      expect(edges).toEqual([])
