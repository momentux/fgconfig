function [x,y,z,spd] = speedwithclimb_altitude(X,Y,Z,tarSpd,tarHead,tarVz,tarAcc,updtintvl)

X = X * 1000.0;
Y = Y * 1000.0;

at = tarAcc;

vxy = sqrt(tarSpd^2);
vx = vxy * cos(tarHead * pi/180.0);
vy = vxy * sin(tarHead * pi/180.0);
delVxy = at * updtintvl;


delX = at * updtintvl * updtintvl * cos(tarHead * pi/180.0) / 2.0;
delY = at * updtintvl * updtintvl * sin(tarHead * pi/180.0) / 2.0;


x = X + vx * updtintvl + delX;
y = Y + vy * updtintvl + delY;


vxy = vxy + delVxy;

spd = sqrt(vxy*vxy);

x = x / 1000.0;
y = y / 1000.0;
z = 0;
