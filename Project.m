close all;
global video;
video=[];
% choose the video to edit
openVid
while isempty(video)
    pause(1);
end

%binTh = 0.03; %road
%cleanSize = 300; %road
binTh = 0.03; %pedestrians
cleanSize = 200; %pedestrians

    % PREVIEW
    %figure;
    imshow(video(:,:,:,2))
% save the original dimensions
s=size(video);

% create OF object
opticFlow = opticalFlowLK('NoiseThreshold',0.001);

%% Modifying the video

%% Grayscale
grayscale=[];
w=waitbar(0,'Extracting grayscale images...');
for i=1:s(4)
    grayscale=cat(3,grayscale,im2double(rgb2gray(video(:,:,:,i))));
    waitbar(i/s(4));
end
close(w);
    % PREVIEW
    %figure;
    imshow(grayscale(:,:,2))
    
    % SAVE
    videoWrite(grayscale,'grayscale.avi');
    
%% Compute Optical Flow
flow=estimateFlow(opticFlow,grayscale(:,:,1));
vectorField=[];
w=waitbar(0,'Computing Optical Flow...');
for i=2:s(4)
    flow = [flow estimateFlow(opticFlow,grayscale(:,:,i))];
    vectorField = cat(4,vectorField,insertOF(video(:,:,:,i),flow(i),2,2,1));
    waitbar(i/(s(4)-1));
end
close(w);
    % PREVIEW
    %figure;
    imshow(vectorField(:,:,:,2))
    
    % SAVE AND DELETE
    videoWrite(vectorField,'vectorField.avi');
    clearvars grayscale vectorField opticFlow;
    
%% Show OF norm
norm=[];
w=waitbar(0,'Drawing optical flow norm...');
for i=2:s(4)
    norm=cat(3,norm,OFModMap(flow(i)));
    waitbar(i/(s(4)-1));
end
close(w);
    % PREVIEW
    %figure;
    imshow(norm(:,:,1))
    
    % SAVE AND DELETE
    videoWrite(norm,'norm.avi');
    
s=size(norm); % new size (one image from original video is not used)

% %% Show OF angle
% angle=[];
% w=waitbar(0,'Drawing optical flow angle...');
% for i=2:s(3)
%     angle=cat(4,angle,OFModAngleMap(flow(i)));
%     waitbar(i/s(3));
% end
% close(w);
%     % PREVIEW
%     %figure;
%     imshow(angle(:,:,:,1))
%     
%     % SAVE AND DELETE
%     videoWrite(angle,'angle.avi');
%     clearvars angle flow;

%% Binarization
binarized=[];
w=waitbar(0,'Binarizing images...');
for i=1:s(3)
    binarized=cat(3,binarized,im2bw(norm(:,:,i),binTh));
    waitbar(i/s(3));
end
close(w);
    % PREVIEW
    %figure;
    imshow(binarized(:,:,1))
    
    % SAVE AND DELETE
    videoWrite(binarized,'binarized.avi');
    clearvars norm;
    
%% Cleaning images by deleting small objects due to the noise
cleaned=[];
w=waitbar(0,'Cleaning images...');
for i=1:s(3)
    cleaned=cat(3,cleaned,bwareaopen(binarized(:,:,i), cleanSize));
    waitbar(i/s(3));
end
close(w);
    % PREVIEW
    imshow(cleaned(:,:,1))
    
    % SAVE AND DELETE
    %figure;
    videoWrite(cleaned,'cleaned.avi');
    clearvars binarized;
    
%% Closing objects
closed=[];
w=waitbar(0,'Closing objects...');
for i=1:s(3)
    closed=cat(3,closed,imclose(cleaned(:,:,i),strel('square',8))); % cars -> 16
    waitbar(i/s(3));
end
close(w);
    % PREVIEW
    %figure;
    imshow(closed(:,:,1))
    
    % SAVE AND DELETE
    %figure;
    videoWrite(closed,'closed.avi');
    clearvars cleaned;
    
%% Filling holes
filled=[];
w=waitbar(0,'Filling objects...');
for i=1:s(3)
    filled=cat(3,filled,imfill(closed(:,:,i),'holes'));
    waitbar(i/s(3));
end
close(w);
    % PREVIEW
    %figure;
    imshow(filled(:,:,1))
    
    % SAVE AND DELETE
    %figure;
    videoWrite(filled,'filled.avi');
    clearvars closed;
    
%% Eroding shadows
eroded=[];
w=waitbar(0,'Eroding shadows...');
for i=1:s(3)
    eroded=cat(3,eroded,imopen(filled(:,:,i),strel('square',8))); % cars -> 16
    waitbar(i/s(3));
end
close(w);
    % PREVIEW
    %figure;
    imshow(eroded(:,:,1))
    
    % SAVE AND DELETE
    %figure;
    videoWrite(eroded,'eroded.avi');
    clearvars filled;
    
%% Detecting obects

squares=[];
w=waitbar(0,'Detecting objects...');
blobAnalysis = vision.BlobAnalysis('CentroidOutputPort', true, 'BoundingBoxOutputPort', true, ...
        'AreaOutputPort', false, 'MinimumBlobArea', 100); 
tracking=[]; % only for fixed camera videos
traj=[];
N=[];
m=0;
for i=1:s(3)
    [centroid bbox]= step(blobAnalysis, logical(eroded(:,:,i)));
    traj=[traj;centroid];
    n=size([centroid bbox]); n=n(1); % number of objects for this frame
    N=[N;n];
%     if m > 200 & n ~= 0 % comment for full trajectories
%         traj = traj(n:end,:);
%     end
    m=size([traj]); m=m(1); % number of objects for this frame
    insertBoxes=@(I)insertShape(I, 'Rectangle', bbox, 'Color', 'red');
    insertCentroid=@(I,r)insertShape(insertShape(I, 'FilledCircle', [centroid r*ones(n,1)], 'Color', 'yellow', 'Opacity', 1), 'Circle', [centroid r*ones(n,1)], 'Color', 'red');
    insertTraj=@(I,r)insertShape(insertShape(I, 'FilledCircle', [traj r*ones(m,1)], 'Color', 'yellow', 'Opacity', 1), 'Circle', [traj r*ones(m,1)], 'Color', 'red');
    squares=cat(4,squares,insertBoxes(insertCentroid(video(:,:,:,i),3)));
    tracking=cat(4,tracking,insertBoxes(insertTraj(video(:,:,:,i),1)));
    waitbar(i/s(3));
end
close(w);

    %PREVIEW
    %figure;
    imshow(squares(:,:,:,1));
    figure; imshow(tracking(:,:,:,end))
    figure; plot(1/30*[1:length(N)],N);
    
    %SAVE AND DELETE
    videoWrite(squares,'squares.avi');
    videoWrite(tracking,'tracking.avi');