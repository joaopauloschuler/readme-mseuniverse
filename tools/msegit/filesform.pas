{ MSEgit Copyright (c) 2011-2012 by Martin Schreiber
   
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
unit filesform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msedock,msedataedits,
 mseedit,msegrids,mseifiglob,msestrings,msetypes,msewidgetgrid,msedatanodes,
 mselistbrowser,msegraphedits,mseact,mseactions,mainmodule,filelistframe,
 msetimer,mseificomp,mseificompglob;

type
 tfilesfo = class(tdockform)
   gridpopup: tpopupmenu;
   commitact: taction;
   addact: taction;
   filelist: tfilelistframefo;
   restoreact: taction;
   mergetoolact: taction;
   removeact: taction;
   deleteact: taction;
   commitstagedact: taction;
   renameact: taction;
   procedure udaterowvaluesexe(const sender: TObject; const aindex: Integer;
                   const aitem: tlistitem);
   procedure commitexe(const sender: TObject);
   procedure commitupdateexe(const sender: tcustomaction);
   procedure addupdateexe(const sender: tcustomaction);
   procedure addexe(const sender: TObject);
   procedure cellevexe(const sender: TObject; var info: celleventinfoty);
   procedure gridenterexe(const sender: TObject);
   procedure restoreupdateexe(const sender: tcustomaction);
   procedure restoreexe(const sender: TObject);
   procedure mergetoolexe(const sender: tcustomaction);
   procedure removeupdateexe(const sender: tcustomaction);
   procedure removeexe(const sender: TObject);
   procedure popupupdate(const sender: tcustommenu);
   procedure mergetoolonupdate(const sender: tcustomaction);
   procedure deleteexe(const sender: TObject);
   procedure deleteupdate(const sender: tcustomaction);
   procedure commitstagedexe(const sender: TObject);
   procedure renamexe(const sender: TObject);
   procedure renameupdate(const sender: tcustomaction);
  private
   fpath: filenamety;
   ffilebefore: msestring;
  public
   procedure loadfiles(const apath: filenamety);
   procedure synctodirtree(const apath: filenamety;
                                const refreshlog: boolean);
   function currentitem: tmsegitfileitem;
   function currentfilepath: filenamety;
   procedure savestate;
   procedure restorestate;
   procedure clear;
 end;

var
 filesfo: tfilesfo;
 
implementation
uses
 filesform_mfm,gitdirtreeform,msegitcontroller,msewidgets,mseformatstr,
 main,diffform;
 
{ tfilesfo }

procedure tfilesfo.loadfiles(const apath: filenamety);
var
 int1: integer;
begin
 fpath:= apath;
 if apath = '' then begin
  filelist.grid.clear;
 end
 else begin
  int1:= filelist.grid.row;
  filelist.fileitemed.itemlist.assign(listitemarty(mainmo.getfiles(apath)));
  filelist.grid.checksort;
  filelist.grid.row:= int1;
 end;
end;

procedure tfilesfo.synctodirtree(const apath: filenamety;
                                         const refreshlog: boolean);
begin
 loadfiles(mainmo.repo+'/'+apath);
 mainfo.objchanged(refreshlog);
end;

procedure tfilesfo.udaterowvaluesexe(const sender: TObject;
               const aindex: Integer; const aitem: tlistitem);
//var
// int1: integer;
begin
 with tmsegitfileitem(aitem) do begin
  filelist.filestate[aindex]:= imagenr;
  filelist.originstate[aindex]:= getoriginicon;
 end;
end;

procedure tfilesfo.commitexe(const sender: TObject);
begin
 if mainmo.commit(tgitdirtreenode(gitdirtreefo.treeed.item), 
        msegitfileitemarty(filelist.fileitemed.selecteditems),false) then begin
  activate;
 end;
end;

procedure tfilesfo.commitstagedexe(const sender: TObject);
begin
 if mainmo.commit(tgitdirtreenode(gitdirtreefo.treeed.item), 
        msegitfileitemarty(filelist.fileitemed.selecteditems),true) then begin
  activate;
 end;
end;

procedure tfilesfo.commitupdateexe(const sender: tcustomaction);
begin
 sender.enabled:= filelist.fileitemed.selecteditems <> nil;
// sender.enabled:=  mainmo.cancommit(
//                      msegitfileitemarty(filelist.fileitemed.selecteditems));
end;

procedure tfilesfo.addupdateexe(const sender: tcustomaction);
begin
 sender.enabled:=  mainmo.canadd(
                      msegitfileitemarty(filelist.fileitemed.selecteditems));
end;

procedure tfilesfo.addexe(const sender: TObject);
var
 ar1: msegitfileitemarty;
begin
 ar1:= msegitfileitemarty(filelist.fileitemed.selecteditems);
 if askconfirmation('Do you want to add '+inttostrmse(length(ar1))+ 
                        ' files?') then begin
  if mainmo.add(tgitdirtreenode(gitdirtreefo.treeed.item),ar1) then begin
   mainfo.reload();
  end;
 end;    
 activate;
end;

procedure tfilesfo.restoreupdateexe(const sender: tcustomaction);
begin
 sender.enabled:=  mainmo.canrevert(
                      msegitfileitemarty(filelist.fileitemed.selecteditems));
end;

procedure tfilesfo.restoreexe(const sender: TObject);
begin
 if mainmo.restore(tgitdirtreenode(gitdirtreefo.treeed.item),
             msegitfileitemarty(filelist.fileitemed.selecteditems)) then begin
  activate;
 end;
end;

procedure tfilesfo.removeupdateexe(const sender: tcustomaction);
begin
 sender.enabled:=  mainmo.canremove(
                      msegitfileitemarty(filelist.fileitemed.selecteditems));
end;

procedure tfilesfo.removeexe(const sender: TObject);
begin
 if mainmo.remove(tgitdirtreenode(gitdirtreefo.treeed.item),
             msegitfileitemarty(filelist.fileitemed.selecteditems)) then begin
  mainfo.reload(); //get new changed item
  activate;
 end;
end;

procedure tfilesfo.deleteupdate(const sender: tcustomaction);
begin
 sender.enabled:=  mainmo.candelete(
                      msegitfileitemarty(filelist.fileitemed.selecteditems));
end;

procedure tfilesfo.deleteexe(const sender: TObject);
begin
 if mainmo.delete(tgitdirtreenode(gitdirtreefo.treeed.item),
             msegitfileitemarty(filelist.fileitemed.selecteditems)) then begin
  mainfo.reload();
  activate;
 end;
end;

procedure tfilesfo.cellevexe(const sender: TObject; var info: celleventinfoty);
begin
 if isrowenter(info) or isrowexit(info,true) then begin
  mainfo.objchanged(true);
 end;
end;

function tfilesfo.currentitem: tmsegitfileitem;
begin
 result:= tmsegitfileitem(filelist.fileitemed.item);
 if not filelist.grid.datacols.hasselection then begin
  result:= nil;
 end;
end;

function tfilesfo.currentfilepath: filenamety;
var
 n1: tmsegitfileitem;
begin
 result:= '';
 n1:= currentitem;
 if n1 <> nil then begin
  result:= mainmo.getpath(gitdirtreefo.currentitem,n1.caption);
 end;
end;

procedure tfilesfo.gridenterexe(const sender: TObject);
begin
 gitdirtreefo.grid.datacols.clearselection;
 mainfo.objchanged(true);
end;

procedure tfilesfo.mergetoolexe(const sender: tcustomaction);
var
 ar1: filenamearty;
begin
 setlength(ar1,1);
 ar1[0]:= currentfilepath;
 if ar1[0] <> '' then begin
  if mainmo.mergetoolcall(ar1) then begin
   activate;
  end;
 end;
end;

procedure tfilesfo.savestate;
begin
 if filelist.grid.active then begin
  ffilebefore:= filelist.currentfile;
 end
 else begin
  ffilebefore:= '';
 end;
end;

procedure tfilesfo.restorestate;
begin
 filelist.grid.checksort;
 if ffilebefore = '' then begin
  filelist.grid.row:= invalidaxis;
 end
 else begin
  filelist.setcurrentfile(ffilebefore);
 end;
end;

procedure tfilesfo.popupupdate(const sender: tcustommenu);
begin
 //
end;

procedure tfilesfo.clear;
begin
 filelist.grid.clear;
end;

procedure tfilesfo.mergetoolonupdate(const sender: tcustomaction);
begin
 mergetoolact.enabled:= mainmo.canmergetool and (currentfilepath <> '');
end;

procedure tfilesfo.renamexe(const sender: TObject);
begin
 mainmo.rename(currentfilepath,currentitem);
end;

procedure tfilesfo.renameupdate(const sender: tcustomaction);
begin
 sender.enabled:= currentitem <> nil;
end;

end.
