{ MSEkicad Copyright (c) 2016-2017 by Martin Schreiber
   
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
unit docuseteditform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,
 recordnameeditform,mseact,msedataedits,msedbdialog,mseedit,mseificomp,
 mseificompglob,mseifiglob,msestatfile,msestream,msestrings,sysutils,
 msesplitter,mseprinter,mdb,msedbedit,msegraphedits,msegrids,mselookupbuffer,
 msescrollbar,msewidgetgrid,msedatanodes,mselistbrowser,mseactions,msebitmap,
 msefiledialog,msesys,msedragglob,msetabs,msedbdispwidgets;

type
 tdocuseteditfo = class(trecordnameeditfo)
   docudired: tdbfilenameedit;
   pageeditact: taction;
   ttabwidget1: ttabwidget;
   ttabpage1: ttabpage;
   grid: twidgetgrid;
   pked: tint64edit;
   pagekinded: tdropdownlistedit;
   titleed: tstringedit;
   docupageeditbu: tstockglyphdatabutton;
   ttabpage2: ttabpage;
   stripe5: tlayouter;
   fonted: tdbstringedit;
   fontheighted: tdbrealedit;
   stripe4: tlayouter;
   pagesizeed: tpagesizeselector;
   leftmarged: tdbrealedit;
   widthed: tdbrealedit;
   heighted: tdbrealedit;
   rightmarged: tdbrealedit;
   topmarged: tdbrealedit;
   bottommarged: tdbrealedit;
   stripe3: tlayouter;
   psfileed: tdbfilenameedit;
   pdffileed: tdbfilenameedit;
   stripe2a: tlayouter;
   commented: tdbmemodialogedit;
   procedure readonlychangeev(const sender: TObject; const avalue: Boolean);
   procedure datachaev(Sender: TObject; Field: TField);
   procedure editedev(const sender: TObject);
   procedure cellev(const sender: TObject; var info: celleventinfoty);
   procedure pageeditev(const sender: tcustomaction);
   procedure updatedataev(Sender: TObject);
 end;

implementation
uses
 docuseteditform_mfm,msesqldb,bommodule;
 
procedure tdocuseteditfo.readonlychangeev(const sender: TObject;
               const avalue: Boolean);
begin
 pagesizeed.readonly:= avalue;
 grid.datacols.readonly:= avalue;
 grid.norowedit:= avalue;
 if avalue then begin
  grid.removeappendedrow();
 end
 else begin
  grid.checkreautoappend();
 end;
end;

procedure tdocuseteditfo.datachaev(Sender: TObject; Field: TField);
begin
 pagesizeed.updatesize();
end;

procedure tdocuseteditfo.editedev(const sender: TObject);
begin
// if not bommo.docupagedso.refreshing then begin
 if not tmsesqlquery(dataso.dataset).controller.canceling then begin
  dataso.dataset.edit();
  dataso.dataset.modify(); //set modified flag
 end;
end;

procedure tdocuseteditfo.cellev(const sender: TObject;
               var info: celleventinfoty);
begin
 if iscellclick(info,[ccr_dblclick,ccr_nokeyreturn]) then begin
  pageeditact.execute();
 end;
end;

procedure tdocuseteditfo.pageeditev(const sender: tcustomaction);
begin
 dataso.dataset.checkbrowsemode();
 bommo.editdocupage(grid.row);
end;

procedure tdocuseteditfo.updatedataev(Sender: TObject);
begin
 grid.removeappendedrow();
end;

end.
