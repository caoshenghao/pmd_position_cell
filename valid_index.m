function index = valid_index(coords3d, flag, dismiss_low, frame_rate)
% 依据筛选条件返回合适的index
% flag: hand-选取全部时段；hand_no_food-选取没有food出现的时段
%       food-选取全部时段；food_no_hand-舍去拿到食物的时段
% dismiss_low: bool，是否舍去低速区间

food_pos = coords3d(:, 1:3);
hand_pos = coords3d(:, 4:6);
nose_pos = coords3d(:, 16:18);
nose_pos = mean(nose_pos, 1, 'omitnan');

food_index = ~isnan(food_pos(:, 1)) & ~isnan(food_pos(:, 2)) & ~isnan(food_pos(:, 3));
hand_index = ~isnan(hand_pos(:, 1)) & ~isnan(hand_pos(:, 2)) & ~isnan(hand_pos(:, 3));

% 舍去小于1cm/s的低速区间
if dismiss_low
    food_vel = sqrt(sum(diff(food_pos).^2, 2));
    food_vel = [food_vel; food_vel(end)] * frame_rate / 10;
    food_index = food_index & (food_vel >= 1);
    
    hand_vel = sqrt(sum(diff(hand_pos).^2, 2));
    hand_vel = [hand_vel; hand_vel(end)] * frame_rate / 10;
    hand_index = hand_index & (hand_vel >= 1);
end

% 处理food
if strcmp(flag, 'food') || strcmp(flag, 'food_no_hand')
    index = food_index & (food_pos(:, 2) > nose_pos(2));    % food y轴位置必须超出nose才有可能被注意到
    
    % 每一段非nan数据段的开头和结尾
    didx = diff(index);
    
    trial_end = find(didx==-1);
    trial_start = find(didx==1) + 1;
    
    if index(1)
        trial_start = [1; trial_start];
    end
    
    if index(end)
        trial_end = [trial_end; length(index)];
    end
    
    % food出现的时长肯定要超过0.5s
    trial_len = (trial_end - trial_start) / frame_rate;
    trial_start = trial_start(trial_len > 0.5);
    trial_end = trial_end(trial_len > 0.5);
    
    % food出现后不一定立刻被注意到，我们选择每个非空段的后3/4部分
    trial_start = trial_start + round((trial_end - trial_start) / 4);
    
    index_tmp = zeros(size(index));
    for i=1:length(trial_start)
        index_tmp(trial_start(i):trial_end(i)) = 1;
    end
    index = index & index_tmp;
    
    
    % 在拿到食物后，food与hand轨迹几乎是重合的
    if strcmp(flag, 'food_no_hand')
        
        % 拿住食物后，food与nose在y轴的距离会不断减小
        food_nose_y = abs(food_pos(:, 2) - nose_pos(2)) / 10;
        
        id = find(food_nose_y < 1); % 食物吃到嘴里最终距离接近0，此处取1cm
        did = diff(id);
        idx = [id(1); id(find(did > 1) + 1)];
        % 向前找到极大值点
        catch_points = [];
        for i=1:length(idx)
            s = idx(i);
            while 1
                tmp = s - 1;
                if isnan(food_nose_y(tmp)) || tmp < 1
                    catch_points = [catch_points; s];
                    break
                end
                
                if food_nose_y(tmp) - food_nose_y(s) > 0
                    s = tmp;
                else
                    catch_points = [catch_points; s];
                    break
                end
                
            end
            
        end
        
        % idx表示吃到食物的时刻，catch_points表示拿到食物的时刻，间隔应该至少150ms
        d = (idx - catch_points) / frame_rate;
        catch_points = catch_points(d > 0.15);
        
        % 将trial区间调整为start-catch_point
        for i=1:length(catch_points)
            for s=1:length(trial_start)-1
                if trial_start(s)<=catch_points(i) && trial_start(s+1)>catch_points(i)
                    trial_end(s) = min(catch_points(i), trial_end(s));
                    break
                end
            end
        end
        
        % 更新index
        index_tmp = zeros(size(index));
        for i=1:length(trial_start)
            index_tmp(trial_start(i):trial_end(i)) = 1;
        end
        index = index & index_tmp;
        
    end
    
end


% 处理hand
if strcmp(flag, 'hand') || strcmp(flag, 'hand_no_food')
    index = hand_index;
    
    % 舍去food出现的时段
    if strcmp(flag, 'hand_no_food')
        food_index = ~isnan(food_pos(:, 1)) & ~isnan(food_pos(:, 2)) & ~isnan(food_pos(:, 3));
        index = index & ~food_index;
    end
    
end


end