DebugParser = new window.Yarn.DebugParser()

class Story
  constructor: (@id = 'yarn-' + _.uuid(), @title = 'My New Story', @nodes = {}) ->

  # Public Methods
  add_node: (node_id, text) =>
    if @_contains(node_id)
      throw "Node with title #{node_id} already exists."
    @nodes[node_id] = text

  delete_node: (node_id) =>
    if !@_contains(node_id)
      throw "Node with title #{node_id} does not exist."
    delete @nodes[node_id]

  to_json: =>
   return {title: @title, nodes: @nodes}

  set_title: (@title) =>

  update_node_id: (node_id, new_node_id) =>
    if @_contains(new_node_id) && node_id != new_node_id
      throw "Node with title #{node_id} already exists."
    unless node_id == new_node_id
      @nodes[new_node_id] = @nodes[node_id]
      delete @nodes[node_id]

  update_node_text: (node_id, node_text) =>
    @nodes[node_id] = node_text

  has_nodes: =>
    return !_.isEmpty(@nodes)

  # Private Methods
  _contains: (node_id) =>
    return _.contains(_.keys(@nodes), node_id)

  # Class Methods
  @from_json: (id, json_object) =>
    return new Story(id, json_object.title, json_object.nodes)

class StoryStorage
  constructor: (@storage, @parser) ->

  # Public Methods
  clear: =>
    for key in _.keys(@storage)
      @storage.removeItem(key) if _.startsWith(key, 'yarn-')

  save_story: (story) =>
    @storage.setItem(story.id, JSON.stringify(story.to_json()))
    @storage.setItem(story.id + '-story', @parser.compile_page(story.nodes))

  stories: =>
    stories = {}
    for id in @_story_ids()
      stories[id] = @_load_story(id)
    return stories

  # Private Methods
  _story_ids: =>
    return _.filter _.keys(@storage), (key) ->
      return _.startsWith(key, 'yarn-') && !_.endsWith(key, '-story')

  _load_story: (id) =>
    try
      return Story.from_json(id,
        JSON.parse(@storage.getItem(id)))
    catch error
      throw "Error parsing story with id=#{id}: #{error}\n"

window.Story = Story
window.StoryStorage = StoryStorage
