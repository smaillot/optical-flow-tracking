%% binarization parameters tester

% open a video and extract N images from image n°K
K = 1;
N = 98;

% choose the video
if isempty(video)
    global video;
    % choose the video to edit
    openVid
    while isempty(video)
        pause(1);
    end
    video = video(:,:,:,K:K+N);
end


% parameters
startTh = 0.01;
startCleanSize = 200;
endTh = 0.05;
endCleanSize = 200;

% create OF object
opticFlow = opticalFlowLK('NoiseThreshold',0.001);

preview = [];

w = waitbar(0,'Computing...');
for i=1:N+1
    th = startTh + (endTh - startTh) * ((i-1) / N);
    cleanSize = floor(startCleanSize + (endCleanSize - startCleanSize) * ((i-1) / N));
    flow=im2double(rgb2gray(video(:,:,:,i)));
    flow=estimateFlow(opticFlow,flow);
    flow=OFModMap(flow);
    bin = im2bw(flow,th);
    bin = insertText(uint8(255*bin), [10 10], th, 'BoxOpacity', 1, 'FontSize', 34);
    cleaned = bwareaopen(bin,cleanSize);
    cleaned = insertText(uint8(255*cleaned), [10 10], cleanSize, 'BoxOpacity', 1, 'FontSize', 34);
    preview=cat(3,preview,[bin(:,:,1) cleaned(:,:,1)]);
    waitbar(i/(N+1));
end
close(w);
implay(preview(:,:,4:end));