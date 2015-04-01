angular.module('DebugEditorApp', [
  'xeditable'
])

.run((editableOptions) ->
  editableOptions.theme = 'bs3'
)

.service('DebugParser', Yarn.DebugParser)

.factory('localStorage', -> localStorage)

.factory('_', -> _)

.factory('DebugStory', -> DebugStory)

.factory('StoryStorage', ['localStorage', (localStorage) ->
  return new StoryStorage(localStorage)
])

.controller('DebugEditorCtrl',
['$scope', '$window', '_', 'DebugParser', 'localStorage', 'DebugStory', 'StoryStorage',
($scope, $window, _, DebugParser, localStorage, DebugStory, StoryStorage) ->

  # Debug Editor Methods
  $scope.new_story = ->
    $scope.story = new DebugStory()
    localStorage.setItem('yarn-story-id', $scope.story.id)
    $scope.stories[$scope.story.id] = $scope.story

  $scope.add_node_to_story = (node_id, node_text='') ->
    added_node = $scope.story.add_node(node_id, node_text)
    $scope.new_node = {} if added_node

  $scope.launch_story = ->
    $window.open('/play.html')

  $scope.clear_stories = ->
    $scope.stories = {}
    StoryStorage.clear()
    $scope.new_story()

  # Load all stories
  $scope.stories = StoryStorage.stories()

  # Load current story_id from localStorage if present; otherwise create a new story_id
  story_id = localStorage.getItem('yarn-story-id')

  if story_id
    $scope.story = $scope.stories[story_id]
  else
    console.log('Could not get current story_id from localStorage.')
    $scope.new_story()

  # Debug Editor Graph
  $scope.graph = DebugParser.compile_graph($scope.story.nodes)

  $scope.$watch('story', ->
      StoryStorage.save_story($scope.story)
      localStorage.setItem('yarn-story-id', $scope.story.id)
      $scope.graph = DebugParser.compile_graph($scope.story.nodes)
    , true)
])
