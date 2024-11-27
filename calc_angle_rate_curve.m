function [count_curve, time_curve, angle_index, shuffled_count_curve] = calc_angle_rate_curve(angle, r, abin, EPOCH)
% 计算方向和发放率的关系曲线
% count_curve, time_curve, index_curve

% 输入的angle和r的每一行表示时间步，[timestep, feature]

amax = pi;
amin = -pi;
% 曲线的采样点数量
num_bins = round(2 * pi / abin);        

% 生成角度区间
angle_grid = linspace(amin, amax, num_bins + 1);

% 计算每个点的方向在角度区间的索引
indices = discretize(angle, angle_grid);

% 为每个神经元计算count curve，计算time curve
fprintf('gengerating count curve for each neuron ...\n');
count_curve = cell(1, size(r, 2));
time_curve = zeros(1, num_bins);
for n=1:size(r, 2)
    tmp_count_curve = zeros(1, num_bins);

    for i=1:length(indices)
        idx = indices(i);

        if ~isnan(idx)
            tmp_count_curve(idx) = tmp_count_curve(idx) + r(i, n);

            % 对于所有的neurons来说，time curve是一样的，只需要计算一次
            if n == 1
                time_curve(idx) = time_curve(idx) + 1;
            end
        end

    end

    count_curve{1, n} = tmp_count_curve;
end

% 保留indices
fprintf('generating angle index and time map ...\n');
angle_index = struct('angle_indices', indices);

% 计算shuffled curve
fprintf('generating shuffled angle curve data ...\n');
shuffled_count_curve = cell(1, EPOCH);
for epoch=1:EPOCH
    fprintf('------epoch %d / %d ------\n', epoch, EPOCH);

    % 沿时间轴循环位移
    r_tmp = circshift(r, randi(size(r, 1)), 1);

    % 当前epoch得到的所有神经元的count curve
    count_curve_epoch = cell(1, size(r, 2));
    for n=1:size(r, 2)
        tmp_count_curve = zeros(1, num_bins);

        for i=1:length(indices)
            idx = indices(i);

            if ~isnan(idx)
                tmp_count_curve(idx) = tmp_count_curve(idx) + r_tmp(i, n);
            end

        end

        count_curve_epoch{1, n} = tmp_count_curve;
    end

    shuffled_count_curve{1, epoch} = count_curve_epoch;
end

end