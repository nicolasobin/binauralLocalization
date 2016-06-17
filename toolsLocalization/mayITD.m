function [itd_v,lags] = mayITD(signal_m,fs,maxLag)


Nband = size(signal_m,1);
winSize = size(signal_m,2);
hopSize = round(winSize/2);
window  = hann(winSize);
itd_v = zeros(Nband,1);


%% 4. FRAME-BASED CROSS-CORRELATION ANALYSIS
% 
% 
% Loop over number of auditory filters
for iband = 1 : Nband
    
    % Framing
    frames_L = frameData(signal_m(iband,:,1)',winSize,hopSize,window,false);
    frames_R = frameData(signal_m(iband,:,1)',winSize,hopSize,window,false);
    
    % Cross-correlation analysis to estimate ITD
    [CCF,lags] = xcorrNorm(frames_L,frames_R,maxLag);
    
    % Integrate cross-correlation pattern across all frames
    CCFsum = mean(CCF,2);
    %[foo imax] = max(CCF, [], 2)
    
    % Estimate interaural time delay 
    itd_v(iband,:) = findITD(CCFsum,fs,lags,1);
end