angular.module('DebugEditorApp', [
  'xeditable'
])

.run((editableOptions) ->
  editableOptions.theme = 'bs3'
)

.service('DebugParser', DebugParser)

.factory('_', () -> return _)

.controller('DebugEditorCtrl', ['$scope', '_', 'DebugParser', ($scope, _, DebugParser) ->
  # Load nodes from localStorage if present; otherwise, start with empty nodes.
  try
    parsed_nodes = JSON.parse(localStorage.getItem('yarnNodes'))
  catch error
    parsed_nodes = undefined
    console.log(error)
  $scope.nodes = parsed_nodes || {}

  $scope.update_node_text = (node_id, node_text) ->
    $scope.nodes[node_id] = node_text
    return true

  $scope.update_node_id = (node_id, new_node_id) ->
    return 'Node with this title already exists.' if _.isString($scope.nodes[new_node_id])
    $scope.nodes[new_node_id] = $scope.nodes[node_id]
    delete $scope.nodes[node_id]
    return true

  $scope.add_node = (node_id, text) ->
    if _.isString($scope.nodes[node_id])
      alert('Node with this title already exists.')
      return false
    $scope.nodes[node_id] = text
    $scope.new_node = {}

  $scope.graph = DebugParser.compile_graph($scope.nodes)

  $scope.$watch('nodes',
    () ->
      $scope.graph = DebugParser.compile_graph($scope.nodes)
    , true)

  $scope.save_story = ->
    localStorage.setItem('yarnNodes',
                         JSON.stringify($scope.nodes))
    localStorage.setItem('yarnStory',
                         DebugParser.compile_page($scope.nodes))

  $scope.launch_story = ->
    $scope.save_story()
    window.open('/play.html')

  $scope.new_story = ->
    $scope.nodes = {}
])
