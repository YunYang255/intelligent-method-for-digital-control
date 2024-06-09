function create_tool_path_animation(filename, time)
    % 读取并解析文件，得到路径
    path = parse_gcode_file(filename);

    % 计算总路径长度
    total_length = sum(sqrt(sum(diff(path).^2, 2)));
    
    % 设置总动画时长（秒）
    total_duration = time;
     
    % 计算每段路径的时间间隔
    segment_lengths = sqrt(sum(diff(path).^2, 2));
    segment_times = (segment_lengths / total_length) * total_duration;
    
    % 创建动画
%     fig = figure('Visible', 'off');
%     set(fig, 'Position', [0, 0, 505, 418]); % 设置图形对象的大小
    figure;
    h = animatedline('LineWidth', 2);
    axis([min(path(:,1)) max(path(:,1)) min(path(:,2)) max(path(:,2)) min(path(:,3)) max(path(:,3))]);
    xlabel('X (mm)');
    ylabel('Y (mm)');
    zlabel('Z (mm)');
    title('刀具路径动画');
    grid on;
    
    % 创建视频写入器对象
%     v = VideoWriter('tool_path_animation_3D.mp4', 'MPEG-4');
%     open(v);
    
    % 绘制路径动画并将每一帧写入视频文件
    for k = 1:size(path, 1) - 1
        addpoints(h, path(k, 1), path(k, 2), path(k, 3));
        drawnow;
        pause(segment_times(k)); % 根据路径段的长度调整暂停时间
        
        % 将当前图像帧写入视频文件
%         frame = getframe(fig);
%         writeVideo(v, frame);
    end
    
    % 添加最后一个点
    addpoints(h, path(end, 1), path(end, 2), path(end, 3));
    drawnow;
    
    % 将最后一帧写入视频文件
%     frame = getframe(fig);
%     writeVideo(v, frame);
    
%     % 关闭视频写入器对象
%     close(v);
%     
%     % 关闭图形对象
%     close(fig);
end

function path = parse_gcode_file(filename)
    % 读取并解析文件，得到路径
    fid = fopen(filename, 'r');
    if fid == -1
        error('无法打开文件');
    end

    % 预分配内存
    path = nan(10000, 3); % 假设最多有10000个点，每个点有三个坐标(x, y, z)
    path_idx = 1;
    tolerance = 1e-3;
    current_pos = [0, 0, 0];

    while ~feof(fid)
        line = fgetl(fid);
        num_points = 100; % 插补点的数量
        % 分析G代码行
        if contains(line, 'G00')   %提取G00和G01
            % 直线插补
            end_coords = parse_coords(line);
            interp_points = linear_interpolation(current_pos, end_coords, num_points);
            path = [path; interp_points];
            current_pos = end_coords;
        elseif  contains(line, 'G01') 
            % 直线插补
            end_coords = parse_coords(line);
            interp_points = linear_interpolation(current_pos, end_coords, num_points);
            path = [path; interp_points];
            current_pos = end_coords;
        elseif contains(line, 'G02') || contains(line, 'G03')  %提取G02和G03和非圆
            %判断圆弧还是圆
            x_str = extract_value(line, 'X');
            y_str = extract_value(line, 'Y');  
            z_str = extract_value(line, 'Z');
            new_pos = [str2double(x_str), str2double(y_str), str2double(z_str)]; %str转doubule,存储终点坐标
            %判定终点是不是与上一个刀具位置重合
            if ((new_pos(1,1)-path(end,1))<tolerance ) && ((new_pos(1,2)-path(end,2))<tolerance ) % && ((new_pos(1,3)-path(end,3))<tolerance ) %圆判定
                [arc_path, new_pos] =  parse_circle(line, current_pos);
                path = [path; arc_path];
                current_pos = new_pos;
            else   %圆弧判定
                [arc_path, new_pos]  = parse_arc(line, current_pos);
                path = [path; arc_path];%将arc_path追加到path末尾
                current_pos = new_pos;
            end
        end
    end
    
    fclose(fid);
    
    % 移除预分配的NaN值
    %path = path(~isnan(path(:,1)), :);
end

function coords = parse_coords(line)
    % 提取X, Y, Z坐标
    x_str = extract_value(line, 'X');
    y_str = extract_value(line, 'Y');
    z_str = extract_value(line, 'Z');
    
    % 将字符串转换为double类型
    coords = [str2double(x_str), str2double(y_str), str2double(z_str)];
end

function interp_points = linear_interpolation(start_coords, end_coords, num_points)
    % 生成从起点到终点之间的num_points个等间隔点
    x_interp = linspace(start_coords(1), end_coords(1), num_points);
    y_interp = linspace(start_coords(2), end_coords(2), num_points);
    z_interp = linspace(start_coords(3), end_coords(3), num_points);
    
    % 将插补点组合成坐标数组
    interp_points = [x_interp', y_interp', z_interp'];
end

function value = extract_value(line, prefix)
    idx = strfind(line, prefix);
    if isempty(idx)
        value = '';
    else
        % 找到起始位置和结束位置
        start_idx = idx + 1;
        end_idx = start_idx;
        while end_idx <= length(line) && (isstrprop(line(end_idx), 'digit') || line(end_idx) == '.' || line(end_idx) == '-')
            end_idx = end_idx + 1;
        end
        value = line(start_idx:end_idx-1);
    end
end

function [arc_path, end_pos] = parse_arc(line, start_pos)
    % 提取X, Y, Z, I, J, K坐标
    x_str = extract_value(line, 'X');
    y_str = extract_value(line, 'Y');
    z_str = extract_value(line, 'Z');
    i_str = extract_value(line, 'I');
    j_str = extract_value(line, 'J');
    k_str = extract_value(line, 'K');
    
    end_pos = [str2double(x_str), str2double(y_str), str2double(z_str)];
    center_offset = [str2double(i_str), str2double(j_str), str2double(k_str)];
    center_pos = start_pos + center_offset;
    
    % 计算圆弧路径
    start_angle = atan2(start_pos(2) - center_pos(2), start_pos(1) - center_pos(1));
    end_angle = atan2(end_pos(2) - center_pos(2), end_pos(1) - center_pos(1));
    
    % 调整角度范围
    if contains(line, 'G02')
        % 顺时针
        if start_angle < end_angle
            start_angle = start_angle + 2 * pi;
        end
    else
        % 逆时针
        if start_angle > end_angle
            end_angle = end_angle + 2 * pi;
        end
    end
    
    theta = linspace(start_angle, end_angle, 100);
    r = sqrt(sum(center_offset.^2));
    arc_x = center_pos(1) + r * cos(theta);
    arc_y = center_pos(2) + r * sin(theta);
    arc_z = linspace(start_pos(3), end_pos(3), 100); % 插补Z轴坐标
    arc_path = [arc_x', arc_y', arc_z'];
end

function [arc_path, end_pos] = parse_circle(line, start_pos)
    % 提取X, Y, Z, I, J, K坐标
    x_str = extract_value(line, 'X');
    y_str = extract_value(line, 'Y');
    z_str = extract_value(line, 'Z');
    i_str = extract_value(line, 'I');
    j_str = extract_value(line, 'J');
    k_str = extract_value(line, 'K');
    
    end_pos = [str2double(x_str), str2double(y_str), str2double(z_str)];
    center_offset = [str2double(i_str), str2double(j_str), str2double(k_str)];
    center_pos = start_pos + center_offset;
    
    % 计算圆弧路径
    start_angle = atan2(start_pos(2) - center_pos(2), start_pos(1) - center_pos(1));
    end_angle = start_angle + 2 * pi;
    
    % 调整角度范围
    theta = linspace(start_angle, end_angle, 100);
    r = sqrt(sum(center_offset.^2));
    arc_x = center_pos(1) + r * cos(theta);
    arc_y = center_pos(2) + r * sin(theta);
    arc_z = linspace(start_pos(3), end_pos(3), 100); % 插补Z轴坐标
    arc_path = [arc_x', arc_y', arc_z'];
end
