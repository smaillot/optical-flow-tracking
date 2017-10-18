function frame=OFModMap(flow)
    frame = sqrt(flow.Vx.^2+flow.Vy.^2);
    frame=frame./max(max(frame));
    %frame=cat(3,frame,frame,frame);
end