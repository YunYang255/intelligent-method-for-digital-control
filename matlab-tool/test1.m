

% 读取 DXF 文件
dxfFile = 'C:\Users\tplink\Desktop\cutterOffset\matlab-tool\Drawing2.dxf'; % 替换为实际的 DXF 文件路径
dxfData = DXFtool(dxfFile); % 使用 dxf_read 函数读取 DXF 文件

entities = dxfData.entities;

% 提取线段和圆弧数据
lines = []; % 初始化线段数组
arcs = [];  % 初始化圆弧数组

cutter_offset_line = entities(1);

% for i = 1:length(entities)
%     entity = entities(i); % 获取每个实体
%     if strcmp(entity.name, 'LINE') % 如果实体是线段
%         lines = [lines; entity]; % 将线段添加到 lines 数组中
%     elseif strcmp(entity.name, 'ARC') % 如果实体是圆弧
%         arcs = [arcs; entity]; % 将圆弧添加到 arcs 数组中
%     end
% end


for i = 1:length(entities)
    cross_point = struct();%声明线段交点，为结构体
    entity1 = entities(1);%将读取到的实体数据存入entity中
    entity2 = entities(2);
    line = [];
    arc = [];
    if i == 1 && (strcmp(entity1.name,"LINE") && strcmp(entity2.name,"LINE"))
        cross_point = line_lineCrossPointget(entity1.line,entity2.line);%获取两直线的交点
        line = [entity1.line(1),entity1.line(2),cross_point.x,cross_point.y];
    end
    
end

% 显示线段和圆弧图像
%figure; % 创建一个新的图形窗口
hold on; % 保持图形窗口处于绘制状态
axis equal; % 设置坐标轴比例相同
lineHandles = []; % 存储每个线段的句柄
arcHandles = [];  % 存储每个圆弧的句柄

% 绘制线段
% for i = 1:length(lines)
%     line = lines(i); % 获取当前线段
%     h = plot([line(1), line(3)], [line(2), line(4)], 'k-'); % 绘制线段，使用黑色线条
%     lineHandles = [lineHandles; h]; % 将线段的句柄存储在 lineHandles 数组中
% end

% 绘制圆弧
% for i = 1:length(arcs)
%     arc = arcs(i); % 获取当前圆弧
%     theta = linspace(deg2rad(arc.startAngle), deg2rad(arc.endAngle), 100); % 生成圆弧角度
%     x = arc.radius * cos(theta) + arc.x; % 计算圆弧的 x 坐标
%     y = arc.radius * sin(theta) + arc.y; % 计算圆弧的 y 坐标
%     h = plot(x, y, 'b-'); % 绘制圆弧，使用蓝色线条
%     arcHandles = [arcHandles; h]; % 将圆弧的句柄存储在 arcHandles 数组中
% end

% % 找到离点击位置最近的线段或圆弧
% minDist = inf; % 初始化最小距离为无穷大
% selectedIndex = -1; % 初始化选中的索引
% selectedType = '';  % 初始化选中的类型
% 
% % 检查线段
% for i = 1:length(lines)
%     line = lines(i); % 获取当前线段
%     % 计算点击位置到线段两个端点的距离，选择最小的一个
%     dist = min(sqrt((x - line.x1)^2 + (y - line.y1)^2), sqrt((x - line.x2)^2 + (y - line.y2)^2));
%     if dist < minDist % 如果当前距离小于已知最小距离
%         minDist = dist; % 更新最小距离
%         selectedIndex = i; % 更新选中的索引
%         selectedType = 'line'; % 更新选中的类型
%     end
% end
% 
% % 检查圆弧
% for i = 1:length(arcs)
%     arc = arcs(i); % 获取当前圆弧
%     % 计算点击位置到圆弧圆心的距离减去半径的绝对值
%     dist = abs(sqrt((x - arc.x)^2 + (y - arc.y)^2) - arc.radius);
%     if dist < minDist % 如果当前距离小于已知最小距离
%         minDist = dist; % 更新最小距离
%         selectedIndex = i; % 更新选中的索引
%         selectedType = 'arc'; % 更新选中的类型
%     end
% end
% 
% % 选择最近的线段或圆弧并进行操作
% if strcmp(selectedType, 'line')
%     selectedLine = lines(selectedIndex); % 获取选中的线段
%     disp(['Selected Line: Start(', num2str(selectedLine.x1), ', ', num2str(selectedLine.y1), ...
%           ') End(', num2str(selectedLine.x2), ', ', num2str(selectedLine.y2), ')']); % 打印选中线段的起点和终点坐标
%     
%     % 对选择的线段进行操作，例如，移动线段
%     dx = 10; % 移动 x 方向的距离
%     dy = 5;  % 移动 y 方向的距离
%     selectedLine.x1 = selectedLine.x1 + dx; % 更新线段起点的 x 坐标
%     selectedLine.y1 = selectedLine.y1 + dy; % 更新线段起点的 y 坐标
%     selectedLine.x2 = selectedLine.x2 + dx; % 更新线段终点的 x 坐标
%     selectedLine.y2 = selectedLine.y2 + dy; % 更新线段终点的 y 坐标
% 
%     % 更新图像
%     delete(lineHandles(selectedIndex)); % 删除原来的线段
%     plot([selectedLine.x1, selectedLine.x2], [selectedLine.y1, selectedLine.y2], 'r-'); % 用红色线段绘制新的线段
%     
% elseif strcmp(selectedType, 'arc')
%     selectedArc = arcs(selectedIndex); % 获取选中的圆弧
%     disp(['Selected Arc: Center(', num2str(selectedArc.x), ', ', num2str(selectedArc.y), ...
%           ') Radius(', num2str(selectedArc.radius), ') StartAngle(', num2str(selectedArc.startAngle), ...
%           ') EndAngle(', num2str(selectedArc.endAngle), ')']); % 打印选中圆弧的相关信息
%     
%     % 对选择的圆弧进行操作，例如，移动圆弧
%     dx = 10; % 移动 x 方向的距离
%     dy = 5;  % 移动 y 方向的距离
%     selectedArc.x = selectedArc.x + dx; % 更新圆弧圆心的 x 坐标
%     selectedArc.y = selectedArc.y + dy; % 更新圆弧圆心的 y 坐标
%     
%     % 更新图像
%     delete(arcHandles(selectedIndex)); % 删除原来的圆弧
%     theta = linspace(deg2rad(selectedArc.startAngle), deg2rad(selectedArc.endAngle), 100); % 生成新的圆弧角度
%     x = selectedArc.radius * cos(theta) + selectedArc.x; % 计算新的圆弧的 x 坐标
%     y = selectedArc.radius * sin(theta) + selectedArc.y; % 计算新的圆弧的 y 坐标
%     plot(x, y, 'r-'); % 用红色线条绘制新的圆弧
% end

hold off; % 关闭保持绘图状态