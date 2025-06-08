classdef IdentModelHandler < ModelHandler
    % IdentifyModelHandler Class for handling identification-model-related 
    % tasks like identifying at one noise level, identifying at a series of
    % noise levels.
    %
    % Usage:
    %   handler = ModelHandlerIdentify(config)
    %   handler.identify(identifierModulePath, 0.05, rng_seed)
    %   handler.loopIdentify(identifierModulePath, [0:0.1:1])
    %
    % Properties:
    %   identifierModulePath - Path to identifier module.
    %   nsrLevels            - Noise levels for identification.
    %   numRepetition        - Number of ident for each noise level.
    %
    % Methods:
    %   IdentModelHandler - Constructor to initialize the handler with a config.
    %   identify          - Execute identification once (Optional with random seed).
    %   loopIdentify      - Execute multiple times and collect statistics.


    properties (Access=protected)
        identifierModulePath
        nsrLevels
        numRepetition
    end
    methods
        function obj=IdentModelHandler(config)
            obj@ModelHandler(config);
            obj.setIdentifierModulePath(obj.config.model.path);
            obj.setNumRepetition(obj.config.dataset.repeat);
            sss = obj.config.dataset.nsrs.start_step_stop;
            obj.setNoiseLevels(sss(1):sss(2):sss(3));
        end
        function setIdentifierModulePath(self, identifierModulePath)
            % Set path to Identifier Moduler
            %
            % Syntax:
            %   hanlder.setIdentifierModulePath('./path/to/module')
            %
            % Inputs:
            %   identifierModulePath - Path to module
            %
            self.identifierModulePath = identifierModulePath;
        end
        function setNoiseLevels(self, nsrLevels)
            % Set noise levels for the dataset
            %
            % Syntax:
            %   handler.setNoiseLevels(nsrLevels)
            %
            % Inputs:
            %   nsrLevels - Noise levels 
            self.nsrLevels = nsrLevels;
        end
        function setNumRepetition(self, numRepetition)
            % Set repeat times of identification execution
            %
            % Syntax:
            %   handler.setNumRepetition(10)
            %
            % Inputs:
            %   numRepetition - Number of repetition for identifation.
            self.numRepetition = numRepetition;
        end
        function results=loopIdentify(self, identifierModulePath, nsrLevels, numRepetition)
            % Execute identification with repetition for a range of
            % noise-signal-ratio levels 
            %
            % Syntax: 
            %   handler.loopIdentify() % Run with default setup
            %   handler.loopIdentify('path/to/module', 0:0.1:1, 5)
            %
            % Inputs:
            %   identifierModulePath - Path to identification module.
            %   nsrLevels            - Noise levels for identification.
            %   numRepetition        - Number of repetition of the experiments.
            arguments
                self
                identifierModulePath=self.identifierModulePath
                nsrLevels=self.nsrLevels
                numRepetition=self.numRepetition
            end
            self.log(sprintf("Executing the identifier on %s for noise level [%s], each identification is repeated %i times with different random seed.", identifierModulePath, num2str(nsrLevels, 3),numRepetition))
            metricAccumulator = MetricAccumulator();
            metricTable = MetricTable();
            for t = enumerate(nsrLevels, verbose=false, description='nsr', fid=self.fileID)
                step = t.num; nsr = t.item;
                for r = 1:numRepetition
                    results = self.identify(nsr, identifierModulePath);

                    metricsPairs = struct2Pairs(results.metrics);
                    metricAccumulator.addMetric(metricsPairs{:});
                    metricTable.addMetricRow('nsr', nsr, metricsPairs{:});
                end
                metricAccumulator.bufferAllStatsAndClear('nsr', nsr);

                if mod(step, 5)==0 || step == numel(nsrLevels)
                    buffer = metricAccumulator.flushBuffer();
                    self.log(buffer{:});
                end
            end
            
            % persist the results to struct, 
            % the code here needs to be simplified
            results = struct( ...
                results_table = metricTable ,...
                mean_table = metricTable.get_stats("nsr", "mean"), ...
                std_table = metricTable.get_stats("nsr", "std") ...
            );

            % save results
            if ~exist(fullfile(self.outputDir, 'results'), 'dir')
                mkdir(fullfile(self.outputDir, 'results'));
            end
            results_path = fullfile(self.outputDir, 'results', 'results.mat');
            save(results_path, '-struct', 'results');
        end
        function [results, itemizedResults] = applyIdent(self, nsrLevel, options)
            arguments
                self
                nsrLevel
                options.identifierModulePath=self.identifierModulePath
                options.rngSeed=generate_rng_seed()
            end
            [results, itemizedResults] = self.identify(nsrLevel, options.identifierModulePath, options.rngSeed);
        end
        function [varargout] = identify(self, nsrLevel, identifierModulePath, rngSeed, verbose)
            arguments
                self
                nsrLevel
                identifierModulePath=self.identifierModulePath
                rngSeed=generate_rng_seed()
                verbose=false
            end
            % If only one noise level is given, the function returns detailed, itemized results.
            % If multiple noise levels are given, it returns a collection of metrics (e.g., errors).
            algo = importModule(identifierModulePath);
            if nargout == 1
                ret = algo(self.config.dataset, nsrLevel, rngSeed);
            elseif nargout == 2
                [ret, itemizedResults] = algo(self.config.dataset, nsrLevel, rngSeed);
            end
            
            metrics = struct();
            metrics.tpr  = ret.tpr;
            metrics.ppv  = ret.ppv;
            metrics.e2   = ret.e2;
            metrics.einf = ret.einf;
            metrics.eres = ret.eres;
            
            results = struct('metrics', metrics);
            results.trueEqn = ret.trueEqn; 
            results.retEqn  = ret.retEqn;
            results.ret = ret;
            varargout{1} = results;
            
            if nargin == 5 && ~verbose
                % Add additional true value to the inputs to show the
                % following loggings.
                self.log(sprintf('nsr %.2f rng_seed %d tpr %5.2f ppv %5.2f', nsr, rng_seed, results.tpr, results.ppv));
                self.log(sprintf('True Equation: %s, Returned Equation: %s', metrics.trueEqn, results.retEqn));
            end

            if nargout == 2
                varargout{2} = itemizedResults;
            end
        end

    end
end

function rngSeed = generate_rng_seed()
    rng('shuffle');
    rngSeed = rng().Seed;
end
function c = struct2Pairs(s)
arguments
    s (1,1) struct
end
    c = cell(2*length(fieldnames(s)), 1);
    c(1:2:end) = fieldnames(s);
    c(2:2:end) = struct2cell(s);
end
function module=importModule(modulePath)
%
% Syntax:
%   importModule('path.to.module')
modulePath = strrep(modulePath, '.', '/');
[folder, fileName, ~] = fileparts(modulePath);
addpath(folder);
module=str2func(fileName);
end

