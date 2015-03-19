describe 'DebugEditorApp', ->

  beforeEach ->
    module('DebugEditorApp')

  describe 'DebugEditorCtrl', ->

    $scope = undefined
    DebugParser = undefined
    localStorage = undefined
    $window = undefined
    setUpDebugEditorCtrl = undefined

    beforeEach ->
      # Mock DebugParser
      DebugParser = jasmine.createSpyObj('DebugParser', ['compile_graph', 'compile_page'])
      DebugParser.compile_graph.and.callFake((nodes) ->
        return new Graph(nodes, [])
      )
      DebugParser.compile_page.and.callFake((nodes) ->
        return '<code>' + JSON.stringify(nodes) + '</code>'
      )
      # Mock localStorage
      localStorage = new MockLocalStorage()

      # Mock $window
      $window = jasmine.createSpyObj('$window', ['open'])

      # setUp method to make DebugEditorCtrl's $scope available for testing
      setUpDebugEditorCtrl = ->
        inject(($rootScope, $controller, _) ->
          $scope = $rootScope.$new()

          $controller('DebugEditorCtrl', {
            $scope: $scope,
            $window: $window,
            _: _,
            DebugParser: DebugParser,
            localStorage: localStorage
          })
      )

    describe 'if yarnNodes key is set in localStorage', ->
      TEST_NODES = {test_node: 'test'}

      beforeEach ->
        localStorage.setItem('yarnNodes', JSON.stringify(TEST_NODES))
        setUpDebugEditorCtrl()

      it 'should initialise $scope.nodes to its value', ->
        expect($scope.nodes).toEqual(TEST_NODES)

    describe 'if yarnNodes key is not set in localStorage', ->
      beforeEach ->
        setUpDebugEditorCtrl()

      it 'should initialise $scope.nodes to an empty object', ->
        expect($scope.nodes).toEqual({})

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

      describe '.save_story', ->
        beforeEach ->
          $scope.nodes = {test_node: 'test'}
          $scope.save_story()

        it 'should save $scope.nodes to key yarnNodes in localStorage', ->
          expect(localStorage.getItem('yarnNodes')).toEqual(JSON.stringify($scope.nodes))

        it 'should save compiled story, yarnStory, to localStorage', ->
          expect(localStorage.getItem('yarnStory')).toEqual(DebugParser.compile_page($scope.nodes))

      describe '.launch_story', ->
        beforeEach ->
          spyOn($scope, 'save_story')
          $scope.launch_story()

        it 'should save the current story', ->
          expect($scope.save_story).toHaveBeenCalled()

        it 'should play the story in a new window', ->
          expect($window.open).toHaveBeenCalledWith('/play.html')

      describe '.new_story', ->
        it 'should reset $scope.nodes', ->
          $scope.nodes = {test_node: 'test'}
          $scope.new_story()
          expect($scope.nodes).toEqual({})
