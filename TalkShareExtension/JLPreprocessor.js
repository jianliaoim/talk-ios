var MyPreprocessor = function() {};

MyPreprocessor.prototype = {
    run: function(arguments) {
        arguments.completionFunction({"baseURL":document.baseURL, "URL": document.URL, "title": document.title});
    }
};

var ExtensionPreprocessingJS = new MyPreprocessor;
