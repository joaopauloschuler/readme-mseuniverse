unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,
 mseassistiveserver,mseassistiveclient,msegrids,msestrings,msesimplewidgets,
 msedataedits,mseedit,mseificomp,mseificompglob,mseifiglob,msestatfile,
 msestream,sysutils,mseact,msegraphedits,msescrollbar,msetoolbar,msemenuwidgets,
 msebitmap,mseshapes,msewidgetgrid,msedispwidgets,mserichstring,mseeditglob,
 msetextedit;

type
 tassistivemonitor = class(tobject,iassistiveserver)
  private
   fgrid: tstringgrid;
  protected
   procedure track(const prefix: msestring; const sender: iassistiveclient; 
                                                   const atext: msestring);
   procedure track(const prefix: msestring; const sender: tobject; 
                                                     const atext: msestring);
    //iassistiveserver
   procedure doenter(const sender: iassistiveclient);
   procedure doitementer(const sender: iassistiveclient; //sender can be nil
                            const items: shapeinfoarty; const aindex: integer);
   procedure doitementer(const sender: iassistiveclient;
                         const items: menucellinfoarty; const aindex: integer);
   procedure clientmouseevent(const sender: iassistiveclient;
                                           const info: mouseeventinfoty);
   procedure dofocuschanged(const oldwidget,newwidget: iassistiveclient);
   procedure dokeydown(const sender: iassistiveclient;
                                        const info: keyeventinfoty);
   procedure doactionexecute(const sender: tobject; const info: actioninfoty);
   procedure dochange(const sender: iassistiveclient);
   procedure docellevent(const sender: iassistiveclientgrid;
                                      const info: celleventinfoty);
  public
   constructor create(const agrid: tstringgrid);
   destructor destroy(); override;
 end;
 
 tmainfo = class(tmainform)
   stringgrid: tstringgrid;
   tbutton1: tbutton;
   tbutton2: tbutton;
   tstringedit1: tstringedit;
   tstringedit2: tstringedit;
   tbooleanedit1: tbooleanedit;
   tslider1: tslider;
   ttoolbar1: ttoolbar;
   tmainmenuwidget1: tmainmenuwidget;
   tfacecomp1: tfacecomp;
   tframecomp1: tframecomp;
   tframecomp2: tframecomp;
   tfacecomp2: tfacecomp;
   timagelist1: timagelist;
   tstringgrid1: tstringgrid;
   widgetgrid: twidgetgrid;
   tstringedit3: tstringedit;
   tintegeredit1: tintegeredit;
   tstatfile1: tstatfile;
   assistivecaption: tstringdisp;
   assistivetext: tstringdisp;
   assistivename: tstringdisp;
   ttextedit1: ttextedit;
   procedure createexe(const sender: TObject);
   procedure destroyexe(const sender: TObject);
   procedure exe(const sender: TObject);
   procedure exitexe(const sender: TObject);
  private
   fmonitor: tassistivemonitor;
  public
   procedure showvalues(const sender: iassistiveclient);
   procedure showtext(const atext: msestring);
 end;
 
var
 mainfo: tmainfo;

implementation
uses
 main_mfm,typinfo,mclasses,mseactions,mseformatstr,msegridsglob;

function getname(const sender: iassistiveclient): msestring;
begin
 if sender = nil then begin
  result:= 'NIL';
 end
 else begin
  result:= sender.getassistivename;
 end;
end;
 
{ tassistivemonitor }

constructor tassistivemonitor.create(const agrid: tstringgrid);
begin
 fgrid:= agrid;
 assistiveserver:= iassistiveserver(self);
end;

destructor tassistivemonitor.destroy();
begin
 assistiveserver:= nil;
 fgrid.free();
end;

procedure tassistivemonitor.track(const prefix: msestring; 
                       const sender: iassistiveclient; const atext: msestring);
var
 mstr1: msestring;
// inst1: tobject;               
begin
 if (sender = nil) or (sender.getinstance <> fgrid) then begin
  mstr1:= '<'+getname(sender)+'> ';
  fgrid.appendrow(prefix+mstr1+atext);
  fgrid.showlastrow();
 end;
end;

procedure tassistivemonitor.track(const prefix: msestring;
                                const sender: tobject; const atext: msestring);
var
 intf1: iassistiveclient;
 mstr1: msestring;
begin
 if getcorbainterface(sender,typeinfo(iassistiveclient),intf1) then begin
  track(prefix,intf1,atext);
 end
 else begin
  mstr1:= '';
  if sender is tcomponent then begin
   mstr1:= msestring(tcomponent(sender).name+' ');
  end;
  track(prefix,iassistiveclient(nil),mstr1+atext);
 end;
end;

procedure tassistivemonitor.doenter(const sender: iassistiveclient);
begin
 track('<doenter>',sender,'');
 mainfo.showvalues(sender);
end;

procedure tassistivemonitor.doitementer(const sender: iassistiveclient;
               const items: shapeinfoarty; const aindex: integer);
begin
 track('<doitementer shape>',sender,inttostrmse(aindex));
 mainfo.showvalues(sender);
end;

procedure tassistivemonitor.doitementer(const sender: iassistiveclient;
                        const items: menucellinfoarty; const aindex: integer);
begin
 track('<doitementer menu>',sender,inttostrmse(aindex));
 mainfo.showvalues(sender);
end;

procedure tassistivemonitor.clientmouseevent(const sender: iassistiveclient;
               const info: mouseeventinfoty);
begin
 track('<clientmouseevent '+msestring(getenumname(typeinfo(eventkindty),
                       ord(info.eventkind)))+'>',sender,'');
end;

procedure tassistivemonitor.dofocuschanged(const oldwidget: iassistiveclient;
               const newwidget: iassistiveclient);
begin
 track('<dofocuschanged '+getname(newwidget)+'>',oldwidget,'');
end;

procedure tassistivemonitor.dokeydown(const sender: iassistiveclient;
               const info: keyeventinfoty);
begin
 with info do begin
  track('<dokeydown '+
 //          getenumname(typeinfo(eventkindty),ord(info.eventkind)) + ' ' +
           getshortcutname(shortcutty(key)) + ' "'+chars + '" ' +
   msestring(settostring(ptypeinfo(typeinfo(shiftstate)),
                               int32(shiftstate),true) + ' ' +
   settostring(ptypeinfo(typeinfo(eventstate)),
                               int32(eventstate),true) + '>'),sender,'');
 end;
end;

procedure tassistivemonitor.doactionexecute(const sender: tobject;
               const info: actioninfoty);
begin
 track('<doactionexecute>',sender,'');
end;

procedure tassistivemonitor.dochange(const sender: iassistiveclient);
begin
 track('<dochange>',sender,'');
end;

procedure tassistivemonitor.docellevent(const sender: iassistiveclientgrid;
               const info: celleventinfoty);
begin
 track('<docellevent>',sender,msestring(getenumname(typeinfo(info.eventkind),
           int32(info.eventkind)))+' col:'+inttostrmse(info.cell.col)+
                                 ' row:'+inttostrmse(info.cell.row));
 if info.eventkind = cek_enter then begin
  mainfo.showtext(sender.getassistivecelltext(info.cell));
 end;
end;

{ tmainfo }

procedure tmainfo.createexe(const sender: TObject);
begin
 fmonitor:= tassistivemonitor.create(stringgrid);
end;

procedure tmainfo.destroyexe(const sender: TObject);
begin
 fmonitor.free();
end;

procedure tmainfo.exe(const sender: TObject);
begin
 guibeep();
end;

procedure tmainfo.exitexe(const sender: TObject);
begin
 application.terminated:= true;
end;

procedure tmainfo.showvalues(const sender: iassistiveclient);
begin
 assistivename.value:= sender.getassistivename();
 assistivecaption.value:= sender.getassistivecaption();
 assistivetext.value:= sender.getassistivetext();
end;

procedure tmainfo.showtext(const atext: msestring);
begin
 assistivename.value:= '';
 assistivecaption.value:= '';
 assistivetext.value:= atext;
end;

end.
