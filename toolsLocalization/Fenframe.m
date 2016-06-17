% FENFRAME Split signal into (overlapping) frames
%
% USAGE
% [sw, indices] = Fenframe(s, Lw, hop, mode)
%
% INPUTS
% s         : signal samples
% Lw        : frame length (in samples)
% hop       : step size (in samples) between successive frames
% mode      : 'padd' (centered frames) or 'truncate' (default)
%
% OUTPUTS
% sw        : matrix of frames extracted from signal (one frame per column)
% indices   : running indices of frames
%
% EXAMPLE
% s = sin(2*pi*(0:1024)*20/48000);
% [sw, idx] = Fenframe(s, 501, 250, 'padd');
% subplot(211), plot(idx, sw, '*');
% xlim([0 1024]); title('padd')
% [sw, idx] = Fenframe(s, 500, 250, 'truncate');
% subplot(212), plot(idx, sw, '*');
% xlim([0 1024]); title('truncate')
%
% ADAPTED FROM
%   VOICEBOX
%   Home page: http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
%
% AUTHOR
% veaux@ircam.fr

function [sw, indices] = Fenframe(s, Lw, hop, mode)

    s = s(:);
    Ls = length(s);

    % Default arguments
    if ~exist('hop', 'var') | isempty(hop)
        hop = Lw;
    end
    if ~exist('mode', 'var')
        mode = 'truncate';
    end

    % Set frame size and positions
    switch mode

        case 'padd'

            if ~rem(Lw, 2)
                error('Frame size must be odd');
            end
            Lw2 = fix(Lw/2);
            % number of frames
            nframe = fix((Ls - 1)/hop) + 1;
            % start indices of frames
            framepos = hop*(0:(nframe-1));
            % running indices within window
            winsamples = -Lw2:Lw2;

        case 'truncate'
            % number of frames
            nframe = fix((Ls - Lw)/hop) + 1;
            % start indices of frames
            framepos = hop*(0:(nframe-1));
            % running indices within window
            winsamples = 1:Lw;

        otherwise
            error('Unknown mode')

    end

    % make matrix of running indices within frames (one frame by column)
    indices = repmat(framepos,Lw,1) + repmat(winsamples(:),1,nframe);
    indices = max(1, indices);
    indices = min(Ls, indices);

    % split signal into frames
    sw = s(indices);

return