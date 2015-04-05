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
    DebugParser = undefined
    DebugStoryStorage = undefined
    setUpDebugEditorCtrl = undefined

    beforeEach ->
      stories = {}
      story1 = new DebugStory()
      story2 = new DebugStory()
      stories[story1.id] = story1
      stories[story2.id] = story2

      # Mock $routeParams, $location. $window
      $routeParams = {id: story1.id}
      $location = jasmine.createSpyObj('$location', ['path'])
      $window = jasmine.createSpyObj('$window', ['open'])

      # Mock DebugParser
      DebugParser = jasmine.createSpyObj('DebugParser', ['compile_graph'])
      DebugParser.compile_graph.and.callFake((nodes) ->
        return new Yarn.Graph(nodes, [])
      )

      # Mock DebugStoryStorage
      DebugStoryStorage = jasmine.createSpyObj('DebugStoryStorage', ['clear', 'stories', 'save_story'])
      DebugStoryStorage.stories.and.callFake(() ->
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
            DebugParser: DebugParser,
            DebugStory: DebugStory,
            DebugStoryStorage: DebugStoryStorage
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
        
      it 'should set $scope.stories by calling DebugStoryStorage.stories', ->
        expect($scope.stories).toEqual(DebugStoryStorage.stories())

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
          spyOn($scope.story, 'add_node').and.returnValue(false)
          $scope.add_node_to_story($scope.new_node.id, $scope.new_node.text)
          expect($scope.story.add_node).toHaveBeenCalledWith($scope.new_node.id, $scope.new_node.text)

        describe 'if $scope.story.add_node returns false', ->
          it 'should not set $scope.new_node to an empty object', ->
            spyOn($scope.story, 'add_node').and.returnValue(false)
            $scope.add_node_to_story($scope.new_node.id, $scope.new_node.text)
            expect($scope.new_node).toEqual(new_node)

        describe 'if $scope.story.add_node returns true', ->
          beforeEach ->
            spyOn($scope.story, 'add_node').and.returnValue(true)
            $scope.add_node_to_story($scope.new_node.id, $scope.new_node.text)

          it 'should set $scope.new_node to an empty object', ->
            expect($scope.new_node).toEqual({})

      describe '.launch_story', ->
        it 'should play the story in a new window', ->
          $scope.launch_story()
          expect($window.open).toHaveBeenCalledWith('/play.html#' + $scope.story.id)

      describe '.new_story', ->
        beforeEach ->
          spyOn($scope, 'go_to_story')
          $scope.new_story()

        it 'should set $scope.story a new DebugStory', ->
          expect($scope.story).not.toEqual(story1)
          expect($scope.story).toEqual(jasmine.any(DebugStory))

        it 'should add $scope.story to $scope.stories', ->
          expect(Object.keys($scope.stories).length).toEqual(3)
          expect($scope.stories[$scope.story.id]).toEqual($scope.story)

        it 'should call $scope.go_to_story', ->
          expect($scope.go_to_story).toHaveBeenCalled()

        it 'should compile $scope.graph from $scope.story.nodes', ->
          expect(DebugParser.compile_graph).toHaveBeenCalledWith($scope.story.nodes) 
          expect($scope.graph).toEqual(DebugParser.compile_graph())

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

        it 'should call DebugStoryStorage#clear', ->
          expect(DebugStoryStorage.clear).toHaveBeenCalled()

      describe '.has_stories', ->
        it 'should return true if $scope.stories is not empty', ->
          expect($scope.has_stories()).toBe(true)

        it 'should return false if $scope.stories is empty', ->
          $scope.stories = {}
          expect($scope.has_stories()).toBe(false)
