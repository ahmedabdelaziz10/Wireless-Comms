clear;
clc;
eta = 480;
fc = 800;
T = 0.01;
Ts = T / eta;
Nt = 100;		% Training sequence length
Fs = 48000;
dur = 7;     % recording time
SM = [+1 -1];
hT = ones(1, eta) / sqrt(T);
hR = fliplr(hT);
kmax = 50000;
rng(17)
v_train = 2*randi([0 1], 1, Nt) - 1;
    %% Channel
ar = audiorecorder(Fs, 16, 1);
recordblocking(ar,dur);
play(ar);
rct = getaudiodata(ar)';

    %% Down-converstion
 t = (0:length(rct)-1) * Ts;
 rot = rct * sqrt(2) .* exp(-1j*2*pi*fc*t);
    
    %% Receiver Filter
 rt = conv(rot, hR) * Ts;
 plot(real(rt))

    %% Detect delay
 mu = zeros(1, kmax+1);
 for k=0:kmax
	rx = rt(k + eta:eta:end);
	mu(k+1) = abs(mean(rx(1:Nt) .* conj(v_train)));
 end
[~,k] = max(mu);
k = k - 1;

    %% Sampler
r = rt(k + eta:eta:end);

    %% Estimate phase error
q = mean(r(1:Nt) ./ v_train);

    %% Remove training
r = r(Nt+1:end);

    %% Fix phase error
z = r / q;

    %% Decision Device
ah1 = (z < 0);
x = reshape(ah1,[],1);
N = bi2de(x(1:16));
Na = bi2de(N')*8;
ah = x(17:end);
ah2 = ah(1:Na)';
    
    %% Sink
rcvd = reshape(ah2,[],8);
new_msg = reshape(char(bi2de(rcvd)),1,[]);
disp("Received message")
disp(new_msg)