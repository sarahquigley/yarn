describe 'DebugStory', ->

  story = undefined

  beforeEach ->
    story = new DebugStory()

  describe '#add_node', ->
    describe 'if a node with the node_id of the new node does not exist', ->
      it 'should add a new node', ->
        expect(story.nodes.test_node).toBeUndefined()
        story.add_node('test_node', 'test')
        expect(story.nodes.test_node).toEqual('test')

    describe 'if a node with the node_id of the new node exists', ->
      beforeEach ->
        story.nodes = {test_node: 'test'}
        spyOn(window, 'alert')
        story.add_node('test_node', 'test2')

      it 'should not add a new node', ->
        expect(Object.keys(story.nodes).length).toEqual(1)

      it 'should not alter the node text of the pre-existing node', ->
        expect(story.nodes.test_node).toEqual('test')

      it 'should pop up an alert', ->
        expect(window.alert).toHaveBeenCalled()

  describe '#to_json', ->
    it 'should return plain javascript object in expected format', ->
      story.title = 'Test Story'
      story.nodes = {test_node: 'test', test_node_2: 'test2'}
      expect(story.to_json()).toEqual({title: story.title, nodes: story.nodes})

  describe '#update_title', ->
    it 'should update the story\'s title to the specified value', ->
      story.update_title('Test title')
      expect(story.title).toEqual('Test title')

  describe '#update_node_id', ->
    describe 'if a node with the new node_id does not exist', ->
      it 'should update the node_id of the specified node', ->
        story.nodes.test_node = 'test'
        story.update_node_id('test_node', 'my_test_node')
        expect(story.nodes.test_node).toBeUndefined()
        expect(story.nodes.my_test_node).toEqual('test')

    describe 'if a node with the new node_id exists', ->
      result = undefined

      beforeEach ->
        story.nodes = {test_node: 'test', test_node_2: 'test2'}
        result = story.update_node_id('test_node_2', 'test_node')

      it 'should return a string (error string for x-editable)', ->
        expect(result).toEqual(jasmine.any(String))

      it 'should not update the node_id of the specified node', ->
        expect(story.nodes.test_node).toEqual('test')
        expect(story.nodes.test_node_2).toEqual('test2')


  describe '#update_node_text', ->
    it 'should update the text of the specified node', ->
      story.nodes.test_node = ''
      story.update_node_text('test_node', 'test')
      expect(story.nodes.test_node).toEqual('test')

  describe '.from_json', ->
    it 'should correctly construct a DebugStory from a story_id and the jsonified story', ->
      story_from_json = DebugStory.from_json(story.id, story.to_json())
      expect(story_from_json).toEqual(jasmine.any(DebugStory))
      expect(_.isEqual(story_from_json, story)).toBe(true)


describe 'DebugStoryStorage', ->

  beforeEach ->

  describe '#clear', ->

  describe '#save_story', ->

  describe '#stories', ->
