str1=input('�������ȡ���ļ���:\n','s');
str2=input('������������ļ���:\n','s');
fidin = fopen(['.\data\',str1,'.txt'],'r');              
fidout_jd = fopen('jd.txt','w'); 
fidout_dy = fopen('dy.txt','w'); 
fidout_hz = fopen('hz.txt','w'); 
fidout = fopen(['.\outdata\',str2,'.txt'],'w');
while ~feof(fidin)              
    tline=fgetl(fidin);
    %�жϿո�������
    if isempty(tline)
        continue 
    else
        [~,n] = size(tline);
        %��jd:�����������д��jd.txt��
        if(tline(1) == 'j'&&tline(2) == 'd'&&tline(3) == ':')
            for i = 4:n
                fprintf(fidout_jd,'%s',tline(i)); 
            end
            fprintf(fidout_jd,'\r\n');
        %��dy:�����������д��dy.txt��
        elseif(tline(1) == 'd'&&tline(2) == 'y'&&tline(3) == ':')
            for i = 4:n
                fprintf(fidout_dy,'%s',tline(i)); 
            end
            fprintf(fidout_dy,'\r\n');
        %��hz:�����������д��hz.txt��
        elseif(tline(1) == 'h'&&tline(2) == 'z'&&tline(3) == ':')
            for i = 4:n
                fprintf(fidout_hz,'%s',tline(i)); 
            end
            fprintf(fidout_hz,'\r\n');
        end
    end
end
%���tline,n,i
clear tline n i ;
%�ر�����ļ�
fclose(fidin);
fclose(fidout_jd);
fclose(fidout_dy);
fclose(fidout_hz);

%����㡢��Ԫ��������Ϣ��������
jd = load('jd.txt');
dy = load('dy.txt');
hz = load('hz.txt');
%ɾ��jd.txt��dy.txt��hz.txt
delete ('jd.txt');
delete ('dy.txt');
delete ('hz.txt');
%�������С��ý�㡢��Ԫ����������
[jd_num,~] = size(jd);
[dy_num,~] = size(dy);
[hz_num,~] = size(hz);

wy_num = 0;%����λ�Ƹ���
%��������λ�Ƹ���
for i = 1:jd_num
    for j = 3:5
        if wy_num < jd(i,j)
            wy_num = jd(i,j);
        end
    end
end

K = zeros(wy_num,wy_num);%����նȾ���
P = zeros(wy_num,1);%�����Ч�ڵ����

dydw = zeros(6,dy_num);%��Ԫ��λ����
l = zeros(dy_num,1);%��Ԫ�ĳ���
T = zeros(6,6,dy_num);%��Ԫ����ת������
ke = zeros(6,6,dy_num);%�ֲ�����ϵ�ĵ�Ԫ�նȾ���
k = zeros(6,6,dy_num);%��������ϵ�ĵ�Ԫ�նȾ���
x = zeros(6,dy_num);%��������ϵ�ĵ�Ԫ�ڵ�λ��
F = zeros(6,dy_num);%��������ϵ�ĵ�Ԫ�˶�����
Fe = zeros(6,dy_num);%�ֲ�����ϵ�ĵ�Ԫ�˶�����

Fpe = zeros(6,hz_num);%�ֲ�����ϵ�ĵ�Ԫ�̶���
p = zeros(6,hz_num);%��������ϵ�ĵ�Ч������

for i = 1:dy_num
    dydw(:,i) = [jd(dy(i,1),3),jd(dy(i,1),4),jd(dy(i,1),5),jd(dy(i,2),3),jd(dy(i,2),4),jd(dy(i,2),5)];%��Ԫ��λ����������
    [l(i),T(:,:,i)] = to_T(jd(dy(i,1),1),jd(dy(i,1),2),jd(dy(i,2),1),jd(dy(i,2),2));%���㵥Ԫ���Ⱥ͵�Ԫ����ת������
    ke(:,:,i) = to_ke(dy(i,3),dy(i,4),l(i));%����ֲ�����ϵ�ĵ�Ԫ�նȾ���
    k(:,:,i) = T(:,:,i)'*ke(:,:,i)*T(:,:,i);%������������ϵ�ĵ�Ԫ�նȾ���
    %��Ԫ�նȾ���������նȾ��󼯳�
    for j = 1:6
        if dydw(j,i) ~= 0
            for n = 1:6
                if dydw(n,i) ~= 0
                    K(dydw(j,i),dydw(n,i)) = K(dydw(j,i),dydw(n,i)) + k(j,n,i);
                end
            end
        end
    end
end

for i = 1:hz_num
    if hz(i,1) == 1%�жϺ��������ڽ��
        if jd(hz(i,2),hz(i,3)+2) ~= 0%�жϽ���ں������÷�������λ��
            P(jd(hz(i,2),hz(i,3)+2),1) = P(jd(hz(i,2),hz(i,3)+2),1) + hz(i,4);
        end
    else
        Fpe(:,i) = to_hz(hz(i,3),hz(i,4),hz(i,5),l(hz(i,2)));%���㵥Ԫ�̶���
        p(:,i) = - T(:,:,hz(i,2))'*Fpe(:,i);%������������ϵ�ĵ�Ԫ��Ч������
        F(:,hz(i,2)) = F(:,hz(i,2)) + T(:,:,hz(i,2))' * Fpe(:,i);%�Ƚ���������ϵ�ĵ�Ԫ�̶����ӵ���������ϵ�ĵ�Ԫ�˶�����
        %����Ԫ��Ч�����������弯��
        for j = 1:6
            if dydw(j,hz(i,2)) ~= 0
                P(dydw(j,hz(i,2)),1) = P(dydw(j,hz(i,2)),1) + p(j,i);
            end
        end
    end
end
X = K\P;%�����������ϵ�µ�λ��

%�����������ϵ�µĵ�Ԫ�˶�λ��
for i = 1:dy_num
   for j = 1:6
       if dydw(j,i) ~= 0
           x(j,i) = X(dydw(j,i));
       end
   end
end

for i = 1:dy_num
    F(:,i) = F(:,i) + k(:,:,i) * x(:,i);%�����������ϵ�µĵ�Ԫ�˶�����
    Fe(:,i) = T(:,:,i)*F(:,i);%����ֲ�����ϵ�µĵ�Ԫ�˶�����
end
%�ѽ��д����Ӧ���ļ���
fprintf(fidout,'%s','X:');
fprintf(fidout,'\r\n');
for i = 1:wy_num
    fprintf(fidout,'%8.3f',X(i));
    fprintf(fidout,'\r\n');
end
fprintf(fidout,'%s','Fe:');
fprintf(fidout,'\r\n');
for i = 1:6
    for j = 1:dy_num
        fprintf(fidout,'%8.3f',Fe(i,j));
        fprintf(fidout,'%s','  ');
    end
    fprintf(fidout,'\r\n');
end
fclose(fidout);

r_zl = max(max(abs(Fe(1,:))),max(abs(Fe(4,:))));
r_jl = max(max(abs(Fe(2,:))),max(abs(Fe(5,:))));
r_wj = max(max(abs(Fe(3,:))),max(abs(Fe(6,:))));
l_min = min(l);
r_zl = 2 * r_zl / l_min;
r_jl = 2 * r_jl / l_min;
r_wj = 2 * r_wj / l_min;
x_min = min(jd(:,1));
y_min = min(jd(:,2));
x_max = max(jd(:,1));
y_max = max(jd(:,2));

set (gcf,'Position',[200,50,750,600], 'color','w');%���û�ͼ�ռ�
%������ͼ
subplot(2,2,1)
hold on;
set(gca,'Xlim',[x_min - l_min/2,x_max + l_min/2]);
set(gca,'Ylim',[y_min - l_min/2,y_max + l_min/2]);
for i = 1:dy_num
    plot([jd(dy(i,1),1),jd(dy(i,2),1)],[jd(dy(i,1),2),jd(dy(i,2),2)],'black');
end
for i = 1:dy_num
    dyhz = 0;
    hzlx = 0;
    hzcd = 0;
    for j = 1:hz_num
        if hz(j,1) == 2
            if hz(j,2) == i
               dyhz = 1; 
               hzlx = hz(j,3);
               hzcd = hz(j,5);
            end
        end
    end
    to_zlt(dyhz,hzlx,hzcd,l(i),-Fe(1,i),Fe(4,i),jd(dy(i,1),1),jd(dy(i,1),2),T(1,1,i),T(2,1,i),r_zl);
end
title('����ͼ');
axis off;

%�����ͼ
subplot(2,2,2)
hold on;
set(gca,'Xlim',[x_min - l_min/2,x_max + l_min/2]);
set(gca,'Ylim',[y_min - l_min/2,y_max + l_min/2]);
for i = 1:dy_num
    plot([jd(dy(i,1),1),jd(dy(i,2),1)],[jd(dy(i,1),2),jd(dy(i,2),2)],'black');
end
for i = 1:dy_num
    dyhz = 0;
    hzlx = 0;
    hzdx = 0;
    hzcd = 0;
    for j = 1:hz_num
        if hz(j,1) == 2
            if hz(j,2) == i
               dyhz = 1; 
               hzlx = hz(j,3);
               hzdx = hz(j,4);
               hzcd = hz(j,5);
            end
        end
    end
    to_jlt(dyhz,hzlx,hzdx,hzcd,l(i),-Fe(2,i),Fe(5,i),jd(dy(i,1),1),jd(dy(i,1),2),T(1,1,i),T(2,1,i),r_jl);
end
title('����ͼ');
axis off;

%�����ͼ
subplot(2,2,3)
hold on;
set(gca,'Xlim',[x_min - l_min/2,x_max + l_min/2]);
set(gca,'Ylim',[y_min - l_min/2,y_max + l_min/2]);
for i = 1:dy_num
    plot([jd(dy(i,1),1),jd(dy(i,2),1)],[jd(dy(i,1),2),jd(dy(i,2),2)],'black');
end
for i = 1:dy_num
    dyhz = 0;
    hzlx = 0;
    hzdx = 0;
    hzcd = 0;
    for j = 1:hz_num
        if hz(j,1) == 2
            if hz(j,2) == i
               dyhz = 1; 
               hzlx = hz(j,3);
               hzdx = hz(j,4);
               hzcd = hz(j,5);
            end
        end
    end
   to_wjt(dyhz,hzlx,hzdx,hzcd,l(i),Fe(2,i),-Fe(3,i),Fe(6,i),jd(dy(i,1),1),jd(dy(i,1),2),T(1,1,i),T(2,1,i),r_wj); 
end
title('���ͼ');
axis off;
 