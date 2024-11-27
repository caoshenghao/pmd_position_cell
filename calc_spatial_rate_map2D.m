function [count_map, time_map, space_index, shuffled_count_map] = calc_spatial_rate_map2D(traj, r, xrange, yrange, binwidth, EPOCH)
% 计算空间发放热图以及shuffle数据集，二维空间
% count_map, time_map, space_index

% 输入的traj和r的每一行表示时间步，[timestep, feature]

% map的大小
x_bins = round((xrange(2) - xrange(1)) / binwidth);
y_bins = round((yrange(2) - yrange(1)) / binwidth);

% 生成空间格点
x_grid = linspace(xrange(1), xrange(2), x_bins + 1);
y_grid = linspace(yrange(1), yrange(2), y_bins + 1);

% 计算每个轨迹点在空间格点的索引
x_indices = discretize(traj(:, 1), x_grid);
y_indices = discretize(traj(:, 2), y_grid);

% 为每个神经元计算count map，计算time map
fprintf('generating count map for each neuron ...\n');
count_map = cell(1, size(r, 2));
time_map = zeros(x_bins, y_bins);
for n=1:size(r, 2)
    tmp_count_map = zeros(x_bins, y_bins);

    for i=1:length(x_indices)
        x_idx = x_indices(i);
        y_idx = y_indices(i);

        if ~isnan(x_idx) && ~isnan(y_idx)
            tmp_count_map(x_idx, y_idx) = tmp_count_map(x_idx, y_idx) + r(i, n);

            % 对于所有的neuron来说，time map是一样的，只需要计算一次
            if n == 1
                time_map(x_idx, y_idx) = time_map(x_idx, y_idx) + 1;
            end
        end

    end

    count_map{1, n} = tmp_count_map;
end

% 保留grid indices
fprintf('generating space index and time map ...\n');
space_index = struct('x_indices', x_indices, 'y_indices', y_indices);

% 计算shuffled map
fprintf('generating shuffled spatial rate map data ...\n')
shuffled_count_map = cell(1, EPOCH);
for epoch=1:EPOCH
    fprintf('------epoch %d / %d ------\n', epoch, EPOCH);

    % 沿时间轴循环位移
    r_tmp = circshift(r, randi(size(r, 1)), 1);

    % 当前epoch得到的所有神经元的count map
    count_map_epoch = cell(1, size(r, 2));
    for n=1:size(r, 2)
        tmp_count_map = zeros(x_bins, y_bins);

        for i=1:length(x_indices)
            x_idx = x_indices(i);
            y_idx = y_indices(i);

            if ~isnan(x_idx) && ~isnan(y_idx)
                tmp_count_map(x_idx, y_idx) = tmp_count_map(x_idx, y_idx) + r_tmp(i, n);
            end

        end

        count_map_epoch{1, n} = tmp_count_map;
    end

    shuffled_count_map{1, epoch} = count_map_epoch;
end

end