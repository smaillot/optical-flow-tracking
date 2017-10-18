function openVid()
    fig=figure(1);
    ph = uipanel('Parent',fig,'Units','pixels', 'Position',[20 20 500 300]);
    videoLabels=[{'Birds'},{'Hotel'},{'Road'},{'Fish'};{'Marathon'},{'Traffic'},{''},{''};{''},{''},{''},{''};{''},{''},{''},{''}];
    videoNames=[{'birds.mp4'},{'pedestrianTracking.avi'},{'seq.avi'},{'fish.mp4'};{'marathon.mp4'},{'traffic.mp4'},{''},{''};{''},{''},{''},{''};{''},{''},{''},{''}];
    global video
    for i=1:4
        for j=1:4
            label=videoLabels(i,j);
            name=videoNames(i,j);
            bh(i,j) = uicontrol(ph,'String',label{1}, 'Position',[20+120*(i-1) 20+70*(j-1) 100 50],'Callback',{@load,name});
        end
    end
    function load(src,event,name)
        file=['DB/' name{1}];
        vr=VideoReader(file);
        video=[];
        w=waitbar(0,'Creating the video...');
        k=1;
        while hasFrame(vr)
            video = cat(4,video,readFrame(vr));
            k=k+1;
            waitbar(k/(vr.Duration*vr.FrameRate));
        end
        close(w);
        evalin('base','video=video;');
        close(fig);
    end
    evalin('base','video=video;');
end