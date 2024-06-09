function offset = cutter_offset(entity,status,radius_)%获取实体的补偿刀补路径，未修复
    if strcmp(entity.name,"LINE")
        offset_line = line_offset(entity,status,radius_);
        offset.line = offset_line;
    elseif strcmp(entity.name,"ARC")
        offset_arc = arcoffset(entity,status,raidus_);
        offset.arc = offset_arc;
    end
end

%offset与entity为同类型结构体