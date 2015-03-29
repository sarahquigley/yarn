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

  # Set story_ids
  $scope.story_ids = StoryStorage.story_ids()

  # Debug Editor Methods
  $scope.edit_story = (id) ->
    localStorage.setItem('yarn-story-id', id)
    $scope.story = StoryStorage.load_story(id)

  $scope.save_story = ->
    StoryStorage.save_story($scope.story)

  $scope.new_story = ->
    $scope.story = new DebugStory()
    localStorage.setItem('yarn-story-id', $scope.story.id)
    $scope.save_story()
    $scope.chosen_story_id = $scope.story.id
    $scope.story_ids = StoryStorage.story_ids()

  $scope.add_node_to_story = (node_id, node_text='') ->
    added_node = $scope.story.add_node(node_id, node_text)
    $scope.new_node = {} if added_node

  $scope.launch_story = ->
    $scope.save_story()
    $window.open('/play.html')

  $scope.clear_stories = ->
    StoryStorage.clear()
    $scope.new_story()

  # Load current story_id from localStorage if present; otherwise create a new story_id
  story_id = localStorage.getItem('yarn-story-id')

  if story_id
    $scope.story = StoryStorage.load_story(story_id)
    $scope.chosen_story_id = $scope.story.id
  else
    console.log('Could not get current story_id from localStorage.')
    $scope.new_story()

  $scope.graph = DebugParser.compile_graph($scope.story.nodes)

  $scope.$watch('nodes', ->
      $scope.graph = DebugParser.compile_graph($scope.story.nodes)
    , true)
])
