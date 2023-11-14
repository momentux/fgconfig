function [x,y,z,spd,head] = speedwithheading_altitude(tarX,tarY,tarZ,tarSpd,tarHead,tarClimb,tarAcc,tarTurnRate,updtintvl)

X = X * 1000.0;
Y = Y * 1000.0;

tarTurnRate = sign(tarTurnRate) * sqrt(tarTurnRate*tarTurnRate - 1);

at = tarAcc * cos(tarClimb * pi/180.0);
vxy = tarSpd * cos(tarClimb * pi/180.0);

delHead = 9.81 * tarTurnRate * updtintvl * (180.0/pi)/tarSpd;

vx = vxy * sin(tarHead * pi/180.0);
vy = vxy * cos(tarHead * pi/180.0);

delVxy = at * updtintvl;

delX = at * updtintvl * updtintvl * sin(tarHead * pi/180.0) / 2.0;
delY = at * updtintvl * updtintvl * cos(tarHead * pi/180.0) / 2.0;

x = tarX + vx * updtintvl + delX;
y = tarY + vy * updtintvl + delY;

vxy = vxy + delVxy;

head = tarHead + delHead;
spd = sqrt(vx*vx + vy*vy);

x = x / 1000.0;
y = y / 1000.0;
z = 0;
