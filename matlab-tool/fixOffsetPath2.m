function fixOffsetPath2(entities)

status = 1;
m = 1;
tool_num = evalin('base', 'tool_num')-1;
if tool_num ==1
    radius = 0.1;
elseif tool_num == 2
    radius = 0.3;

elseif tool_num == 3
    radius = 0.5;
    
elseif tool_num == 4
    radius = 0.7;
    
elseif tool_num == 5
    radius = 1;
    
end

VectorAnlge = zeros(1,length(entities)-1);
for i = 1:length(entities)-1
entity1 = entities(i);
entity2 = entities(i+1);
VectorAnlge(i) = getVectorAnlge(entity1,entity2,status,radius);
end

figure%('Visible', 'off');  % 创建一个不可见的图形对象
hold on

    for i = 1:length(entities)
            e= entities(i);
            line([e.line(1), e.line(3)], [e.line(2), e.line(4)], 'Color', 'k', 'LineWidth', 2);  %绘制原图直线
    end
    hold on
    VectorAnlge = zeros(length(entities)-1,1);
    for n = 1:length(entities)-1
        entity1 = entities(n);
        entity2 = entities(n+1);
        VectorAnlge(n) = getVectorAnlge(entity1,entity2,status,0.1);
    end
    
  for i = 1: length(entities)-1
    %计算矢量夹角
    e_pre = entities(i); %第一条直线
    e = entities(i+1); %第二条直线
    if VectorAnlge(i) <= 90
        if m ==1
            offset_line_previous= line_offset(e_pre.line,status,radius);
            offset_line = line_offset(e.line,status,radius);
            radius = 0.1;
            k1 = (offset_line_previous(2)-offset_line_previous(4))/(offset_line_previous(1)-offset_line_previous(3));
            b1 = offset_line_previous(2) - offset_line_previous(1)*k1;
            k2 = (offset_line(2) - offset_line(4))/(offset_line(1)-offset_line(3));
            b2 = offset_line(2) - offset_line(1)*k2;
            extendx11 = (radius^2/(k1^2+1))^0.5+offset_line_previous(3);
            extendx12 = -1*(radius^2/(k1^2+1))^0.5+offset_line_previous(3);
            if (extendx11 - extendx12)/(offset_line_previous(3)-offset_line_previous(1)) >= 0
                extend_point1(1) = extendx11;
            else
                extend_point1(1) = extendx12;
            end
            extend_point1(2) = k1*extend_point1(1)+b1;
            extendx21 = (radius^2/(k2^2+1))^0.5 + offset_line(1);
            extendx22 = -1*(radius^2/(k2^2+1))^0.5 + offset_line(1);
            if (extendx21 - extendx22)/(offset_line(1)-offset_line(3)) >= 0
                extend_point2(1) = extendx21;
            else
                extend_point2(1) = extendx22;
            end
            extend_point2(2) = k2*extend_point2(1)+b2;
         
         line([offset_line_previous(1), offset_line_previous(3)], [offset_line_previous(2), offset_line_previous(4)], 'Color', 'b', 'LineWidth', 2);
         line([offset_line(1), offset_line(3)], [offset_line(2), offset_line(4)], 'Color', 'b', 'LineWidth', 2);
          %插入点
         line([offset_line_previous(3), extend_point1(1)], [offset_line_previous(4), extend_point1(2)], 'Color', 'b', 'LineWidth', 2);
         line([offset_line(1), extend_point2(1)], [offset_line(2), extend_point2(2)], 'Color', 'b', 'LineWidth', 2);

         line([extend_point1(1), extend_point2(1)], [extend_point1(2), extend_point2(2)], 'Color', 'r', 'LineWidth', 2);
         axis equal
        else
            offset_line_previous= line_offset(e_pre.line,status,radius);
            offset_line = line_offset(e.line,status,radius);
            radius = 0.1;
            k1 = (offset_line_previous(2)-offset_line_previous(4))/(offset_line_previous(1)-offset_line_previous(3));
            b1 = offset_line_previous(2) - offset_line_previous(1)*k1;
            k2 = (offset_line(2) - offset_line(4))/(offset_line(1)-offset_line(3));
            b2 = offset_line(2) - offset_line(1)*k2;
            extendx11 = (radius^2/(k1^2+1))^0.5+offset_line_previous(3);
            extendx12 = -1*(radius^2/(k1^2+1))^0.5+offset_line_previous(3);
            if (extendx11 - extendx12)/(offset_line_previous(3)-offset_line_previous(1)) >= 0
                extend_point1(1) = extendx11;
            else
                extend_point1(1) = extendx12;
            end
            extend_point1(2) = k1*extend_point1(1)+b1;
            extendx21 = (radius^2/(k2^2+1))^0.5 + offset_line(1);
            extendx22 = -1*(radius^2/(k2^2+1))^0.5 + offset_line(1);
            if (extendx21 - extendx22)/(offset_line(1)-offset_line(3)) >= 0
                extend_point2(1) = extendx21;
            else
                extend_point2(1) = extendx22;
            end
            extend_point2(2) = k2*extend_point2(1)+b2;
            
         line([previous_point(1), extend_point1(1)], [previous_point(2), extend_point1(2)], 'Color', 'b', 'LineWidth', 2); 
         %line([offset_line(1), offset_line(3)], [offset_line(2), offset_line(4)], 'Color', 'b', 'LineWidth', 2);
          %插入点
          
         line([extend_point1(1), extend_point2(1)], [extend_point1(2), extend_point2(2)], 'Color', 'r', 'LineWidth', 2);
   
         line([offset_line(1), extend_point2(1)], [offset_line(2), extend_point2(2)], 'Color', 'b', 'LineWidth', 2);
         previous_point = offset_line(1:2);

         
        end
    else  % 伸长形和缩短形
        if m < 2
         offset_line_previous= line_offset(e_pre.line,status,radius);
         offset_line = line_offset(e.line,status,radius); % 寻找偏移直线
         
         point = line_lineCrossPointget(offset_line_previous,offset_line);%获取直线-直线刀补交点
         
         line([offset_line_previous(1), point(1)], [offset_line_previous(2), point(2)], 'Color', 'b', 'LineWidth', 2);
         line([offset_line(1), point(1)], [offset_line(2), point(2)], 'Color', 'b', 'LineWidth', 2); 
         previous_point = point;
         m = m+1;
        else
         offset_line_previous= line_offset(e_pre.line,status,radius);
         offset_line = line_offset(e.line,status,radius); % 寻找偏移直线
         
         point = line_lineCrossPointget(offset_line_previous,offset_line);%获取直线-直线刀补交点
         
         line([previous_point(1), point(1)], [previous_point(2), point(2)], 'Color', 'b', 'LineWidth', 2);
         line([offset_line(3), point(1)], [offset_line(4), point(2)], 'Color', 'b', 'LineWidth', 2); 
         previous_point = point;
         m = m+1;
        end
    end
    if i == length(entities)-1
         e_pre = entities(1); %第一条直线
         e = entities(i+1); %第二条直线
       offset_line_previous= line_offset(e_pre.line,status,radius);
       offset_line = line_offset(e.line,status,radius); % 寻找偏移直线
       point = line_lineCrossPointget(offset_line_previous,offset_line);%获取直线-直线刀补交点
       line([offset_line(3), point(1)], [offset_line(4), point(2)], 'Color', 'b', 'LineWidth', 2); 
       line([offset_line_previous(3), point(1)], [offset_line_previous(4), point(2)], 'Color', 'b', 'LineWidth', 2); 
       line([offset_line(3), offset_line(1)], [offset_line(4), offset_line(2)], 'Color', 'b', 'LineWidth', 2); 
    end
end

 print(gcf, 'C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\plot_image_daobu.png', '-dpng', '-r300');
 end


