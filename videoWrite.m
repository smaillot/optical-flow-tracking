function videoWrite(video,name)
    % Video writter obj
    s=size(video);
    writerObj = VideoWriter(['render/' name]);
    writerObj.FrameRate = 30;    
    open(writerObj);
    if max(max(max(max(video))))<=1 % convert binary videos into RGB
        video=255*video;
    end
    w=waitbar(0,'Saving video...');
    for i=1:s(end)
        if length(s)==3 % if this video is a grayscale video
            frame = im2frame(uint8(cat(3,video(:,:,i),video(:,:,i),video(:,:,i))));
        else
            frame = im2frame(uint8(video(:,:,:,i)));
        end
        writeVideo(writerObj, frame);
        waitbar(i/s(end));
    end
    close(w);
end