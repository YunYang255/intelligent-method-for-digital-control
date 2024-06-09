dxfFile = 'C:\Users\tplink\Desktop\cutterOffset\matlab-tool\text2.dxf'; % 替换为实际的 DXF 文件路径
dxfData = DXFtool(dxfFile); % 使用 dxf_read 函数读取 DXF 文件

entities = dxfData.entities;
for i = 1:length(entities)
    entity1 = entities(1);%将读取到的实体数据存入entity中
    entity2 = entities(2);
    line = [0,0,0,0];
    arc = [0,0,0,0,0];
    cross_point = [0,0,0,0];
    %获取两直线的交点
    line = [entity1.line(1),entity1.line(2),cross_point(1),cross_point(2)];
    if strcmp(entity1.name,"LINE") && strcmp(entity2.name,"LINE")
        cross_point = line_lineCrossPointget(entity1.line,entity2.line);
    elseif strcmp(entity1.name,"LINE") && strcmp(entity2.name,"ARC")
        cross_point = line_arcCrossPointget(entity1.line,entity2.arc);
    elseif strcmp(entity1.name,"ARC") && strcmp(entity2.name,"ARC")
        cross_point = arc_arcCrossPointget(entity1.arc,entity2.arc);
    elseif strcmp(entity1.name,"ARC") && strcmp(entity2.name,"LINE")
        cross_point = line_arcCrossPointget(entity2.line,entity1.arc);
    end
    disp(cross_point);
        
end