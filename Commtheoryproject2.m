function [s,t_new]=sampler(filename, fs)
    [y,signal_f] = audioread(filename);
    signal_length=(size(y,1)-1)/signal_f;
    mp=abs(max(y(:,1)));
    t=linspace(0,signal_length,size(y,1));
    s=[];
    t_new=[];
    for i = 1:floor(signal_f/fs):size(y,1)
        s(end+1)=y(i);
        t_new(end+1)=t(i);
    end
    figure;
    p = tiledlayout(2,1);
    ax1 = nexttile;
    plot(ax1,t,y)
    ax2 = nexttile;
    plot(ax2,t_new,s)
    
    % Link the axes
    linkaxes([ax1,ax2],'x');

    title(p,'Original Signal (Above) vs Sampled Signal (Below)')
    xlabel(p,'Time (seconds)')
    ylabel(p,'Amplitude')
    xlim("tight")
    ylim([-mp mp])
    % Move plots closer together
    xticklabels(ax1,{})
    p.TileSpacing = 'compact';
    hold off;
end

function [qs,bs,avg]=qntizer(L,mp,setting,s,t,fs)
    n=log2(L);
    qs=[];
    bs=[];
    values=[];
    sum=0;
    count=0;
    if setting==1
        for k=1:L
            values(end+1)=-mp + (2*k-1)*mp/L;
        end
    else
        for k=1:L
            values(end+1)=-mp + 2*k*mp/L;
        end
    end
    for k=1:length(s)
            min=3*mp;
            index=0;
            for j=1:L
                if(abs(s(k)-values(j))<min)
                    index=j;
                    min=abs(s(k)-values(j));
                end
            end
            count=count+1;
            sum=sum+min^2;
            qs(end+1)=values(index);
            bin=dec2bin(index-1);
            binarr=[];
            binarr=bin-'0';
            if length(binarr) < n
                binarr = [zeros(1, n - length(binarr)), binarr];  % Pad with zeros from the left
            end
            bs=[bs,binarr];     
    end
    avg=sum/count;
    p = tiledlayout(2,1);
    ax1 = nexttile;
    plot(ax1,t,s)
    ax2 = nexttile;
    plot(ax2,t,qs)
    
    % Link the axes
    linkaxes([ax1,ax2],'x');

    title(p,'Sampled Signal (Above) vs Quantized Signal (Below)')
    xlabel(p,'Time (seconds)')
    ylabel(p,'Amplitude')
    xlim("tight")
    ylim([-mp mp])
    % Move plots closer together
    xticklabels(ax1,{})
    p.TileSpacing = 'compact';
    hold off;
    
end

function word = unipolar_pulse_encode(pulse_amplitude, bits, samples_per_bit)
    word = [];
    for i = 1:length(bits)
        if bits(i) == 1
            word = [word, pulse_amplitude*ones(1, samples_per_bit)];
        else
            word = [word, zeros(1, samples_per_bit)];
        end
    end
end

function word = polar_pulse_encode(pulse_amplitude, bits, samples_per_bit)
    word = [];
    for i = 1:length(bits)
        if bits(i) == 1
            word = [word, pulse_amplitude*ones(1, samples_per_bit)];
        else
            word = [word, -pulse_amplitude*ones(1, samples_per_bit)];
        end
    end
end

function [word,t_mod] = encoder(pulse_amplitude,pulse_type, bits,Tb)
    samples_per_bit=40;
    if pulse_type==0
        word=unipolar_pulse_encode(pulse_amplitude,bits, samples_per_bit);
    else
        word=polar_pulse_encode(pulse_amplitude,bits,samples_per_bit);
    end
    t_mod = (0:Tb/samples_per_bit:Tb*length(bits)-Tb/samples_per_bit);  
end

function bit_stream = pulse_to_bitstream(encoded_signal,pulse_type)
    samples_per_bit=40;
    bit_stream = encoded_signal(1:samples_per_bit:end);
    if pulse_type==1
        for i=1:length(bit_stream)
            if bit_stream(i)==-1
                bit_stream(i)=0;
            end
        end
    end
end

function decoded_signal = decoder(word, n, fs, quantizer_peak_level, quantization_type,pulse_type)
    L=2^n;
    bit_stream=pulse_to_bitstream(word,pulse_type);

    bits_matrix = reshape(bit_stream, n, []).';  
    indices = bi2de(bits_matrix, 'left-msb');  

    if quantization_type==1
        q_levels = linspace(-quantizer_peak_level+(quantizer_peak_level/L), quantizer_peak_level-(quantizer_peak_level/L), L); 
    elseif quantization_type==0
        q_levels = linspace(-quantizer_peak_level+(2*quantizer_peak_level/L), quantizer_peak_level, L);
    end

    decoded_signal = q_levels(indices + 1); 

    t = (0:length(decoded_signal)-1) / fs;
    figure;
    p=plot(t,decoded_signal);
    title('Decoded Signal');
    xlabel('Time (seconds)');
    ylabel('Quantized Amplitude');
    ylim([-quantizer_peak_level, quantizer_peak_level]);
    xlim("tight")
end

function regenerated_signal = regenerative_pcm(pulse_amplitude,noisy_signal, pulse_type)
    samples_per_bit=40;
    num_bits = length(noisy_signal) / samples_per_bit;
    regenerated_signal = zeros(1,length(noisy_signal));

    for i = 1:num_bits
        segment = noisy_signal((i-1)*samples_per_bit + 1 : i*samples_per_bit);
        segment_mean = mean(segment);

        if pulse_type==0
            bit_val = segment_mean > 0.5;
        elseif pulse_type==1
            bit_val = segment_mean > 0;
        end

        if pulse_type==0
            regenerated_signal((i-1)*samples_per_bit + 1 : i*samples_per_bit) = pulse_amplitude*bit_val;
        elseif pulse_type==1
            regenerated_signal((i-1)*samples_per_bit + 1 : i*samples_per_bit) = pulse_amplitude*(2*bit_val - 1);
        end
    end
end

options_list=[20000 8 0 1 4]; %fs, L, Pulse Code, Quantization Type, Noise Variance
pulse_type=options_list(3); %0 for unipolar, 1 for polar
quantization_type=options_list(4); %1 for mid_rise, 0 for mid_tread

avgs=[];
%Sampler
fs=options_list(1);
Ts=1/fs;
filename = "C:\Users\youss\Documents\creep.mp3";
[s,t_new]=sampler(filename,fs);
mp=max(s);
%Quantizer
L=options_list(2);
n=log2(L);
[qs,bs,avg]=qntizer(L,mp,quantization_type,s,t_new,fs);
avgs=[avgs,avg];
%Encoder
pulse_amplitude=1;
Tb=Ts/n;
[word, t_mod]=encoder(pulse_amplitude,pulse_type, bs,Tb);
figure;
plot(t_mod,word);
title("First 10 bits of the Pulse Modulated Signal")
xlabel("Time (Seconds)")
ylabel("Amplitude")
xlim([0,10*Tb])
ylim([-pulse_amplitude pulse_amplitude])
%Channel
AWGN= normrnd(0,sqrt(options_list(5)),[1,length(word)]);
noisy_word=word+AWGN;
max_noise=max(noisy_word);
figure;
plot(t_mod,noisy_word);
title("First 10 bits of the Noisy Pulse Modulated Signal")
xlabel("Time (Seconds)")
ylabel("Amplitude")
xlim([0,10*Tb])
ylim([-max_noise max_noise])
%Regeneration
regenerated_word=regenerative_pcm(pulse_amplitude, noisy_word,pulse_type);
figure;
plot(t_mod,regenerated_word);
title("First 10 bits of the Regenrated Pulse Modulated Signal")
xlabel("Time (Seconds)")
ylabel("Amplitude")
xlim([0,10*Tb])
ylim([-pulse_amplitude pulse_amplitude])
%Decoder
decoded_signal=decoder(word, n, fs, mp, quantization_type,pulse_type);
%audiowrite('C:\Mohammad\Zewail\CIE 337\Projects\Project 2\Test 1 Decoded audio fs=' +string(options_list(i,1))+ ' L=' +string(options_list(i,2))+ 'Signaling type= ' +string(options_list(i,3))+'(0 for unipolar, 1 for polar).wav', decoded_signal, fs);
