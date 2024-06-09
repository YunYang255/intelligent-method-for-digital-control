%% G代码的生成
function generateGCode(entities, inputFile)
    % generateGCode 根据几何特征点生成数控加工的G代码和M代码
    % entities - 存储几何特征点的结构数组
    % outputFile - 输出的G代码文件路径

    % 打开文件以写入G代码
    fid = fopen(inputFile, 'wt');
    if fid == -1
        error('Cannot open file: %s', inputFile);
    end
    
    % 写入文件头部
    fprintf(fid, '%% G代码生成\n');
    fprintf(fid, 'G21 ; 设置单位为毫米\n');
    fprintf(fid, 'G90 ; 绝对坐标编程\n');
    fprintf(fid, 'G17 ; 选择X-Y平面\n');
    
    duidaox = evalin('base', 'duidaox');
    duidaoy = evalin('base', 'duidaoy');
    duidaoz = evalin('base', 'duidaoz');

    fprintf(fid, 'G00 X%.3f Y%.3f Z%.3f;快速对刀到对刀点\n',duidaox,duidaoy, duidaoz); %计算直线起点坐标
    
    Start = entities(1);
    speed = evalin('base', 'speed');
    fast = evalin('base', 'fast');
    deep = evalin('base', 'deep');
    
    if strcmp (Start.name, 'LINE')
       fprintf(fid, 'G00 X%.3f Y%.3f Z%.3f;快速对刀\n',Start.line(1,1),Start.line(1,2) , -deep); %计算直线起点坐标
    x_d=Start.line(1,1);
    y_d=Start.line(1,2);
    elseif strcmp (Start.name, 'ARC')
        [x,y]=coordinate_calculation(Start.arc(1,4), Start.arc(1,1), Start.arc(1,2), Start.arc(1,3));  %计算圆弧起点坐标
       fprintf(fid, 'G00 X%.3f Y%.3f Z%.3f;\n',x,y,-deep);
    x_d=x;
    y_d=y;
    elseif strcmp (Start.name, 'CIRCLE')
        x=Start.circle(1,1)+Start.circle(1,3);
        y=Start.circle(1,2);
       fprintf(fid, 'G00 X%.3f Y%.3f Z%.3f;\n',x,y,-deep);
    x_d=x;
    y_d=y;
    end
    
    % 遍历所有实体生成相应的G代码
  for i = 1:length(entities)
    e = entities(i);
      if (i==1)
          [x_d , y_d] = processEntity_with_S_and_F(e, x_d, y_d , speed , fast,deep,fid);
      
      else 
          [x_d, y_d] = processEntity(e, x_d, y_d,deep, fid);
      end
  end

    % 写入文件尾部
    fprintf(fid, 'G40 ; 取消刀补\n');
    fprintf(fid, 'M30 ; 程序结束\n');

    % 关闭文件
    fclose(fid);

    fprintf('G代码已生成并保存到文件: %s\n', inputFile);
end

function [x_d, y_d] = processEntity(e, x_d, y_d,deep, fid)
    if strcmp(e.name, 'LINE')
        % 判断轮廓是否断开     
        round_x_d = round(x_d * 10000) / 10000; 
        round_x = round(e.line(1, 1) * 10000) / 10000;            
        round_y_d = round(y_d * 10000) / 10000; 
        round_y = round(e.line(1, 2) * 10000) / 10000; 

        if (round_x_d ~= round_x || round_y_d ~= round_y) % 判断断开
            fprintf(fid, ' Z%.3f; 抬刀防止撞刀\n', deep+2);
            fprintf(fid, 'G01 X%.3f Y%.3f ; 直线插补\n', e.line(1, 1), e.line(1, 2)); % 直线插补去到直线起点坐标
            fprintf(fid, ' Z%.3f; 下刀\n', -deep);
        end
        fprintf(fid, 'G01 X%.3f Y%.3f ; 直线插补\n', e.line(1, 3), e.line(1, 4));
        x_d = e.line(1, 3);
        y_d = e.line(1, 4);


        % 判断圆是否和上一个轮廓脱离
    elseif strcmp(e.name,'CIRCLE')
        distance = ((e.circle(1, 1) - x_d)^2 + (e.circle(1, 2) - y_d)^2);
        if distance > e.circle(1, 3)^2  % 圆与上一个轮廓脱离
            fprintf(fid, ' Z%.3f; 抬刀防止撞刀\n', deep+2);
            fprintf(fid, 'G01 X%.3f Y%.3f ; 直线插补\n', e.circle(1, 1) + e.circle(1, 3), e.circle(1, 2)); % 直线插补走到圆上
            fprintf(fid, ' Z%.3f; 下刀\n', -deep);
            fprintf(fid, 'G02 X%.3f Y%.3f I%.3f J%.3f; 圆\n', e.circle(1, 1) + e.circle(1, 3), e.circle(1, 2), e.circle(1, 1) - e.circle(1, 1) - e.circle(1, 3), e.circle(1, 2) - e.circle(1, 2)); % 画整圆
            x_d = e.circle(1, 1) + e.circle(1, 3);
            y_d = e.circle(1, 2);
        else
            fprintf(fid, 'G02 X%.3f Y%.3f I%.3f J%.3f; 圆\n', x_d, y_d, e.circle(1, 1) - x_d, e.circle(1, 2) - y_d); % 画整圆
        end

    elseif strcmp(e.name, 'ARC')
        % 圆弧加工
        arc_start = e.arc(1, 4);
        arc_end = e.arc(1, 5);

        [x, y] = coordinate_calculation(arc_end, e.arc(1, 1), e.arc(1, 2), e.arc(1, 3)); % 计算圆弧终点坐标  
        % 保留前四位小数
        round_x_d = round(x_d * 10000) / 10000; 
        round_x = round(x * 10000) / 10000;            
        round_y_d = round(y_d * 10000) / 10000; 
        round_y = round(y * 10000) / 10000; 

        if (round_x == round_x_d && round_y_d == round_y) % 判断圆弧终点坐标与上一个轮廓的终点是否重合
            % 重合的情况为顺时针
            [a, b] = coordinate_calculation(arc_end, e.arc(1, 1), e.arc(1, 2), e.arc(1, 3)); % 顺时针圆弧起点
            I = e.arc(1, 1) - a;
            J = e.arc(1, 2) - b;
            [x, y] = coordinate_calculation(arc_start, e.arc(1, 1), e.arc(1, 2), e.arc(1, 3)); % 顺时针圆弧终点
            fprintf(fid, 'G02 X%.3f Y%.3f I%.3f J%.3f ; 圆弧插补\n', x, y, I, J);    
        else 
            % 终点不重合的情况
            [a, b] = coordinate_calculation(arc_start, e.arc(1, 1), e.arc(1, 2), e.arc(1, 3)); % 计算圆弧起点坐标
            % 保留前四位小数
            round_a = round(a * 10000) / 10000;            
            round_b = round(b * 10000) / 10000; 
            if (round_a == round_x_d && round_b == round_y_d)    % 判断起点是否重合
                % 起点重合的情况
                [x, y] = coordinate_calculation(arc_end, e.arc(1, 1), e.arc(1, 2), e.arc(1, 3)); % 计算圆弧终点坐标
                I = e.arc(1, 1) - a;
                J = e.arc(1, 2) - b;
                fprintf(fid, 'G03 X%.3f Y%.3f I%.3f J%.3f ; 圆弧插补\n', x, y, I, J);
            else
                % 起点不重合的情况
                fprintf(fid, ' Z%.3f; 抬刀防止撞刀\n', deep+2);
                fprintf(fid, 'G00 X%.3f Y%.3f ; 直线插补\n', a, b); % 直线插补走到圆弧上
                fprintf(fid, ' Z%.3f; 下刀\n', -deep);
                I = e.arc(1, 1) - a;
                J = e.arc(1, 2) - b;
                fprintf(fid, 'G03 X%.3f Y%.3f I%.3f J%.3f ; 圆弧插补\n', x, y, I, J); 
            end
        end
        x_d = x;
        y_d = y;
    end
end

function [x_d, y_d] = processEntity_with_S_and_F(e, x_d, y_d, s , f, deep,fid)
    conpensation_way = evalin('base', 'conpensation_way');
    tool_num = evalin('base', 'tool_num')-1;

    if conpensation_way == 2
        conpensation = 41;
    else 
        conpensation = 42;
    end
    
    if strcmp(e.name, 'LINE')
        % 判断轮廓是否断开     
        round_x_d = round(x_d * 10000) / 10000; 
        round_x = round(e.line(1, 1) * 10000) / 10000;            
        round_y_d = round(y_d * 10000) / 10000; 
        round_y = round(e.line(1, 2) * 10000) / 10000; 

        if (round_x_d ~= round_x || round_y_d ~= round_y) % 判断断开
            fprintf(fid, ' Z%.3f; 抬刀防止撞刀\n', deep+2);
            fprintf(fid, 'G00 X%.3f Y%.3f; 快速走刀定位\n', e.line(1, 1), e.line(1, 2)); % 快速走刀定位
            fprintf(fid, ' Z%.3f; 下刀\n', -deep);
        end
        fprintf(fid, 'G01 X%.3f Y%.3f F%.3f S%.3f M02 G%.0f T0%.0f; 直线插补\n', e.line(1, 3), e.line(1, 4),f,s ,conpensation ,tool_num );
        x_d = e.line(1, 3);
        y_d = e.line(1, 4);

    elseif strcmp(e.name, 'CIRCLE')
        % 判断圆是否和上一个轮廓脱离
        distance = ((e.circle(1, 1) - x_d)^2 + (e.circle(1, 2) - y_d)^2);
        if distance > e.circle(1, 3)^2  % 圆与上一个轮廓脱离
             fprintf(fid, ' Z%.3f; 抬刀防止撞刀\n', deep+2);
            fprintf(fid, 'G00 X%.3f Y%.3f ; 快速走刀定位\n', e.circle(1, 1) + e.circle(1, 3), e.circle(1, 2)); % 快速走刀定位
            fprintf(fid, ' Z%.3f; 下刀\n', -deep);
            fprintf(fid, 'G02 X%.3f Y%.3f I%.3f J%.3f F%.3f S%.3f M02 G%.0f T0%.0f ; 圆\n', e.circle(1, 1) + e.circle(1, 3), e.circle(1, 2), e.circle(1, 1) - e.circle(1, 1) - e.circle(1, 3), e.circle(1, 2) - e.circle(1, 2),f,s ,conpensation ,tool_num); % 画整圆
            x_d = e.circle(1, 1) + e.circle(1, 3);
            y_d = e.circle(1, 2);
        else
            fprintf(fid, 'G02 X%.3f Y%.3f I%.3f J%.3f F%.3f S%.3f M02 G%.0f T0%.0f; 圆\n', x_d, y_d, e.circle(1, 1) - x_d, e.circle(1, 2) - y_d,f,s,conpensation ,tool_num); % 画整圆
        end

    elseif strcmp(e.name, 'ARC')
        % 圆弧加工
        arc_start = e.arc(1, 4);
        arc_end = e.arc(1, 5);

        [x, y] = coordinate_calculation(arc_end, e.arc(1, 1), e.arc(1, 2), e.arc(1, 3)); % 计算圆弧终点坐标  
        % 保留前四位小数
        round_x_d = round(x_d * 10000) / 10000; 
        round_x = round(x * 10000) / 10000;            
        round_y_d = round(y_d * 10000) / 10000; 
        round_y = round(y * 10000) / 10000; 

        if (round_x == round_x_d && round_y_d == round_y) % 判断圆弧终点坐标与上一个轮廓的终点是否重合
            % 重合的情况为顺时针
            [a, b] = coordinate_calculation(arc_end, e.arc(1, 1), e.arc(1, 2), e.arc(1, 3)); % 顺时针圆弧起点
            I = e.arc(1, 1) - a;
            J = e.arc(1, 2) - b;
            [x, y] = coordinate_calculation(arc_start, e.arc(1, 1), e.arc(1, 2), e.arc(1, 3)); % 顺时针圆弧终点
            fprintf(fid, 'G02 X%.3f Y%.3f I%.3f J%.3f F%.3f S%.3f M02 G%.0f T0%.0f; 圆弧插补\n', x, y, I, J,f,s,conpensation ,tool_num);    
        else 
            % 终点不重合的情况
            [a, b] = coordinate_calculation(arc_start, e.arc(1, 1), e.arc(1, 2), e.arc(1, 3)); % 计算圆弧起点坐标
            % 保留前四位小数
            round_a = round(a * 10000) / 10000;            
            round_b = round(b * 10000) / 10000; 
            if (round_a == round_x_d && round_b == round_y_d)    % 判断起点是否重合
                % 起点重合的情况
                [x, y] = coordinate_calculation(arc_end, e.arc(1, 1), e.arc(1, 2), e.arc(1, 3)); % 计算圆弧终点坐标
                I = e.arc(1, 1) - a;
                J = e.arc(1, 2) - b;
                fprintf(fid, 'G03 X%.3f Y%.3f I%.3f J%.3f F%.3f S%.3f M02G%.0f T0%.0f; 圆弧插补\n', x, y, I, J,f,s,conpensation ,tool_num);
            else
                % 起点不重合的情况
                fprintf(fid, ' Z%.3f; 抬刀防止撞刀\n', deep+2);
                fprintf(fid, 'G00 X%.3f Y%.3f ; 快速走刀定位\n', a, b); % 快速走刀定位
                fprintf(fid, ' Z%.3f; 下刀\n', -deep);
                I = e.arc(1, 1) - a;
                J = e.arc(1, 2) - b;
                fprintf(fid, 'G03 X%.3f Y%.3f I%.3f J%.3f F%.3f S%.3f M02 G%.0f T0%.0f; 圆弧插补\n', x, y, I, J,f,s,conpensation ,tool_num); 
            end
        end
        x_d = x;
        y_d = y;
    end
end
