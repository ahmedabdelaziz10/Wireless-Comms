clear 
clc

eta = 480;
fc = 800;
T = 0.01;
Ts = T / eta;
Nt = 100;		% Training sequence length
Fs = 48000;
SM = [+1 -1];
hT = ones(1, eta) / sqrt(T); 
hR = fliplr(hT);

kmax = 50000;


rng(17)
v_train = 2*randi([0 1], 1, Nt) - 1;


    %% Source
    msg = input("Enter message into program: ","s");
    binary = de2bi(uint8(msg),8);
    a = reshape(binary,1,[]);
    Na = length(a);
    %% Symbol Mapper
     v_len = SM(a_len+1);
    v_data = SM(a+1);
    
    %% Add Training sequence

    v = [v_train v_len   v_data];

    %% Transmit Filter
    vt = conv(upsample(v, eta), hT);
    Ns = length(v) * (eta); % total number of samples
    vt = vt(1:Ns);
    %% Modulator
    t = (0:length(vt)-1) * Ts;
    vct = real(vt * sqrt(2) .* exp(1j*2*pi*fc.*t));
    vct = vct/(10*sqrt(2));
    plot(vct)
    ar = audioplayer(vct,Fs);
    play(ar);