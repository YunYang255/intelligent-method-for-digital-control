function plot_tool_path(filename)
    % 打开并读取文件
    fid = fopen(filename, 'r');
    if fid == -1
        error('无法打开文件');
    end
    tolerance = 1e-3;
    % 初始化刀具位置和路径数组
    current_pos = [0, 0];
    path = [0,0];

    % 读取文件内容
    while ~feof(fid)  %循环读取文件的每一行
        line = fgetl(fid);  %将每一行存储在line中
        
        % 分析G代码行
        if contains(line, 'G00')   %提取G00和G01
            % 直线插补
            coords = parse_coords(line);
            path = [path; coords];
            current_pos = coords;
        elseif  contains(line, 'G01') 
            % 直线插补
            coords = parse_coords(line);
            path = [path; coords];
            current_pos = coords;
        elseif contains(line, 'G02') || contains(line, 'G03')  %提取G02和G03和非圆
            %判断圆弧还是圆
               x_str = extract_value(line, 'X');
               y_str = extract_value(line, 'Y');  
               new_pos = [str2double(x_str), str2double(y_str)]; %str转doubule,存储终点坐标
            %判定终点是不是与上一个刀具位置重合
            contidition = abs((new_pos(1,1)-path(end,1)))<tolerance;
            contidition2 = abs((new_pos(1,2)-path(end,2)))<tolerance;
            if contidition && contidition2 %圆判定
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
    
    % 绘制路径
figure%('Visible', 'off');  % 创建一个不可见的图形对象

% 绘制图像
plot(path(:,1), path(:,2), '-o');
xlabel('X (mm)');
ylabel('Y (mm)');
title('刀具路径');
grid on;

% 保存图像为 PNG 文件
print(gcf, 'C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\plot_image.png', '-dpng', '-r300');

hold off
% 关闭图形对象
%close(gcf);

end

function coords = parse_coords(line)      % 提取X和Y坐标
    x_str = extract_value(line, 'X');
    y_str = extract_value(line, 'Y'); 
    coords = [str2double(x_str), str2double(y_str)];
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

function [arc_path, end_pos] = parse_arc(line, start_pos)  %返回圆弧路径与刀具最终位置
    % 提取X, Y, I, J坐标
    x_str = extract_value(line, 'X');
    y_str = extract_value(line, 'Y');
    i_str = extract_value(line, 'I');
    j_str = extract_value(line, 'J');
    
    end_pos = [str2double(x_str), str2double(y_str)]; %str转doubule,存储终点坐标
    center_offset = [str2double(i_str), str2double(j_str)];%计算圆心的偏移量
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
    
    theta = linspace(start_angle, end_angle, 100);%生成从 start_angle 到 end_angle 间的100个等间隔角度值
    r = sqrt(sum(center_offset.^2));
    arc_x = center_pos(1) + r * cos(theta);
    arc_y = center_pos(2) + r * sin(theta);
    arc_path = [arc_x', arc_y'];
end

function [arc_path, end_pos] = parse_circle(line, start_pos)  %返回圆弧路径与刀具最终位置
    % 提取X, Y, I, J坐标
    x_str = extract_value(line, 'X');
    y_str = extract_value(line, 'Y');
    i_str = extract_value(line, 'I');
    j_str = extract_value(line, 'J');
    
    end_pos = [str2double(x_str), str2double(y_str)]; %str转doubule,存储终点坐标
    center_offset = [str2double(i_str), str2double(j_str)];%计算圆心的偏移量
    center_pos = start_pos + center_offset; %计算圆心位置
    
    % 计算圆弧路径
    start_angle = atan2(start_pos(2) - center_pos(2), start_pos(1) - center_pos(1));  %计算起始位置相对于圆心的位置角度
    end_angle = start_angle + 2*pi; %计算终止位置....
    
    %调整角度范围
    theta = linspace(start_angle, end_angle, 100);%生成从 start_angle 到 end_angle 间的100个等间隔角度值
    r = sqrt(sum(center_offset.^2));
    arc_x = center_pos(1) + r * cos(theta);
    arc_y = center_pos(2) + r * sin(theta);
    arc_path = [arc_x', arc_y'];
end