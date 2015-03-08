module.exports = function(grunt) {

  require('time-grunt')(grunt);

  // Load grunt tasks automatically
  require('load-grunt-tasks')(grunt);

  // Configure variables for use across grunt tasks
  var config = {
    dirs: {
      app: 'app',
      dev: '.dev'
    },
    files: {
      scripts: [
        '<%= config.dirs.app %>/**/*.coffee',
        '!<%= config.dirs.app %>/**/*.spec.coffee'
      ],
      tests: [
        '<%= config.dirs.app %>/**/*.spec.coffee'
      ]
    }
  };

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    config: config,
    
    // Clean tasks    - For erasing contents of specified directories
    // clean:dev      - Clean temporary directory created for holding compiled files during development
    clean: {
      dev: [config.dirs.dev],
      test: [config.dirs.test]
    },

    // Coffee tasks   - Coffeescript compilation
    // coffee:dev     - Compile coffeescript files to temporary directory during development
    coffee: {
      dev: {
        files: {
          '<%= config.dirs.dev %>/main.js': config.files.scripts 
        }
      }
    },

    // Concurrent tasks   - Allow tasks to be run concurrently
    // concurrent:test    - Allow unit-tests and watch task to be run simultaneously
    concurrent: {
      test: {
        tasks: [
          'karma:concurrent',
          'watch'
        ],
        options: {
          logConcurrentOutput: true
        }
      }
    },

    // Connect task   
    // connect:livereload - Serve site on port 9000
    connect: {
      options: {
        port: 9000,
        hostname: 'localhost', // Change this to '0.0.0.0' to access the server from outside.
        livereload: 35729
      },

      livereload: {
        options: {
          open: true, // open page in default browser
          middleware: function (connect) {
            return [
              connect.static(config.dirs.dev),
              connect.static(config.dirs.app)
            ];
          }
        }
      }
    },

    // Karma - test runner 
    // karma:concurrent   - Run test in the background
    // karma:single       - Run tests once 
    karma: {
      options: {
        configFile: 'karma.conf.js'
      },
      // Keep tests running in the background
      concurrent: {
        singleRun: false 
      },
      // Run tests once
      single: {
        singleRun: true
      }
    },

    // Watch tasks      - Watch for changes in specified directories, and re-run specified task(s)
    // watch:coffee     - Watch coffeescript files, re-compile coffeescripts
    // watch:wiredep    - Watch bower.json for new bower_components, and inject new dependencies
    // watch:livereload - Trigger livereload on update of html or scripts 
    watch: {
      options: {
        livereload: true
      },

      coffee: {
        files: config.files.scripts,
        tasks: ['coffee:dev']
      },

      livereload: {
        options: {
          livereload: '<%= connect.options.livereload %>'
        },
        files: [
          '<%= config.dirs.app %>/**/*.html',
          '<%= config.dirs.dev %>/**/*.js'
        ]
      },

      wiredep: {
        files: ['bower.json'],
        tasks: ['wiredep:dev']
      }
    },

    // Wiredep tasks    - Inject bower dependencies automatically into source code
    // wiredep:dev      - Inject bower dependencies into html pages
    // wiredep:test     - Inject bower dependencies into karma config
    wiredep: {
      dev: {
        src: ['<%= config.dirs.app %>/index.html']
      },

      test:{
        src: 'karma.conf.js',
        fileTypes: {
          js: {
            block: /(([\s\t]*)\/\/\s*bower:*(\S*))(\n|\r|.)*?(\/\/\s*endbower)/gi, // Wire dependencies between '// bower:extension' and '// endbower'
            detect: {
              js: /'(.*\.js)'/gi
            },
            replace: {
              js: '\'{{filePath}}\','
            }
          }
        }
      }
    }

  });

  // Custom tasks

  // test     - Run a single run of unit tests
  grunt.registerTask('test', 'Run unit tests', function(){
    grunt.task.run([
      'npm-install',
      'wiredep:test',
      'clean:dev',
      'coffee:dev',
      'karma:single'
    ]);
  });

  // serve          - Compile site assets, serve site
  // serve --test   - Compile site assets, serve site, run unit tests concurrently
  grunt.registerTask('serve', 'Compile, serve, optionally run tests', function(){
    grunt.task.run([
      'npm-install',
      'clean:dev',
      'coffee:dev',
      'wiredep:dev',
      'connect:livereload'
    ]);

    if(grunt.option('test')){
      grunt.task.run([
        'wiredep:test',
        'concurrent:test'
      ]);
    } else {
      grunt.task.run(['watch']);
    }
  });

  // default task   - run by grunt when no task is specified
  grunt.registerTask('default', 'serve');
};
