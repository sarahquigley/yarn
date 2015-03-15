describe 'DebugEditorApp', ->

  beforeEach ->
    module('DebugEditorApp')

  describe 'DebugEditorCtrl', ->

    $scope = undefined
    DebugParser = undefined

    beforeEach ->
      # Create mock DebugParser
      DebugParser = jasmine.createSpyObj('DebugParser', ['compile_graph'])
      DebugParser.compile_graph.and.callFake((nodes) ->
        return new Graph(nodes, [])
      )

      # Make DebugEditorCtrl's $scope available for testing 
      inject(($rootScope, $controller, _) ->
        $scope = $rootScope.$new()

        $controller('DebugEditorCtrl', {
          $scope: $scope,
          _: _,
          DebugParser: DebugParser
        })
      )

    it 'should define a $scope variable, $scope.nodes', ->
      expect($scope.nodes).toEqual(jasmine.any(Object))

    it 'should define a $scope variable, $scope.graph, to equal result of DebugParser.compile_graph of $scope.nodes', ->
      expect(DebugParser.compile_graph).toHaveBeenCalledWith($scope.nodes)
      expect($scope.graph.nodes).toEqual($scope.nodes)

    it 'should watch $scope.nodes and set $scope.graph to result of DebugParser.compile_graph of $scope.nodes when $scope.nodes change', ->
      $scope.nodes.test_node = 'test'
      expect(DebugParser.compile_graph).toHaveBeenCalledWith($scope.nodes)
      expect($scope.graph.nodes).toEqual($scope.nodes)
    
    describe '.update_node_text', ->
      it 'should update the text of the specified node', ->
        $scope.nodes.test_node = ''
        $scope.update_node_text('test_node', 'test')
        expect($scope.nodes.test_node).toEqual('test')

    describe '.update_node_id', ->
      describe 'if a node with the new node_id does not exist', ->
        it 'should update the node_id of the specified node', ->
          $scope.nodes.test_node = 'test'
          $scope.update_node_id('test_node', 'my_test_node')
          expect($scope.nodes.test_node).toBeUndefined()
          expect($scope.nodes.my_test_node).toEqual('test')

      describe 'if a node with the new node_id exists', ->
        result = undefined

        beforeEach ->
          $scope.nodes = {test_node: 'test', test_node_2: 'test2'}
          result = $scope.update_node_id('test_node_2', 'test_node')

        it 'should return a string (error string for x-editable)', ->
          expect(result).toEqual(jasmine.any(String))

        it 'should not update the node_id of the specified node', ->
          expect($scope.nodes.test_node).toEqual('test')
          expect($scope.nodes.test_node_2).toEqual('test2')

    describe '.add_node', ->
      describe 'if a node with the node_id of the new node does not exist', ->
        it 'should add a new node', ->
          expect($scope.nodes.test_node).toBeUndefined()
          $scope.add_node('test_node', 'test')
          expect($scope.nodes.test_node).toEqual('test')

      describe 'if a node with the node_id of the new node exists', ->
        beforeEach ->
          $scope.nodes = {test_node: 'test'}
          spyOn(window, 'alert')
          $scope.add_node('test_node', 'test2')

        it 'should not add a new node', ->
          expect(Object.keys($scope.nodes).length).toEqual(1)

        it 'should not alter the node text of the pre-existing node', ->
          expect($scope.nodes.test_node).toEqual('test')

        it 'should pop up an alert', ->
          expect(window.alert).toHaveBeenCalled()
