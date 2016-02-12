{ MSEtest Copyright (c) 2014 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit runform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,msestatfile,
 msedataedits,mseedit,msegrids,mseificomp,mseificompglob,mseifiglob,msestream,
 msestrings,msewidgetgrid,sysutils,mseterminal,mainmodule,msesimplewidgets,
 msesplitter,msepipestream,mseprocess,msedispwidgets,mserichstring,
 msegraphedits;
type
 runstatety = (rs_none,rs_compile,rs_test,rs_canceled);
 errorstatety = (ers_none,ers_ok,ers_error);
 
 trunfo = class(tmseform)
   tstatfile1: tstatfile;
   grid: twidgetgrid;
   term: tterminal;
   proc: tmseprocess;
   tlayouter2: tlayouter;
   tlayouter1: tlayouter;
   okbu: tbutton;
   cancelbu: tbutton;
   tlayouter3: tlayouter;
   nrdi: tintegerdisp;
   captiondi: tstringdisp;
   okdi: tintegerdisp;
   errordi: tintegerdisp;
   againbu: tbutton;
   totaldi: tintegerdisp;
   procedure procfinishedexe(const sender: TObject);
   procedure showexe(const sender: TObject);
   procedure cancelexe(const sender: TObject);
   procedure outputrx(const sender: tpipereader);
   procedure errorrx(const sender: tpipereader);
   procedure againexe(const sender: TObject);
   procedure errorchangeexe(const sender: TObject);
   procedure okchaexe(const sender: TObject);
   procedure sendtextexe(const sender: TObject; var atext: msestring;
                   var donotsend: Boolean);
  protected
   fstate: runstatety;
   ftestitem: ttestnode;
   fcurrenttest: ttestitem;
   ftestok: boolean;
   foutputbuffer: string;
   ferrorbuffer: string;
   procedure start();
   procedure docompile();
   procedure dotest();
   procedure dofinish(const ok: boolean);
  protected
   fstartwidget: twidget;
   procedure stop();
  public
//   constructor create(const atestitem: ttestnode);
   function runtest(const atestitem: ttestnode): teststatety;
 end;

procedure seterror(const adisp: twidget; const astate: errorstatety);
procedure seterror(const adisp: twidget; const aerror: boolean;
                   const startcommand: tdataedit = nil);
procedure seterror(const aexpected: tcustomstringedit; 
                   const aactual: tcustomstringedit;
                   const any: tcustombooleanedit;
                   const startcommand: tdataedit = nil);

implementation
uses
 runform_mfm,msesystypes,main;

procedure seterror(const adisp: twidget; const astate: errorstatety);
var
 co1: colorty;
begin
 case astate of
  ers_ok: begin
   co1:= cl_ltgreen;
  end;
  ers_error: begin
   co1:= cl_ltred;
  end;
  else begin
   co1:= cl_transparent;
  end;
 end;
 adisp.frame.colorclient:= co1;
end;


procedure seterror(const adisp: twidget; const aerror: boolean;
                                  const startcommand: tdataedit = nil);
begin
 if (startcommand <> nil) and startcommand.isnull then begin
  seterror(adisp,ers_none);
 end
 else begin
  if aerror then begin
   seterror(adisp,ers_error);
  end
  else begin
   seterror(adisp,ers_ok);
  end;
 end;
end;

procedure seterror(const aexpected: tcustomstringedit; 
                   const aactual: tcustomstringedit;
                   const any: tcustombooleanedit;
                   const startcommand: tdataedit = nil);
begin
 if any.value then begin
  seterror(aactual,ers_none);
 end
 else begin
  seterror(aactual,aexpected.value <> 
                removelineterminator(aactual.value),startcommand);
 end;
end;
 
{ trunfo }
{
constructor trunfo.create(const atestitem: ttestnode);
begin
 ftestitem:= atestitem;
 inherited create(nil);
end;
}
function trunfo.runtest(const atestitem: ttestnode): teststatety;
begin
 fstate:= rs_none;
 ftestitem:= atestitem;
 show(ml_application);
 case fstate of
  rs_canceled: begin
   result:= tes_canceled;
  end;
  rs_none: begin
   result:= tes_none;
  end;
  else begin
   if ftestok then begin
    result:= tes_ok;
   end
   else begin
    result:= tes_error;
   end;
  end;
 end;
end;

procedure trunfo.start;
begin
 ftestok:= true;
 fstartwidget:= window.focusedwidget;
 if fstartwidget = nil then begin
  fstartwidget:= okbu;
 end;
 cancelbu.enabled:= true;
 okbu.enabled:= false;
 againbu.enabled:= false;
 okdi.value:= 0;
 errordi.value:= 0;
 seterror(errordi,ers_none);
 if ftestitem is ttestitem then begin
  fcurrenttest:= ttestitem(ftestitem);
 end
 else begin
  fcurrenttest:= ftestitem.firsttestitem();
 end;
 if fcurrenttest <> nil then begin
  docompile();
 end
 else begin
  stop();
 end;
end;

procedure trunfo.docompile();
var
 mstr1: msestring;
begin
 grid.clear();
 fcurrenttest.inputerror:= false;
 captiondi.value:= fcurrenttest.caption;
 nrdi.value:= fcurrenttest.nr;
 fstate:= rs_compile;
 mstr1:= mainmo.expandmacros(fcurrenttest,fcurrenttest.compilecommand,
                                                         fn_compilecommand);
 if mstr1 <> '' then begin
  try
   term.execprog(mstr1,mainmo.expandmacros(fcurrenttest,
                           fcurrenttest.compiledirectory,fn_compiledirectory)); 
  except
   on e: exception do begin
    term.addline(msestring(e.message));
    procfinishedexe(nil);
   end;
  end;
 end
 else begin
  dotest();
 end;
end;

procedure trunfo.dotest();
var
 mstr1: msestring;
 int1: integer;
begin
 fstate:= rs_test;
 ferrorbuffer:= '';
 foutputbuffer:= '';
 with fcurrenttest do begin
  actualexitcode:= -1;
  actualoutput:= '';
  actualerror:= '';
 end;
 mstr1:= mainmo.expandmacros(fcurrenttest,fcurrenttest.runcommand,
                                                            fn_runcommand);
 if mstr1 <> '' then begin
  int1:= application.unlockall();
  try
   proc.active:= false;
   proc.commandline:= mstr1;
   proc.workingdirectory:=
            mainmo.expandmacros(fcurrenttest,fcurrenttest.rundirectory,
                                                            fn_rundirectory);
   try
    proc.active:= true;
   except
    on e: exception do begin
     fcurrenttest.actualerror:= msestring(e.message);
    end;
   end;
   if proc.lastprochandle = invalidprochandle then begin
    dofinish(false);
   end
   else begin
    if fcurrenttest.input <> '' then begin
     try
      proc.input.pipewriter.write(fcurrenttest.input+lineend);
     except
      fcurrenttest.inputerror:= true;
      proc.kill();
      dofinish(false);
     end;
    end;
   end;
  finally
   application.relockall(int1);
  end;
 end
 else begin
  with fcurrenttest do begin
   actualexitcode:= 0;
   actualoutput:= '';
   actualerror:= '';
  end;
  dofinish(true);
 end;
end;

procedure trunfo.dofinish(const ok: boolean);
begin
 ftestok:= ftestok and ok;
 if fstate = rs_canceled then begin
  fcurrenttest.setteststate(tes_none);
  stop();
 end
 else begin
  if ok then begin
   fcurrenttest.setteststate(tes_ok);
   okdi.value:= okdi.value+1;
  end
  else begin
   fcurrenttest.setteststate(tes_error);
   errordi.value:= errordi.value+1;
  end;
  if (ftestitem = fcurrenttest) or 
            (not ok and mainmo.stoponfirsterr.checked) then begin //single
   stop();
  end
  else begin
   fcurrenttest:= fcurrenttest.nexttestitem(ftestitem);
   if fcurrenttest = nil then begin
    stop();
   end
   else begin
    docompile();
   end;   
  end;
 end;
end;

procedure trunfo.stop();
var
 n1: ttestnode;
begin
 cancelbu.enabled:= false;
 okbu.enabled:= true;
 againbu.enabled:= true;
// fstartwidget.setfocus();
 if fstate = rs_canceled then begin
  n1:= mainmo.findnumber(fcurrenttest.nr);
  if n1 <> nil then begin
   n1.expandtoroot;
   mainfo.grid.row:= n1.index;
  end;
  term.addline('***CANCELED***');
 end
 else begin
  seterror(errordi,errordi.value <> 0);
  if errordi.value <> 0 then begin
   term.addline('***ERROR***');
  end
  else begin
   term.addline('***OK***');
  end;
 end;
end;

procedure trunfo.procfinishedexe(const sender: TObject);
var
 rea1: realty;
begin
 case fstate of
  rs_compile: begin
   fcurrenttest.compileresult:= term.exitcode();
   if fcurrenttest.compileresult <> 0 then begin
    if (mainmo.stoponcomperr.checked) or 
                          (mainmo.stoponfirsterr.checked) then begin
     cancelexe(nil);
    end
    else begin
     dofinish(false);
    end;
   end
   else begin
    dotest();
   end;
  end;
  rs_test: begin
   with fcurrenttest do begin
    actualexitcode:= proc.exitcode;
    actualoutput:= removelineterminator(utf8tostring(foutputbuffer));
    foutputbuffer:= '';
    actualerror:= removelineterminator(utf8tostring(ferrorbuffer));
    ferrorbuffer:= '';
    rea1:= lookupexpectedexitcode(fcurrenttest);
    dofinish(((rea1 = emptyreal) or (actualexitcode = rea1)) and 
       (anyoutput or (actualoutput = expectedoutput)) and
       (anyerror or (actualerror = expectederror)));
   end;
  end;
  else begin
   dofinish(false);
  end;
 end;
end;

procedure trunfo.showexe(const sender: TObject);
begin
 if fstate = rs_none then begin
  start();
 end;
end;

procedure trunfo.cancelexe(const sender: TObject);
begin
 case fstate of
  rs_compile: begin
   fstate:= rs_canceled;
   term.killprocess();
   term.waitforprocess();
  end;
  rs_test: begin
   fstate:= rs_canceled;
   proc.kill();
   proc.waitforprocess();
  end;
 end;
end;

procedure trunfo.againexe(const sender: TObject);
begin
 start();
end;

procedure trunfo.outputrx(const sender: tpipereader);
begin
 foutputbuffer:= foutputbuffer+sender.readdatastring();
end;

procedure trunfo.errorrx(const sender: tpipereader);
begin
 ferrorbuffer:= ferrorbuffer+sender.readdatastring();
end;

procedure trunfo.errorchangeexe(const sender: TObject);
begin
 seterror(twidget(sender),errordi.value <> 0);
 totaldi.value:= okdi.value + errordi.value;
end;

procedure trunfo.okchaexe(const sender: TObject);
begin
 totaldi.value:= okdi.value + errordi.value;
end;

procedure trunfo.sendtextexe(const sender: TObject; var atext: msestring;
               var donotsend: Boolean);
begin
 if okbu.enabled then begin
  donotsend:= true;
  window.modalresult:= mr_ok;
 end;
end;

end.
