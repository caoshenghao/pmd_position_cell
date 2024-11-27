function coherence = calc_spatial_coherence(map)
% 计算spatial coherence
% 每个bin上的rate，以及每个bin周边8个bin的平均rate，这两个之间的相关性
% 只保留有完整8个相邻bin的位置

% map: 输入，二维空间发放热图
% coherence: 输出

% 卷积核
kernel = ones(3, 3) ./ 8;
kernel(2, 2) = 0;

map2 = conv2(map, kernel, 'same');

% 有效数据点
idx = ~isnan(map) & ~isnan(map2);

coherence = corr(map(idx), map2(idx));

end