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

.service('DebugParser', Yarn.DebugParser)

.factory('Story', -> Story)

.factory('StoryStorage',
['localStorage', 'DebugParser',
(localStorage, DebugParser) ->
  return new StoryStorage(localStorage, DebugParser)
])

.controller('DebugEditorCtrl',
['$scope', '$window', '$routeParams', '$location', '_', 'DebugParser', 'Story', 'StoryStorage',
($scope, $window, $routeParams, $location, _, DebugParser, Story, StoryStorage) ->

  # Load all stories
  $scope.stories = StoryStorage.stories()

  # If viewing a story, set story
  if $routeParams.id
    $scope.story = $scope.stories[$routeParams.id]

  # Debug Editor Methods
  $scope.go_to_story = () ->
    story_id = if $scope.story then $scope.story.id else ''
    $location.path('/stories/' + story_id)

  $scope.new_story = ->
    $scope.story = new Story()
    $scope.go_to_story()
    $scope.stories[$scope.story.id] = $scope.story
    $scope.graph = DebugParser.compile_graph($scope.story.nodes)

  $scope.add_node_to_story = (node_id, node_text='') ->
    try
      $scope.story.add_node(node_id, node_text)
      $scope.new_node = {}
    catch error
      alert(error)

  $scope.launch_story = ->
    $window.open('/play.html#' + $scope.story.id)
    return true

  $scope.clear_stories = ->
    $scope.stories = {}
    $scope.story = undefined
    $scope.go_to_story()
    StoryStorage.clear()

  $scope.has_stories = ->
    return !_.isEmpty($scope.stories)

  # Watch $scope.story
  $scope.$watch('story', ->
      if $scope.story
        StoryStorage.save_story($scope.story)
        $scope.graph = DebugParser.compile_graph($scope.story.nodes)
    , true)
])
