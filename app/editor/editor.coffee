angular.module('DebugEditorApp', [
  'xeditable',
  'ngRoute'
])

.run((editableOptions) ->
  editableOptions.theme = 'bs3'
)

.config(['$routeProvider', ($routeProvider) ->
  $routeProvider
  .when('/stories', {
    templateUrl: 'editor/editor.html',
    controller: 'DebugEditorCtrl',
    controllerAs: 'editor'
  })
  .when('/stories/:id', {
    templateUrl: 'editor/editor.html',
    controller: 'DebugEditorCtrl',
    controllerAs: 'editor'
  })
  .otherwise({
    redirectTo: '/stories'
  })
])

.factory('localStorage', -> localStorage)

.factory('_', -> _)

.service('debugParser', Yarn.DebugParser)

.factory('Story', -> Story)

.factory('storyStorage',
['localStorage', 'debugParser',
(localStorage, debugParser) ->
  return new StoryStorage(localStorage, debugParser)
])

.controller('DebugEditorCtrl',
['$scope', '$window', '$routeParams', '$location', '_', 'debugParser', 'Story', 'storyStorage',
($scope, $window, $routeParams, $location, _, debugParser, Story, storyStorage) ->

  # Load all stories
  $scope.stories = storyStorage.stories()

  # If viewing a story, set story
  if $routeParams.id
    $scope.story = $scope.stories[$routeParams.id]

  # Private methods
  add_nodes_for_node_edges = (node_id) ->
    $scope.graph = debugParser.compile_graph($scope.story.nodes)
    edges = $scope.graph.edges_by_node(node_id)
    for edge in edges
      try
        $scope.story.add_node(edge.destination, '')
      catch error

  # Debug Editor $scope Methods
  $scope.go_to_story = ->
    story_id = if $scope.story then $scope.story.id else ''
    $location.path('/stories/' + story_id)

  $scope.new_story = ->
    $scope.story = new Story()
    $scope.go_to_story()
    $scope.stories[$scope.story.id] = $scope.story
    $scope.graph = debugParser.compile_graph($scope.story.nodes)

  $scope.add_node_to_story = (node_id, node_text='') ->
    try
      $scope.story.add_node(node_id, node_text)
      $scope.new_node = {}
      add_nodes_for_node_edges(node_id)
    catch error
      alert(error)

  $scope.update_node_text = (node_id, node_text) ->
    $scope.story.update_node_text(node_id, node_text)
    add_nodes_for_node_edges(node_id)

  $scope.launch_story = ->
    $window.open('/play.html#' + $scope.story.id)
    return true

  $scope.clear_stories = ->
    $scope.stories = {}
    $scope.story = undefined
    $scope.go_to_story()
    storyStorage.clear()

  $scope.has_stories = ->
    return !_.isEmpty($scope.stories)

  $scope.x_edit = (callback, args...) ->
    try
      callback(args...)
      return true
    catch error
      return "#{error}"

  # Watch $scope.story
  $scope.$watch('story', ->
      if $scope.story
        storyStorage.save_story($scope.story)
        $scope.graph = debugParser.compile_graph($scope.story.nodes)
    , true)
])
