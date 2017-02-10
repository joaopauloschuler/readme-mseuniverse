{ MSEkicad Copyright (c) 2016 by Martin Schreiber
   
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
unit titlereppage;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,basereppage,
 mdb,mseifiglob,msereport,mserichstring,msesplitter,msestrings,
 mainmodule;

type
 ttitlereppa = class(tbasereppa)
   title: trecordband;
   text: trecordband;
  public
   constructor create(const apage: docupageinfoty);
 end;
 
implementation
uses
 titlereppage_mfm;

{ ttitlereppa }

constructor ttitlereppa.create(const apage: docupageinfoty);
begin
 inherited create(nil);
 title.tabs[0].value:= mainmo.expandprojectmacros(apage.title);
 text.tabs[0].value:= mainmo.expandprojectmacros(apage.text);
end;

end.
