% Non-volcanic tremor detection code
% Brian Bagley
% University of Minnesota
% May 2011

% INPUT: 20 Hz seismogram 1 day long
% OUTPUT: Array of possible tremor - 1 file for each station 
% Multiple stations can be compared using compareFiles.m
% REQUIRED FUNCTIONS: rms.m

% ##########     VARIABLE DEFINITIONS     ##########
% A       Butterworth filter coefficient (denominator)
% B     	Butterworth filter coefficient (numerator)
% bp		Counter for bandpass filter
% fid	File name to save array for compareFiles.m - trem_pos_array.txt
% fid2    File name to save diag results - trem_pos.txt
% fn		Filename of data file to be analyzed
% hour	Hour
% j       Temperary index for duration check
% k       Array index
% min	Minute
% m       Mean of window
% n     	Size of envelop array (i.e. data / 20), currently 86400
% Pos	4 X n matrix to store 'possible' tremor detections
% PosSum	Sum of Pos, this is 1 X n with largest possible value of 4 
% r       Counter (actually the same value as bp)
% s       Seconds (range = 0 to 60, compare with sec)
% s1		Standard deviation of window
% s2		Standard deviation of window + mean of window (NOT USED)
% s3		( Standard deviation of window * 4 ) + mean of window
% sec 	Seconds (range = 0 to 86400, compare with s)
% str	Filename (fn) converted to a string
% thold 	Threshold used to detect tremor, mean of m * 2
% Thresh 	Same as thold (except this is an array), used for plotting
% tmp	Temporary location for data file
% Tplot   Used for plotting purposes only, indicitive of possible tremor
% TREM	Set to 1 if possible tremor duration exceeds 3 minutes
% Tremor 	Tremor detections that remain after comparing all filterbanks
% wh		Middle of the window (Int math)
% w       Window size (must be odd), currently set to 5 min and one sec
% x       Data array
% Y       Copy of envelop, used for plotting only
% ye		RMS envelop of filtered data
% y       Filtered data
% 
% Function Calls
% 
% Butter 	[B,A]=butter(filter order,[low corner, high corner])
% rms	ye=rms(data, # of samples per window, sample overlap, padding)
% filter	y=filter([filter coefficients],data to filter)
% ##########       END OF VAR DEF         ##########

clear all; close all;

for fn=309:1:309
    %str=sprintf('/home/brian/Desktop/Tremor/DATA/Park/Data/2004.%i.VARB.txt',fn);
    %str=sprintf('/home/brian/Desktop/Tremor/DATA/PNSN/Data/2010.%i.B009.txt',fn);
    str=sprintf('/home/brian/Desktop/Tremor/DATA/TAdata/2010.%i.A32A.txt',fn);
    tmp=load(str);
    x=tmp(1:1728000);   % Save data file to array, 1 day at 20 Hz
    clear load;
    n=size(x,1)/20;	    % Array length of envelop function, 1 day at 1 Hz
    w=301;              % Window size, odd for window centering
    wh=int32(w/2);      % Center of window
    Pos=zeros(4,n);	    % Possible tremor for each filterbank
    Tremor=zeros(1,n);  % Possible tremor after comparing filterbanks				
    r=1;			    % Counter (range 1 to 4)

% Filter loop
    for bp=1:1:4														
        fprintf(1,'%i %i to %i Hz\n',fn,bp,bp+1)   				
        [B,A]=butter(4,[bp/10, (bp+1)/10]);   % Build Butterworth filter
        y=filter(B,A,x);                      % Filter data
        ye=rms(y, 20, 0, 0);                  % Create RMS envelope
        Y=ye;					% Save envelope, used for plotting only
        k=wh;           		% Index for storing mean, SD, etc.
        m=zeros(n,1); Thresh=zeros(n,1);	  % m = mean of window
        s1=zeros(n,1); s2=zeros(n,1); 
        s3=zeros(n,1);          % s1=SD, s2=SD+mean, s3 = SD*4+mean
          
% Calculate values for first window
        m(1:k)=mean(ye(1:w));		 % Value stored at center of window			
        s1(1:k)=std(ye(1:w));		 % Values prior to center are constant 
        s2(1:k)=s1(k)+m(k);          % and equal to center value
        s3(1:k)=(s1(k)*4)+m(k);

% Advance 5 minute window 1 sec at a time
        for i=2:1:n-w+1           
            if (ye(i+w-1) > s3(k)) % Check next value BEFORE advancing k
                %ye(i+w-1)=m(k);   
                ye(i+w-1)=0;	   % These values are spikes, eq's, etc.
            end
            k=k+1;				   % Advance k and get the next window
            m(k)=m(k-1) + ( (ye(i+w-1)-ye(i-1) ) / w ); % Calc new values
            s1(k)=std(ye(i:i+w-1));
            s2(k)=s1(k)+m(k);
            s3(k)=(s1(k)*4)+m(k);
        end

% Calculate windows at the END of trace
        m(k+1:k+wh-1)=m(k);
        s1(k+1:k+wh-1)=s1(k);
        s2(k+1:k+wh-1)=s2(k);
        s3(k+1:k+wh-1)=s3(k);
        thold=mean(m)*2;           % Set tremor detection threshold 
 
% #########################
% Diagnostic plotting 
  if (bp==1) y1=m; th1(1:n)=thold; end
  if (bp==2) y2=m; th2(1:n)=thold; end
  if (bp==3) y3=m; th3(1:n)=thold; end
  if (bp==4) y4=m; th4(1:n)=thold; end
%        Thresh(1:n)=thold;
%        figure(r)
%        hold on;   
%        plot(Y,'r')
%        plot(m,'b')
%        plot (s2,'c')
%        plot (s3,'k')
%        plot(ye,'g')
%        plot(Thresh,'k')
% #########################

% Search 30 sec windows, advance 1 second at a time 	
% If maximum of window exceeds threshold it's possible tremor
% This is a 4 X n array to hold values for each filterbank	
        for i=1:1:n-29
            %if (max(m(1:1+29)) >= thold)
            if (max(ye(i:i+29)) >= thold)
                Pos(r,i)=1;													
            end
        end
        r=r+1;
    end % End bp loop

% Check for possible tremor
% Must be present in all filterbanks with duration longer than 3 mins
    PosSum=sum(Pos);	% If present in all filterbanks value will be 4
    Tplot=zeros(1,n);	% For plotting purposes	
    TREM=zeros(1,n);	% Used to store possible tremor hits
    
    fid=fopen('trem_poss_array.txt', 'a');
    
    for i=2:1:n
        if (PosSum(i)==4)           
            Tremor(i)=Tremor(i-1)+1;	% Check for coherency 
        end                             % between all filterbanks
        if (Tremor(i)>180 && Tremor(i+1) < 2)	% Check 3 min duration				
            j=Tremor(i);                        
            Tplot(i-j+1:i)=thold*10;	% Set possible tremor to yes
            TREM(i-j+1:i)=1;			  
        end								
    end
    
    % Print array, 1's for possible tremor
    % This file is read by compareFiles.m
    fprintf (fid,'%3i ',fn);
    for i=1:1:n
        fprintf (fid,'%1i ',TREM(i));
    end
    fprintf (fid,'\n');
       
    % plot(Tplot,'y')	     			% Diagnostic
    
% Diagnostic Section
% Creates trem.pos.txt and contains start and stop times
% of possible tremor - not needed for compareFiles.m
% Store results for start time
% fid2=fopen('trem_pos.txt', 'a'); 			% Open output file
% for i=1:1:n-1
%         if (TREM(i)==1 && TREM(i-1)==0)											
%             sec=i; hour=idivide(sec,int32(3600)); 
%             min=idivide(sec,int32(60))-int32((hour*60)); s=sec - int32((hour*3600)) - int32((min*60));  
%             fprintf (fid,'%3i %5i %02i:%02i:%02i',fn,sec,hour,min,s);
%         end
%         
% % Store results for stop time
%         if (TREM(i)==1 && TREM(i+1)==0)											
%             sec=i; hour=idivide(sec,int32(3600)); 
%             min=idivide(sec,int32(60))-int32((hour*60)); s=sec - int32((hour*3600)) - int32((min*60));  
%             fprintf (fid,' %5i %02i:%02i:%02i\n',sec,hour,min,s);
%         end
%     end
% fclose(fid2);
end %fn loop
fclose(fid);

% DIAGNOSTIC
  plot (y1,'k')
  hold on;
  plot (th1,'k')
  plot (y2,'g')
  plot (th2,'g')
  plot (y3,'b')
  plot (th3,'b')
  plot (y4,'r')
  plot (th4,'r')
