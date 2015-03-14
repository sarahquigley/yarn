angular.module('EditorApp', [
  'xeditable'
])

.run((editableOptions) ->
  editableOptions.theme = 'bs3'
)

.service('Parser', DebugParser)

.factory('_', () -> return _)

.controller('EditorCtrl', ['$scope', '_', 'Parser', ($scope, _, Parser) ->
  $scope.test_nodes =
    start: 'Hello! I am the first node. Go to the [second] one. Or the [third] one.'
    second: 'Hi! Second node here. Go to the [third]!'
    third: "That's all folks. [fourth]"
    fourth: "Except it isn't really. [fifth]"
    fifth: "Maybe now it is all. [sixth]"
    sixth: "Maybe now it is all. [seventh]"
    seventh: 'Foo.'

  $scope.graph = Parser.compile_graph($scope.test_nodes)
])
