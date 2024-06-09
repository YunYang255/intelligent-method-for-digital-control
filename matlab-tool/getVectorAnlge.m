function VectorAnlge = getVectorAnlge(entity1,entity2,left_status,radius_)%判断转接形式，并获取对应矢量夹角
    VectorAnlge = -1;
    if (strcmp(entity1.name,"LINE")) && strcmp(entity2.name,"LINE")%直线与直线的转接
        line1 = entity1.line;
        line2 = entity2.line;
        VectorAnlge = countVectorAnlge(line1,line2,left_status,radius_);
    elseif (strcmp(entity1.name,"LINE")) && strcmp(entity2.name,"ARC")%直线与圆弧的转接
        line1 = entity1.line;
        arc1 = entity2.arc;
        line2 = getArcline2(line1,arc1);
        VectorAnlge = countVectorAnlge(line1,line2);
    elseif (strcmp(entity1.name,"ARC")) && strcmp(entity2.name,"ARC")%圆弧与圆弧的转接
        arc1 = entity1.arc;
        arc2 = entity2.arc;
        line1 = getArcLine1(arc1);
        line2 = getArcLine1(arc2);
        VectorAnlge = countVectorAnlge(line1,line2);
    end
end