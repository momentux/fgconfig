function [x,y,z] = climb_altitude(X,Y,Z,Spd,Head,tarVz,intvl)

X = X * 1000.0;
Y = Y * 1000.0;

vxy = sqrt(Spd^2);
vx = vxy * cos(Head * pi/180.0);
vy = vxy * sin(Head * pi/180.0);

delX = vx * intvl;
delY = vy * intvl;
delZ = tarVz*intvl;

x = X + delX;
y = Y + delY;


x = x / 1000.0;
y = y / 1000.0;
z = 0;