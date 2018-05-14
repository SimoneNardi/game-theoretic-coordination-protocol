function videowrite(nomefile,movie)

v = VideoWriter(nomefile,'MPEG-4');
v.FrameRate = 20;
open (v);
writeVideo(v,movie);
close(v);
end