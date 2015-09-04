{ MSEspice Copyright (c) 2012-2013 by Martin Schreiber
   
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
unit plotpage;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msetabs,msedataedits,
 mseedit,mseifiglob,msestrings,msetypes,msewidgets,classes,mclasses,plotoptions,
 msesplitter,msegrids,msewidgetgrid,msegraphedits,msesimplewidgets,
 mselistbrowser,msedatanodes,msememodialog,msengspice,chartform,mseact,
 mseactions,msescrollbar,msestatfile,msestream,sysutils,spicetabform,
 msedispwidgets,mserichstring,msetimer;
 
type

 tplotnode = class(ttreelistedititem)
  private
   fvalue0: msestring;
   fvalue1: msestring;
   fvalue2: msestring;
   fkey: integer;
   procedure setvalue0(const avalue: msestring); virtual;
   procedure setvalue1(const avalue: msestring);
   procedure setvalue2(const avalue: msestring);
  protected
   property value0: msestring read fvalue0 write setvalue0;
   property value1: msestring read fvalue1 write setvalue1;
   property value2: msestring read fvalue2 write setvalue2;
  public
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
   procedure showchart; virtual;
 end;
 
 tchartnode = class(tplotnode)
  private
   fchart: tchartfo;
  protected
   procedure setvalue0(const avalue: msestring); override;
   function createsubnode: ttreelistitem; override;
   procedure setcaption(const avalue: msestring); override;
   function defaulttracecaption: msestring;
  public
   constructor create(const aowner: tcustomitemlist = nil;
              const aparent: ttreelistitem = nil); override;
   destructor destroy; override;
   procedure newtrace(const aindex: integer);
   procedure dostatread(const reader: tstatreader); override;
   procedure showchart; override;
   function getsavevalues: msestringarty;
   property chart: tchartfo read fchart;
   procedure loaddata(const adata: plotinfoty; const xexpression: msestring;
                       const stepping: boolean; var destindex: integerarty);
   property title: msestring read fvalue0;
 end;

 chartnodearty = array of tchartnode;

 ttracenode = class(tplotnode)
  private
//   fexpression: msestring;
   fxvaluekind: valuekindty;
   fyexpression: msestring;
   fyvaluekind: valuekindty;
  protected
  public
   constructor create(const acaption: msestring);
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
   procedure showchart; override;
   property xexpression: msestring read fvalue0 write fvalue0;
   property xvaluekind: valuekindty read fxvaluekind write fxvaluekind 
                                                        default vk_def;
   property yexpression: msestring read fyexpression write fyexpression;
   property yvaluekind: valuekindty read fyvaluekind write fyvaluekind 
                                                        default vk_def;
 end;
 
 tplotpagefo = class(tspicetabfo)
   plotname: tstringedit;
   plotkind: tenumedit;
   plotactive: tbooleanedit;
   gridpopup: tpopupmenu;
   showchartoptact: taction;
   showchartact: taction;
   ttabwidget1: ttabwidget;
   ttabpage1: ttabpage;
   tracegrid: twidgetgrid;
   treeed: ttreeitemedit;
   value0: tmemodialogedit;
   xvaluekind: tenumedit;
   yexpression: tmemodialogedit;
   yvaluekind: tenumedit;
   plotcont: tspacer;
   ttabpage2: ttabpage;
   stepactive: tbooleanedit;
   stepgrid: twidgetgrid;
   stepdest: tmemodialogedit;
   stepstart: trealedit;
   stepstop: trealedit;
   stepcount: tintegeredit;
   stepkind: tenumedit;
   stepsigma: trealedit;
   ttabpage3: ttabpage;
   savegrid: twidgetgrid;
   savevector: tstringedit;
   procedure setnameexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure kindsetexe(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure createitemexe(const sender: tcustomitemlist;
                   var item: ttreelistedititem);
   procedure updaterowvalueexe(const sender: TObject; const aindex: Integer;
                   const aitem: tlistitem);
   procedure value0setexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure celleventexe(const sender: TObject; var info: celleventinfoty);
   procedure rowinsertexe(const sender: tcustomgrid; var aindex: Integer;
                   var acount: Integer);
   procedure rowdeleteexe(const sender: tcustomgrid; var aindex: Integer;
                   var acount: Integer);
   procedure rowmoveexe(const sender: tcustomgrid; var fromindex: Integer;
                   var toindex: Integer; var acount: Integer);
   procedure xvaluekindsetexe(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure yexpressionsetexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure yvaluekindsetexe(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure showchartoptexe(const sender: TObject);
   procedure showchartexe(const sender: TObject);
   procedure udateshowexe(const sender: tcustomaction);
   procedure stepkindsetexe(const sender: TObject; var avalue: Integer;
                   var accept: Boolean);
   procedure stepstartsetexe(const sender: TObject; var avalue: realty;
                   var accept: Boolean);
   procedure stepstopsetexe(const sender: TObject; var avalue: realty;
                   var accept: Boolean);
   procedure plotrowinsertedexe(const sender: tcustomgrid;
                   const aindex: Integer; const acount: Integer);
   procedure yunitsetexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure xunitsetexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure datamodifiedexe(const sender: TObject);
   procedure createexe(const sender: TObject);
   private
   fplot: tplotoptionsfo;
   fnameindex: integer;
   fexpressions: msestringarty;
  protected
   procedure setkind(const akind: integer);
   function getchartname: string;
  public
   constructor create(const aowner: tcomponent; const akind: integer);
   function kind: plotkindty;
   function getplotstatement: string;
   function chartnodes: chartnodearty;
   function exptag(const aindex: integer): string;
   function exptags: stringarty;
   procedure resetnameindex;
   procedure updatechartsettings;
   property plot: tplotoptionsfo read fplot;
   property expressions: msestringarty read fexpressions;
 end;
 
implementation
uses
 plotpage_mfm,dcplot,acplot,transplot,mseeditglob,msechart,plotsform,
 msearrayutils,mainmodule;

const
 plotclasses: array[plotkindty] of plotsfoclassty = (
  tdcplotfo,tacplotfo,ttransplotfo);

function getplotclass(const akind: integer): plotsfoclassty;
begin
 if (akind < 0) or (akind > ord(high(plotclasses))) then begin
  result:= nil;
 end
 else begin
  result:= plotclasses[plotkindty(akind)];
 end;
end;

function getplotkind(const aclass: tplotoptionsfo): plotkindty;
var
 kind1: plotkindty;
 po1: pointer;
begin
 result:= plotkindty(-1);
 if aclass <> nil then begin
  po1:= aclass.classtype;
  for kind1:= low(plotclasses) to high(plotclasses) do begin
   if plotclasses[kind1] = plotsfoclassty(po1) then begin
    result:= kind1;
    break;
   end;
  end;
 end;
end;

{ tplotnode }

procedure tplotnode.dostatread(const reader: tstatreader);
begin
 inherited;
 fvalue0:= reader.readmsestring('value0',fvalue0);
 fvalue1:= reader.readmsestring('value1',fvalue1);
 fvalue2:= reader.readmsestring('value2',fvalue2);
 fkey:= reader.readinteger('key',fkey);
end;

procedure tplotnode.dostatwrite(const writer: tstatwriter);
begin
 inherited;
 writer.writemsestring('value0',fvalue0);
 writer.writemsestring('value1',fvalue1);
 writer.writemsestring('value2',fvalue2);
 writer.writeinteger('key',fkey);
end;

procedure tplotnode.showchart;
begin
 //dummy
end;

procedure tplotnode.setvalue0(const avalue: msestring);
begin
 fvalue0:= avalue;
 mainmo.projectmodified;
end;

procedure tplotnode.setvalue1(const avalue: msestring);
begin
 fvalue1:= avalue;
 mainmo.projectmodified;
 tchartnode(parent).chart.updatechart;
end;

procedure tplotnode.setvalue2(const avalue: msestring);
begin
 fvalue2:= avalue;
 mainmo.projectmodified;
 tchartnode(parent).chart.updatechart;
end;

{ tchartnode }

constructor tchartnode.create(const aowner: tcustomitemlist = nil;
               const aparent: ttreelistitem = nil);
begin
 inherited;
 fchart:= tchartfo.create(nil,self);
 caption:= plotsfo.getchartcaption;
end;

destructor tchartnode.destroy;
begin
 freeandnil(fchart);
 inherited;
end;

function tchartnode.getsavevalues: msestringarty;
var
 int1: integer;
// ar1: msestringarty;
// mstr1: msestring;
begin
 setlength(result,2*count);
 for int1:= 0 to count - 1 do begin
  with ttracenode(fitems[int1]) do begin
   result[2*int1]:= unifyexpression(xexpression);
   result[2*int1+1]:= unifyexpression(yexpression);
  end;
 end;
end;

function tchartnode.createsubnode: ttreelistitem;
begin
 result:= ttracenode.create('');
end;

procedure tchartnode.showchart;
begin
 chart.activate;
end;

procedure tchartnode.loaddata(const adata: plotinfoty;
               const xexpression: msestring; const stepping: boolean;
               var destindex: integerarty);

 function getdata(const aexpression: msestring;
                            var akind: valuekindty): realarty;
 var
  int1: integer;
  mstr1: msestring;
 begin
  result:= nil;
  mstr1:= unifyexpression(aexpression);
  if mstr1 = '' then begin //scale
   result:= getplotvalues(adata,0,akind);
  end
  else begin
   with tplotpagefo(editwidget.owner) do begin
    for int1:= 0 to high(fexpressions) do begin
     if mstr1 = fexpressions[int1] then begin
      if int1 <= high(adata.vars) then begin
       result:= getplotvalues(adata,int1,akind);
      end;
      break;
     end;
    end;
   end;
  end;
 end; //getdata
 
var
 int1,int2,int3: integer;
 ar1: realarty;
 ar2: integerarty;
 found: booleanarty;
 kx,ky: valuekindty;
 mstr1: msestring;
begin
 with chart do begin
  if not stepping then begin
   setlength(destindex,count);
   setlength(found,optfo.tracesgrid.rowcount);
   for int1:= 0 to high(destindex) do begin
    int3:= ttracenode(fitems[int1]).fkey;
    destindex[int1]:= -1;
    for int2:= 0 to optfo.tracesgrid.rowhigh do begin
     if optfo.tracekey[int2] = int3 then begin
      destindex[int1]:= int2;
      found[int2]:= true;
      break;
     end;
    end;
   end;
   for int1:= 0 to high(destindex) do begin
    if destindex[int1] < 0 then begin
     for int2:= 0 to high(found) do begin
      if not found[int2] then begin
       found[int2]:= true;
       optfo.tracekey[int2]:= ttracenode(fitems[int1]).fkey;
       destindex[int1]:= int2;
       break;
      end;
     end;
     if destindex[int1] < 0 then begin
      found:= nil;
      optfo.tracesgrid.appendrow; 
      destindex[int1]:= optfo.tracesgrid.rowhigh;
      optfo.tracekey[destindex[int1]]:= ttracenode(fitems[int1]).fkey;
     end;
    end;
   end;
   for int1:= 0 to high(found) do begin
    if not found[int1] then begin
     optfo.tracesgrid.deleterow(int1);
     for int2:= 0 to high(destindex) do begin
      if destindex[int2] > int1 then begin
       dec(destindex[int2]);
      end;
     end;
    end;
   end;
  end;
//  optfo.tracesgrid.rowcount:= count;
  with chart do begin
   traces.count:= count;
   for int1:= 0 to count-1 do begin
    int2:= destindex[int1];
    if int1 >= high(adata.data) then begin
     clear;
     optfo.xexpdisp[int2]:= '';
     optfo.yexpdisp[int2]:= '';
    end
    else begin
     with traces[int2],ttracenode(items[int1]) do begin
      kind:= trk_xy;
      kx:= xvaluekind;
      ky:= yvaluekind;
      if stepping then begin
       options:= options - [cto_xordered];
       ar2:= breaks;
       ar1:= xdata;
       additem(ar2,length(ar1));
       breaks:= ar2;
       stackarray(getdata(xexpression,kx),ar1);
       xdata:= ar1;
       ar1:= ydata;
       stackarray(getdata(yexpression,ky),ar1);
       ydata:= ar1;
      end
      else begin
       breaks:= nil;
       options:= options + [cto_xordered];
       xdata:= getdata(xexpression,kx);
       ydata:= getdata(yexpression,ky);
      end;
      if xexpression = '' then begin
       mstr1:= adata.vars[0].expression;
      end
      else begin
       mstr1:= xexpression;
      end;
      optfo.xexpdisp[int2]:= mstr1 + ' ['+valuekindcaptions[kx]+']';
      optfo.yexpdisp[int2]:= yexpression + ' ['+valuekindcaptions[ky]+']';
     end;
    end;
   end;
  end;
  updatechart;
 end;
end;

procedure tchartnode.setcaption(const avalue: msestring);
begin
 inherited;
 fchart.chartcaption:= avalue;
end;

procedure tchartnode.dostatread(const reader: tstatreader);
var
 int1: integer;
begin
 inherited;
 if fkey = 0 then begin
  for int1:= 0 to count - 1 do begin
   ttracenode(fitems[int1]).fkey:= int1;
  end;
  fkey:= count; //next key
 end;
 setcaption(fcaption);
 fchart.title:= fvalue0;
end;

function tchartnode.defaulttracecaption: msestring;
var
 int1,int2: integer;
label
 lab1;
begin
 int1:= 0;
lab1:
 inc(int1);
 result:= 'Trace '+inttostr(int1);
 for int2:= 0 to fcount - 1 do begin
  if fitems[int2].caption = result then begin
   goto lab1;
  end;
 end; 
end;

procedure tchartnode.setvalue0(const avalue: msestring);
begin
 inherited;
 if fchart <> nil then begin
  fchart.title:= avalue;
 end;
end;

procedure tchartnode.newtrace(const aindex: integer);
var
 node1: ttracenode;
begin
 node1:= ttracenode.create(defaulttracecaption);
 node1.fkey:= fkey;
 inc(fkey); 
 insert(aindex,node1);
 mainmo.projectmodified;
end;

{ ttracenode }

constructor ttracenode.create(const acaption: msestring);
begin
 inherited create;
 caption:= acaption;
end;

procedure ttracenode.showchart;
begin
 tchartnode(parent).showchart;
end;

procedure ttracenode.dostatread(const reader: tstatreader);
begin
 inherited;
 fxvaluekind:= valuekindty(reader.readinteger('xvaluekind',0,0,4));
 fyexpression:= reader.readmsestring('yexpression','');
 fyvaluekind:= valuekindty(reader.readinteger('yvaluekind',0,0,4));
end;

procedure ttracenode.dostatwrite(const writer: tstatwriter);
begin
 inherited;
 writer.writeinteger('xvaluekind',ord(fxvaluekind));
 writer.writeinteger('yvaluekind',ord(fyvaluekind));
 writer.writemsestring('yexpression',fyexpression);
end;

 {tplotpagefo}

constructor tplotpagefo.create(const aowner: tcomponent; const akind: integer);
begin
 inherited create(aowner);
 caption:= plotname.value;
 if akind < 0 then begin
  setkind(plotkind.value);
 end
 else begin  
  setkind(akind);
 end;
end;
 
procedure tplotpagefo.setnameexe(const sender: TObject; var avalue: msestring;
               var accept: Boolean);
begin
 caption:= avalue;
end;

procedure tplotpagefo.kindsetexe(const sender: TObject; var avalue: Integer;
               var accept: Boolean);
begin
 if avalue <> plotkind.value then begin
  setkind(avalue);
 end;
end;

procedure tplotpagefo.setkind(const akind: integer);
var
 cla1: plotsfoclassty;
begin
 freeandnil(fplot);
 cla1:= getplotclass(akind);
// if cla1 = nil then begin
//  cla1:= getplotclass(ord(plk_tran));
// end;
 if cla1 <> nil then begin
  fplot:= cla1.create(self);
  plotcont.insertwidget(fplot,nullpoint);
// fplot.parentwidget:= plotcont;
  fplot.visible:= true;
 end;
end;

function tplotpagefo.kind: plotkindty;
begin
 result:= getplotkind(fplot);
end;

function tplotpagefo.exptag(const aindex: integer): string;
begin
 result:= 'p'+inttostr(tabindex)+'e'+inttostr(aindex)
end;

function tplotpagefo.exptags: stringarty;
var
 int1: integer;
begin
 result:= nil;
 getplotstatement;
 if expressions <> nil then begin
  setlength(result,high(expressions));
  for int1:= 1 to high(expressions) do begin
   result[int1-1]:= exptag(int1);
  end;
 end;
end;

function tplotpagefo.getplotstatement: string;
 
var
 int1,int2: integer;
 ar1: chartnodearty;
 ar2: msestringarty;
 mstr1,mstr2: msestring;
begin
 result:= '';
 ar1:= chartnodes;
 if (ar1 <> nil) and (fplot <> nil) then begin
  ar2:= nil;
  for int1:= 0 to high(ar1) do begin
   stackarray(ar1[int1].getsavevalues,ar2);
  end;
  setlength(fexpressions,length(ar2));
  if ar2 <> nil then begin
   sortarray(ar2);
   mstr1:= '';
   int2:= 0;
   mstr2:= fplot.getxvalue;
   for int1:= 0 to high(ar2) do begin
    if ar2[int1] <> mstr1 then begin
     mstr1:= ar2[int1];
     if mstr1 <> mstr2 then begin
      fexpressions[int2]:= mstr1;
      inc(int2);
     end;
    end;
   end;
   setlength(fexpressions,int2);
   insertitem(fexpressions,0,mstr2); //x unit, always returned first by ngnutmeg
  end;
 end;
 if fplot <> nil then begin
  result:= fplot.getplotstatement;
 end;
end;

procedure tplotpagefo.createitemexe(const sender: tcustomitemlist;
               var item: ttreelistedititem);
begin
 item:= tchartnode.create(sender);
 item.add(1);
 item[0].caption:= 'Trace 1';
 with tchartnode(item).chart do begin
  name:= getchartname;
 end;
end;

procedure tplotpagefo.updaterowvalueexe(const sender: TObject;
               const aindex: Integer; const aitem: tlistitem);
begin
 value0[aindex]:= tplotnode(aitem).value0;
 if aitem is ttracenode then begin
  xvaluekind[aindex]:= ord(ttracenode(aitem).xvaluekind);
  yvaluekind[aindex]:= ord(ttracenode(aitem).yvaluekind);
  yexpression[aindex]:= ttracenode(aitem).yexpression;
  tracegrid.datacols.unmergecols(aindex);
 end
 else begin
  tracegrid.datacols.mergecols(aindex,1,5);
 end;
end;

procedure tplotpagefo.value0setexe(const sender: TObject; var avalue: msestring;
               var accept: Boolean);
begin
 tplotnode(treeed.item).value0:= avalue;
end;

procedure tplotpagefo.xunitsetexe(const sender: TObject; var avalue: msestring;
               var accept: Boolean);
begin
 tplotnode(treeed.item).value1:= avalue;
end;

procedure tplotpagefo.yunitsetexe(const sender: TObject; var avalue: msestring;
               var accept: Boolean);
begin
 tplotnode(treeed.item).value2:= avalue;
end;

procedure tplotpagefo.xvaluekindsetexe(const sender: TObject;
               var avalue: Integer; var accept: Boolean);
begin
 if treeed.item is ttracenode then begin
  ttracenode(treeed.item).xvaluekind:= valuekindty(avalue);
 end;
end;

procedure tplotpagefo.yexpressionsetexe(const sender: TObject;
               var avalue: msestring; var accept: Boolean);
begin
 if treeed.item is ttracenode then begin
  ttracenode(treeed.item).yexpression:= avalue;
 end;
end;

procedure tplotpagefo.yvaluekindsetexe(const sender: TObject;
               var avalue: Integer; var accept: Boolean);
begin
 if treeed.item is ttracenode then begin
  ttracenode(treeed.item).yvaluekind:= valuekindty(avalue);
 end;
end;


procedure tplotpagefo.celleventexe(const sender: TObject;
               var info: celleventinfoty);
begin
 if iscellclick(info,[ccr_dblclick,ccr_nokeyreturn])
                                     { and not treeed.focused} then begin
  tplotnode(treeed.item).showchart;
 end;
end;

function tplotpagefo.chartnodes: chartnodearty;
begin
 result:= chartnodearty(treeed.itemlist.toplevelnodes);
end;

procedure tplotpagefo.updatechartsettings;
var
 ar1: chartnodearty;
 int1: integer;
begin
 ar1:= chartnodes;
 for int1:= 0 to high(ar1) do begin
  ar1[int1].chart.updatechartsettings;
 end;
end;

function tplotpagefo.getchartname: string;
begin
 result:= 'p'+inttostr(tabindex)+'_'+inttostr(fnameindex);
 inc(fnameindex);
end;

procedure tplotpagefo.resetnameindex;
begin
 fnameindex:= 0;
end;

procedure tplotpagefo.rowinsertexe(const sender: tcustomgrid;
               var aindex: Integer; var acount: Integer);
//var
// n1: ttracenode;
begin
 if sender.userinput then begin
  if (treeed.item is tchartnode) then begin
   with tchartnode(treeed.item) do begin
    if (aindex > tracegrid.row) and (count = 0) then begin
     newtrace(0);
//     insert(ttracenode.create(defaulttracecaption),0);
     acount:= 0;
    end
    else begin
     if expanded and (aindex > tracegrid.row) then begin
      aindex:= tracegrid.row + treeheight+1;
     end;
    end;
   end;
  end
  else begin
   if treeed.item is ttracenode then begin
    with tchartnode(treeed.item.parent) do begin
     if aindex > tracegrid.row then begin
      newtrace(treeed.item.parentindex+1);
//      insert(ttracenode.create(defaulttracecaption),treeed.item.parentindex+1);
     end
     else begin
      newtrace(treeed.item.parentindex);
//      insert(ttracenode.create(defaulttracecaption),treeed.item.parentindex);
     end;
    end;
    acount:= 0;
   end;
  end;
 end;
end;

procedure tplotpagefo.plotrowinsertedexe(const sender: tcustomgrid;
               const aindex: Integer; const acount: Integer);
begin
 if sender.userinput then begin
  updaterowvalueexe(nil,aindex,treeed[aindex]);
 end;
end;

procedure tplotpagefo.rowdeleteexe(const sender: tcustomgrid;
               var aindex: Integer; var acount: Integer);
var
 int1: integer;
begin
 if sender.userinput then begin
  int1:= tracegrid.row;
  treeed[aindex].free;
  acount:= 0;
  if (int1 <= tracegrid.rowhigh) or (int1 = 0) then begin
   tracegrid.row:= aindex;
  end;
 end;
end;

procedure tplotpagefo.rowmoveexe(const sender: tcustomgrid;
               var fromindex: Integer; var toindex: Integer;
               var acount: Integer);
var
 source,dest: ttreelistedititem;
// int1: integer;
begin
 if sender.userinput then begin
  source:= treeed[fromindex];
  if source is tchartnode then begin
   treeed.itemlist.moverow(fromindex,toindex);
  end
  else begin
   if treeed[toindex] is tchartnode then begin
    dest:= nil;
    if toindex > fromindex then begin
     dest:= treeed[toindex];
     dest.insert(0,treeed[fromindex]);
    end
    else begin
     if toindex > 0 then begin
      dest:= treeed[toindex-1];
      dest.parentorself.insert(bigint,treeed[fromindex]);
     end;
    end;
    if dest <> nil then begin
     dest.expanded:= true;
    end;
   end
   else begin
    treeed[fromindex].parent.move(treeed[fromindex].parentindex,
                                     treeed[toindex].parentindex);
   end;
  end;
  acount:= 0;
  tracegrid.row:= source.index;
  mainmo.projectmodified;
 end;
end;

procedure tplotpagefo.showchartoptexe(const sender: TObject);
begin
 if treeed.item <> nil then begin
  tchartnode(treeed.item.rootnode).chart.optfo.activate;
 end;
end;

procedure tplotpagefo.showchartexe(const sender: TObject);
begin
 if treeed.item <> nil then begin
  tchartnode(treeed.item.rootnode).chart.activate;
 end;
end;

procedure tplotpagefo.udateshowexe(const sender: tcustomaction);
var
 bo1: boolean;
begin
 bo1:= treeed.item <> nil;
 showchartact.enabled:= bo1;
 showchartoptact.enabled:= bo1;
end;

procedure tplotpagefo.stepkindsetexe(const sender: TObject; var avalue: Integer;
               var accept: Boolean);
var
 rea1: real;
begin
 if (stepkindty(avalue) = sk_log) then begin
  if stepstart.value = 0 then begin
   stepstart.value:= 1;
  end;
  if stepstop.value = 0 then begin
   stepstop.value:= 1;
  end;
  if ((stepstart.value < 0) xor (stepstop.value < 0)) then begin
   stepstop.value:= stepstop.value * -1;
  end;
  if ((stepstart.value < 0) xor (stepstop.value < stepstart.value)) then begin
   rea1:= stepstart.value;
   stepstop.value:= stepstart.value;
   stepstart.value:= rea1;
  end;
 end;
end;

procedure tplotpagefo.stepstartsetexe(const sender: TObject; var avalue: realty;
               var accept: Boolean);
begin
 if (stepkindty(stepkind.value) = sk_log) then begin
  if avalue = 0 then begin
   avalue:= 1;
  end;
  if ((avalue < 0) xor (stepstop.value < 0)) then begin
   stepstop.value:= stepstop.value * -1;
  end;
  if (avalue < 0) xor (stepstop.value < avalue) then begin
   stepstop.value:= avalue;
  end;
 end;
end;

procedure tplotpagefo.stepstopsetexe(const sender: TObject; var avalue: realty;
               var accept: Boolean);
begin
 if (stepkindty(stepkind.value) = sk_log) then begin
  if avalue = 0 then begin
   avalue:= 1;
  end;
  if ((stepstart.value < 0) xor (avalue < 0)) then begin
   stepstart.value:= stepstart.value * -1;
  end;
  if (avalue < 0) xor (stepstart.value > avalue) then begin
   stepstart.value:= avalue;
  end;
 end;
end;

procedure tplotpagefo.datamodifiedexe(const sender: TObject);
begin
 mainmo.projectmodified;
end;
 
procedure tplotpagefo.createexe(const sender: TObject);
begin
 xvaluekind.enums:= enumar;
 yvaluekind.enums:= enumar;
end;

end.
