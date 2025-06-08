classdef ModelHandler < handle
    % ModelHandler Class for handling model-related tasks like creating handler names,
    % output directories, and log files.
    %
    % Usage:
    %   handler = ModelHandler(config);
    %   handler.createOutputDir();
    %   handler.createLogFile();
    %
    % Properties:
    %   handlerName  - The name assigned to the handler, typically a model name with a timestamp.
    %   outputDir    - The path of the output directory where files related to the handler are stored.
    %   logFilePath  - The path of the log file created in the output directory.
    %
    % Methods:
    %   ModelHandler     - Constructor to initialize the handler with a config.
    %   createHandlerName- Creates a handler name with a timestamp.
    %   createOutputDir  - Creates the output directory for the handler.
    %   createLogFile    - Creates a log file in the output directory.
    
    properties (Access=public)
        config      % set to static or readonly
        handlerName % Stores the handler name (e.g., model name with dataset name)
        outputDir   % Stores the output directory path
        logFilePath % Stores the path of the log file
        fileID
    end
    methods
        %% Constructor: Initialize handler with a name
        function self=ModelHandler(config)
            % ModelHandler Constructor to create a new handler object.
            %
            % Syntax:
            %   obj = ModelHandler(config)
            %
            % Input:
            %   name - (optional) A string specifying the base name of the handler. 
            %          If not provided, 'defaultHandler' is used.
            %
            % Output:
            %   obj  - Instance of the ModelHandler class.
            self.config=config;
            self.createHandlerName();
            self.createOutputDir();
            self.createLogFile();
            self.log(sprintf('Output directory created: %s', self.outputDir));
            self.log(sprintf('Output file created: %s', self.logFilePath));
            self.log('ModelHandler initialized.');
            self.log(sprintf('Configuration: \n%s', OmegaConf.to_yaml(self.config)));
        end
        function createHandlerName(self)
            self.handlerName = sprintf('%s_%s', self.config.model.name, self.config.dataset.name);
        end
        function createOutputDir(self)
            self.outputDir = fullfile('./Results/ModelHandler', self.config.model.name, self.config.dataset.name);
            % Create output directory if it doesn't exist
            if ~exist(self.outputDir, 'dir')
                mkdir(self.outputDir);
            end
        end
        function createLogFile(self)
            % createLogFile Creates a log file in the output directory for the handler.
            %
            % Syntax:
            %   obj = obj.createLogFile()
            %
            % Output:
            %   obj - Instance of the ModelHandler class with the log file created.
            
            self.logFilePath = fullfile(self.outputDir, sprintf('Output_%s.txt', self.handlerName));
            % Open log file
            self.fileID = fopen(self.logFilePath, 'a'); % Open log file in append mode
            if self.fileID == -1
                error('Error opening log file.')
            end
        end
        function log(self, msg)
            % Write log message to file with timestamp
            arguments
                self
            end
            arguments (Repeating)
                msg
            end
            if numel(msg) == 1
                fprintf(self.fileID, '%s: %s\n', datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'), msg{1});
            else
                fprintf(self.fileID, '%s:\n', datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
                fprintf(self.fileID, '%s\n', msg{:});
            end
        end
        function logEntry(self)
            stack = dbstack('-completenames');
            if numel(stack) >= 2
                msg = sprintf("Entering %s.\n", stack(2).name);
            else
                msg = sprintf('No caller.\n');
            end
            self.log(msg);
        end
        function close(self)
            % Close the log file
            self.log('Log file closed.');
            fclose(self.fileID);
        end
    end
end