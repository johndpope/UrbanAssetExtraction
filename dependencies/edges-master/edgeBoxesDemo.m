% Demo for Edge Boxes (please see readme.txt first).

%% load pre-trained edge detection model and set opts (see edgesDemo.m)
model=load('models/forest/modelBsds'); model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;

%% set up opts for edgeBoxes (see edgeBoxes.m)
opts = edgeBoxes;
opts.alpha = .65;     % step size of sliding window search
opts.beta  = .75;     % nms threshold for object proposals
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 1e4;  % max number of boxes to detect

%% detect Edge Box bounding box proposals (see edgeBoxes.m)
imdir='E:\E\KAUST\GMSV\Datasets\Urban\strasburg\rectified\';
imname='IMG_2706.jpg';
I=imread([imdir imname]);
tic, bbs=edgeBoxes(I,model,opts); toc

mapdir='E:\E\KAUST\GMSV\Datasets\Urban\strasburg\groundtruth\map\';
map=imread([mapdir imname(1:end-4) '.png']);
s=regionprops(rgb2gray(map)==76,'BoundingBox');
gt=cat(1,s.BoundingBox);

%% show evaluation results (using pre-defined or interactive boxes)
ov=0.5;

gt(:,5)=0; [gtRes,dtRes]=bbGt('evalRes',gt,double(bbs(1:1000,:)),ov);
subplot(1,3,1); bbGt('showRes',I,gtRes,dtRes(dtRes(:,6)==1,:));
title('green=matched gt  red=missed gt  dashed-green=matched detect');


gop_mex( 'setDetector', 'MultiScaleStructuredForest("sf.dat")' );

% Setup the proposal pipeline (baseline)
p = Proposal('max_iou', 0.8,...
    'unary', 130, 5, 'seedUnary()', 'backgroundUnary({0,15})',...
    'unary', 130, 1, 'seedUnary()', 'backgroundUnary({})', 0, 0, ... % Seed Proposals (v1.2 and newer)
    'unary', 0, 5, 'zeroUnary()', 'backgroundUnary({0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15})' ... % Background Proposals
    );

os = OverSegmentation( I );
props = p.propose( os );

fprintf( ' %d proposals generated. Image size %d x %d.\n', size(props,1), size(I,1), size(I,2) );
boxes = os.maskToBox( props );


boxes(:,5)=0;
boxes(:,3)=boxes(:,3)-boxes(:,1);
boxes(:,4)=boxes(:,4)-boxes(:,2);
[gtRes,dtRes]=bbGt('evalRes',gt,double(boxes),ov);
subplot(1,3,2);bbGt('showRes',I,gtRes,dtRes(dtRes(:,6)==1,:));
title('green=matched gt  red=missed gt  dashed-green=matched detect');

foldername=('E:\E\Programs\BingObjectnessCVPR14\VOC2007\Results\BBoxesB2W8MAXBGR\');
bb=dlmread([foldername imname(1:end-4) '.txt']);
bb(1,:)=[];
bb(:,6)=bb(:,1);
bb(:,1)=[];

[gtRes,dtRes]=bbGt('evalRes',gt,double(bb),ov);
subplot(1,3,3); bbGt('showRes',I,gtRes,dtRes(dtRes(:,6)==1,:));
title('green=matched gt  red=missed gt  dashed-green=matched detect');

