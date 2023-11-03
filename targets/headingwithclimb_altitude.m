function [x7,y7,z7,spd7,head7] = headingwithclimb_altitude(X7,Y7,Z7,Spd7,Head7,tarVz,TurnRate7,intvl7)

X7 = X7 * 1000.0;
Y7 = Y7 * 1000.0;

vxy = sqrt(Spd7^2);

% TurnRate7 = sign(TurnRate7) * sqrt(TurnRate7*TurnRate7 - 1);

delHead = 9.81 * TurnRate7 * intvl7 * (180.0/pi) / Spd7;

vx = vxy * cos(Head7 * pi/180.0);
vy = vxy * sin(Head7 * pi/180.0);

x7 = X7 + vx * intvl7;
y7 = Y7 + vy * intvl7;

head7 = Head7 + delHead;

spd7 = sqrt(vx*vx + vy*vy);

x7 = x7 / 1000.0;
y7 = y7 / 1000.0;
z7 = 0;
