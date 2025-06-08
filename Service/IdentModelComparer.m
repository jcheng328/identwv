classdef IdentModelComparer < ModelComparer
    % IdentModelComparer Class for handling identification-model-related 
    % tasks like identifying at one noise level, identifying at a series of
    % noise levels.
    %
    % Usage:
    %   handler = IdentModelComparer(config)
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
        comparerModulePath
        statsName
        modelNames
        displayNames
        datasetNames
        nsrLevels
        numRepetition
    end
    methods
        function obj=IdentModelComparer(config)
            obj@ModelComparer(config);
            obj.setComparerModulePath(obj.config.comparer.path);
            obj.setStatsName(obj.config.comparer.statsName);
            obj.setModelNames(obj.config.models)
            obj.setDisplayNames(obj.config.displayNames)
            obj.setDatasetNames(obj.config.datasets)
        end
        function setComparerModulePath(self, comparerModulePath)
            % Set path to Comparer Moduler
            %
            % Syntax:
            %   hanlder.setComparerModulePath('./path/to/module')
            %
            % Inputs:
            %   comparerModulePath - Path to module
            %
            self.comparerModulePath = comparerModulePath;
        end
        function setModelNames(self, modelNames)
            % Set model names
            %
            % Syntax:
            %   hanlder.setModelNames({'model1', 'model2'})
            %
            % Inputs:
            %   modelNames - Model names
            %
            self.modelNames = modelNames;
        end
        function setStatsName(self, statsName)
            % Set stats names
            %
            % Syntax:
            %   hanlder.setStatsNames('stats')
            %
            % Inputs:
            %   statsNames - Stats names
            %
            self.statsName = statsName;
        end
        function setDisplayNames(self, displayNames)
            % Set model names
            %
            % Syntax:
            %   hanlder.setDisplayNames({'model1', 'model2'})
            %
            % Inputs:
            %   displayNames - Display names
            %
            self.displayNames = displayNames;
        end
        function setDatasetNames(self, datasetNames)
            % Set dataset names
            %
            % Syntax:
            %   hanlder.setDatasetNames({'data1', 'data2'})
            %
            % Inputs:
            %   datasetNames - Dataset names
            %
            self.datasetNames = datasetNames;
        end
        function loopCompare(self, comparerModulePath, modelNames, displayNames, datasetNames)
            arguments
                self
                comparerModulePath = self.comparerModulePath
                modelNames = self.modelNames
                displayNames = self.displayNames
                datasetNames = self.datasetNames
            end
            for i = 1:numel(self.datasetNames)
                self.compare(self.statsName, datasetNames{i}, modelNames, displayNames, comparerModulePath, self.config.xlim{i}, self.config.legendLoc{i})
            end
        end
        function compare(self, statsName, datasetName, modelNames, displayNames, comparerModulePath, xlimits, legendLoc, verbose)
            arguments
                self
                statsName
                datasetName
                modelNames
                displayNames
                comparerModulePath=self.comparerModulePath
                xlimits=self.config.figure.get('xlim', 'tight')
                legendLoc=self.config.figure.get('legendLoc','best')
                verbose=false
            end
            % legendLoc = 'bestoutside'
            algo = importModule(comparerModulePath);
            % Initial figures
            fig = figure("Visible", "off");
            ax = fig.CurrentAxes;
            if isempty(ax); ax = axes(); end
            fig.Units = 'centimeters';
            fig.Position = self.config.figure.get('position', [1,1,9.3,9.3]);
            % fig.Position = self.config.figure.get('position', [1,1,15.3,9.3]);

            % Plot figures
            try
                ret = algo(statsName, datasetName, modelNames);
            catch ME
                self.log(sprintf('An error occurred: %s\n', ME.message));
                return
            end
            colors = self.config.get('colors', {'r', 'g', 'b', 'k', 'y'});
            % markers = self.config.get('markers', {'o', '+', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'});
            markers = self.config.get('markers', {'o', '+', '*', '.', '.', '.', '.', '.', 'v', '>', '<', 'p', 'h'});
            plotHandlers = {};
            for i=1:numel(ret.x)
                x = ret.x{i};
                y = ret.y{i};
                lineStyle = '-';
                marker = markers{i};
                displayName = displayNames{i};
                color = colors{i};

                if isfield(ret, 'err') && self.config.figure.get('errorbar', true)
                    err = ret.err{i};
                    plotHandlers{end+1,1} = errorbar(ax, x, y, err, LineStyle=lineStyle, Marker=marker, LineWidth=2, DisplayName=displayName, Color=color);
                else
                    plotHandlers{end+1,1} = plot(ax, x, y, LineStyle=lineStyle, Marker=marker, LineWidth=2, DisplayName=displayName, Color=color);
                end
                hold on;
            end
            hold off;

            % Format figures
            set(ax,'LooseInset', max(get(ax,'TightInset'), 0.02));
            xlabel(ax, self.config.figure.get('xlabel', ''));
            ylabel(ax, self.config.figure.get('ylabel', ''));
            title(ax, self.config.figure.get('title', ''));
            legend([plotHandlers{:}],'location', legendLoc, 'NumColumns', self.config.figure.get('legendCols', 1));
            ylim(ax, self.config.figure.get('ylim', 'auto'));
            xlim(ax, xlimits);
            set(ax, 'YScale', self.config.figure.get('YScale','linear'));
            set(findall(fig,'-property','FontSize'),'FontSize',self.config.figure.get('FontSize', 16));
            set(findall(fig,'-property','MarkerSize'),'MarkerSize',self.config.figure.get('MarkerSize', 8));
            set(ax,'LineWidth',self.config.figure.get('LineWidth', 1));
            set(ax,'OuterPosition',[0.01 0.01 0.96 0.96]);
            annotation('rectangle',[0 0 1 1],'Color','w');
            
            % Save and close figures
            dirName = fullfile(self.outputDir, datasetName);
            if ~exist(dirName, 'dir')
                % Create the directory if it does not exist
                mkdir(dirName);
            end
            figName = self.config.comparer.get('figName', statsName);
            % saveas(fig, fullfile(dirName, sprintf('%s.pdf', figName)), 'pdf');
            saveas(fig, fullfile(dirName, sprintf('%s.png', figName)), 'png');
            saveas(fig, fullfile(dirName, sprintf('%s.epsc', figName)), 'epsc');
            saveas(fig, fullfile(dirName, sprintf('%s.fig', figName)), 'fig');
            exportgraphics(fig, fullfile(dirName, sprintf('%s.pdf', figName)),'BackgroundColor','none');
            close(fig);

        end
    end
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

