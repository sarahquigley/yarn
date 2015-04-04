DebugParser = new window.Yarn.DebugParser()

class DebugStory
  constructor: (@id = 'yarn-' + _.uuid(), @title = 'My New Story', @nodes = {}) ->

  # Public Methods
  add_node: (node_id, text) ->
    if @_contains(node_id)
      alert('Node with this title already exists.')
      return false
    @nodes[node_id] = text
    return true

  to_json: () ->
   return {title: @title, nodes: @nodes}

  update_title: (title) ->
    @title = title
    return true

  update_node_id: (node_id, new_node_id) ->
    if node_id == new_node_id
      return true
    if @_contains(new_node_id)
      return 'Node with this title already exists.'
    @nodes[new_node_id] = @nodes[node_id]
    delete @nodes[node_id]
    return true

  update_node_text: (node_id, node_text) ->
    @nodes[node_id] = node_text
    return true

  # Private Methods
  _contains: (node_id) ->
    return _.contains(_.keys(@nodes), node_id)

  # Class Methods
  @from_json: (id, json_object) ->
    return new DebugStory(id, json_object.title, json_object.nodes)


class DebugStoryStorage
  constructor: (@storage) ->

  # Public Methods
  clear: ->
    for key in _.keys(@storage)
      @storage.removeItem(key) if _.startsWith(key, 'yarn-')

  save_story: (story) ->
    @storage.setItem('yarn-story-id', story.id)
    @storage.setItem(story.id, JSON.stringify(story.to_json()))
    @storage.setItem(story.id + '-story', DebugParser.compile_page(story.nodes))

  stories: ->
    stories = {}
    for id in @_story_ids()
      stories[id] = @_load_story(id)
    return stories

  # Private Methods
  _story_ids: ->
    return _.filter _.keys(@storage), (key) ->
      return _.startsWith(key, 'yarn-') && !_.endsWith(key, '-story') && !_.endsWith(key, 'story-id')

  _load_story: (id) ->
    try
      json_object = JSON.parse(@storage.getItem(id))
    catch error
      json_object = undefined
      console.log('Error deserializing nodes from localStorage: ' + error)
    return DebugStory.from_json(id, json_object)

window.DebugStory = DebugStory
window.DebugStoryStorage = DebugStoryStorage
