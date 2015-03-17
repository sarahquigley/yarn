module.exports = function(config){
  config.set({

    basePath : './',

    // List of files/patterns to load in the browser
    files : [
      // bower:js
      'app/bower_components/jquery/dist/jquery.js',
      'app/bower_components/lodash/lodash.js',
      'app/bower_components/angular/angular.js',
      'app/bower_components/angular-xeditable/dist/js/xeditable.js',
      'app/bower_components/bootstrap/dist/js/bootstrap.js',
      // endbower
      'node_modules/angular-mocks/angular-mocks.js',
      'node_modules/mock-localstorage/lib/mock-localstorage.js',
      '.dev/main.js',
      'app/**/*.spec.coffee',
    ],

    // Enable watching files and executing the tests whenever one of the above files changes
    autoWatch : true,

    frameworks: [
      'jasmine',
      'jasmine-matchers'
    ],

    // List of browsers to launch and capture
    browsers : ['Chrome'],

    plugins : [
      'karma-chrome-launcher',
      'karma-firefox-launcher',
      'karma-jasmine',
      'karma-jasmine-matchers',
      'karma-jasmine-html-reporter',
      'karma-mocha-reporter',
      'karma-coffee-preprocessor',
      'karma-ng-html2js-preprocessor'
    ],

    // List of reporters to use
    reporters: [
      'html',
      'mocha'
    ],

    // Preprocessors to use
    preprocessors: {
      'app/**/*.html' : 'html2js',
      'app/**/*.spec.coffee': 'coffee'
    },

    // Coffeescript preprocessor config
    coffeePreprocessor: {
      // options passed to the coffee compiler
      options: {
        bare: true,
        sourceMap: false
      },
      // transforming the filenames
      transformPath: function(path) {
        return path.replace(/\.coffee$/, '.js');
      }
    }

  });
};
