function sparsity = calc_sparsity(count_map, time_map)
% 计算sparsity

% count_map: 输入，空间发放计数图
% time_map: 输入，空间停留时间图
% sparsity: 输出

% 1. 计算空间发放率
r = count_map ./ time_map;

% 2. 依据时间计算出空间概率
all_time = sum(time_map(:), 'omitnan');
p = time_map ./ all_time;

% 展开成向量
r = r(:);
p = p(:);

% 3. 计算sparsity
s1 = sum(r .* p, 'omitnan')^2;
s2 = sum(p .* (r.^2), 'omitnan');
sparsity = s1 / s2;

end