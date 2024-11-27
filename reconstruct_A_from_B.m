function target = reconstruct_A_from_B(target_index, source_index, source)
% 已知source的调谐形式，来重建target

% 新版本，加速

target_size = size(target_index);

% index抻成列向量，保留cell格式
target_index = target_index(:);
source_index = source_index(:);

% 获取所有的源数据
source = source(:);

target = nan * zeros(size(target_index));
for i=1:length(target_index)
    index = target_index{i};
    
    if ~isempty(index)
        
        % 在target bin位置处有index这些数据点，计算得到这些数据点按照source bin
        % 进行划分后分布在各个位置的概率
        p = cellfun(@(x) sum(ismember(x, index)), source_index);
        p = p ./ sum(p);
        
        % 点乘
        r = p .* source;
        
        % 某些情况下p在某个位置有值，但是source在该位置是nan，需要忽略该位置
        % 导致所有有效的p值加和不是1，需要根据有效的p值重新计算分布概率
        nonnan = ~isnan(r);
        target(i) = sum(r(nonnan)) ./ sum(p(nonnan));
    end
end

% 重整回原始形状
target = reshape(target, target_size);


% 
% target_size = size(target_index);
% 
% % flatten data
% target_index = target_index(:);
% source_index = source_index(:);
% source = source(:);
% 
% target = nan * zeros(size(target_index));
% 
% % 计算target_index在source_index上的概率分布
% P = cell(size(target_index));
% 
% for i=1:length(target_index)
%     index = target_index{i};
%     
%     if ~isempty(index)
%         % 计算target_index出现在source各个位置的次数
%         tmp = zeros(size(source_index));
%         
%         for j=1:length(index)
%             idx = index(j);
%             
%             for k=1:length(source_index)
%                 if find(source_index{k}==idx)
%                     tmp(k) = tmp(k) + 1;
%                     break
%                 end
%             end
%         end
%         
%         P{i} = tmp ./ sum(tmp);
%         
%     end
% end
% 
% % 按照概率分布和source进行加权和
% for i=1:length(target_index)
%     p = P{i};
%     
%     if ~isempty(p)
%         r = p .* source;
% 
%         nonnan = ~isnan(r);
%         target(i) = sum(r(nonnan)) / sum(p(nonnan));
%     end
% end
% 
% % 重整回原始形状
% target = reshape(target, target_size);

end