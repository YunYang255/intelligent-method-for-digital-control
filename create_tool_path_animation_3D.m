function create_tool_path_animation_3D(filename)
    % 打开并读取文件
    fid = fopen(filename, 'r');
    if fid == -1
        error('无法打开文件');
    end
    tolerance = 1e-3;
    % 初始化刀具位置和路径数组
    current_pos = [0, 0 ,0];
    prev_z = 0; % 初始化之前的Z值为0
    path= [0,0,0];
    
length =  evalin('base', 'length'); %胚料的长度
width = evalin('base', 'width');  %胚料的宽度
height = evalin('base', 'height') ; %胚料的高度

a = evalin('base', 'Gcenter_x');
b = evalin('base', 'Gcenter_y');
c = evalin('base', 'Gcenter_z');

Center_Point = [a,b,c];

x= Center_Point(1,1)-length/2;
y= Center_Point(1,2)+width/2;
z= Center_Point(1,3)+height/2;

pointA_1 =[x y z];
pointA_2 =[x y z-height];
pointA_3 =[x y-width z];
pointA_4 =[x y-width z-height];

pointB_1 =[x+length y z];
pointB_2 =[x+length y z-height];
pointB_3 =[x+length y-width z];
pointB_4 =[x+length y-width z-height];

% 定义长方体的八个顶点坐标
    cuboidVertices = [pointA_1;pointA_2;pointA_3;pointA_4;
                pointB_1;pointB_2;pointB_3;pointB_4;];
% 定义每个面的顶点索引
faces = [
    1, 2, 4, 3; % 面 1
    1, 2, 6, 5; % 面 2
    1, 3, 7, 5; % 面 3
    2, 4, 8, 6; % 面 4
    3, 4, 8, 7; % 面 5
    5, 6, 8, 7  % 面 6
];

while ~feof(fid)
    line = fgetl(fid);
    
    % 分析G代码行
    if contains(line, 'G00') || contains(line, 'G01')
        % 直线插补
        coords = parse_coords(line, current_pos);
        interpolated = interpolate_line(current_pos, coords); % 插值
        path = [path; interpolated];
        current_pos = coords;
    elseif contains(line, 'G02') || contains(line, 'G03')
        % 判断圆弧还是圆
        x_str = extract_value(line, 'X');
        y_str = extract_value(line, 'Y');
        new_pos = [str2double(x_str), str2double(y_str), current_pos(3)]; % 使用当前Z值
        
        % 判定终点是不是与上一个刀具位置重合
        if (abs((new_pos(1,1)-path(end,1)))<tolerance) && (abs((new_pos(1,2)-path(end,2)))<tolerance) %圆判定
            % 圆判定
            [arc_path, new_pos] = parse_circle(line, current_pos);
            path = [path; arc_path];
            current_pos = new_pos;
        else
            % 圆弧判定
            [arc_path, new_pos] = parse_arc(line, current_pos);
            path = [path; arc_path];
            current_pos = new_pos;
        end
    elseif contains(line, 'Z') && ~contains(line, 'X') && ~contains(line, 'Y')
        % 只有Z坐标变化，X和Y坐标保持不变
         z_str = extract_value(line, 'Z');
        new_pos = [current_pos(1), current_pos(2), str2double(z_str)]; % 新的Z坐标
        
        % 插值
        interpolated = interpolate_line_z(current_pos, new_pos); % 插值
        path = [path; interpolated];
        
        % 更新当前坐标
        current_pos = new_pos;
    end
end
    
    fclose(fid);
    
    % 初始化刀具数据存储
    % 预分配内存
    num_points = size(path, 1);
    cylinders = cell(num_points, 1); % 预分配内存
    
    % 刀具的半径和高度
    radius = 0.5;
    tool_height = 1;
        
    %figure('Position', [100, 100, 1200, 800]); % 设置图形窗口大小
    %h = animatedline('Marker', 'o');
    view(3); % 设置为三维视图
    axis equal;
    axis([min(path(:,1))-2*radius-tool_height/2  max(path(:,1))+2*radius+tool_height/2 min(path(:,2))-2*radius-width/2 max(path(:,2))+2*radius+width/2  min(path(:,3))-tool_height-height/2 max(path(:,3))+tool_height+height/2]);
    pbaspect([1 1 1]); % 保持绘图区域的比例

    xlabel('X (mm)');
    ylabel('Y (mm)');
    zlabel('Z (mm)');
    title('刀具路径');
    grid on;
    hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 绘制动画 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 初始设置
    % 绘制路径
    plot3(path(:,1), path(:,2), path(:,3), 'k--');
    %创建一个 animatedline 对象用于绘制刀具中心轨迹
    tool_trace = animatedline('Marker', 'o');
%     % 创建初始的文本对象
    V=0;
    V_text_handle = text(0, 0, 0, 'V = 0', 'FontSize', 12, 'Color', 'blue');
    patch('Vertices', cuboidVertices, 'Faces', faces, 'FaceColor', 'cyan', 'FaceAlpha', 0.5);
    % 绘制动画
    for k = 1:size(path, 1)
        % 绘制路径
    %plot3(path(1:k, 1), path(1:k, 2), path(1:k, 3), '-o');
    addpoints(tool_trace, path(k, 1), path(k, 2), path(k, 3));
    % 生成圆柱体表面数据
    [Xc, Yc, Zc] = cylinder(radius, 30);
    Zc = Zc * tool_height - tool_height / 2; % 调整圆柱体的高度中心
    Xc = Xc + path(k, 1);
    Yc = Yc + path(k, 2);
    Zc = Zc + path(k, 3);
    
    %判断刀具是否在切削胚料
    cylinderCenter = [path(k,1) path(k,2) path(k,3)];
    cylinderRadius = radius;
    cylinderHeight = tool_height;
    cylinderAxis = [0,0,1];
    
    condition =  Minkowski (cuboidVertices, cylinderCenter, cylinderRadius, cylinderHeight, cylinderAxis);
    if condition == 1 
       legend_strings = {'刀具中心轨迹', '切削中', '一号冷却液开启' ,'二号冷却液关闭', '主轴旋转'};
       V = V+2*pi*radius;
    else
       legend_strings = {'刀具中心轨迹', '没有切削' , '一号冷却液关闭','二号冷却液关闭','主轴旋转'};
    end
    
    % 存储当前圆柱体数据
    cylinders{k} = surf(Xc, Yc, Zc, 'FaceAlpha', 0.5, 'EdgeColor', 'none');  %  绘制圆柱体并存储句柄
    fill3(Xc(1,:), Yc(1,:), Zc(1,:), 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'none');  %  底面
    fill3(Xc(2,:), Yc(2,:), Zc(2,:), 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'none');  %  顶面
    
    set(V_text_handle, 'Position', [path(k, 1), path(k, 2), path(k, 3) + 1], 'String', ['V = ' num2str(V)]);
    drawnow;
    pause(0.05); % 控制动画速度
    
    legend(legend_strings);
    
    end
   
   
    end

%计算直线插补终点位置
function coords = parse_coords(line, prev_coords) % 提取X和Y以及Z坐标，prev_coords为之前的坐标
    x_str = extract_value(line, 'X');
    y_str = extract_value(line, 'Y'); 
    z_str = extract_value(line, 'Z');
    
    if isempty(x_str)
        x_val = prev_coords(1); % 如果没有读取到X值，使用之前的X值
    else
        x_val = str2double(x_str);
    end
    
    if isempty(y_str)
        y_val = prev_coords(2); % 如果没有读取到Y值，使用之前的Y值
    else
        y_val = str2double(y_str);
    end
    
    if isempty(z_str)
        z_val = prev_coords(3); % 如果没有读取到Z值，使用之前的Z值
    else
        z_val = str2double(z_str);
    end
    
    coords = [x_val, y_val, z_val];
end



function value = extract_value(line, prefix)  %提取数字信息
    idx = strfind(line, prefix);  %返回prefix的位置索引
    if isempty(idx)
        value = ''; %如果idx为空则返回空字符
    else
        % 找到数字的起始位置和结束位置
        start_idx = idx + 1;
        end_idx = start_idx;
        while end_idx <= length(line) && (isstrprop(line(end_idx), 'digit') || line(end_idx) == '.' || line(end_idx) == '-') %条件1:不超过字符串长度 条件2:检查当前字符是否为数字 条件3和条件4:允许小数点和符号
            end_idx = end_idx + 1;  %只要当前字符是数字或者是小数点或者是符号,字符串结束标志位+1
        end
        %循环运行直到end_idx指向数值后的第一个非数字字符位置
        value = line(start_idx:end_idx-1);  %提取字符
    end
end

%圆弧插补
function [arc_path, end_pos] = parse_arc(line, start_pos)  %返回圆弧路径与刀具最终位置
    % 提取X, Y, I, J坐标
    x_str = extract_value(line, 'X');
    y_str = extract_value(line, 'Y');
    i_str = extract_value(line, 'I');
    j_str = extract_value(line, 'J');
    
    end_pos = [str2double(x_str), str2double(y_str)  start_pos(3) ]; %str转doubule,存储终点坐标
    center_offset = [str2double(i_str), str2double(j_str) , 0];%计算圆心的偏移量
    center_pos = start_pos + center_offset; %计算圆心位置
    
    % 计算圆弧路径
    start_angle = atan2(start_pos(2) - center_pos(2), start_pos(1) - center_pos(1));  %计算起始位置相对于圆心的位置角度
    end_angle = atan2(end_pos(2) - center_pos(2), end_pos(1) - center_pos(1)); %计算终止位置....
    
    %调整角度范围
    if contains(line, 'G02')
        % 顺时针
        if start_angle < end_angle
            start_angle = start_angle + 2 * pi;
        end
       
    else
        % 逆时针
        if start_angle > end_angle
            end_angle = end_angle+2*pi;
        end
    end
    
    % 计算圆弧长度
    radius = norm(center_offset);
    arc_length = radius * abs(end_angle - start_angle);
    
    % 根据长度确定插补点的数量
    points_per_unit = 2;
    num_points = max(ceil(arc_length * points_per_unit), 2);
    
    theta = linspace(start_angle, end_angle, num_points);%生成从 start_angle 到 end_angle 间的100个等间隔角度值
    r = sqrt(sum(center_offset.^2));
    arc_x = center_pos(1) + r * cos(theta);
    arc_y = center_pos(2) + r * sin(theta);
    arc_z = repmat(start_pos(3), size(arc_x)); % Z 坐标保持不变
    arc_path = [arc_x', arc_y' arc_z'];
end

%圆插补
function [arc_path, end_pos] = parse_circle(line, start_pos)  %返回圆路径与刀具最终位置
    % 提取X, Y, I, J坐标
    x_str = extract_value(line, 'X');
    y_str = extract_value(line, 'Y');
    i_str = extract_value(line, 'I');
    j_str = extract_value(line, 'J');
    
    end_pos = [str2double(x_str), str2double(y_str) start_pos(3)]; %str转doubule,存储终点坐标
    center_offset = [str2double(i_str), str2double(j_str) , 0];%计算圆心的偏移量
    center_pos = start_pos + center_offset; %计算圆心位置
    
    % 计算圆弧路径
    start_angle = atan2(start_pos(2) - center_pos(2), start_pos(1) - center_pos(1));  %计算起始位置相对于圆心的位置角度
    end_angle = start_angle + 2*pi; %计算终止位置....
    
    % 计算圆的周长
    radius = norm(center_offset);
    circle_length = 2 * pi * radius;
    
    %根据长度确定插补点的数量
    points_per_unit = 2;
    num_points = max(ceil(circle_length * points_per_unit), 2);
    
    %调整角度范围
    theta = linspace(start_angle, end_angle, num_points);%生成从 start_angle 到 end_angle 间的100个等间隔角度值
    r = sqrt(sum(center_offset.^2));
    arc_x = center_pos(1) + r * cos(theta);
    arc_y = center_pos(2) + r * sin(theta);
    arc_z = repmat(start_pos(3), size(arc_x)); % Z 坐标保持不变
    arc_path = [arc_x', arc_y' arc_z'];
end

%直线插补
function interpolated = interpolate_line(start_pos, end_pos)
   deep = evalin('base', 'deep');
  if end_pos(1,3)==deep +2
    line_length = norm(end_pos - start_pos); %计算直线长度
    points_per_unit = 0.5;  %单位距离插补点的数量
    num_points = max(ceil(line_length * points_per_unit), 2);
    t = linspace(0, 1, num_points)';
    interpolated = start_pos + t .* (end_pos - start_pos);
  else
      line_length = norm(end_pos - start_pos); %计算直线长度
    points_per_unit = 2;  %单位距离插补点的数量
    num_points = max(ceil(line_length * points_per_unit), 2);
    t = linspace(0, 1, num_points)';
    interpolated = start_pos + t .* (end_pos - start_pos);
  end
end

function interpolated = interpolate_line_z(start_pos, end_pos)
     line_length = norm(end_pos - start_pos); %计算直线长度
    points_per_unit = 0.5;  %单位距离插补点的数量
    num_points = max(ceil(line_length * points_per_unit), 2);
    % 插入100个点
    t = linspace(0, 1, num_points)';
    interpolated = start_pos + t .* (end_pos - start_pos);
end