function gridscore = calc_gridscore2D(map)
% 计算二维图的grid score

% map: 输入，二维空间发放热图
% gridscore: 输出

if ~ismatrix(map)
    error("输入必须为二维矩阵！");
end

% 1 ======首先确定圆环内径======
% 1.1 计算correlation curve

% 计算map中所有点到中心的距离，以及所有点的相关值
w = size(map, 1);
h = size(map, 2);

[x, y] = ndgrid(1:w, 1:h);
x = x(:);
y = y(:);
dis = sqrt((x-(w+1)/2).^2 + (y-(h+1)/2).^2);
r = map(:);

% 距离步长1bin，有nan值的距离就不要了
curve_y = [];
for d=0:1:ceil(max(dis))-1
    idx = find(dis>=d & dis<(d+1));
    if isempty(find(isnan(r(idx)), 1))
        curve_y = [curve_y, mean(r(idx))];
        
    else
        break
    end
end

curve_x = 1:length(curve_y);

% 1.2 找到curve上第一个极小值点和第一个负值点，取距离更小的值作为内径D1
idx = find(curve_y<0);
if ~isempty(idx)
    d1 = curve_x(idx(1));
else
    d1 = length(curve_y);
end

[~, locs] = findpeaks(-curve_y);
if ~isempty(locs)
    d2 = locs(1);
else
    d2 = length(curve_y);
end

D1 = min(d1, d2);


% 2 ======确定外径D2的取值范围：D1+4：border-4======
d1 = D1 + 4;
d2 = max(curve_x) - 4;
if d2 <= d1
    gridscore = nan;
    return
end

D2 = d1:d2;


% 3 ======对于每一个内外径组成的圆环，计算一个score======
scores = nan * zeros(1, length(D2));
for i=1:length(D2)
    
    % 3.1 找出圆环内的所有点
    idx = find(dis>=D1 & dis<=D2(i));
    r_raw = r(idx);
    
    % 3.2 分成两组，group1：逆时针旋转60°、120°；group2：顺时针旋转30°、90°、150°
    group1 = [60, 120];
    for g=1:length(group1)
        % 旋转图像
        mapr = imrotate(map, group1(g), 'nearest', 'crop');
        
        % 旋转后圆环内的相关值
        rr = mapr(:);
        r_r = rr(idx);
        
        % 旋转前后的圆环的相关值
        tmp = corrcoef(r_raw, r_r);
        
        group1(g) = tmp(1, 2);
        
    end
    
    group2 = -1 * [30, 90, 150];
    for g=1:length(group2)
        % 旋转图像
        mapr = imrotate(map, group2(g), 'nearest', 'crop');
        
        % 旋转后圆环内的相关值
        rr = mapr(:);
        r_r = rr(idx);
        
        % 旋转前后的圆环的相关值
        tmp = corrcoef(r_raw, r_r);
        
        group2(g) = tmp(1, 2);
        
    end
    
    % 3.3 第一组和第二组差值的最小值作为score
    tmp = [group1-group2(1), group1-group2(2), group1-group2(3)];
    scores(i) = min(tmp);
end

% ======4 取所有内外径组合的最大值======
gridscore = max(scores);

end