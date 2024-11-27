function mi = calc_spatial_mutual_information(count_map, time_map)
% 计算空间互信息
% 返回值bits/spike

% count_map: 输入，空间发放计数图
% time_map: 输入，空间停留时间图
% mi: 输出

% 1. 计算空间发放率
r = count_map ./ time_map;

% 2. 依据时间计算出空间概率
all_time = sum(time_map(:), 'omitnan');
p = time_map ./ all_time;

% 展开成向量
r = r(:);
p = p(:);

% 3. 计算整个空间内整体的平均发放率
R = sum(r .* p, 'omitnan');

% 4. 计算mi
mi = sum(r .* log2(r / R) .* p, 'omitnan');
mi = mi / R;

end