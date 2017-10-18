function frame=OFModAngleMap(flow)
    mod = uint8(sqrt(flow.Vx.^2+flow.Vy.^2));
    frame=OFAngleMap(flow);
    frame(:,:,3)=uint8(mod);
    frame=hsv2rgb(frame);
end