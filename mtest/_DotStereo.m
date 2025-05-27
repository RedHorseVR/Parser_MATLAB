clear;
%load('stereoParams.mat');

% SETUP PARAMETERS
% addpath(genpath('E:\Users\luis\OneDrive\projects\stereocam\mex')
% addpath(genpath('E:\Users\luis\OneDrive\projects\stereocam\Stereo3D\MeshFunctions')
density = 4;
delay = 2;%/
mask_thresh = .6;%/
use_dark = true;
expo = -11;
fname = [ 'dots.png' ] ;
[L, R] = stereoImread(  fname );% stereo(0).acquire();
s  = size( L);
RimageShift = [ 0, 6 ] ;
R  = imtranslate( R,  RimageShift   );
E = zeros( s(1), s(2) );
L1 = zeros( s(1), 1 );
R1 = zeros( s(1), 1 );
d = zeros( s(1) );
x = zeros( s(1) );
v = 1;
MAXDEPTH = 200;
DEPTHSCALE = 20;
steps = 1;%steps= 10;
d = zeros( s(1) );
x = zeros( s(1) );

% MAIN
[ UPhaseL, WPhaseL, UPhaseR, WPhaseR  ] = getPhaseMap( ) ;
fprintf( fname );
thresh = .5;%thresh = .1;
bwL = im2bw( L , thresh );
bwR = im2bw( R , thresh );
figure(1); imshow( [ bwL bwR ] ); drawnow;
tic
[ Xl, Yl, Pl, szl ] = getXYP ( bwL , WPhaseL );%[ Xl, Yl, Pl, szl ] = getXYP ( bwL , UPhaseL );
[ Xr, Yr, Pr, szr ] = getXYP ( bwR , WPhaseR );%[ Xr, Yr, Pr, szr ] = getXYP ( bwR , UPhaseR );
%Pr = Pr - mod( Pr , pi/2 );
%Pl = Pl - mod( Pl, pi/2);
%Pl = Pl - mod( Pl, pi/2);
cla;% clear axis
P1 = [ Yl , Pl ];
P2 = [ Yr , Pr ];

C  = PointCorr( P1 , P2 );
figure( 2 ); cla; hold on;
for i=1:length(C)
	X1 = (Xl(C( i,1))) ;
	Y1 = (Yl(C( i,1))) ;
	P1 = (Pl(C( i,1))) ;
	X2 = (Xr(C( i,2))) ;
	Y2 = (Yr(C( i,2))) ;
	P2 = (Pr(C( i,2))) ;
	XX = [ X1 X2 ];
	YY = [ Y1 Y2 ];
	PP = [ P1 P2 ];
	line(XX,YY, PP) ;%scatter( Yr, Pr, 'r' )
	[ z, x ] = Get2DCoord( X1 ,  X2,  s  );%  computes depth at x given the Left and Right eye corresponing values and s = size( image )
	y = Y1;%  computes depth at x given the Left and Right eye corresponing values and s = size( image )
	V( i , : ) = [ x, y, z ];
	end
pc = pointCloud( V );
pcwrite( pc, 'PC.ply' );
%scatter( Yl, Pl, 'b' )
scatter3( Xr,Yr,Pr, 'r' ) ; scatter3( Xl,Yl,Pl, 'b' ) ;
hold off;
figure(9); pcshow( pc, 'markersize', 50 );
toc
Rl = 5*ones( szl( 1 ), 1  );
Rr = 5*ones( szr( 1 ), 1  );
figure(1); imshow( [ L R ] );
hold on;
viscircles( [ Xl  ,  Yl  ], Rl  ,'Color', 'b' );
viscircles( [ Xr + s(2) ,  Yr  ], Rr ,'Color', 'r' );
hold off;
%figure(2); plot( d ); drawnow;
%V = V - min(V) ;
%//pc = pointCloud( V );//
%pcwrite( pc, 'PC.ply' );


function [ d, x ] = Get2DCoord( XL,  XR, s )%  computes depth at x given the Left and Right eye corresponing values and s = size( image )
		
		epsilon = .0000001;
		MAXD = 1500;
		NOMINALD = 0 ;
		ZSCALE = 9;
		T = 50;% interocular
		view_angle = pi/3 ;
		F = (view_angle / 2) / (s(2)/2) ;%  est inverse focal from est view angle
		cx = s(2)/2;
		ThetaL = pi/2 - atan( (XL-cx) * F );
		ThetaR = pi/2 - atan( (cx-XR) * F );
		d = T * sin(ThetaR) * sin( ThetaL ) / ( sin( ThetaL + ThetaR ) + epsilon );
		d = d*ZSCALE%h = - d * sin( ThetaL ) / ( cos( ThetaR + ThetaL ) +epsilon );
		if     abs(d) > MAXD
		
			
			d = NOMINALD;
			end
		%d = SCALEDEPTH*d;
		x = double( XL ) + 1;%x =  h;
		
	end
function [ CorrArray ] = PointCorr( P1 , P2 )%input 2 lists of points and output a corrArray of indcies of matched points
		
		XTOL= 4 ;%XTOL= 2;
		YTOL= 0.05 ;%YTOL= 0.2 ;
		%maxD2 = XTOL*XTOL + YTOL*YTOL;
		N1 = length( P1 );
		N2 = length( P2 );
		E = zeros( N1 ,  N2 );
		%X0 = min(  [ min( P1(:,1)) , min( P2(:,1)) ]  );
		%X1 = max(  [ max( P1(:,1)) , max( P2(:,1)) ]  );
		%Y0 = min(  [ min( P1(:,2)) , min( P2(:,2)) ]  );
		%Y1 = max(  [ max( P1(:,2)) , max( P2(:,2)) ]  );
		%ystep = YTOL* (Y1 - Y0)/100;
		inx = 1;
		for n1 = 1:N1%for x = X0:X1
			x1 = P1(n1,1);
			y1 = P1(n1,2);
			for  n2 = 1:N2%for  y = Y0:Y1
				x2 = P2(n2,1);
				y2 = P2(n2,2);
				if  abs(x2-x1) <= XTOL  && abs(y2-y1) <= YTOL
				
					
					E( n1, n2 ) = 1 / (y1-y2)^2 ;%E( n1, n2 ) = 1 / ((x1-x2)^2 + (y1-y2)^2 + 0.001);
					inx= inx+1;
					end
				end
			end
		k = 1;
		for i=1:N1
			if   nnz( E(i,:)  ) > 0
			
				
				[t, j] = max( E(i,:) )% ////
				CorrArray( k, : ) = [ i, j ];%CorrArray( inx, : ) = [ n1, n2 , x1, x2 ];
				k = k + 1;
				end
			end
		
	end
function [ UL, WL, UR, WR ] = getPhaseMap( )
		
		[ L1, R1 ] = stereoImread( 'F1.png');%/ //
		[ L2, R2 ] = stereoImread( 'F2.png');%/ //
		[ L3, R3 ] = stereoImread('F3.png');%/ //
		dL1 = double(L1);%/ //
		dL2 = double(L2);%/ //
		dL3 = double(L3);%/ //
		dR1 = double(R1);%////
		dR2 = double(R2);%/ //
		dR3 = double(R3);%/// //
		WL = atan(sqrt(3) * (dL1 - dL3)./(2*dL2-dL1-dL3) );%WL = 2*atan(sqrt(3) * (dL1 - dL3)./(2*dL2-dL1-dL3) );
		WL(isnan(WL)) = 0;%/ //
		UL = unwrap( WL' )';%/ //
		WR = atan(sqrt(3) * (dR1 - dR3)./(2*dR2-dR1-dR3) );%WR = 2* atan(sqrt(3) * (dR1 - dR3)./(2*dR2-dR1-dR3) );
		WR(isnan(WR)) = 0;%/// //
		UR = unwrap( WR' )';%/// //
		
	end
function [ X, Y, P, sz ] = getXYP ( BW , Phase )%computes the image coordinates for a bw dot image and the phases at each point
		
		stats = regionprops( 'table', BW, 'Centroid' );%stats = regionprops('table', BW, 'Centroid', 'MajorAxisLength','MinorAxisLength')
		%[ y, x ]= find (bwL);
		sz = size(stats)
		centers = stats.Centroid ;
		for i=1:length(centers)
			ix = round( centers(i,2)) ;
			iy = round( centers(i,1)) ;
			fx = centers(i,2) - ix ;
			fy = centers(i,1) - iy ;
			J(i) = Phase( ix , iy );
			end
		P = J';
		X = centers( :, 1 );
		Y = centers( :, 2 );
		
	end
function [L,R] = stereoImread( file )%// //
		
		% //STEREOIMREAD Summary of this function goes here //
		% //   Detailed explanation goes here //
		simg = imread( file );%/ //
		s = size( simg );%/ //
		R = simg(:,1+s(2)/2:s(2));%/ //
		L = simg(:,1:s(2)/2);%/ //
		
	end%//// //
%  Export  Date: 02:13:10 PM - 04:Apr:2019.

%  Export  Date: 02:20:33 PM - 04:Apr:2019.

