function [CutSignal] = ResampleNoEdgeEffects(Signal,NewLength)
% ResampleNoEdgeEffects
% Resample a signal without edge effects
% Tom Buurke, UMCG, 2023

% Inputs
% Signal - Signal to be resampled
% NewLength - Desired length of resampled signal

% Outputs
% NewSignal - Resampled signal

% OldTimeArray=1:1:length(Signal);
% NewTimeArrayTemp=1:1:NewLength;
% ArrayStep=length(OldTimeArray)/length(NewTimeArrayTemp);
% NewTimeArray=1:ArrayStep:length(OldTimeArray);
% NewSignal=interp1(OldTimeArray,Signal,NewTimeArray,'spline');

FlipSignal = [flip(Signal);Signal;flip(Signal)];

NewSignal=resample(FlipSignal,NewLength*3,length(FlipSignal));

CutSignal=NewSignal(101:200);

end