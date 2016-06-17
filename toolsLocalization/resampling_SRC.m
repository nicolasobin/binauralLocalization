function [ signal_s ] = resampling_SRC( signal_e,fs_e,fs_s )
%RESAMPLING_SRC Re-echantillone un signal à une fréquence désiré
% IN
%         signal_e : signal a re-echantilloner
%         fs_e     : fréquence d'echantillonnage original
%         fs_s     : nouvelle fréquence d'echantillonnage desire
% OUT
%         signal_s : signal re-echantillone

% calcule du SRC
[p,q] = rat(fs_s/fs_e);

%reechantillonnage
signal_s= resample(signal_e',p,q,2)'; % ' sur chaque ligne pas colonne

end

