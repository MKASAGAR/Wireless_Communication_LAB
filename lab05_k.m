clc;
clear all;
close all;

% First part signal generate.........

f=1000;
Fs=4000;


 sp=1/Fs;
 t=[sp:sp:1];
 Am=1.0;
 
 
 signal= Am*sin(2*pi*f*t);
 plot(t(1:100),signal(1:100))

 set(gca,'ytick',[-1.0 0 1.0]);
 xlabel('Time')
 ylabel('Amplitude')
 
 
 % second part calculate max min value for interleaving...
 
 maximumvalue=max(signal);
 minimumvalue=min(signal);
 
 interval=(maximumvalue-minimumvalue)/255;
 
 partition= [minimumvalue:interval:maximumvalue];
 
 codebook= (minimumvalue-interval): interval:maximumvalue;
 
 [index, quants, distor]= quantiz(signal, partition , codebook);
 
 indextrn= index';

 for i=1:4000									
matrix(i,1:1:8)=bitget(uint8(indextrn(i)),1:1:8);									
end
 matrixtps = matrix';
 
 baseband = reshape( matrixtps, 4000*8,1);
 
 Tb=1/32000;
 
 time = [0 : Tb: 1];
 figure(2)
 stairs (time(1:500),baseband(1:500));
 xlabel('Time(sec)')
 ylabel('Binary value')
 set(gca,'ytick',[0 1])
 axis([0,time(500),0,1])
 
 % Third part Coding Decoding........
 
 %Interleaving.....
 
 
 input_to_Conventional_encoder= baseband';
 
 t=poly2trellis(7,[171 133]);
 
 code= convenc(input_to_Conventional_encoder, t);
  str2=4831;
  
  data_interleave=randintrlv (code,str2);
  
  %BPSK Modulation
  
  M=2;
  
  k=log2(M);
  
  symbol=bi2de(reshape(data_interleave,k,length(data_interleave)/k).','left-msb');
  
  symbol=double(symbol);
  
  modBPSK=pskmod(symbol,M);
  
  demodBPSK=pskdemod(modBPSK,M);
  
  retrived_bit= de2bi(demodBPSK,'left-msb');
  
  % Deinterleaving......
  
  errors=zeros(size(retrived_bit));
  
  inter_error= bitxor(retrived_bit, errors);
  
  data_deinterleave= randdeintrlv( inter_error,str2);
  
  
  %Decoding........
  
  tblen=3;
  decodx= vitdec(data_deinterleave,t,tblen,'cont','hard'); %poly2terillis
  
  N3=length(decodx);
 % NN= N3/8;
 
 decod2 (1:(N3-3))=decodx(tblen+1:end);
 decod2 (N3)=decodx(1);
 decod2= decod2';
 
 %.... transformation...
 baseband = double (baseband);
 [number, ratio]= biterr(decod2,baseband);
 convert= reshape(decod2,8,4000);
 
 
 matrixtps = double (matrixtps);
 [number,ratio]= biterr(convert,matrixtps);
 convert=convert';
 
 
 intconv= bi2de(convert);
 
[number, ratio]=biterr(intconv, index');

sample_value= minimumvalue+intconv.*interval;

figure(3)
subplot(2,1,1)
plot(time(1:100),signal(1:100))
set(gca,'ytick',[ -1.0   0 1.0 ])									
axis([0,time(100),-1,1])
subplot(2,1,2)
plot(time(1:100),sample_value(1:100))
%plot(time(1:100),sample_value(1:100));									
axis([0,time(100),-1,1])									
set(gca,'ytick',[ -1.0   0 1.0 ])
  
  
  
 
 
 
 
 
 
 


