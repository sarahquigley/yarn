
describe 'Debug Parser', ->
  test_nodes =
    start: 'Hello! I am the first node. Go to the [second] one. Or the [third] one.'
    second: 'Hi! Second node here. Go to the [third]!'
    third: "That's all folks."

  describe '#compile_page', ->
    it 'should produce a page which contains the start node text', ->
      page = new DebugParser().compile_page(test_nodes)
      expect(page).toContain(test_nodes['start'])
