describe 'DebugEditorApp', ->

  beforeEach ->
    module('DebugEditorApp')

  describe 'DebugEditorCtrl', ->

    stories = undefined
    story1 = undefined
    story2 = undefined
    $scope = undefined
    $window = undefined
    $routeParams = undefined
    $location = undefined
    debugParser = undefined
    storyStorage = undefined
    setUpDebugEditorCtrl = undefined

    beforeEach ->
      stories = {}
      story1 = new Story()
      story2 = new Story()
      stories[story1.id] = story1
      stories[story2.id] = story2

      # Mock $routeParams, $location. $window
      $routeParams = {id: story1.id}
      $location = jasmine.createSpyObj('$location', ['path'])
      $window = jasmine.createSpyObj('$window', ['open'])

      # Mock debugParser
      debugParser = jasmine.createSpyObj('debugParser', ['compile_graph'])
      debugParser.compile_graph.and.callFake((nodes) ->
        return new Yarn.Graph(nodes, [])
      )

      # Mock storyStorage
      storyStorage = jasmine.createSpyObj('storyStorage', ['clear', 'stories', 'save_story'])
      storyStorage.stories.and.callFake(() ->
        return stories
      )

      # setUp method to make DebugEditorCtrl's $scope available for testing
      setUpDebugEditorCtrl = ->
        inject(($rootScope, $controller, _) ->
          $scope = $rootScope.$new()

          $controller('DebugEditorCtrl', {
            $scope: $scope,
            $window: $window,
            $routeParams: $routeParams,
            $location: $location,
            _: _,
            debugParser: debugParser,
            Story: Story,
            storyStorage: storyStorage
          })
        )

    describe 'if $routeParams.id is not defined', ->
      it 'should not set $scope.story', ->
        $routeParams = {}
        setUpDebugEditorCtrl()
        expect($scope.story).toBeUndefined()

    describe 'setting up DebugEditorCtrl', ->
      beforeEach ->
        setUpDebugEditorCtrl()

      it 'should set $scope.stories by calling storyStorage.stories', ->
        expect($scope.stories).toEqual(storyStorage.stories())

      describe 'if $routeParams.id is defined', ->
        it 'should set $scope.story as expected', ->
          expect($scope.story).toEqual(story1)

      describe '.go_to_story', ->
        describe 'if $scope.story is defined', ->
          it 'should navigate to the url of the current story', ->
            $scope.go_to_story()
            expect($location.path).toHaveBeenCalledWith('/stories/' + $scope.story.id)

        describe 'if $scope.story is not defined', ->
          it 'should navigate to the base stories url', ->
            $scope.story = undefined
            $scope.go_to_story()
            expect($location.path).toHaveBeenCalledWith('/stories/')

      describe '.add_node_to_story', ->
        new_node = undefined

        beforeEach ->
          new_node = {id: 'Test Node', text: 'Test text'}
          $scope.new_node = new_node

        it 'should call $scope.story.add_node', ->
          spyOn($scope.story, 'add_node')
          $scope.add_node_to_story($scope.new_node.id, $scope.new_node.text)
          expect($scope.story.add_node).toHaveBeenCalledWith(new_node.id, new_node.text)

        describe 'if $scope.story.add_node throws an error', ->
          beforeEach ->
            spyOn(window, 'alert')
            spyOn($scope.story, 'add_node').and.callFake(-> throw "Error")
            $scope.add_node_to_story($scope.new_node.id, $scope.new_node.text)

          it 'should not set $scope.new_node to an empty object', ->
            expect($scope.new_node).toEqual(new_node)

          it 'should pop open an alert', ->
            expect(window.alert).toHaveBeenCalled()

        describe 'if $scope.story.add_node returns true', ->
          edges = undefined

          beforeEach ->
            edges = [
              new Yarn.Edge('source1', 'destination1'),
              new Yarn.Edge('source1', 'destination2')
            ]

            debugParser.compile_graph.and.callFake((nodes) ->
              graph = new Yarn.Graph(nodes, [])
              spyOn(graph, 'edges_by_node').and.returnValue(edges)
              return graph
            )

            spyOn($scope.story, 'add_node')
            $scope.add_node_to_story($scope.new_node.id, $scope.new_node.text)

          it 'should set $scope.new_node to an empty object', ->
            expect($scope.new_node).toEqual({})

          it 'should call debugParser.compile_graph', ->
            expect(debugParser.compile_graph).toHaveBeenCalledWith($scope.story.nodes)

          it 'should call $scope.graph.edges_by_node', ->
            expect($scope.graph.edges_by_node).toHaveBeenCalledWith(new_node.id)

          it 'should call $scope.story.add_node once for every edge in the new node', ->
            expect($scope.story.add_node).toHaveBeenCalledWith('destination1', '')
            expect($scope.story.add_node).toHaveBeenCalledWith('destination2', '')

      describe '.launch_story', ->
        it 'should play the story in a new window', ->
          $scope.launch_story()
          expect($window.open).toHaveBeenCalledWith('/play.html#' + $scope.story.id)

      describe '.new_story', ->
        beforeEach ->
          spyOn($scope, 'go_to_story')
          $scope.new_story()

        it 'should set $scope.story a new Story', ->
          expect($scope.story).not.toEqual(story1)
          expect($scope.story).toEqual(jasmine.any(Story))

        it 'should add $scope.story to $scope.stories', ->
          expect(Object.keys($scope.stories).length).toEqual(3)
          expect($scope.stories[$scope.story.id]).toEqual($scope.story)

        it 'should call $scope.go_to_story', ->
          expect($scope.go_to_story).toHaveBeenCalled()

        it 'should compile $scope.graph from $scope.story.nodes', ->
          expect(debugParser.compile_graph).toHaveBeenCalledWith($scope.story.nodes)
          expect($scope.graph).toEqual(debugParser.compile_graph())

      describe '.clear_stories', ->
        beforeEach ->
          spyOn($scope, 'go_to_story')
          $scope.clear_stories()

        it 'should set $scope.stories to an empty object', ->
          expect($scope.stories).toEqual({})

        it 'should set $scope.story to undefined', ->
          expect($scope.story).toBeUndefined()

        it 'should call $scope.go_to_story', ->
          expect($scope.go_to_story).toHaveBeenCalled()

        it 'should call storyStorage#clear', ->
          expect(storyStorage.clear).toHaveBeenCalled()

      describe '.has_stories', ->
        it 'should return true if $scope.stories is not empty', ->
          expect($scope.has_stories()).toBe(true)

        it 'should return false if $scope.stories is empty', ->
          $scope.stories = {}
          expect($scope.has_stories()).toBe(false)

      describe '.x_edit', ->
        callback = undefined

        describe 'if an error is not thrown', ->
          result = undefined

          beforeEach ->
            callback = jasmine.createSpy()
            result = $scope.x_edit(callback, false, 'test')

          it 'should call the passed callback with all passed args', ->
            expect(callback).toHaveBeenCalledWith(false, 'test')

          it 'should return true', ->
            expect(result).toBe(true)

        describe 'if an error is thrown', ->
          it 'should catch it and return the error message string', ->
            callback = jasmine.createSpy().and.throwError('error')
            result = $scope.x_edit(callback, true)
            expect(result).toEqual('Error: error')

      describe 'watches $scope.story', ->
        describe 'if $scope.story is defined', ->
          beforeEach ->
            $scope.$apply()

          it 'should call storyStorage#save_story', ->
            expect(storyStorage.save_story).toHaveBeenCalledWith($scope.story)

          it 'should compile $scope.graph from $scope.story.nodes', ->
            expect(debugParser.compile_graph).toHaveBeenCalledWith($scope.story.nodes)
            expect($scope.graph).toEqual(debugParser.compile_graph())

        describe 'if $scope.story is not defined', ->
          beforeEach ->
            $scope.story = undefined
            $scope.$apply()

          it 'should not call storyStorage#save_story', ->
            expect(storyStorage.save_story).not.toHaveBeenCalled()

          it 'should compile $scope.graph from $scope.story.nodes', ->
            expect(debugParser.compile_graph).not.toHaveBeenCalled()
