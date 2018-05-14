map=1000;
safeZone =[200,600;];
critAreas=[700 700; 700 100];
obstacles=[10,0;200 400;]
critArea_dim=[90,90];
safeZone_dim=[90,90];
colors=['b','m','c','r','y'];
sz=50;

scatter(IntrPos(:,1),IntrPos(:,2),sz,'r','filled');
hold on
scatter(RobotPos1(:,1),RobotPos1(:,2),sz,'k','x');
hold on
scatter(RobotPos2(:,1),RobotPos2(:,2),sz,'b','+');
axis square 
axis([0 800 0 800]);
%rectangle('position',[3 3 map-3 map-3],'edgecolor','y', 'LineWidth',2) %drawing map borders

for d=1:size(critAreas,1)
    rectangle('position',[critAreas(d,:)-critArea_dim/2 critArea_dim],'FaceColor',colors(d))%drawing target area
end
rectangle('position',[safeZone-critArea_dim/2 safeZone_dim],'FaceColor','g')%drawing target area