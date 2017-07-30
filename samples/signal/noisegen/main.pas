unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,mseaudio,
 msestrings,msesignal,msesigaudio,msesignoise,msechartedit,msedataedits,mseedit,
 mseificomp,mseificompglob,mseifiglob,msesiggui,msestatfile,msesigfft,
 msesigfftgui,msegraphedits,msescrollbar,msedispwidgets,mserichstring,
 msesplitter,msesimplewidgets,msefilter,mseact,msestream,sysutils;

type
 tmainfo = class(tmainform)
   cont: tsigcontroller;
   out: tsigoutaudio;
   noise: tsignoise;
   sta: tstatfile;
   tlayouter1: tlayouter;
   average: tbooleanedit;
   tlayouter2: tlayouter;
   tsplitter1: tsplitter;
   fft: tsigscopefft;
   scope: tsigscope;
   sampcount: tslider;
   tsigslider1: tsigslider;
   kinded: tenumtypeedit;
   averagecount: tintegerdisp;
   sampcountdi: tintegerdisp;
   tsimplewidget1: tsimplewidget;
   procedure onclosexe(const sender: TObject);
   procedure samcountsetexe(const sender: TObject; var avalue: realty;
                   var accept: Boolean);
   procedure typinitexe(const sender: tenumtypeedit);
   procedure kindsetexe(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure averagesetev(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
   procedure buffullev(const sender: tsigsampler;
                   const abuffer: samplerbufferty);
 end;
var
 mainfo: tmainfo;
implementation
uses
 main_mfm,defaultskin;

procedure tmainfo.onclosexe(const sender: TObject);
begin
 out.audio.active:= false;
end;

procedure tmainfo.samcountsetexe(const sender: TObject; var avalue: realty;
               var accept: Boolean);
begin
 noise.samplecount:= round(19*avalue)+1;
 sampcountdi.value:= noise.samplecount;
end;

procedure tmainfo.typinitexe(const sender: tenumtypeedit);
begin
 sender.typeinfopo:= typeinfo(noisekindty);
end;

procedure tmainfo.kindsetexe(const sender: TObject; var avalue: Integer;
               var accept: Boolean);
begin
 noise.kind:= noisekindty(avalue);
end;

procedure tmainfo.averagesetev(const sender: TObject; var avalue: Boolean;
               var accept: Boolean);
begin
 if avalue then begin
  fft.sampler.options:= fft.sampler.options + [sso_average];
 end
 else begin
  fft.sampler.options:= fft.sampler.options - [sso_average];
 end;
end;

procedure tmainfo.buffullev(const sender: tsigsampler;
               const abuffer: samplerbufferty);
begin
 sender.lockapplication();
 averagecount.value:= tsigsamplerfft(sender).averagecount;
 sender.unlockapplication();
end;

end.
