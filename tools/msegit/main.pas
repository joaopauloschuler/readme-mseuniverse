{ MSEgit Copyright (c) 2011-2017 by Martin Schreiber
   
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
unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msedock,
 msedockpanelform,msestrings,msestatfile,mseact,mseactions,mseifiglob,msebitmap,
 msedataedits,mseedit,msetypes,msegraphedits,msesplitter,msedispwidgets,
 msetimer,mserichstring,msesimplewidgets,msewidgets,msegrids,mseifigui,
 mseifilink,finddialogform;
const
 versiontext = '2.8.1';
type
 tmainfo = class(tmainform)
   dockpanel: tdockpanel;
   mainmen: tmainmenu;
   panelcontroller: tdockpanelformcontroller;
   formsta: tstatfile;
   mainfosta: tstatfile;
   repoloadedact: taction;
   repoclosedact: taction;
   reloadact: taction;
   commitmergeact: taction;
   resetmergeact: taction;
   fetchfromremoteact: taction;
   pullfromact: taction;
   mergefromact: taction;
   pushtoact: taction;
   objectrefreshtimer: ttimer;
   diffrefreshtimer: ttimer;
   commitallact: taction;
   stashsaveact: taction;
   stashpopact: taction;
   pushact: taction;
   pullact: taction;
   mergeact: taction;
   rebasefromact: taction;
   rebasecontinueact: taction;
   rebaseabortact: taction;
   rebaseskipact: taction;
   fetchact: taction;
   fetchallact: taction;
   tlayouter1: tlayouter;
   statdisp: trichstringdisp;
   waiticon: ticon;
   iconimage: timagelist;
   editlogfilter: tifidialog;
   rebaseact: taction;
   procedure newpanelexe(const sender: TObject);
   procedure showdirtreeexe(const sender: TObject);
   procedure showuntrackedexe(const sender: TObject);
   procedure formstaafterreadexe(const sender: TObject);
   procedure repoloadedexe(const sender: TObject);
   procedure repoclosedexe(const sender: TObject);
   procedure optionsexe(const sender: TObject);
   procedure showfilesexe(const sender: TObject);
   procedure reloadeexe(const sender: TObject);
   procedure showignoredexe(const sender: TObject);
   procedure showremotesexe(const sender: TObject);
   procedure gitconsoleshowexe(const sender: TObject);
   procedure closerepoexe(const sender: TObject);
   procedure showdiffexe(const sender: TObject);
   procedure commitmergeexe(const sender: TObject);
   procedure resetmergeexe(const sender: TObject);
   procedure fetchfromremoteexe(const sender: TObject);
   procedure pullfromexe(const sender: TObject);
   procedure mergefromexe(const sender: TObject);
   procedure pustohexe(const sender: TObject);
   procedure pushupdateexe(const sender: tcustomaction);
//   procedure branchcheckoutexe(const sender: TObject; var accept: Boolean);
   procedure showbranchexe(const sender: TObject);
   procedure objectrefreshtiexe(const sender: TObject);
   procedure showlogexe(const sender: TObject);
   procedure difrefreshtiexe(const sender: TObject);
   procedure commitallexe(const sender: TObject);
   procedure aboutexe(const sender: TObject);
   procedure updatecaptionxe(const sender: tdockpanelformcontroller;
                   const apanel: tdockpanelform; var avalue: msestring);
   procedure showstashexe(const sender: TObject);
   procedure stashsaveexe(const sender: TObject);
   procedure stashpopexe(const sender: TObject);
   procedure pullactexe(const sender: TObject);
   procedure pushactexe(const sender: TObject);
   procedure fetchfrombranchexe(const sender: TObject);
   procedure mergetactexe(const sender: TObject);
   procedure rebaseexe(const sender: TObject);
   procedure rebasecontinueexe(const sender: TObject);
   procedure rebaseabortexe(const sender: TObject);
   procedure rebaseskipexe(const sender: TObject);
   procedure fetchexe(const sender: TObject);
   procedure fetchallexe(const sender: TObject);
   procedure showtagsexe(const sender: TObject);
   procedure getlogfilteredit(const sender: TObject;
                   var adialogclass: custommseformclassty);
   procedure rebaseactexe(const sender: TObject);
   procedure terminatequeryexe(var terminate: Boolean);
   procedure showcurrentcommitexe(const sender: TObject);
   procedure asyncev(const sender: TObject; var atag: Integer);
  private
   frefreshing: boolean;
   fbackgroundcount: integer;
  protected
   function fetchedtarget: msestring;
   procedure doreload;
  public
   hastagdialogstat: boolean;
   findinfo: findinfoty;
   procedure merge(const aref: msestring);
   procedure rebase(const aref: msestring);
   procedure checkout(const aref: msestring; const partial: boolean);
   procedure reload(const async: boolean = false);
   procedure refreshdiff;
   property refreshing: boolean read frefreshing;
   procedure updatestate(const message: msestring = '');
   procedure objchanged(const refreshlog: boolean);
   procedure diffchanged;
   procedure beginbackground;
   procedure endbackground;
 end;
var
 mainfo: tmainfo;

implementation

uses
 main_mfm,gitdirtreeform,mainmodule,optionsform,filesform,stashform,remotesform,
 gitconsole,diffwindow,sysutils,branchform,msegitcontroller,
 logform,msestringenter,tagsform,editlogfilterform,commitdispform;
const
 mergecolor = $ffb030;
 reloadtag = 1;
  
procedure tmainfo.newpanelexe(const sender: TObject);
begin
 with panelcontroller.newpanel do begin
  activate;
 end;
end;

procedure tmainfo.showdirtreeexe(const sender: TObject);
begin
 gitdirtreefo.activate;
end;

procedure tmainfo.showfilesexe(const sender: TObject);
begin
 filesfo.activate;
end;

procedure tmainfo.showstashexe(const sender: TObject);
begin
 stashfo.activate;
end;

procedure tmainfo.showbranchexe(const sender: TObject);
begin
 branchfo.activate;
end;

procedure tmainfo.showtagsexe(const sender: TObject);
begin
 tagsfo.activate;
end;

procedure tmainfo.showremotesexe(const sender: TObject);
begin
 remotesfo.activate;
end;

procedure tmainfo.showdiffexe(const sender: TObject);
begin
 diffwindowfo.activate;
end;

procedure tmainfo.showlogexe(const sender: TObject);
begin
 logfo.activate;
end;

procedure tmainfo.showcurrentcommitexe(const sender: TObject);
begin
 commitdispfo.activate();
end;

procedure tmainfo.gitconsoleshowexe(const sender: TObject);
begin
 gitconsolefo.activate;
end;

procedure tmainfo.showuntrackedexe(const sender: TObject);
begin
 mainmo.opt.showuntrackeditems:= tmenuitem(sender).checked;
 formstaafterreadexe(nil);
 reloadact.execute; 
end;

procedure tmainfo.showignoredexe(const sender: TObject);
begin
 mainmo.opt.showignoreditems:= tmenuitem(sender).checked;
 formstaafterreadexe(nil);
 reloadact.execute; 
end;

procedure tmainfo.formstaafterreadexe(const sender: TObject);
begin
 with mainmo.opt do begin
  mainmen.menu.itembynames(['view','untracked']).checked:= showuntrackeditems;
  mainmen.menu.itembynames(['view','ignored']).checked:= showignoreditems;
 end;
end;

procedure tmainfo.repoloadedexe(const sender: TObject);
begin
 caption:= 'MSEgit '+mainmo.repo;
 updatestate;
 if not refreshing then begin
  objchanged(false);
 end;
end;

procedure tmainfo.repoclosedexe(const sender: TObject);
begin
 if not frefreshing then begin
  caption:= 'MSEgit';
  gitconsolefo.clear;
  filesfo.clear;
  statdisp.value:= '';
  statdisp.hint:= '';
  statdisp.color:= cl_default;
  hastagdialogstat:= false;
  findinfo.text:= '';
 end;
end;

procedure tmainfo.optionsexe(const sender: TObject);
begin
 editoptions;
end;

procedure tmainfo.reloadeexe(const sender: TObject);
begin
 reload;
end;

procedure tmainfo.closerepoexe(const sender: TObject);
begin
 mainmo.repo:= '';
end;

procedure tmainfo.doreload;
begin
 filesfo.savestate;
 gitdirtreefo.savestate;
 tagsfo.savestate;
 if mainmo.isrepoloaded then begin
  mainmo.repostatf.writestat;
 end;
 try
  frefreshing:= true;
//  dirtreefo.grid.clear;
  mainmo.reload;
 finally
  frefreshing:= false;
  gitdirtreefo.restorestate;
  tagsfo.restorestate;
  filesfo.restorestate;
  branchfo.refresh;
  stashfo.refresh;
  objchanged(true);
 end;
end;

procedure tmainfo.reload(const async: boolean = false);
begin
 if async then begin
  asyncevent(reloadtag);
 end
 else begin
  doreload();
 end;
end;

procedure tmainfo.updatestate(const message: msestring = '');
var
 ar1: msestringarty;
 int1: integer;
 rstr1: richstringty;
 col1: colorty;
 mstr1: msestring;
begin
 with statdisp do begin
  color:= cl_default;
  value:= '';
  hint:= '';
  font.color:= cl_text;
 end;
 if message <> '' then begin
  with statdisp do begin
   value:= message;
   font.color:= cl_red;
  end;
 end
 else begin
  with mainmo do begin
   if isrepoloaded then begin
    if (mergehead <> '') then begin
     statdisp.color:= mergecolor;
     ar1:= breaklines(mergemessage);
     if high(ar1) >= 0 then begin
      statdisp.value:= ar1[0];
      if ar1[high(ar1)] = '' then begin
       setlength(ar1,high(ar1));
      end;
      int1:= 1;
      if (high(ar1) >= 1) and (ar1[1] = '') then begin
       inc(int1);
      end;
      if int1 <= high(ar1) then begin
       statdisp.hint:= concatstrings(copy(ar1,int1,bigint),lineend);
      end;
     end
     else begin
      if reverting then begin
       statdisp.value:= 'Reverting';
      end
      else begin
       statdisp.value:= 'Merging';
      end;
     end;
    end
    else begin
     col1:= cl_ltgreen;
     if rebasing then begin
      col1:= mergecolor;
      richconcat1(rstr1,'Rebasing ',[fs_bold]);
     end;
     if mainmo.dirtree.gitstatey * [gist_modified,gist_deleted] <> [] then begin
      col1:= cl_ltred;
     end
     else begin
      if mainmo.dirtree.gitstatex * [gist_modified,gist_added] <> [] then begin
       statdisp.font.color:=  cl_dkred;
      end;
     end;
     richconcat1(rstr1,'Branch: ',[fs_force]);
     richconcat1(rstr1,mainmo.activebranch,[fs_bold]);
     richconcat1(rstr1,' Log: ',[fs_force]);
     mstr1:= mainmo.repostat.logfiltercommit;
     if mstr1 <> '' then begin
      mstr1:= copy(mstr1,1,8);
     end
     else begin
      mstr1:= mainmo.repostat.activelogcommit(false);
      if (mstr1 = '') then begin
       mstr1:= 'HEAD';
      end;
     end;
     richconcat1(rstr1,mstr1,[fs_bold]);
     richconcat1(rstr1,' Remote: ',[fs_force]);
     richconcat1(rstr1,mainmo.remotetargetref,[fs_bold]);
     statdisp.richvalue:= rstr1;
     statdisp.color:= col1;
    end;
   end;
  end;
 end;
end;

procedure tmainfo.commitallexe(const sender: TObject);
begin
 if mainmo.commitall then begin
  reload;
 end;
end;

procedure tmainfo.commitmergeexe(const sender: TObject);
begin
 if mainmo.mergecommit then begin
  reload;
 end;
end;

procedure tmainfo.resetmergeexe(const sender: TObject);
begin
 if mainmo.reverting then begin
  if askconfirmation('Do you want to reset the revert operation?') then begin
   if mainmo.revertreset then begin
    reload;
   end;
  end;
 end
 else begin
  if mainmo.cherrypicking then begin
   if askconfirmation(
                'Do you want to reset the cherry-pick operation?') then begin
    if mainmo.cherrypickreset then begin
     reload;
    end;
   end;
  end
  else begin
   if askconfirmation('Do you want to reset the merge operation?') then begin
    if mainmo.mergereset then begin
     reload;
    end;
   end;
  end;
 end;
end;

procedure tmainfo.rebaseexe(const sender: TObject);
begin
 rebase(mainmo.repostat.activelogcommit(false));
end;

procedure tmainfo.rebasecontinueexe(const sender: TObject);
begin
// if askconfirmation('Do you want to continue the current rebase operation?') then begin
  if mainmo.rebasecontinue then begin
//   reload;
  end;
  reload;
// end;
end;

procedure tmainfo.rebaseskipexe(const sender: TObject);
begin
// if askconfirmation('Do you want to skip the current rebase operation?') then begin
  if mainmo.rebaseskip then begin
//   reload;
  end;
  reload;
// end;
end;

procedure tmainfo.rebaseabortexe(const sender: TObject);

begin
 if askconfirmation('Do you want to abort the rebase operation?') then begin
  if mainmo.rebaseabort then begin
   reload;
  end;
 end;
end;

procedure tmainfo.fetchexe(const sender: TObject);
begin
 with mainmo do begin
  if mainmo.fetch('','') then begin
   self.reload;
  end;
 end;
end;

procedure tmainfo.fetchallexe(const sender: TObject);
begin
 with mainmo do begin
  mainmo.fetchall;
  self.reload;
 end;
end;

procedure tmainfo.fetchfromremoteexe(const sender: TObject);
begin
 with mainmo do begin
  if mainmo.fetch(activeremote,'') then begin
   self.reload;
  end;
 end;
end;

procedure tmainfo.fetchfrombranchexe(const sender: TObject);
begin
 with mainmo do begin
  if mainmo.fetch(activeremote,activeremotebranch[activeremote]) then begin
   self.reload;
  end;
 end;
end;

procedure tmainfo.pullfromexe(const sender: TObject);
begin
 with mainmo do begin
  if askconfirmation('Do you want to fetch and merge data from '+
         remotetargetref+' to '+activebranch+'?') then begin
   pull(activeremote,mainmo.activeremotebranch[activeremote]);
   self.reload;
  end;
 end;
end;

procedure tmainfo.merge(const aref: msestring);
begin
 if askconfirmation('Do you want to merge "'+aref+'" to "'+
                             mainmo.activebranch+'"?')  then begin
  mainmo.merge(aref);
  reload;
 end;
end;

procedure tmainfo.rebase(const aref: msestring);
begin
 with mainmo do begin
  if repobase <> '' then begin
   showmessage('Rebase not possible in sub-directories.','ERROR');
  end
  else begin
   if askconfirmation('Do you want to rebase '+ activebranch +
                  ' from '+aref+'?') then begin
    rebase(aref);
    self.reload; //show possible merge conflict
   end;
  end;
 end;
end;

procedure tmainfo.checkout(const aref: msestring; const partial: boolean);
var
 bo1: boolean;
 mstr1: msestring;
begin
 if partial then begin
  mstr1:= 'files from '+aref;
 end
 else begin
  mstr1:= aref;
 end;
 if askconfirmation('Do you want to checkout ' + mstr1+'?') then begin
  if partial then begin
   bo1:= mainmo.checkout(aref,gitdirtreefo.currentitem,
                            filesfo.filelist.currentitems);
  end
  else begin
   bo1:= mainmo.checkout(aref);
   if bo1 then begin
    branchfo.checkoutcommit:= aref; 
   end;
  end;
  if bo1 then begin
   reload;
  end;
 end;
end;

procedure tmainfo.mergetactexe(const sender: TObject);
begin
 merge(fetchedtarget);
end;

procedure tmainfo.rebaseactexe(const sender: TObject);
begin
 rebase(fetchedtarget);
end;

procedure tmainfo.mergefromexe(const sender: TObject);
begin
 merge(mainmo.repostat.activelogcommit(false));
end;

procedure tmainfo.pustohexe(const sender: TObject);
begin
 with mainmo do begin
  if askconfirmation('Do you want to push '+activebranch+' to '+
        remotetargetref+'?') and 
        push(activeremote,activeremotebranch[activeremote]) then begin
   self.reload;
  end;
 end;
end;

procedure tmainfo.pullactexe(const sender: TObject);
begin
 if mainmo.pull('','') then begin
//  reload;
 end;
 reload;
end;

procedure tmainfo.pushactexe(const sender: TObject);
begin
 if mainmo.push('','') then begin
  reload;
 end;
end;

function tmainfo.fetchedtarget: msestring;
begin
 result:= mainmo.matchingremotebranch;
end;

procedure tmainfo.pushupdateexe(const sender: tcustomaction);
var
 bo1,bo2,bo3: boolean;
 mstr1,mstr2,mstr3: msestring;
begin
 bo1:= mainmo.isrepoloaded;
 bo2:= bo1 and not mainmo.merging and not mainmo.rebasing;
 bo3:= mainmo.remotetargetbranch <> '';
 mstr3:= fetchedtarget;
 mainmen.menu.itembynames(['file','close']).enabled:= bo1;
 commitallact.enabled:= bo1;
 mstr1:= mainmo.remotetargetref;
 mstr2:= mainmo.repostat.activelogcommit(false);
 pushact.enabled:= bo2;
 pushtoact.enabled:= bo2 and (mstr1 <> '') and bo3;
 pushtoact.caption:= '&Push to '+mstr1;
 fetchact.enabled:= bo1;
 fetchallact.enabled:= bo1;
 fetchfromremoteact.enabled:= bo1;
 fetchfromremoteact.caption:= '&Fetch from '+mainmo.activeremote;
 commitmergeact.enabled:= mainmo.merging;
 pullact.enabled:= bo2;
 pullfromact.enabled:= bo2 and (mstr1 <> '') and bo3;;
 pullfromact.caption:= 'P&ull from '+mstr1;
 mergeact.enabled:= bo2 and (mstr3 <> '') and (mstr3 <> mstr2);
 mergeact.caption:= 'Merge from '+mstr3;
 mergefromact.enabled:= bo2 and (mstr2 <> '') and
                                            (mstr2 <> mainmo.activebranch);
//                      (mainmo.activeremotebranch[mainmo.activeremote] <> '');
 mergefromact.caption:= 'Merge from '+mstr2;
 resetmergeact.enabled:= mainmo.merging;

 rebaseact.enabled:= mergeact.enabled;
 rebaseact.caption:= 'Rebase from '+mstr3;
 rebasefromact.enabled:= mergefromact.enabled;
 rebasefromact.caption:= 'Rebase from '+mstr2;
 rebasecontinueact.enabled:= mainmo.rebasing;
 rebaseskipact.enabled:= mainmo.rebasing;
 rebaseabortact.enabled:= mainmo.rebasing;
 
// resetmergeact.enabled:= bo1;
 stashsaveact.enabled:= bo1;
 stashpopact.enabled:= bo1 and (mainmo.stashes <> nil);
// mainmen.menu.itembynames(['git','branch']).enabled:= bo2;
end;

procedure tmainfo.objectrefreshtiexe(const sender: TObject);
begin
 logfo.refresh(gitdirtreefo.currentitem,filesfo.currentitem); 
 diffrefreshtimer.firependingandstop;
end;

procedure tmainfo.refreshdiff;
var
 int1: integer;
 ar1: integerarty;
 ar2: msestringarty;
begin
 commitdispfo.refresh();
 if logfo.visible then begin
//  objectrefreshtimer.firependingandstop;
  if logfo.diffmode.value = 1 then begin
   ar1:= logfo.grid.datacols.selectedrows;
   if ar1 <> nil then begin
    setlength(ar2,length(ar1));
    for int1:= 0 to high(ar1) do begin
     ar2[int1]:= logfo.commit[ar1[int1]];
    end;
    diffwindowfo.refresh(gitdirtreefo.currentitem,filesfo.currentitem,ar2); 
   end
   else begin
    diffwindowfo.clear;
   end;
  end
  else begin
   if (logfo.grid.row >= 0) then begin
    int1:= logfo.diffbase.checkedrow;
    if (int1 >= 0) then begin
     diffwindowfo.refresh(gitdirtreefo.currentitem,filesfo.currentitem,
                                   logfo.commit[int1],logfo.commit.value+'^'); 
    end
    else begin
     diffwindowfo.refresh(gitdirtreefo.currentitem,filesfo.currentitem,
                                   logfo.commit.value,''); 
    end;
   end
   else begin
    diffwindowfo.clear;
   end;
  end;
 end
 else begin
  diffwindowfo.refresh(gitdirtreefo.currentitem,filesfo.currentitem,'',''); 
 end;   
end;

procedure tmainfo.difrefreshtiexe(const sender: TObject);
begin
 if logfo.visible then begin
  objectrefreshtimer.firependingandstop;
 end;
 refreshdiff;
end;

procedure tmainfo.objchanged(const refreshlog: boolean);
begin
 if refreshlog then begin
  objectrefreshtimer.restart;
 end
 else begin
  diffrefreshtimer.restart;
 end;
 updatestate;
end;

procedure tmainfo.diffchanged;
begin
 diffrefreshtimer.restart;
end;

procedure tmainfo.aboutexe(const sender: TObject);
begin
 showmessage('MSEgit version: '+versiontext+c_linefeed+
             'MSEgui version: '+mseguiversiontext+c_linefeed+
             c_linefeed+
             copyrighttext+c_linefeed+
             'by Martin Schreiber'
             ,'About MSEgit');
end;

procedure tmainfo.updatecaptionxe(const sender: tdockpanelformcontroller;
               const apanel: tdockpanelform; var avalue: msestring);
begin
end;

procedure tmainfo.stashsaveexe(const sender: TObject);
var
 mstr1: msestring;
begin
 if askconfirmation('Do you want to save and reset local changes?')
       and (stringenter(mstr1,'Message','Stash') = mr_ok)
       and mainmo.stashsave(mstr1) then begin
  reload;
 end;
end;

procedure tmainfo.stashpopexe(const sender: TObject);
begin
 if askconfirmation('Do you want to restore "'+
                 mainmo.stashes[0].message+'"?') and mainmo.stashpop then begin
  reload;
 end;
end;

procedure tmainfo.beginbackground;
begin
 if fbackgroundcount = 0 then begin
  waiticon.width:= 16;
  waiticon.anim_enabled:= true;
 end;
 inc(fbackgroundcount);
end;

procedure tmainfo.endbackground;
begin
 dec(fbackgroundcount);
 if fbackgroundcount = 0 then begin
  waiticon.width:= 0;
  waiticon.anim_enabled:= false;
  waiticon.animrestart;
 end;
end;

procedure tmainfo.getlogfilteredit(const sender: TObject;
               var adialogclass: custommseformclassty);
begin
 adialogclass:= teditlogfilterfo;
end;

procedure tmainfo.terminatequeryexe(var terminate: Boolean);
begin
 mainmo.closerepo;
end;

procedure tmainfo.asyncev(const sender: TObject; var atag: Integer);
begin
 case atag of
  reloadtag: begin
   doreload();
  end;
 end;
end;

end.
