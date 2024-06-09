classdef DXFtool < handle
% DXFtool v1.0 for reading and plotting DXF files in Matlab figures.
% by M.M. Pedersen, Aarhus University, March 2018.
% 
% USAGE:    dxf = DXFtool('filename.dxf');
%           plots dxf file in current axes/figure 
%           (or creates a new figure/axes if none exist)
%
% INPUT:    filename of dxf file as a string (may also include path)
%
% OUTPUT:   [optional] dxf object. Each entity is stored in a struct
%           in dxf.entites(i), where i is the entity number,
%           containing the following fields:
%           .name:      entity type name (string), code 0
%           .layer:     Layer name (string), code 8
%           .linetype:  Line dashing type (string), code 6
%           .color:     Line color (int), code 62
%           .closed:    polygon status: open/closed, code 70
%           .point:     Xp, Yp
%           .poly:      vertices X,Y array [n_verts,2]
%           .arc:       Xc, Yc, R, begin angle, end angle
%           .circle:    Xc, Yc, R
%           .ellipse:   Xc, Yc, Xe, Ye, ratio, begin angle, end angle
%           .line:      X1, Y1, X2, Y2
%           .hatch:     color data for closed polygons
%           .handle:    Matlab graphics handle to plotted entity
%
% FEATURES:
% - supports: LINE, POINT, ARC, CIRCLE, ELLIPSE, LWPOLYLINE
% - colored entities (line and hatch color)
% - respects ordering of objects (back to front)
% - supports bulges, open/closed polygons
% - line dashing
%
% TODO:
% - more entities: DIMENSION, 3D...
% - propor handling of splines (currently piecewise linear)
% - line weight
    properties
        filename;       % path/filename of DXF file
        entities;       % struct array of entities
        ne;             % number of entities
        divisions = 50; % points along nonlinear entities (circles, arcs, bulges, ellipses)
    end
    
    methods
        function dxf = DXFtool(filename)
        % construct dxf object
        
            dxf.filename = filename;
            dxf.entities = read_dxf(filename);
            dxf.ne       = length(dxf.entities);
            plot(dxf);
            
        end
        
        function plot(dxf)

            % getting plot started
            hold on
            axis equal
            %axis off
            
            % plot all entities
            for i = 1:dxf.ne
                
                % get colors
                line_col = color_code(dxf.entities(i).color);
                
                if (i<dxf.ne) && strcmp(dxf.entities(i+1).name,'HATCH')
                    hatch_col = color_code(dxf.entities(i+1).color);
                else
                    hatch_col = 'none';
                end
                
                switch dxf.entities(i).name
                    case 'POINT'
                        dxf.entities(i).handle = plot_point(dxf.entities(i).point,line_col);
                    case 'LINE'
                        dxf.entities(i).handle = plot_line(dxf.entities(i).line,line_col);
                    case 'LWPOLYLINE'
                        dxf.entities(i).handle = plot_poly(dxf.entities(i).poly,line_col,hatch_col,dxf.entities(i).closed);
                    case 'CIRCLE'
                        dxf.entities(i).handle = plot_circle(dxf.entities(i).circle,dxf.divisions,line_col);
                    case 'ARC'
                        dxf.entities(i).handle = plot_arc(dxf.entities(i).arc,dxf.divisions,line_col);
                    case 'ELLIPSE'
                        dxf.entities(i).handle = plot_ellipse(dxf.entities(i).ellipse,dxf.divisions,line_col,hatch_col,dxf.entities(i).closed);
                    case 'SPLINE'
                        dxf.entities(i).handle = plot_spline(dxf.entities(i).spline,line_col);
                end
                
                % change line type
                switch upper(dxf.entities(i).linetype)
                    case {'DASHED','DASHEDX2'}
                        LineStyle = '--';
                    case {'DASHDOT','CENTERX2'}
                        LineStyle = '-.';
                    case 'HIDDEN2'
                        LineStyle = ':';
                    otherwise % e.g. CONTINUOUS
                        LineStyle = '-';
                end
                dxf.entities(i).handle.LineStyle = LineStyle;

            end

        end
       
        function list(dxf)

            fprintf('NO. %-10s %5s %5s %8s\n','ENTITY','LAYER','COLOR','LINETYPE')
            
            % plot all entities
            for i = 1:dxf.ne
                
                
                name    = dxf.entities(i).name;
                layer   = dxf.entities(i).layer;
                color   = dxf.entities(i).color;
                ltype   = dxf.entities(i).linetype;
                
                fprintf('%3d %-10s %4s %5d  %-10s\n',i,name,layer,color,ltype)
                
            end

        end
               
    end
    
end



function h = plot_poly(poly,col,col2,isclosed)
% plot polygons incl. bulges by vertices (X,Y)

    if isclosed==1
        h = patch('faces',1:length(poly),'vertices',poly,'edgecolor',col,'facecolor',col2);
    else % plot open polygon
        h = plot(poly(:,1),poly(:,2),'color',col);
    end

end

function h = plot_circle(circle,div,col)
% plot circles: (X Center,Y Center,Radius)
    
    x = circle(1);
    y = circle(2);
    r = circle(3);

    theta = linspace(0,2*pi,div);
    X = x + r*cos(theta);
    Y = y + r*sin(theta);

    h = plot(X,Y,'-','color',col);

end

function h = plot_arc(arc,div,col)
% plot arcs: (X Center,Y Center,Radius,Start angle,End angle)
        
    x = arc(1);
    y = arc(2);
    r = arc(3);
    a1 = arc(4);
    a2 = arc(5);

    if a2<a1
        a2 = a2 + 360;
    end

    theta = deg2rad(linspace(a1,a2,div));
    X = x + r*cos(theta);
    Y = y + r*sin(theta);

    h = plot(X,Y,'-','color',col);

end

function h = plot_ellipse(ellipse,div,line_col,hatch_col,isclosed)
% plot ellipses: (% X center ,Y center, X end, Y end, ratio, start, end)
% https://www.autodesk.com/techpubs/autocad/acad2000/dxf/ellipse_command39s_parameter_option_dxf_06.htm

    Cx = ellipse(1);  % center
    Cy = ellipse(2);
    Ex = -ellipse(3); % X value of endpoint of major axis, relative to the center
    Ey = -ellipse(4); % Y value of endpoint of major axis, relative to the center
    R  = ellipse(5);  % Ratio of minor axis to major axis

    u1 = ellipse(6);  % Start parameter of u (this value is 0.0 for a full ellipse)
    u2 = ellipse(7);  % End parameter of u (this value is 2pi for a full ellipse)

    E = [Ex Ey]';
    a = -norm(E);
    b = R*a;

    % rotation of the ellipse
    theta = atan2(Ey,Ex);
    rad2deg(theta)
    R = rotation(theta);

    % sweep
    u = linspace(u2,u1,div);
    for j = 1:div

        P(1) = a*cos(u(j));
        P(2) = b*sin(u(j));

        Pr = R*P';

        X(j) = Cx + Pr(1);
        Y(j) = Cy + Pr(2);

    end

    
    if isclosed
        h = patch('faces',1:length(X),'vertices',[X' Y'],'edgecolor',line_col,'facecolor',hatch_col);
    else
        h = plot(X,Y,'-','color',line_col);
    end
    
end

function h = plot_point(point,col)
% plot points

    X = point(1);
    Y = point(2);
    h = plot(X,Y,'k','markerfacecolor',col);

end

function h = plot_line(line,col)
% plot lines: (Xi,Yi,Xj,Yj) start and end points 
    
    Xi = line(1);
    Yi = line(2);
    Xj = line(3);
    Yj = line(4);

    h = plot([Xi Xj],[Yi Yj],'color',col);
    
end

function h = plot_spline(sp,col)
% plot splines as piecewise linear poly line (very crude) 

    poly = [sp.X sp.Y];
    h = plot_poly(poly,col,'',0);
    
end

function entities = read_dxf(filename)
% based on Read DXF File data by Sebastian, 
% https://se.mathworks.com/matlabcentral/fileexchange/24572-read-dxf-file-data
%
% POLYLINES:
%   8:  Layer no.
%  10:  X value; APP: 2D point Vertex coordinates (in OCS), multiple entries; one entry for each vertex
%  20:  Y value of vertex coordinates (in OCS), multiple entries; one entry for each vertex
%  70:  Polyline flag (bit-coded); default is 0, 1 = Closed, 128 = Plinegen
%  42:  Bulge (optional; default is 0). 
%       The bulge is the tangent of one fourth the included angle for an arc segment, 
%       made negative if the arc goes clockwise from the start point to the endpoint. 
%       A bulge of 0 indicates a straight segment, and a bulge of 1 is a semicircle.
%       See http://www.afralisp.net/archive/lisp/Bulges1.htm
%       and John Hughes, https://math.stackexchange.com/questions/482751/how-do-i-move-through-an-arc-between-two-specific-points
%
% ELLIPSE:
% 100:  Subclass marker (AcDbEllipse)
%  10:  Center point (in WCS) DXF: X value; APP: 3D point
%  20:  DXF: Y and Z values of center point (in WCS)
%  11:  Endpoint of major axis, relative to the center (in WCS) DXF: X value; APP: 3D point
%  21:  DXF: Y and Z values of endpoint of major axis, relative to the center (in WCS)
%  40:  Ratio of minor axis to major axis
%  41:  Start parameter (this value is 0.0 for a full ellipse)
%  42:  End parameter (this value is 2pi for a full ellipse)


    % Read file
    fid = fopen(filename);    
    AllValues = textscan(fid,'%d%s','Delimiter','\n');
    fclose(fid);
    
    AllCodes  = AllValues{1}; % Code group numbers
    AllValues = AllValues{2}; % Values
    
    % Extract entities
    EntPos = find(AllCodes==0);
    
    % Entities Position
    nEntities   = find(strcmp('ENTITIES',AllValues(EntPos(1:end-1)+1)));
    mEntities   = find(strcmp('ENDSEC'  ,AllValues(EntPos(nEntities:end))));
    EntPos      = EntPos(nEntities:nEntities-1+mEntities(1));
 
    
    % get relevant data for each entity
    for i = 1:length(EntPos)-2
        
        % current entity codes/values
        eCodes     = AllCodes(EntPos(i+1):EntPos(i+2)-1);
        eStrings   = AllValues(EntPos(i+1):EntPos(i+2)-1);
        eValues    = str2double(eStrings);
        
        entities(i).name        = AllValues{EntPos(i+1)};
        entities(i).layer       = eStrings{eCodes==8};
        try
            entities(i).linetype    = eStrings{eCodes==6};
        catch
            entities(i).linetype    = '';
        end
        
			% get color
        color = get_values(62,eCodes,eValues);
        if isempty(color)
            entities(i).color = 0;
        else
            entities(i).color = color;
        end
        
        switch upper(entities(i).name)
            case 'HATCH'
                % just store it for coloring previous entity.
                
            case 'SPLINE'
                entities(i).spline.degree     = get_values(71,eCodes,eValues);
                entities(i).spline.no_knots   = get_values(72,eCodes,eValues);
                entities(i).spline.no_control = get_values(73,eCodes,eValues);
                entities(i).spline.knot_value = get_values(40,eCodes,eValues);
                entities(i).spline.X          = get_values(10,eCodes,eValues);
                entities(i).spline.Y          = get_values(20,eCodes,eValues);
                
            case 'LINE' 
                % (Xi,Yi,Xj,Yj) start and end points
                entities(i).line = [get_values(10,eCodes,eValues),...
                                    get_values(20,eCodes,eValues),...
                                    get_values(11,eCodes,eValues),...
                                    get_values(21,eCodes,eValues)];
                
            case 'LWPOLYLINE' 
                % (X,Y) coordinates of vertices + bulges
                ix = eCodes == 10;
                iy = eCodes == 20;
                ib = eCodes == 42;
                i_poly = ix + iy + ib;
                
                % closed polygon
                entities(i).closed = get_values(70,eCodes,eValues);
                
                eCodes(~i_poly)=[];
                eValues(~i_poly)=[];
                
                n_verts = sum(ix) + sum(ib);
                verts = zeros(n_verts,2);
                iv = 0;
                for j=1:length(eCodes)
                    switch eCodes(j)
                        case 10
                            iv = iv + 1;
                            verts(iv,1) = eValues(j);
                        case 20
                            verts(iv,2) = eValues(j);
                        case 42
                            iv = iv + 1;
                            verts(iv,1) = NaN; % handle bulges later
                            verts(iv,2) = eValues(j);
                    end
                end
                
                % handle bulges
                ib = find(isnan(verts(:,1)));
                for j = length(ib):-1:1
                    P1 = verts(ib(j)-1,:)';
                    
                    if ib(j)+1 > size(verts,1)
                        P2 = verts(1,:)';
                    else
                        P2 = verts(ib(j)+1,:)';
                    end 
                    b  = verts(ib(j),2);
                    
                    bulge_verts = bulge(P1,P2,b,15);
                    
                    % glue vertices array together including discretized arcs
                    verts = [verts(1:ib(j)-1,:);
                             bulge_verts;
                             verts(ib(j)+1:end,:)];
                end
                
                % return polygon vertices
                entities(i).poly = verts;               
               
            case 'CIRCLE' 
                % (X Center,Y Center,Radius)
                entities(i).circle = [get_values(10,eCodes,eValues),...
                                      get_values(20,eCodes,eValues),...
                                      get_values(40,eCodes,eValues)];
                
            case 'ARC' 
                % (X Center,Y Center,Radius,Start angle,End angle)
                entities(i).arc = [get_values(10,eCodes,eValues),...
                                   get_values(20,eCodes,eValues),...
                                   get_values(40,eCodes,eValues),...
                                   get_values(50,eCodes,eValues),...
                                   get_values(51,eCodes,eValues)];
                
            case 'POINT' 
                % (X,Y) Position
                entities(i).point = [get_values(10,eCodes,eValues),...
                                     get_values(20,eCodes,eValues)]; %#ok<*AGROW>
            
            case 'ELLIPSE' 
                % X center ,Y center, X end, Y end, ratio, start, end
                entities(i).ellipse = [get_values(10,eCodes,eValues),...
                                       get_values(20,eCodes,eValues),...
                                       get_values(11,eCodes,eValues),...
                                       get_values(21,eCodes,eValues),...
                                       get_values(40,eCodes,eValues),...
                                       get_values(41,eCodes,eValues),...
                                       get_values(42,eCodes,eValues)];
                
                if entities(i).ellipse(6)==0 && entities(i).ellipse(7)>0.999*2*pi
                    entities(i).closed = 1;
                else
                    entities(i).closed = 0;
                end
        
        end        
    end      

end

function values = get_values(code_no,eCodes,eValues)
% get values for current entity during reading of file
    
    values = eValues(eCodes==code_no);
    
end

function bulge_verts = bulge(P1,P2,b,n)
% 计算弧（凸起）上的n个点.起始点P1、结束点P2和凸起b。

    %theta = 4*atan(b);  % angle spanned by arc
    cv = P2-P1;         % vector from P1 -> P2
    c  = norm(cv);      % chord length
    cu = cv/c;          % unit vector from P1 -> P2
    s  = b*c/2;         % sagita
    r  = ((c/2)^2+s^2)/(2*s); % radius

    M  = P1 + 0.5*cv;   % midpoint on chord
    a  = r-s;           % length from midpoint to C
    au = [-cu(2); cu(1)];

    C  = M + a*au;      % center of arc

    % discretize
    dir1 = (P1 - C)/r;
    dir2 = (P2 - C)/r;
    a1 = atan2(dir1(2),dir1(1));
    a2 = atan2(dir2(2),dir2(1));

    % fix directions
    if (b < 0) 
        if (a1 < a2)
            a1 = a1 + 2*pi;
        end
    else
        if (a2 < a1)
            a2 = a2 + 2*pi; 
        end
    end

    theta = (linspace(a1,a2,n));
    X = C(1) + r*cos(theta)';
    Y = C(2) + r*sin(theta)';
    bulge_verts = [X Y];
    
end

function R = rotation(phi)
% setup 2D rotation matrix based on angle phi.

    R = [cos(phi) -sin(phi);
         sin(phi)  cos(phi)];
 
end

function col = color_code(code)
% returns the RGB color triplet associated with the DXF color code
% http://sub-atomic.com/~moses/acadcolors.html

    map = [0	0	0	0
            1	255	0	0
            2	255	255	0
            3	0	255	0
            4	0	255	255
            5	0	0	255
            6	255	0	255
            7	255	255	255
            8	65	65	65
            9	128	128	128
            10	255	0	0
            11	255	170	170
            12	189	0	0
            13	189	126	126
            14	129	0	0
            15	129	86	86
            16	104	0	0
            17	104	69	69
            18	79	0	0
            19	79	53	53
            20	255	63	0
            21	255	191	170
            22	189	46	0
            23	189	141	126
            24	129	31	0
            25	129	96	86
            26	104	25	0
            27	104	78	69
            28	79	19	0
            29	79	59	53
            30	255	127	0
            31	255	212	170
            32	189	94	0
            33	189	157	126
            34	129	64	0
            35	129	107	86
            36	104	52	0
            37	104	86	69
            38	79	39	0
            39	79	66	53
            40	255	191	0
            41	255	234	170
            42	189	141	0
            43	189	173	126
            44	129	96	0
            45	129	118	86
            46	104	78	0
            47	104	95	69
            48	79	59	0
            49	79	73	53
            50	255	255	0
            51	255	255	170
            52	189	189	0
            53	189	189	126
            54	129	129	0
            55	129	129	86
            56	104	104	0
            57	104	104	69
            58	79	79	0
            59	79	79	53
            60	191	255	0
            61	234	255	170
            62	141	189	0
            63	173	189	126
            64	96	129	0
            65	118	129	86
            66	78	104	0
            67	95	104	69
            68	59	79	0
            69	73	79	53
            70	127	255	0
            71	212	255	170
            72	94	189	0
            73	157	189	126
            74	64	129	0
            75	107	129	86
            76	52	104	0
            77	86	104	69
            78	39	79	0
            79	66	79	53
            80	63	255	0
            81	191	255	170
            82	46	189	0
            83	141	189	126
            84	31	129	0
            85	96	129	86
            86	25	104	0
            87	78	104	69
            88	19	79	0
            89	59	79	53
            90	0	255	0
            91	170	255	170
            92	0	189	0
            93	126	189	126
            94	0	129	0
            95	86	129	86
            96	0	104	0
            97	69	104	69
            98	0	79	0
            99	53	79	53
            100	0	255	63
            101	170	255	191
            102	0	189	46
            103	126	189	141
            104	0	129	31
            105	86	129	96
            106	0	104	25
            107	69	104	78
            108	0	79	19
            109	53	79	59
            110	0	255	127
            111	170	255	212
            112	0	189	94
            113	126	189	157
            114	0	129	64
            115	86	129	107
            116	0	104	52
            117	69	104	86
            118	0	79	39
            119	53	79	66
            120	0	255	191
            121	170	255	234
            122	0	189	141
            123	126	189	173
            124	0	129	96
            125	86	129	118
            126	0	104	78
            127	69	104	95
            128	0	79	59
            129	53	79	73
            130	0	255	255
            131	170	255	255
            132	0	189	189
            133	126	189	189
            134	0	129	129
            135	86	129	129
            136	0	104	104
            137	69	104	104
            138	0	79	79
            139	53	79	79
            140	0	191	255
            141	170	234	255
            142	0	141	189
            143	126	173	189
            144	0	96	129
            145	86	118	129
            146	0	78	104
            147	69	95	104
            148	0	59	79
            149	53	73	79
            150	0	127	255
            151	170	212	255
            152	0	94	189
            153	126	157	189
            154	0	64	129
            155	86	107	129
            156	0	52	104
            157	69	86	104
            158	0	39	79
            159	53	66	79
            160	0	63	255
            161	170	191	255
            162	0	46	189
            163	126	141	189
            164	0	31	129
            165	86	96	129
            166	0	25	104
            167	69	78	104
            168	0	19	79
            169	53	59	79
            170	0	0	255
            171	170	170	255
            172	0	0	189
            173	126	126	189
            174	0	0	129
            175	86	86	129
            176	0	0	104
            177	69	69	104
            178	0	0	79
            179	53	53	79
            180	63	0	255
            181	191	170	255
            182	46	0	189
            183	141	126	189
            184	31	0	129
            185	96	86	129
            186	25	0	104
            187	78	69	104
            188	19	0	79
            189	59	53	79
            190	127	0	255
            191	212	170	255
            192	94	0	189
            193	157	126	189
            194	64	0	129
            195	107	86	129
            196	52	0	104
            197	86	69	104
            198	39	0	79
            199	66	53	79
            200	191	0	255
            201	234	170	255
            202	141	0	189
            203	173	126	189
            204	96	0	129
            205	118	86	129
            206	78	0	104
            207	95	69	104
            208	59	0	79
            209	73	53	79
            210	255	0	255
            211	255	170	255
            212	189	0	189
            213	189	126	189
            214	129	0	129
            215	129	86	129
            216	104	0	104
            217	104	69	104
            218	79	0	79
            219	79	53	79
            220	255	0	191
            221	255	170	234
            222	189	0	141
            223	189	126	173
            224	129	0	96
            225	129	86	118
            226	104	0	78
            227	104	69	95
            228	79	0	59
            229	79	53	73
            230	255	0	127
            231	255	170	212
            232	189	0	94
            233	189	126	157
            234	129	0	64
            235	129	86	107
            236	104	0	52
            237	104	69	86
            238	79	0	39
            239	79	53	66
            240	255	0	63
            241	255	170	191
            242	189	0	46
            243	189	126	141
            244	129	0	31
            245	129	86	96
            246	104	0	25
            247	104	69	78
            248	79	0	19
            249	79	53	59
            250	51	51	51
            251	80	80	80
            252	105	105	105
            253	130	130	130
            254	190	190	190
            255	255	255	255];

    % find color in map
    if code == 7 || code == 256 %BYLAYER
        col = [0 0 0]; % override default white lines to black
    else
        id = find(code==map(:,1));
        col = map(id,2:4)/255;
    end
        
end