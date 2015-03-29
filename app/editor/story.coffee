DebugParser = new window.Yarn.DebugParser()

class DebugStory
  constructor: (@id = 'yarn-' + _.uuid(), @nodes = {}) ->

  _contains: (node_id) ->
    return _.contains(_.keys(@nodes), node_id)

  add_node: (node_id, text) ->
    if @_contains(node_id)
      alert('Node with this title already exists.')
      return false
    @nodes[node_id] = text
    return true

  update_node_text: (node_id, node_text) ->
    @nodes[node_id] = node_text
    return true

  update_node_id: (node_id, new_node_id) ->
    if node_id == new_node_id
      return true
    if @_contains(new_node_id)
      return 'Node with this title already exists.'
    @nodes[new_node_id] = @nodes[node_id]
    delete @nodes[node_id]
    return true

  to_json: () ->
   return {nodes: @nodes}

  @from_json: (id, json_object) ->
    return new DebugStory(id, json_object.nodes)


class StoryStorage
  constructor: (@storage) ->

  load_story: (id) ->
    try
      json_object = JSON.parse(@storage.getItem(id))
    catch error
      json_object = undefined
      console.log('Error deserializing nodes from localStorage: ' + error)
    return DebugStory.from_json(id, json_object)

  save_story: (story) ->
    @storage.setItem(story.id, JSON.stringify(story.to_json()))
    @storage.setItem(story.id + '-story', DebugParser.compile_page(story.nodes))

  story_ids: ->
    return _.filter _.keys(@storage), (key) ->
      return _.startsWith(key, 'yarn-') && !_.endsWith(key, '-story') && !_.endsWith(key, 'story-id')

  clear: ->
    for key in _.keys(@storage)
      @storage.removeItem(key) if _.startsWith(key, 'yarn-')


window.DebugStory = DebugStory
window.StoryStorage = StoryStorage
