{ MSEgit Copyright (c) 2011-2015 by Martin Schreiber
   
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
unit optionsform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msesimplewidgets,
 msewidgets,msescrollbar,msetabs,sysutils,msestatfile,msebitmap,msedataedits,
 msedatanodes,mseedit,msefiledialog,msegrids,mseifiglob,mselistbrowser,
 msestrings,msesys,msetypes,msegraphedits,msesplitter,mseificomp,mseificompglob,
 msestream;

type
 toptionsfo = class(tmseform)
   ttabwidget1: ttabwidget;
   ttabpage1: ttabpage;
   tstatfile1: tstatfile;
   gitcommand: tfilenameedit;
   patchtool: thistoryedit;
   repostatfilename: tstringedit;
   texpandingwidget1: tlayouter;
   mergetool: thistoryedit;
   difftool: thistoryedit;
   showutc: tbooleanedit;
   dateformat: tstringedit;
   texpandingwidget2: tlayouter;
   diffencoding: tenumtypeedit;
   diffcontextn: tintegeredit;
   splitdiffs: tbooleanedit;
   maxlog: tintegeredit;
   tspacer2: tspacer;
   texpandingwidget3: tlayouter;
   maxdiffsize: tintegeredit;
   maxdiffcount: tintegeredit;
   tspacer3: tspacer;
   tspacer4: tspacer;
   tbutton1: tbutton;
   tspacer1: tspacer;
   tbutton2: tbutton;
   tspacer5: tspacer;
   autoadd: tbooleanedit;
   procedure repostafnasetexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure diffencinitexe(const sender: tenumtypeedit);
   procedure showdatetimehintexe(const sender: TObject; var info: hintinfoty);
   procedure tablayoutev(const sender: TObject);
 end;

procedure editoptions;

implementation
uses
 optionsform_mfm,mserttistat,mainmodule,mseformatstr,msedate;
 
procedure editoptions;
var
 fo1: toptionsfo;
begin
 fo1:= toptionsfo.create(nil);
 mainmo.optionsobj.objtovalues(fo1);
 if fo1.show(ml_application) = mr_ok then begin
  mainmo.optionsobj.valuestoobj(fo1);
  mainmo.git.resetversioncheck;
 end;
end;

procedure toptionsfo.repostafnasetexe(const sender: TObject;
               var avalue: msestring; var accept: Boolean);
begin
 if avalue = '' then begin
  avalue:= defaultrepostatfilename;
 end;
end;

procedure toptionsfo.diffencinitexe(const sender: tenumtypeedit);
begin
 sender.typeinfopo:= typeinfo(charencodingty);
end;

procedure toptionsfo.showdatetimehintexe(const sender: TObject;
               var info: hintinfoty);
begin
 info.caption:= dateformat.text+lineend;
 if showutc.value then begin
  info.caption:= info.caption + formatdatetimemse(dateformat.text,nowutc);
 end
 else begin
  info.caption:= info.caption + formatdatetimemse(dateformat.text,nowlocal);
 end;
end;

procedure toptionsfo.tablayoutev(const sender: TObject);
begin
 aligny(wam_center,[dateformat,maxlog,maxdiffcount]);
 aligny(wam_center,[showutc,splitdiffs,maxdiffsize]);
 aligny(wam_center,[difftool,diffcontextn,autoadd]);
 aligny(wam_center,[mergetool,diffencoding]);
end;

end.
