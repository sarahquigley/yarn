DebugParser = new window.Yarn.DebugParser()

class DebugStory
  constructor: (@id = 'yarn-' + _.uuid(), @title = 'My New Story', @nodes = {}) ->

  # Public Methods
  add_node: (node_id, text) ->
    if @_contains(node_id)
      throw "Node with title #{node_id} already exists."
    @nodes[node_id] = text

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
  constructor: (@storage, @parser) ->

  # Public Methods
  clear: ->
    for key in _.keys(@storage)
      @storage.removeItem(key) if _.startsWith(key, 'yarn-')

  save_story: (story) ->
    @storage.setItem(story.id, JSON.stringify(story.to_json()))
    @storage.setItem(story.id + '-story', @parser.compile_page(story.nodes))

  stories: ->
    stories = {}
    for id in @_story_ids()
      stories[id] = @_load_story(id)
    return stories

  # Private Methods
  _story_ids: ->
    return _.filter _.keys(@storage), (key) ->
      return _.startsWith(key, 'yarn-') && !_.endsWith(key, '-story')

  _load_story: (id) ->
    try
      return DebugStory.from_json(id,
        JSON.parse(@storage.getItem(id)))
    catch error
      throw "Error parsing story with id=#{id}: #{error}\n"

window.DebugStory = DebugStory
window.DebugStoryStorage = DebugStoryStorage
