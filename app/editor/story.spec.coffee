describe 'Story', ->

  story = undefined

  beforeEach ->
    story = new Story()

  describe '#add_node', ->
    describe 'if a node with the node_id of the new node does not exist', ->
      it 'should add a new node', ->
        expect(story.nodes.test_node).toBeUndefined()
        story.add_node('test_node', 'test')
        expect(story.nodes.test_node).toEqual('test')

    describe 'if a node with the node_id of the new node exists', ->
      it 'should throw an error, and leave nodes unchanged', ->
        story.nodes = {test_node: 'test'}
        expect(-> story.add_node('test_node', 'test2')).toThrow()
        expect(Object.keys(story.nodes).length).toEqual(1)
        expect(story.nodes.test_node).toEqual('test')

  describe '#delete_node', ->
    it 'should remove specified node from the story\'s nodes array', ->
      story.nodes = {test_node: 'test'}
      story.delete_node('test_node')
      expect(story.nodes.test_node).toBeUndefined()

    it 'should throw an error if specified node does not exist', ->
      expect(-> story.delete_node('test_node')).toThrow()

  describe '#to_json', ->
    it 'should return plain javascript object in expected format', ->
      story.title = 'Test Story'
      story.nodes = {test_node: 'test', test_node_2: 'test2'}
      expect(story.to_json()).toEqual({title: story.title, nodes: story.nodes})

  describe '#set_title', ->
    it 'should set the story\'s title to the specified value', ->
      story.set_title('Test title')
      expect(story.title).toEqual('Test title')

  describe '#update_node_id', ->
    describe 'if a node with the new node_id does not exist', ->
      it 'should update the node_id of the specified node', ->
        story.nodes.test_node = 'test'
        story.update_node_id('test_node', 'my_test_node')
        expect(story.nodes.test_node).toBeUndefined()
        expect(story.nodes.my_test_node).toEqual('test')

    describe 'if a node with the new node_id exists', ->
      beforeEach ->
        story.nodes = {test_node: 'test', test_node_2: 'test2'}

      it 'should throw an error and leave nodes unchanged', ->
        expect(-> story.update_node_id('test_node_2', 'test_node')).toThrow()
        expect(story.nodes.test_node).toEqual('test')
        expect(story.nodes.test_node_2).toEqual('test2')

  describe '#update_node_text', ->
    it 'should update the text of the specified node', ->
      story.nodes.test_node = ''
      story.update_node_text('test_node', 'test')
      expect(story.nodes.test_node).toEqual('test')

  describe 'has_nodes', ->
    it 'should return true if the story has nodes', ->
      expect(story.has_nodes()).toBe(false)

    it 'should return false if the story has no nodes', ->
      story.nodes = {test_node: 'test'}
      expect(story.has_nodes()).toBe(true)

  describe '.from_json', ->
    it 'should correctly construct a Story from a story_id and the jsonified story', ->
      story_from_json = Story.from_json(story.id, story.to_json())
      expect(story_from_json).toEqual(jasmine.any(Story))
      expect(_.isEqualIgnoringFxn(story, story_from_json)).toBe(true)


describe 'StoryStorage', ->

  story_storage = undefined
  localStorage = undefined
  story1 = undefined
  story2 = undefined
  DebugParser = undefined

  beforeEach ->
    DebugParser = jasmine.createSpyObj('DebugParser', ['compile_page'])
    DebugParser.compile_page.and.callFake((nodes) ->
      return '<code>' + JSON.stringify(nodes) + '</code>'
    )
    story1 = new Story()
    story2 = new Story()
    localStorage = new MockLocalStorage()
    story_storage = new StoryStorage(localStorage, DebugParser)
    localStorage.setItem(story1.id, JSON.stringify(story1.to_json()))
    localStorage.setItem(story2.id, JSON.stringify(story2.to_json()))

  describe '#clear', ->
    beforeEach ->
      localStorage.setItem('test', 'test value')
      story_storage.clear()

    it 'should clear all keys beginning with "yarn-" from storage', ->
      expect(localStorage.getItem(story1.id)).not.toBeDefined()
      expect(localStorage.getItem(story2.id)).not.toBeDefined()

    it 'should not clear keys that do not begin with "yarn-" from storage', ->
      expect(localStorage.getItem('test')).toEqual('test value')

  describe '#save_story', ->
    story = undefined

    beforeEach ->
      story = new Story()
      story_storage.save_story(story)

    it 'should save the serialized story to storage with expected reference key', ->
      serialized_story = JSON.stringify(story.to_json())
      expect(localStorage.getItem(story.id)).toEqual(serialized_story)

    it 'should save the compiled story to storage with expected reference key', ->
      compiled_story = DebugParser.compile_page(story.nodes)
      expect(localStorage.getItem(story.id + '-story')).toEqual(compiled_story)

  describe '#stories', ->
    it 'should return an object containing all stories in storage as Story objects, using their ids as keys', ->
      stories = story_storage.stories()
      expect(_.keys(stories).length).toEqual(2)
      expect(_.isEqualIgnoringFxn(stories[story1.id], story1)).toBe(true)
      expect(_.isEqualIgnoringFxn(stories[story2.id], story2)).toBe(true)
