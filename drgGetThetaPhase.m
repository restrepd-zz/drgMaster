function [anglethetaLFP]=drgGetThetaPhase(LFPlow,Fs,lowF1,lowF2,highF1,highF2,time_pad,no_bins,method)
%Generates the phase histogram for the emvelope and pac
%function [pac_value, mod_indx, phase, phase_histo, theta_wave]=drgGetThetaAmpPhase(LFP,Fs,lowF1,lowF2,highF1,highF2,time_pad,no_bins)


%Time pad is used to exclude filter artifacts at the end
Fs=floor(Fs);



% angleThFlGammaEnv = angle(hilbert(thfiltLFPgenv)); % phase modulation of amplitude
% vect_length_Env = abs(hilbert(thfiltLFPgenv)); % vector length of the envelope filtered at theta
% meanVectorLength=sqrt((mean(vect_length_Env.*sin(angleThFlGammaEnv)))^2+(mean(vect_length_Env.*cos(angleThFlGammaEnv)))^2)/mean(LFPgenv);




%Filter LFP theta
        thfiltLFP=filtfilt(bpFilttheta,LFPlow);



%thfiltLFP=LFPlow;

anglethetaLFP = angle(hilbert(thfiltLFP)); % phase modulation of amplitude



