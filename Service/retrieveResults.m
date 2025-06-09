function ret=retrieveResults(statsName, datasetName, modelNames)
    [x, m, s] = deal(cell(numel(modelNames),1));
    for i = 1:numel(modelNames)
        resultPath = sprintf("Results/ModelHandler/%s/%s/results/results.mat", modelNames{i}, datasetName);
        load(resultPath, 'mean_table', 'std_table');
        listats = strcmp(statsName,std_table.stats_varname);
        x{i} = mean_table.index;
        m{i} = mean_table.stats(:, listats);
        s{i} = std_table.stats(:, listats);
    end
    ret.x = x;
    ret.y = m;
    ret.err = s;
end