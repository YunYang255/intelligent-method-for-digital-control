function sorted_entities = BFS(entities)
% 提取直线和圆弧的起点和终点坐标信息
data = zeros(length(entities), 5); % 初始化 data 矩阵  
m = 0;

for i = 1:length(entities)
    e = entities(i);
    if strcmp (e.name, 'LINE')
        a = e.line(1,1);
        b = e.line(1,2);
        c = e.line(1,3);
        d = e.line(1,4);
        data(i-m,:) = [a,b,c,d,0];
        e_line = entities(i);
    elseif strcmp (e.name, 'ARC')
        [x1,y1] = coordinate_calculation(e.arc(1,4), e.arc(1,1), e.arc(1,2), e.arc(1,3));  %计算圆弧起点坐标
        [x2,y2] = coordinate_calculation(e.arc(1,5), e.arc(1, 1), e.arc(1, 2), e.arc(1, 3)); % 计算圆弧终点坐标  
        data(i,:) = [x1,y1,x2,y2,1];
        e_arc = entities(i);
    elseif strcmp (e.name, 'CIRCLE')
        e_circle(m+1) = entities(i);
        m = m+1;
        % 删除 data 中的当前行
        data(i,:) = [];
        % 更新循环索引以保持正确
        %i = i - 1;
    end
end
 % 计算给定坐标与所有起点和终点之间的距离
    duidaox = evalin('base', 'duidaox');
    duidaoy = evalin('base', 'duidaoy');
 distances = sqrt((data(:, 1) - duidaox).^2) + ((data(:, 2) - duidaoy).^2);
  
 % 找到距离最小的起点或终点的行索引
 [~, min_index] = min(distances);
    
 % 将最小距离对应的行与第一行交换
 reordered_data= data;
 reordered_data([1 min_index], :) = reordered_data([min_index 1], :);
 data =  reordered_data;

tolerance = 0.1; % 容差

% 寻找相互连接的线条
connected_lines = {}; % 用于存储相互连接的线条
remaining_lines = data; % 剩余未处理的线条

while ~isempty(remaining_lines) %循环处理直到reamin_line为空
    connected_line = [];
    current_point = remaining_lines(1, :);%当前点
    remaining_lines(1, :) = []; % 从剩余线条中移除当前线条
    
    while true
        connected_line = [connected_line; current_point]; % 将当前点加入连接线条中
        end_point = current_point(3:4);
        
        % 寻找与当前线条相连的下一条线条
        next_line_index = [];
        for i = 1:size(remaining_lines, 1)
            next_line_end_point = remaining_lines(i, 3:4);
            next_line_start_point = remaining_lines(i, 1:2);
            distance1 = sqrt((end_point(1) - next_line_end_point(1))^2 + (end_point(2) - next_line_end_point(2))^2);
            distance2 = sqrt((end_point(1) - next_line_start_point(1))^2 + (end_point(2) - next_line_start_point(2))^2);
            if distance1 <= tolerance 
                next_line_index = i;
                next_line = remaining_lines(next_line_index, :);
                current_point = next_line;
                changing = current_point;
                current_point(1,1:2)=changing(1,3:4);
                current_point(1,3:4)=changing(1,1:2);
                remaining_lines(next_line_index, :) = []; % 从剩余线条中移除当前线条
                break;
            elseif distance2 <= tolerance
                next_line_index = i;
                next_line = remaining_lines(next_line_index, :);
                remaining_lines(next_line_index, :) = []; % 从剩余线条中移除当前线条
                current_point = next_line;
                break;
            end
        end
        
        if isempty(next_line_index) % 如果没有找到下一条线条，则跳出循环
            break;
        end
    end
    
    connected_lines{end+1} = connected_line; % 将连接的线条加入结果中
end

% 将连接的线条按顺序存储到一个新的数组中
ordered_lines = [];
for i = 1:numel(connected_lines)
    ordered_lines = [ordered_lines; connected_lines{i}];
end

% 显示连接的线条
disp('按顺序存储的连接线条：');
disp(ordered_lines);

% 根据排序结果重新排列 entities
sorted_entities = entities(length(entities)-m); % 初始化 sorted_entities
for i = 1:size(ordered_lines, 1)
    if ordered_lines(i,5) == 0
       for j = 1:length(entities)
        e = entities(j);
          if strcmp(e.name, 'LINE')
            line_points = [e.line(1,1), e.line(1,2), e.line(1,3), e.line(1,4)];
            reverse_line_points = [e.line(1,3), e.line(1,4), e.line(1,1), e.line(1,2)];
            if isequal(line_points, ordered_lines(i, 1:4))
                sorted_entities(i) = e;
                break;
            elseif isequal(reverse_line_points, ordered_lines(i, 1:4))
                % 如果匹配的是反转的顺序，需要反转存储在 sorted_entities 中的线的坐标
                sorted_entities(i) = e;
                sorted_entities(i).line = [reverse_line_points(1:2), reverse_line_points(3:4)];
                break;
            end
          end
       end
    else
        for j = 1:length(entities)
        e = entities(j);
         if strcmp(e.name, 'ARC')
            [x1, y1] = coordinate_calculation(e.arc(1,4), e.arc(1,1), e.arc(1,2), e.arc(1,3));
            [x2, y2] = coordinate_calculation(e.arc(1,5), e.arc(1, 1), e.arc(1, 2), e.arc(1, 3));
            arc_points = [x1, y1, x2, y2];
            reverse_arc_points = [x2, y2, x1, y1];
            if isequal([x1, y1, x2, y2], ordered_lines(i, 1:4))
                sorted_entities(i) = e;
                break; 
            elseif isequal(reverse_arc_points, ordered_lines(i, 1:4))
                sorted_entities(i) = e;
                break; 
            end
         end
        end
    end
end

    for i = 1:m
        sorted_entities(end+1) = e_circle(i);
    end

end
