unit main;

interface
{$ifdef gui4} {$define gui3} {$define gamecore}{$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define bmp} {$define ico} {$define gif} {$define snd} {$endif}
{$ifdef con3} {$define con2} {$define net} {$define ipsec} {$endif}
{$ifdef con2} {$define bmp} {$define ico} {$define gif} {$define jpeg} {$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses gosswin2, gossroot, {$ifdef gui}gossgui,{$endif} {$ifdef snd}gosssnd,{$endif} gosswin, gossio, gossimg, gossnet;
{$align on}{$O+}{$W-}{$I-}{$U+}{$V+}{$B-}{$X+}{$T-}{$P+}{$H+}{$J-} { set critical compiler conditionals for proper compilation - 10aug2025 }
//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2025 Blaiz Enterprises ( http://www.blaizenterprises.com )
//##
//## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//## files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//## modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
//## is furnished to do so, subject to the following conditions:
//##
//## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//##
//## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//##
//## ==========================================================================================================================================================================================================================
//## Library.................. app code (main.pas)
//## Version.................. 2.00.1410
//## Items.................... 1
//## Last Updated ............ 09nov2025, 08nov2025, 26sep2025, 18sep2025, 14sep2025, 08aug2025, 14may2025
//## Lines of Code............ 2,200+
//##
//## main.pas ................ app code
//## gossroot.pas ............ console/gui app startup and control
//## gossio.pas .............. file io
//## gossimg.pas ............. image/graphics
//## gossnet.pas ............. network
//## gosswin.pas ............. static Win32 api calls
//## gosswin2.pas ............ dynamic Win32 api calls
//## gosssnd.pas ............. sound/audio/midi/chimes
//## gossgui.pas ............. gui management/controls
//## gossdat.pas ............. app icons (24px and 20px) and help documents (gui only) in txt, bwd or bwp format
//## gosszip.pas ............. zip support
//## gossjpg.pas ............. jpeg support
//## gossgame.pas ............ game support (optional)
//## gamefiles.pas ........... internal files for game (optional)
//##
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================


const
   vlist   =0;
   vscroll =1;
   vslide  =2;
   vmax    =2;

   //options by index - 08nov2025
   voNormal        =0;
   voReverse       =1;
   voRandom        =2;
   voImageOnly     =3;
   voAutoShow      =4;

var
   itimerbusy:boolean=false;
   iapp:tobject=nil;

type
{tapp}
   tapp=class(tbasicapp)
   private

    ibuffer:twinbmp;
    ibufrows:tstr8;
    ibufREF:string;
    ilastcellcount,ilastcelldelay,ionstart,iscreenstyleCount,iscreenstyle,iscreencolor:longint;
    ipastecurrentfolder,islide_wasfullwhenstarted,ionstartONCE,ishownav,imustpaint,ibuildingcontrol,iloaded:boolean;
    iinfotimer,iswitchtimer,itimer100,itimer250,itimer500,itimerslow:comp;
    ipastefilename,ilastsavefilename,inavfolderref,inavchangeref,iscreenref,isettingsref:string;

    //left
    ileft:tbasicscroll;
    inavbar:tbasictoolbar;
    iimageformatsbar:tbasictoolbar;
    inav:tbasicnav;
    ifilters:tbasicset;
    inav_firstfile:longint;
    inav_lastfile:longint;
    inav_filecount:longint;

    ilist_width:tbasicsel;
    iscroll_trans:tsimpleint;
    iscroll_speed:tbasicsel;
    iscroll_options:tbasicset;
    iscroll_optionsList:tbasicset_valarray;
    iscroll_fill:tbasicsel;

    islide_trans:tsimpleint;
    islide_speed:tbasicsel;
    islide_options:tbasicset;
    islide_optionsList:tbasicset_valarray;
    islide_fill:tbasicsel;

    icustom_speed:array[0..vmax] of longint;//ms

    //right
    iright:tbasicscroll;
    iimagebar:tbasictoolbar;
    iscreen:tbasicimgview;

    //scroll
    iscrollstyle:string;

    procedure xcmd(sender:tobject;xcode:longint;xcode2:string);
    procedure __onclick(sender:tobject);
    procedure __ontimer(sender:tobject); override;
    procedure xloadsettings; override;
    procedure xsavesettings; override;
    procedure xautosavesettings;
    procedure xsyncinfo(xforce:boolean);//08nov2025
    procedure xonshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
    function xonshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
    function xscreencolor:longint;
    function __onaccept(sender:tobject;xfolder,xfilename:string;xindex,xcount:longint):boolean;
    function getnavfolder:string;
    procedure setnavfolder(x:string);
    function filter__findbyindex(xindex:longint;var xcap,xext:string):boolean;
    function filter__currentlist(xdef:string):string;
    procedure xnavfilerange;
    procedure ____onclick(sender:tobject);
    function ____onnotify(sender:tobject):boolean;
    function gettransspeed(xindex:longint):longint;
    procedure settransspeed(xindex,xval:longint);
    function getfill(xindex:longint):longint;
    procedure setfill(xindex,xval:longint);
    function getswitchspeedVAL(xindex:longint):longint;
    procedure setswitchspeedVAL(xindex,xval:longint);
    function getswitchspeedMAX(xindex:longint):longint;
    function getswitchspeedDEF(xindex:longint):longint;
    function getoptions(xindex:longint):longint;
    procedure setoptions(xindex,xval:longint);

    //.scroll support
    procedure xprev;
    procedure xnext;
    procedure xnextrandom;
    procedure xfirst;
    procedure xlast;
    function xautohide(xindex:longint):boolean;
    function xautoshow(xindex:longint):boolean;//08nov2025
    function xrandom(xindex:longint):boolean;
    function xreverse(xindex:longint):boolean;
    function xpastesave(const xcells:boolean;var e:string):boolean;//08nov2025, 26sep2025

    //.other
    function xlistwidth:longint;
    procedure gamemode__onpaint(sender:tobject);
    function gamemode__onnotify(sender:tobject):boolean;
    function gamemode__onshortcut(sender:tobject):boolean;
    procedure ximgformats(const xmode:longint);
    procedure xoptions__readwriteval(sender:tobject;var xval:tbasicset_valarray;xwrite:boolean);//08nov2025

   public
    //create
    constructor create; virtual;
    destructor destroy; override;
    //information
    property navfolder:string read getnavfolder write setnavfolder;
    function mode:longint;//vlist..vslide
    function transspeedDEF(xindex:longint):longint;
    property transspeed[xindex:longint]:longint read gettransspeed write settransspeed;
    function fillDEF(xindex:longint):longint;
    property fill[xindex:longint]:longint read getfill write setfill;
    function switchdelay(xindex:longint):comp;
    property switchspeedVAL[xindex:longint]:longint read getswitchspeedVAL write setswitchspeedVAL;
    property switchspeedMAX[xindex:longint]:longint read getswitchspeedMAX;
    property switchspeedDEF[xindex:longint]:longint read getswitchspeedDEF;
    function optionsDEF(xindex:longint):longint;
    property options[xindex:longint]:longint read getoptions write setoptions;
    //nav
    procedure navreload;
    function navfile:string;
    //scroll
    procedure scroll(x:string);
    function scrolling:boolean;
    function sliding:boolean;
    //io
    function canopen:boolean;
    function cansaveas:boolean;
    function cancopy:boolean;
   end;


//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024


//app procs --------------------------------------------------------------------
//.create / destroy
procedure app__remove;//does not fire "app__create" or "app__destroy"
procedure app__create;
procedure app__destroy;

//.event handlers
function app__onmessage(m,w,l:longint):longint;
procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
procedure app__onpaint(sw,sh:longint);
procedure app__ontimer;

//.support procs
function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
function app__findcustomtep(xindex:longint;var xdata:tlistptr):boolean;
function app__syncandsavesettings:boolean;


implementation

{$ifdef gui}
uses
    gossdat;
{$endif}


//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//get
if      (xname='slogan')              then result:=info__app('name')+' by Blaiz Enterprises'
else if (xname='width')               then result:='1650'
else if (xname='height')              then result:='900'
else if (xname='language')            then result:='english-australia'//for Clyde - 14sep2025
else if (xname='codepage')            then result:='1252'
else if (xname='ver')                 then result:='2.00.1410'
else if (xname='date')                then result:='09nov2025'
else if (xname='name')                then result:='Image Viewer'
else if (xname='web.name')            then result:='imageviewer'//used for website name
else if (xname='des')                 then result:='View images in a folder or play a slideshow'
else if (xname='infoline')            then result:=info__app('name')+#32+info__app('des')+' v'+app__info('ver')+' (c) 1997-'+low__yearstr(2024)+' Blaiz Enterprises'
else if (xname='size')                then result:=low__b(io__filesize64(io__exename),true)
else if (xname='diskname')            then result:=io__extractfilename(io__exename)
else if (xname='service.name')        then result:=info__app('name')
else if (xname='service.displayname') then result:=info__app('service.name')
else if (xname='service.description') then result:=info__app('des')
else if (xname='new.instance')        then result:='1'//1=allow new instance, else=only one instance of app permitted
//.links and values
else if (xname='linkname')            then result:=info__app('name')+' by Blaiz Enterprises.lnk'
else if (xname='linkname.vintage')    then result:=info__app('name')+' (Vintage) by Blaiz Enterprises.lnk'
//.author
else if (xname='author.shortname')    then result:='Blaiz'
else if (xname='author.name')         then result:='Blaiz Enterprises'
else if (xname='portal.name')         then result:='Blaiz Enterprises - Portal'
else if (xname='portal.tep')          then result:=intstr32(tepBE20)
//.software
else if (xname='software.tep')        then result:=intstr32(low__aorb(tepNext20,tepIcon20,sizeof(program_icon20h)>=2))
else if (xname='url.software')        then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.html'
else if (xname='url.software.zip')    then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.zip'
//.urls
else if (xname='url.portal')          then result:='https://www.blaizenterprises.com'
else if (xname='url.contact')         then result:='https://www.blaizenterprises.com/contact.html'
else if (xname='url.facebook')        then result:='https://web.facebook.com/blaizenterprises'
else if (xname='url.mastodon')        then result:='https://mastodon.social/@BlaizEnterprises'
else if (xname='url.twitter')         then result:='https://twitter.com/blaizenterprise'
else if (xname='url.x')               then result:=info__app('url.twitter')
else if (xname='url.instagram')       then result:='https://www.instagram.com/blaizenterprises'
else if (xname='url.sourceforge')     then result:='https://sourceforge.net/u/blaiz2023/profile/'
else if (xname='url.github')          then result:='https://github.com/blaiz2023'
//.program/splash
else if (xname='license')             then result:='MIT License'
else if (xname='copyright')           then result:='© 1997-'+low__yearstr(2025)+' Blaiz Enterprises'
else if (xname='splash.web')          then result:='Web Portal: '+app__info('url.portal')
else
   begin
   //nil
   end;

except;end;
end;


//app procs --------------------------------------------------------------------
procedure app__create;
begin
{$ifdef gui}
iapp:=tapp.create;
{$else}

//.starting...
app__writeln('');
//app__writeln('Starting server...');

//.visible - true=live stats, false=standard console output
scn__setvisible(false);


{$endif}
end;

procedure app__remove;
begin
try

except;end;
end;

procedure app__destroy;
begin
try
//save
//.save app settings
app__syncandsavesettings;

//free the app
freeobj(@iapp);
except;end;
end;

function app__findcustomtep(xindex:longint;var xdata:tlistptr):boolean;

  procedure m(const x:array of byte);//map array to pointer record
  begin
  {$ifdef gui}
  xdata:=low__maplist(x);
  {$else}
  xdata.count:=0;
  xdata.bytes:=nil;
  {$endif}
  end;
begin//Provide the program with a set of optional custom "tep" images, supports images in the TEA format (binary text image)
//defaults
//result:=false;

//sample custom image support
{
case xindex of
tepHand20:m(_tephand20);
end;
}
//successful
result:=(xdata.count>=1);
end;

function app__syncandsavesettings:boolean;
begin
//defaults
result:=false;
try
//.settings
{
app__ivalset('powerlevel',ipowerlevel);
app__ivalset('ramlimit',iramlimit);
{}


//.save
app__savesettings;

//successful
result:=true;
except;end;
end;

function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
begin
result:=tnetbasic.create;
end;

function app__onmessage(m,w,l:longint):longint;
begin
//defaults
result:=0;
end;

procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
begin
//nil
end;

procedure app__onpaint(sw,sh:longint);
begin
//console app only
end;

procedure app__ontimer;
begin
try
//check
if itimerbusy then exit else itimerbusy:=true;//prevent sync errors

//last timer - once only
if app__lasttimer then
   begin

   end;

//check
if not app__running then exit;


//first timer - once only
if app__firsttimer then
   begin

   end;



except;end;
try
itimerbusy:=false;
except;end;
end;


constructor tapp.create;
const
   voptionsDEF =8+16;//08nov2025
   vsep        =10;
var
   v,xval32,xpos,p:longint;
   xname,str1,xcap,xext,e:string;
   xuse32:boolean;

   function ntrans(xhost:tbasiccontrol;xcap:string;xdef:longint):tsimpleint;
   begin

   if (xhost<>nil) then
      begin

      result:=xhost.mint(xcap,'Transition speed: 0=Off (update immediately), 1=slowly transition to new image, 5=moderately transition to new image, 100=quickly transition to new image',0,30,xdef,xdef);
      result.osepv:=vsep;

      end
   else result:=nil;

   end;

   function nspeed(xhost:tbasiccontrol;xcap:string;xdef,xtag:longint):tbasicsel;

      procedure xadd(xms:longint);
      begin

      if (result=nil) then exit;
      if (xms>=1) then result.xadd(float__tostr_divby(xms,1000)+'s',k64(xms),float__tostr_divby(xms,1000)+' seconds') else result.xadd('#','customspeed','Custom delay');

      end;

   begin

   if (xhost<>nil) then result:=xhost.nsel(xcap,'Time to wait before displaying the next image',xdef) else result:=nil;

   if (result<>nil) then
      begin
      result.osepv:=vsep;
      result.tag:=xtag;
      xadd(500);
      xadd(1000);
      xadd(2000);
      xadd(5000);
      xadd(10000);
      xadd(15000);
      xadd(30000);
      xadd(60000);
      xadd(0);
      result.setparams(xdef,xdef);
      result.onclick:=__onclick;
      end;

   end;

   function nwidth(xhost:tbasiccontrol;xcap:string;xdef:longint):tbasicsel;

      procedure xadd(xpert:longint);
      begin

      if (result=nil) then exit;
      if (xpert>=1) then result.xadd(intstr32(xpert)+'%',intstr32(xpert),intstr32(xpert)+'%');

      end;

   begin

   if (xhost<>nil) then result:=xhost.nsel(xcap,'Set navigation list width',xdef) else result:=nil;

   if (result<>nil) then
      begin
      xadd(20);
      xadd(25);
      xadd(30);
      xadd(35);
      xadd(40);
      xadd(45);
      xadd(50);
      result.setparams(xdef,xdef);
      result.osepv:=vsep;
      end;

   end;

   function noptions(xhost:tbasiccontrol;xcap:string;xdef:longint):tbasicset;
   begin

   if (xhost<>nil) then result:=xhost.nset(xcap,'Select options to apply',xdef,xdef);

   if (result<>nil) then
      begin

      result.itemsperline   :=5;
      result.xset(voNormal,'Normal','normal','Options|Cycle through images in normal order (top down)',false);//1 - 08nov2025
      result.xset(voReverse,'Reverse','reverse','Options|Cycle through images in reverse order (bottom up)',false);//2
      result.xset(voRandom,'Random','random','Options|Cycle through images in random order',false);//4

      result.xset(voImageOnly,'Image Only','autohide',
       'Options|Automatically hide the GUI and display only the image whilst scrolling or in slideshow mode.  '+
       'Activates after a few seconds of mouse / tap inactivity.  '+
       'Disengages automatically upon a click / tap, pressing the ESC key, or any mouse movement when Auto.Show is selected',false);//8

      result.xset(voAutoShow,'Auto.Show','autoshow',
       'Options|Automatically show the GUI (if hidden) when the mouse cursor moves during a scroll or slideshow task',false);//16 - 08nov2025

      result.osepv          :=vsep;
      result.onreadwriteval :=xoptions__readwriteval;//08nov2025

      end;

   end;

   function nfill(xhost:tbasiccontrol;xcap:string;xdef:longint):tbasicsel;

      procedure xadd(xpert:longint);
      begin

      if (result=nil) then exit;
      if (xpert>=1) then result.xadd(intstr32(xpert)+'%',intstr32(xpert),intstr32(xpert)+'%');

      end;

   begin

   if (xhost<>nil) then result:=xhost.nsel(xcap,'Fill Style',xdef) else result:=nil;

   if (result<>nil) then
      begin
      result.xadd('Scale',intstr32(vfsScale),'Fill Style|View at 1:1 or scale down to fit');
      result.xadd('Scale Fit',intstr32(vfsScreen),'Fill Style|Scale up or down to fit');
      result.xadd('Crop',intstr32(vfsCrop),'Fill Style|View at 1:1 or trim to fit');
      result.xadd('Stretch',intstr32(vfsFit),'Fill Style|Stretch to fill entire area');
      result.xadd('Echo',intstr32(vfsEcho),'Fill Style|View at 1:1 or scale down to fit and echo a strong background in unused area');
      result.xadd('Echo 2',intstr32(vfsEcho2),'Fill Style|View at 1:1 or scale down to fit and echo a faint background in unused area');
      result.setparams(xdef,xdef);
      result.osepv:=vsep;
      end;

   end;

   function xfilterdescription(const xext:string):string;
   var
      xoutext,xoutmask:string;
   begin

   if not io__findext(xext,result,xoutext,xoutmask) then result:='';

   end;

   function xhelpval(const x:string):string;
   begin

   if      (x='copy.b64.png')        then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format PNG. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'
   else if (x='copy.b64.gif')        then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format GIF. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'+xhelpval('gif.restriction')
   else if (x='gif.restriction')     then result:='|*|'+'Format Restriction|The GIF image format can only store 2 mask values (on and off) and 256 colors. An image with subtle mask values, or 2 or more, or more than 256 colors may appear incorrectly.'

   else
      begin
      result:='';
      showbasic('Undefined help.val');
      end;

   end;

begin


if system_debug then dbstatus(38,'Debug 012');//yyyy


//self
inherited create(strint32(app__info('width')),strint32(app__info('height')),true);
ibuildingcontrol:=true;

//need checkers
need_jpeg;
need_gif;

//init
iinfotimer             :=slowms64;
itimer100              :=slowms64;
itimer250              :=slowms64;
itimer500              :=slowms64;
itimerslow             :=slowms64;
iswitchtimer           :=slowms64;
ibuffer                :=nil;
ibufrows               :=nil;
ibufref                :='';
ilastcellcount         :=2;
ilastcelldelay         :=500;

low__cls(@iscroll_optionsList,sizeof(iscroll_optionsList));
low__cls(@islide_optionsList,sizeof(islide_optionsList));

//vars
iloaded                :=false;
imustpaint             :=false;
islide_wasfullwhenstarted:=false;
iscreenstyleCount      :=7;
iscreenstyle           :=0;
iscreencolor           :=0;
iscreenref             :='';
inav_firstfile         :=0;
inav_lastfile          :=-1;
inav_filecount         :=0;
inavchangeref          :='';
inavfolderref          :='';
ishownav               :=true;
ionstart               :=0;
ionstartONCE           :=true;
ilastsavefilename      :='';
ipastefilename         :='untitled.png';
ipastecurrentfolder    :=true;

//.scroll
iscrollstyle:='';//off

//controls
with rootwin do
begin
ocanshowmenu:=true;
scroll:=false;
xhead;
xgrad;
xgrad2;

with xhead do
begin

add('Prev',tepPrev20,0,'prev','Previous image');
add('Next',tepNext20,0,'next','Next image');

add('Open',tepOpen20,0,'open','Open|Open current image with system app');
add('Save As',tepSave20,0,'saveas','Save|Save current image to file');
add('Copy',tepCopy20,0,'copy','Copy|Copy image to Clipboard (first cell of an animation)');
add('Cells',tepCopy20,0,'copy.cells','Copy|Copy animation cells to Clipboard as an image strip');

add('GIF',tepCopy20,0,'copy.b64.gif', xhelpval('copy.b64.gif') );
add('PNG',tepCopy20,0,'copy.b64.png', xhelpval('copy.b64.png') );

add('Pascal',tepCopy20,0,'copy.pascal','Copy|Copy image to Clipboard as an uncompressed Pascal Array');
add('Paste',tepPaste20,0,'paste.save','Paste|Paste image from Clipboard and save to file');
add('Cells',tepPaste20,0,'paste.save.cells','Paste|Paste image strip from Clipboard as an animation and save to file');

addsep;
add('Nav',tepNav20,0,'nav','Navigation Panel|Toggle display of navigation panel');
add('Scroll',tepPlay20,0,'scroll',
 'Scroll|Click to automatically scroll through the list of images in the current folder.  '+
 'To cancel scroll press the ESC key at anytime, or click / tap on the image, or click the scroll button again.  '+
 '|*| '+
 'Manual Scroll - Use Keyboard Arrow Keys OR Click / Tap Image:|'+
 'Left/up key: Previous image | '+
 'Right/down key: Next Image | '+
 'Ctrl+Left/up keys: First Image | '+
 'Ctrl+Right/down keys: Last Image | '+
 'Click left 1/3 of image: Previous Image | '+
 'Click right 1/3 of image: Next Image');

add('Slideshow',tepPlay20,0,'slideshow',
 'Slideshow|Click to play a slideshow of images from the current folder at fullscreen.  '+
 'To cancel the slideshow press the ESC key at anytime, or click / tap on the image, or click the slideshow button again.');

add('Settings',tepSettings20,0,'settings','Show settings');

addsep;
xaddoptions;
xaddhelp;

//add('Test3',tepPrev20,0,'test3','Previous image');

halign:=1;
end;


ileft:=xcols.cols2[0,30,false];
with ileft do
begin
inavbar:=ntitlebar(false,'Navigation','');
with inavbar do
begin
add('Fav',tepFav20,0,'fav','Show favourites list');
add('Refresh',tepRefresh20,0,'refresh','Refresh file list');
add('Back',tepBack20,0,'nav.prev','Switch to previously viewed folder');
add('Forw',tepForw20,0,'nav.next','Switch to next viewed folder');
end;
inav             :=nnav;
inav.hisname     :='app.filelist';
inav.makenavlist;
inav.sortstyle   :=nlName;
inav.oautoheight :=true;

with xhigh2 do
begin
//.scroll and slide show settings
with nscroll('') do
begin
bordersize       :=0;
oautoheight      :=true;
ofullalignpaint  :=true;
static           :=true;
scroll           :=false;

//.image formats
with xpage2('formats','','Formats','Formats|Select the image formats to show in the navigation panel.  If no formats are selected, then all formats will be listed.',tepFNew20,true) do
begin

iimageformatsbar:=ntitlebar(false,'Image Formats','');
with iimageformatsbar do
begin
add('Select All',tepMore20,0,'imgformats.allon','Image Formats|Select all image formats');
add('Unselect All',tepLess20,0,'imgformats.alloff','Image Formats|Unselect all image formats');
add('Invert',tepNew20,0,'imgformats.invert','Image Formats|Invert the selection of image formats');
end;

ifilters:=nset('','Select image formats to list',0,0);
ifilters.oshowtitle    :=false;
ifilters.itemsperline  :=4;
ifilters.oflatback     :=false;
for p:=0 to maxint do if filter__findbyindex(p,xcap,xext) then ifilters.xset(p,xcap,xext,'Image Format|Select to include '+xfilterdescription(xext)+' files in the navigation list',false) else break;

end;

//.scroll settings
with xpage2('scroll','','Manual / Scroll','Scroll settings',tepFNew20,true) do
begin
ntitlebar(false,'Scroll Settings','');
iscroll_fill           :=nfill(client,'Fill Style',vfsDefault);
iscroll_trans          :=ntrans(client,'Transition Speed',15);
iscroll_speed          :=nspeed(client,'Delay Between Images',1,vscroll);
iscroll_options        :=noptions(client,'Options',voptionsDEF);
ilist_width            :=nwidth(client,'Column Width',2);
end;

//.slideshow settings
with xpage2('slide','','Slideshow','Slideshow settings',tepFNew20,true) do
begin
ntitlebar(false,'Slideshow Settings','');
islide_fill            :=nfill(client,'Fill Style',vfsCrop);
islide_trans           :=ntrans(client,'Transition Speed',4);//08nov2025
islide_speed           :=nspeed(client,'Delay Between Images',3,vslide);
islide_options         :=noptions(client,'Options',voptionsDEF);
end;

with xpage2('hide','','Hide','Hide settings',tepDownward20,true) do
begin

//nil

end;

//.default page
xtoolbar2.halign:=0;
page:='formats';
end;

end;

end;

iright:=xcols.cols2[1,70,false];

with iright do
begin

iimagebar:=ntitlebar(false,'Image','');

with iimagebar do
begin

add('Prev',tepPrev20,0,'prev','Previous image');
add('Next',tepNext20,0,'next','Next image');

add('Open',tepOpen20,0,'open','Open current image with system app');
add('Save As',tepSave20,0,'saveas','Save current image to file');
add('Copy',tepCopy20,0,'copy','Copy image to Clipboard (first cell of an animation)');

//debug only: add('Test',tepNew20,0,'test','Test...');
visible:=false;

end;

//.screen
iscreen:=tbasicimgview.create(client);
iscreen.oautoheight:=true;
iscreen.oroundstyle:=corNone;//corToSquare;//corNone;
iscreen.bordersize:=0;
iscreen.countcolors:=true;
iscreen.help:='Press ESC key to cancel slideshow or fullscreen mode | To stop scrolling, click the image panel or a filename from the list | Left/up key: Previous image | Right/down key: Next Image | Ctrl+Left/up keys: First Image | Ctrl+Right/down keys: Last Image';
iscreen.nohint;

end;

end;

//.last links on toolbar - 22mar2021
with rootwin.xstatus2 do
begin
cellwidth[0]:=190;
cellwidth[1]:=80;
cellwidth[2]:=100;

cellwidth[3]:=100;//delay
cellwidth[4]:=120;//fps

cellwidth[5]:=120;
cellwidth[6]:=130;
cellwidth[7]:=150;
cellwidth[8]:=100;
end;


//events
rootwin.xhead.onclick       :=__onclick;
inavbar.onclick             :=__onclick;
iimageformatsbar.onclick    :=__onclick;
iimagebar.onclick           :=__onclick;
rootwin.showmenuFill1       :=xonshowmenuFill1;
rootwin.showmenuClick1      :=xonshowmenuClick1;
rootwin.onaccept            :=__onaccept;//drag and drop support
iscreen.onnotify            :=____onnotify;
inav.onclick                :=____onclick;

//defaults
xsyncinfo(true);


//gamemode - 29jan2025
gui.gamemode__onpaint       :=gamemode__onpaint;
gui.gamemode__onnotify      :=gamemode__onnotify;
gui.gamemode__onshortcut    :=gamemode__onshortcut;


//start timer event
ibuildingcontrol:=false;
xloadsettings;
createfinish;
//.low__paramstr1
str1:=low__paramstr1;
if (str1<>'') then __onaccept(self,'',str1,0,1);
end;

destructor tapp.destroy;
begin
try
//settings
xautosavesettings;
//controls
freeobj(@ibuffer);
str__free(@ibufrows);
//self
inherited destroy;
except;end;
end;

procedure tapp.xoptions__readwriteval(sender:tobject;var xval:tbasicset_valarray;xwrite:boolean);//08nov2025
var//Note: Converts options 0..2 into a single option (only one of the three can be select at once) with the remaining 2 options 3..4 as on/off options -> e.g. a dual mode control - 08nov2025
   a:tbasicset;
   v:pbasicset_valarray;
   i,p:longint;
begin

//init
if      (sender=iscroll_options) then v:=@iscroll_optionsList
else if (sender=islide_options)  then v:=@islide_optionsList
else                                  exit;

//get
case xwrite of
true:begin

   //filter -> only one option can be selected betweeb "voNormal...voRandom"
   i:=voNormal;
   for p:=voNormal to voRandom do if (xval[p]<>v[p]) then
      begin

      i:=p;
      break;

      end;

   for p:=voNormal to voRandom do xval[p]:=(p=i);

   //get
   v^:=xval;

   end;
else begin

   //simple filter
   i:=0;
   for p:=voNormal to voRandom do if v[p] then inc(i);
   if (i<>1) then v[voNormal]:=true;

   //get
   xval:=v^;

   end;
end;//case

end;

procedure tapp.ximgformats(const xmode:longint);
var
   p:longint;
begin

for p:=0 to (ifilters.count-1) do
begin

case xmode of
0:ifilters.vals[p]:=true;
1:ifilters.vals[p]:=false;
2:ifilters.vals[p]:=not ifilters.vals[p];
end;//case

end;//p

end;

function tapp.mode:longint;
begin
if sliding        then result:=vslide
else if scrolling then result:=vscroll
else                   result:=vlist;
end;

function tapp.switchdelay(xindex:longint):comp;

   function xdelay(x:tbasicsel;xcustomdelay:longint):comp;
   begin
   if (x=iscroll_speed) or (x=islide_speed) then
      begin
      if strmatch(x.nams[x.val],'customspeed') then result:=(frcrange32(xcustomdelay,1,86400)*1000) else result:=strint(x.nams[x.val]);
      end
   else result:=0;
   end;
begin
if (xindex=vslide) then result:=xdelay(islide_speed,icustom_speed[vslide]) else result:=xdelay(iscroll_speed,icustom_speed[vscroll]);
end;

function tapp.getswitchspeedVAL(xindex:longint):longint;
begin
if (xindex=vslide) then result:=islide_speed.val else result:=iscroll_speed.val;
end;

procedure tapp.setswitchspeedVAL(xindex,xval:longint);
begin
if (xindex=vslide) then islide_speed.val:=xval else iscroll_speed.val:=xval;
end;

function tapp.getswitchspeedMAX(xindex:longint):longint;
begin
if (xindex=vslide) then result:=islide_speed.max else result:=iscroll_speed.max;
end;

function tapp.getswitchspeedDEF(xindex:longint):longint;
begin
if (xindex=vslide) then result:=islide_speed.def else result:=iscroll_speed.def;
end;

function tapp.transspeedDEF(xindex:longint):longint;
begin
if (xindex=vslide) then result:=islide_trans.def else result:=iscroll_trans.def
end;

function tapp.optionsDEF(xindex:longint):longint;
begin
if (xindex=vslide) then result:=islide_options.def else result:=iscroll_options.def;
end;

function tapp.xlistwidth:longint;
begin
result:=strint(ilist_width.nams[ilist_width.val])
end;

function tapp.gettransspeed(xindex:longint):longint;
begin
if (xindex=vslide) then result:=islide_trans.val else result:=iscroll_trans.val;
end;

procedure tapp.settransspeed(xindex,xval:longint);
begin
if (xindex=vslide) then islide_trans.val:=xval else iscroll_trans.val:=xval;
end;

function tapp.getfill(xindex:longint):longint;
begin
if (xindex=vslide) then result:=islide_fill.val else result:=iscroll_fill.val;
end;

procedure tapp.setfill(xindex,xval:longint);
begin
if (xindex=vslide) then islide_fill.val:=xval else iscroll_fill.val:=xval;
end;

function tapp.fillDEF(xindex:longint):longint;
begin
if (xindex=vslide) then result:=islide_fill.def else result:=iscroll_fill.def;
end;

function tapp.getoptions(xindex:longint):longint;
begin
if (xindex=vslide) then result:=islide_options.val else result:=iscroll_options.val;
end;

procedure tapp.setoptions(xindex,xval:longint);
begin
if (xindex=vslide) then islide_options.val:=xval else iscroll_options.val:=xval;
end;

function tapp.xautohide(xindex:longint):boolean;
begin
if (xindex=vslide) then result:= islide_options.vals2['autohide'] else result:=iscroll_options.vals2['autohide'];
end;

function tapp.xautoshow(xindex:longint):boolean;//08nov2025
begin
if (xindex=vslide) then result:= islide_options.vals2['autoshow'] else result:=iscroll_options.vals2['autoshow'];
end;

function tapp.xrandom(xindex:longint):boolean;
begin
if (xindex=vslide) then result:= islide_options.vals2['random'] else result:=iscroll_options.vals2['random'];
end;

function tapp.xreverse(xindex:longint):boolean;
begin
if (xindex=vslide) then result:= islide_options.vals2['reverse'] else result:=iscroll_options.vals2['reverse'];
end;

function tapp.getnavfolder:string;
begin
result:=inav.folder;
end;

procedure tapp.setnavfolder(x:string);
begin
inav.folder:=x;
end;

procedure tapp.navreload;
begin
inav.reload;
end;

function tapp.navfile:string;
begin
if (inav.valuestyle=nltFile) then result:=inav.value else result:='';
end;

function tapp.sliding:boolean;
begin
result:=(iscrollstyle='slide') or (iscrollstyle='slide.down') or (iscrollstyle='slide.up');
end;

function tapp.scrolling:boolean;
begin
result:=(iscrollstyle='scroll') or (iscrollstyle='scroll.down') or (iscrollstyle='scroll.up');
end;

procedure tapp.scroll(x:string);
   procedure xreadyscroll;
   var
      i:longint;
   begin
   i:=frcrange32(inav.itemindex,inav_firstfile,inav_lastfile);
   if (inav.itemindex<>i) then inav.itemindex:=i;

   iscrollstyle:=x;
   end;
begin
//init
x:=strlow(x);

if (x='stop') and sliding then
   begin
   if (not islide_wasfullwhenstarted) and (gui.state='f') then gui.state:='n';
   end;

//get
if (x='slide') or (x='slide.down') or (x='slide.up') or (x='scroll') or (x='scroll.down') or (x='scroll.up') then xreadyscroll
else if (x='stop')  then iscrollstyle:=''
else if (x='prev')  then iscrollstyle:='prev'
else if (x='next')  then iscrollstyle:='next'
else if (x='first') then iscrollstyle:='first'
else if (x='last')  then iscrollstyle:='last'
else                     iscrollstyle:='';

if (x='slide') then
   begin
   islide_wasfullwhenstarted:=(gui.state='f');
   gui.state:='f';
   end;

//check
//was: if (inav_filecount<=1) then iscrollstyle:='';
end;

procedure tapp.xprev;
var
   i:longint;
begin
i:=frcrange32(inav.itemindex-1,inav_firstfile-1,inav_lastfile);
if (i<inav_firstfile) then i:=inav_lastfile;
inav.itemindex:=i;
end;

procedure tapp.xnext;
var
   i:longint;
begin
i:=frcrange32(inav.itemindex+1,inav_firstfile,inav_lastfile+1);
if (i>inav_lastfile) then i:=inav_firstfile;
inav.itemindex:=i;
end;

procedure tapp.xnextrandom;
begin
inav.itemindex:=frcrange32(inav_firstfile+random(inav_filecount),inav_firstfile,inav_lastfile);
end;

procedure tapp.xfirst;
begin
inav.itemindex:=inav_firstfile
end;

procedure tapp.xlast;
begin
inav.itemindex:=inav_lastfile
end;

function tapp.filter__currentlist(xdef:string):string;
label
   redo;
var
   p:longint;
   xonce:boolean;
begin
//defaults
result:='';
xonce:=true;

try
//get
redo:
for p:=0 to (ifilters.viscount-1) do if ifilters.vals[p] or (not xonce) then result:=result+'*.'+ifilters.nams[p]+';';

//.fallback -> if no image formats are selected then include them all
if xonce and (result='') then
   begin
   xonce:=false;
   goto redo;
   end;

//check
result:=strdefb(result,xdef);
except;end;
end;

function tapp.filter__findbyindex(xindex:longint;var xcap,xext:string):boolean;
var
   v:string;

   function xfind(x:longint;var v:string):boolean;
   var
      lp,xcount,xlen,p:longint;
      xlist:string;
   begin
   //defaults
   v       :='';
   result  :=false;

   try
   //init
   xlist  :=filter__sort(swapcharsb(feallimgs,fesepX,fesep));//sort - 18sep2025
   xlen   :=low__len(xlist);
   xcount :=0;

   //check
   if (xlen<2) then exit;

   //get
   lp:=1;
   for p:=1 to xlen do
   begin
   if (strcopy1(xlist,p,1)=fesep) then
      begin

      if (xcount>=xindex) then
         begin
         v:=strcopy1(xlist,lp,p-lp);
         break;
         end;

      lp:=p+1;
      inc(xcount);
      end;
   end;//p

   //set
   result:=(v<>'');
   except;end;
   end;
begin

if xfind(xindex,v) then
   begin
   xcap   :=strup(v);
   xext   :=v;
   result :=true;
   end
else result:=false;

end;

function tapp.__onaccept(sender:tobject;xfolder,xfilename:string;xindex,xcount:longint):boolean;
begin
result:=false;
if (xfolder<>'') and io__folderexists(xfolder) and (not strmatch(navfolder,xfolder)) then navfolder:=xfolder;
end;

procedure tapp.xloadsettings;
var
   a:tvars8;
   p:longint;
begin
try
//defaults
a:=nil;
//check
if zznil(prgsettings,5001) then exit;
//init
a:=vnew2(950);
//filter
a.i['screenstyle']          :=prgsettings.idef('screenstyle',0);
a.i['screencolor']          :=prgsettings.idef('screencolor',rgba0__int(60,60,60));
a.b['shownav']              :=prgsettings.bdef('shownav',true);
a.i['onstart']              :=prgsettings.idef2('onstart',0,0,vmax);
a.i['filters']              :=prgsettings.idef('filters',maxint);
a.i['listwidth']            :=prgsettings.idef2('listwidth',2,0,maxint);
a.b['pastecurrentfolder']   :=prgsettings.bdef('pastecurrentfolder',true);

for p:=0 to vmax do
begin
a.i['transspeed.'+intstr32(p)]    :=prgsettings.idef2('transspeed.'+intstr32(p),transspeedDEF(p),0,30);//0..30
a.i['switchspeed.'+intstr32(p)]   :=prgsettings.idef2('switchspeed.'+intstr32(p),switchspeedDEF[p],0,switchspeedMAX[p]);//0..30
a.i['options.'+intstr32(p)]       :=prgsettings.idef('options.'+intstr32(p),optionsDEF(p));
a.i['fill.'+intstr32(p)]          :=prgsettings.idef2('fill.'+intstr32(p),fillDEF(p),0,vfsMax);
a.i['customspeed.'+intstr32(p)]   :=prgsettings.idef2('customspeed.'+intstr32(p),30,1,60*60*24);//1s..24hr
end;//p

//get
iscreenstyle                      :=frcrange32(a.i['screenstyle'],0,iscreenstyleCount-1);
iscreencolor                      :=a.i['screencolor'];
ifilters.val                      :=a.i['filters'];
ilist_width.val                   :=a.i['listwidth'];
ishownav                          :=a.b['shownav'];
ionstart                          :=a.i['onstart'];
ipastecurrentfolder               :=a.b['pastecurrentfolder'];

for p:=0 to vmax do
begin
transspeed[p]:=a.i['transspeed.'+intstr32(p)];
switchspeedVAL[p]:=a.i['switchspeed.'+intstr32(p)];
options[p]:=a.i['options.'+intstr32(p)];
fill[p]:=a.i['fill.'+intstr32(p)];
icustom_speed[p]:=a.i['customspeed.'+intstr32(p)];
end;

//.nav
inav.settings  :=prgsettings.s['nav.settings'];
navfolder      :=io__readportablefilename(prgsettings.s['nav.folder']);


//sync
prgsettings.data:=a.data;
xsyncinfo(true);
except;end;
try
freeobj(@a);
iloaded:=true;
except;end;
end;

procedure tapp.xsavesettings;
var
   a:tvars8;
   p:longint;
begin
try
//check
if not iloaded then exit;

//defaults
a:=nil;
a:=vnew2(951);

//get
a.i['screenstyle']         :=frcrange32(iscreenstyle,0,iscreenstyleCount-1);
a.i['screencolor']         :=iscreencolor;
a.b['shownav']             :=ishownav;
a.i['onstart']             :=ionstart;
a.i['filters']             :=ifilters.val;
a.i['listwidth']           :=ilist_width.val;
a.b['pastecurrentfolder']  :=ipastecurrentfolder;

for p:=0 to vmax do
begin
a.i['transspeed.'+intstr32(p)]:=transspeed[p];
a.i['switchspeed.'+intstr32(p)]:=switchspeedVAL[p];
a.i['options.'+intstr32(p)]:=options[p];
a.i['fill.'+intstr32(p)]:=fill[p];
a.i['customspeed.'+intstr32(p)]:=icustom_speed[p];
end;

//.nav
a.s['nav.settings']:=inav.settings;
a.s['nav.folder']  :=io__makeportablefilename(navfolder);

//set
prgsettings.data:=a.data;
siSaveprgsettings;
except;end;
try;freeobj(@a);except;end;
end;

function tapp.xscreencolor:longint;
begin
case iscreenstyle of
0:begin

   //use a shade light enough from current window.background to show the black pixels of an XBM image - 18sep2025
   result:=vinormal.background;
   if (int__lum(result)<60) then result:=int__splice24(0.20,result,int_255_255_255);

   end;
1:result:=rgba0__int(60,60,60);
2:result:=rgba0__int(120,120,120);
3:result:=rgba0__int(0,0,0);
4:result:=rgba0__int(255,255,255);
5:result:=rgba0__int(240,240,240);
else result:=iscreencolor;
end;
end;

procedure tapp.xautosavesettings;
var
   str1:string;
   p:longint;
begin
try
//check
if not iloaded then exit;
//get
str1:=rootwin.xhead.visref+'|'+intstr32(ionstart)+'|'+intstr32(iscreenstyle)+'|'+intstr32(ilist_width.val)+'|'+iscrollstyle+'|'+intstr32(xscreencolor)+'|'+intstr32(ifilters.val)+'|'+bolstr(ipastecurrentfolder)+bolstr(ishownav)+'|'+navfolder+#1+inav.settings+#1;
//.speed + delay
for p:=0 to vmax do str1:=str1+'|'+intstr32(transspeed[p])+'|'+k64(switchdelay(p))+'|'+intstr32(switchspeedVAL[p])+'|'+intstr32(options[p])+'|'+intstr32(fill[p])+'|'+intstr32(icustom_speed[p]);
//set
if low__setstr(isettingsref,str1) then xsavesettings;
except;end;
end;

procedure tapp.__onclick(sender:tobject);
begin
xcmd(sender,0,'');
end;

procedure tapp.xcmd(sender:tobject;xcode:longint;xcode2:string);
label
   skipend;
var
   a:trawimage;
   b:tstr8;
   xresult,zok:boolean;
   int1:longint;
   daction,dext,str1,e:string;

   function xpascalArray(xdata:tstr8):boolean;
   label
      skipend;
   var
      s,dline:tstr8;
      slen,p:longint;
   begin
   //defaults
   result:=false;
   s:=nil;
   dline:=nil;

   try
   //check
   if (not str__lock(@xdata)) or (str__len(@xdata)<=0) then goto skipend;
   //init
   s:=str__new8;
   dline:=str__new8;
   str__add(@s,@xdata);
   str__clear(@xdata);
   slen:=str__len(@s);
   //start
   str__sadd(@xdata,':array[0..'+intstr32(slen-1)+'] of byte=('+rcode);
   //content
   for p:=1 to slen do
   begin
   str__sadd(@dline,intstr32(byte(s.bytes1[p]))+insstr(',',p<slen));
   if (str__len(@dline)>=990) then//was 1015 for Win95 Delphi 3 but lowered to 990 for Win11 Notepad - 19jul2024
      begin
      str__add(@xdata,@dline);
      str__sadd(@xdata,rcode);
      str__clear(@dline);
      end;
   end;//p
   //.finalise
   str__add(@xdata,@dline);
   str__sadd(@xdata,');'+rcode);
   //successful
   result:=true;
   skipend:
   except;end;
   try
   str__free(@s);
   str__free(@dline);
   except;end;
   end;

begin
//defaults
xresult :=false;
e       :=gecTaskfailed;
a       :=nil;
b       :=nil;

try
//init
zok:=zzok(sender,7455);
if zok and (sender is tbasictoolbar) then
   begin
   //ours next
   xcode:=(sender as tbasictoolbar).ocode;
   xcode2:=strlow((sender as tbasictoolbar).ocode2);
   end
else if (sender is tbasicsel) then
   begin
   xcode:=(sender as tbasicsel).tag;
   int1:=(sender as tbasicsel).val;
   str1:=(sender as tbasicsel).nams[int1];//29aug2021
   if strmatch(str1,'customspeed') and (sender as tbasicsel).focused and (sender as tbasicsel).gui.mouseupstroke then xcode2:=str1;
   end;

//get
if (xcode2='menu') then rootwin.showmenu2('menu')
else if (xcode2='settings') then rootwin.showmenu2('settings')

else if (xcode2='pastecurrentfolder.toggle') then ipastecurrentfolder:=not ipastecurrentfolder

else if (xcode2='imgformats.allon')   then ximgformats(0)
else if (xcode2='imgformats.alloff')  then ximgformats(1)
else if (xcode2='imgformats.invert')  then ximgformats(2)

else if (xcode2='customspeed') then
   begin
   str1:=k64(icustom_speed[xcode]);
   if gui.popedit_small(str1,'Custom delay in seconds (1-86,400)','1=1 second, 60=1 minute, 3600=1 hour and 86400=1 day') then icustom_speed[xcode]:=restrict32(frcrange64(strint64(str1),1,86400));
   end
else if (xcode2='lowopen') then
   begin
   //nil
   end
else if (xcode2='open') then
   begin
   if io__fileexists(iscreen.filename) then runLOW(iscreen.filename,'') else gui.poperror('','File not found');
   end
else if (xcode2='saveas') then
   begin

   if io__fileexists(iscreen.filename) then
      begin

      //retain last used FOLDER and SAVE-FORMAT but use the current IMAGE NAME
      if (ilastsavefilename='') then ilastsavefilename:=iscreen.filename else ilastsavefilename:=io__asfolder(io__extractfilepath(ilastsavefilename))+io__remlastext(io__extractfilename(iscreen.filename))+'.'+io__readfileext_low(ilastsavefilename);
      daction:='';

      if gui.popsaveimg(ilastsavefilename,'',daction) and (not strmatch(ilastsavefilename,iscreen.filename)) then
         begin

         dext:=io__readfileext_low(ilastsavefilename);

         if (daction='') and strmatch(dext,io__readfileext_low(iscreen.filename)) then
            begin

            if not io__copyfile(iscreen.filename,ilastsavefilename,e) then goto skipend;

            end
         else
            begin

            a:=misraw32(1,1);//larger image support
            if not mis__fromfile(a,iscreen.filename,e) then goto skipend;
            if not mis__tofile2(a,ilastsavefilename,dext,daction,e) then goto skipend;

            end;

         end;

      end
   else gui.poperror('','File not found');

   end
else if (xcode2='copy') then
   begin

   case (iscreen.image32.ai.count>=2) of
   true:begin

      a:=misraw32(1,1);
      if not mis__copy(iscreen.image32,a)     then goto skipend;
      mis__onecell(a);
      if not clip__copyimage(a)               then goto skipend;

      end;
   else if not clip__copyimage(iscreen.image32) then goto skipend;
   end;//case

   end
else if (xcode2='copy.cells') then
   begin

   if not clip__copyimage(iscreen.image32) then goto skipend;

   end
else if (xcode2='paste.save') then
   begin
   if not xpastesave(false,e) then goto skipend;
   end
else if (xcode2='paste.save.cells') then
   begin
   if not xpastesave(true,e) then goto skipend;
   end
else if (xcode2='copy.b64.png') or (xcode2='copy.b64.gif') then//08nov2025, 08aug2025
   begin

   case (xcode2='copy.b64.gif') of
   true:dext:='gif';
   else dext:='png';
   end;//case
   
   a:=misraw32(1,1);
   b:=str__new8;
   if not mis__fromfile(a,iscreen.filename,e) then goto skipend;

   if (dext='gif') then
      begin
      if not gif__todata(a,@b,e)  then goto skipend;
      end
   else
      begin
      if not mis__onecell(a)      then goto skipend;
      if not png__todata(a,@b,e)  then goto skipend;
      end;

   e:=gecTaskfailed;
   if not str__tob64(@b,@b,0) then goto skipend;
   if not str__insstr(@b,'data:image/' + dext + ';base64,',0) then goto skipend;//08aug2025
   if not clip__copytext2(@b) then goto skipend;

   end
else if (xcode2='copy.pascal') then
   begin
   b:=str__new8;
   if not io__fromfile(iscreen.filename,@b,e) then goto skipend;
   e:=gecTaskfailed;
   if not xpascalArray(b) then goto skipend;
   if not clip__copytext2(@b) then goto skipend;
   end
else if (xcode2='refresh') then navreload
else if (xcode2='slideshow') then scroll(low__aorbstr('slide','stop',sliding))
else if (xcode2='scroll') then scroll(low__aorbstr('scroll','stop',scrolling))
else if (xcode2='prev') then scroll('prev')
else if (xcode2='next') then scroll('next')
else if (xcode2='nav') then ishownav:=not ishownav
else if (xcode2='nav.prev') then inav.prev
else if (xcode2='nav.next') then inav.next
else if (strcopy1(xcode2,1,8)='onstart.') then ionstart:=frcrange32(strint(strcopy1(xcode2,9,low__len(xcode2))),0,vmax)
else if (xcode2='fav') then
   begin
   str1:=navfolder;
   if gui.popfav(str1) then navfolder:=str1;
   end
else if (strcopy1(xcode2,1,12)='screenstyle.') then
   begin
   iscreenstyle:=frcrange32(strint(strcopy1(xcode2,13,length(xcode2))),0,iscreenstyleCount-1);
   if (iscreenstyle=6) then gui.popcolor(iscreencolor);
   end
else if (xcode2='test') then
     begin
    gui.xstatusstart3(2,'',true);
    gui.xstatus(100,'Hello');
    win____sleep(2000);
    gui.xstatusstop;

     //gui.poptxt0(track__sum)
     end
else if (xcode2='test2') then
     begin
     //gui.poperror('Aaaaaaaaaaaaaaaaa');
     end
else
   begin
   if system_debug then showbasic('Unknown Command>'+xcode2+'<<');
   end;

//successful
xresult:=true;
skipend:
except;end;
try

//free
freeobj(@a);
str__free(@b);

except;end;
try

xsyncinfo(false);
if not xresult then gui.poperror('',e);

except;end;
end;

function tapp.xpastesave(const xcells:boolean;var e:string):boolean;//08nov2025, 26sep2025
label
   skipend;
var
   a:tbasicimage;
   daction,df:string;
   v:array[0..1] of string;
begin

//defaults
result  :=false;
a       :=nil;
e       :=gecTaskfailed;

try
//init
a       :=misimg32(1,1);
daction :='';

//paste
if not clip__pasteimage(a) then goto skipend;

//animation (cells) support
if xcells then
   begin

   v[0] :=k64(ilastcellcount);
   v[1] :=k64(ilastcelldelay);

   case gui.popmanyedit2(high(v)+1,v,tepNone,'Animation Settings',['Number of cells in animation','Delay in milliseconds'],['Animation Cells|Type the number of cells in the image strip (animation).  Leave blank for a simple animation of 2 cells.','Animation Delay|Type the animation delay in milliseconds to pause between cells.  Leave blank for a default delay of '+'500 ms (2 fps).|*|Some Commmon Delays|50 ms = 20 fps|100 ms = 10 fps|133 ms = 7.5 fps|200 ms = 5 fps|250 ms = 4 fps|333 ms = 3 fps|500 ms = 2 fps|1000 ms = 1 fps|fps is frames (cells) per second'],'','',100) of
   true:begin

      //defaults
      if (v[0]='') then v[0]:='2';
      if (v[1]='') then v[1]:='500';

      //get
      ilastcellcount :=frcmin32(strint32(v[0]),1);
      ilastcelldelay :=frcrange32(strint32(v[1]),1,10000);//1 to 10,000

      //set
      a.ai.count     :=frcrange32(ilastcellcount,1,misw(a));
      a.ai.delay     :=ilastcelldelay;
  
      end
   else begin

      result:=true;
      goto skipend;

      end;
   end;//case

   end;

//save prompt
case ipastecurrentfolder of
true:df:=navfolder+io__extractfilename(ipastefilename);
else df:=ipastefilename;
end;//case

if not gui.popsaveimg3(df,'','',xcells,false,daction) then
   begin

   result:=true;
   goto skipend;

   end;

//save
result         :=mis__tofile3(a,df,io__readfileext_low(df),daction,e);
ipastefilename :=df;

skipend:

except;end;

//free
freeobj(@a);

end;

procedure tapp.__ontimer(sender:tobject);//._ontimer
label
   skipend;
var
   int1:longint;
   xmustpaint:boolean;
begin
try
//init
xmustpaint:=false;

//timer100
if iloaded and (ms64>=itimer100) and (not gui.dragging) then
   begin

   //shown
   if iscreen.shown then
      begin
      //manual scroll modes
      if      (iscrollstyle='prev') then
         begin
         iscrollstyle:='';
         xprev;
         end
      else if (iscrollstyle='next') then
         begin
         iscrollstyle:='';
         xnext;
         end
      else if (iscrollstyle='first') then
         begin
         iscrollstyle:='';
         xfirst;
         end
      else if (iscrollstyle='last') then
         begin
         iscrollstyle:='';
         xlast;
         end;

      //restart if folder changes
      if low__setstr(inavfolderref,navfolder) and (scrolling or sliding) then
         begin
         if scrolling then scroll('scroll')
         else if sliding then scroll('slide');
         end;

      //load image and show
      if low__setstr(iscreenref,navfile) then
         begin
         iscreen.loadfromfile(iscreenref,true);
         iswitchtimer:=ms64;
         end

      //image has been shown -> start countdown to next image file
      else if (sliding or scrolling) then
         begin
         if (sub64(ms64,iswitchtimer)>=switchdelay(mode)) then
            begin
            if xrandom(mode)         then xnextrandom
            else if xreverse(mode)   then xprev
            else                          xnext;
            end;
         end

      //not required -> reset timer
      else iswitchtimer:=ms64;
      end
   //not required -> reset timer
   else iswitchtimer:=ms64;


   //nav.change
   if low__setstr(inavchangeref,intstr32(inav.reloadID)) then xnavfilerange;

   //transition speed
   int1:=transspeed[mode];
   if (iscreen.fadespeed<>int1) then iscreen.fadespeed:=int1;

   //reset
   itimer100:=ms64+100;
   end;

//iinfotimer
if (ms64>=iinfotimer) then
   begin
   xsyncinfo(false);
   //reset
   if sliding or scrolling then
      begin
      iinfotimer:=ms64+20;
      app__turbo;//boost app performance
      end
   else
      begin
      iinfotimer:=ms64+200;
      end;
   end;

//timer500
if (ms64>=itimer500) and iloaded then
   begin
   //savesettings
   xautosavesettings;

   //reset
   itimer500:=ms64+500;
   end;

//timerslow
if (ms64>=itimerslow) then
   begin

   //reset
   itimerslow:=ms64+2000;
   end;

//xxxxxxxxxxxxxxxxxxx if iscreen.shown then xdoscroll;

//mustpaint
if xmustpaint or imustpaint then
   begin
   imustpaint:=false;
   iscreen.paintnow;
   end;

//debug support
if system_debug then
   begin
   if system_debugFAST then rootwin.paintallnow;
   end;
if system_debug and system_debugRESIZE then
   begin
   if (system_debugwidth<=0) then system_debugwidth:=gui.width;
   if (system_debugheight<=0) then system_debugheight:=gui.height;
   //change the width and height to stress
   //was: if (random(10)=0) then gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   end;

skipend:
except;end;
end;

function tapp.canopen:boolean;
begin
//result:=(not iscreen.loading) and (iscreen.filename<>'') and (not scrolling) and (not sliding);
result:=(iscreen.filename<>'');
end;

function tapp.cansaveas:boolean;
begin
//result:=(not iscreen.loading) and (iscreen.filename<>'') and (not scrolling) and (not sliding);
result:=(iscreen.filename<>'');
end;

function tapp.cancopy:boolean;
begin
//result:=(not iscreen.loading) and (iscreen.filename<>'') and (not scrolling) and (not sliding);
result:=(iscreen.filename<>'');
end;

procedure tapp.xsyncinfo(xforce:boolean);//08nov2025
const
   xautohidetrigger=5000;
var
   xautohiding,xscrolling,xsliding,bol3,bol2,bol1:boolean;
   xfilecount,xmode,int1:longint;
   str1:string;
   xtoolbar:tbasictoolbar;

   function xautohidems(xcliplowerlevels:boolean):comp;//08nov2025
   begin

   if xautohiding and (xsliding or scrolling) then
      begin

      result:=frcrange64(low__inputidle_nokeyboard,0,xautohidetrigger);

      case gui.showingcursor of
      true:begin

         //always a delay before engaging
         result:=frcrange64(low__inputidle_nokeyboard,0,xautohidetrigger);

         end;
      else begin

         //disengage with input OR not
         case xautoshow(xmode) of
         true:result:=frcrange64(low__inputidle_nokeyboard,0,xautohidetrigger);
         else result:=xautohidetrigger;
         end;//case

         end;
      end;//case

      if xcliplowerlevels and (result<500) then result:=0;

      end
   else result:=0;

   end;

   function xfps(const xms:longint):string;
   var
      v:double;
   begin

   //get
   if (xms<=0) then v:=0.00
   else             v:=1000/frcmin32(xms,1);

   //set
   result:=curdec(v,1,true);

   end;

begin
try
//init
xscrolling  :=scrolling;
xsliding    :=sliding;
xmode       :=mode;
xautohiding :=xautohide(xmode);
xfilecount  :=inav_filecount;
xtoolbar    :=rootwin.xhead;

//.imagebar
with xtoolbar do
begin
benabled2['prev']           :=(xfilecount>=2);
benabled2['next']           :=(xfilecount>=2);
benabled2['open']           :=canopen;
benabled2['saveas']         :=cansaveas;

bol1:=cancopy;
benabled2['copy']           :=bol1;
benabled2['copy.cells']     :=bol1 and (iscreen.image32.ai.count>=2);
benabled2['copy.b64.png']   :=bol1;
benabled2['copy.b64.gif']   :=bol1;
benabled2['copy.pascal']    :=bol1;
end;

//.count colors
iscreen.countcolors:=(not xsliding) and (not xscrolling);
iscreen.fillstyle:=fill[xmode];

//.list width (nav)
rootwin.xcols.size[0]:=xlistwidth;


//.slideshow
bol1:=xsliding;
xtoolbar.bmarked2['slideshow']:=bol1;
xtoolbar.bflash2['slideshow']:=bol1;
xtoolbar.btep2['slideshow']:=low__aorb(tepPlay20,tepStop20,bol1);

//.scroll
bol1:=xscrolling;
xtoolbar.bmarked2['scroll']:=bol1;
xtoolbar.bflash2['scroll']:=bol1;
xtoolbar.btep2['scroll']:=low__aorb(tepPlay20,tepStop20,bol1);

//.show nav
bol1:=ishownav;
xtoolbar.bvisible2['nav']:=(not xsliding);
xtoolbar.bmarked2['nav']:=bol1;
xtoolbar.bflash2['nav']:=bol1;

inavbar.benabled2['nav.prev']:=inav.canprev;
inavbar.benabled2['nav.next']:=inav.cannext;

//.screen color
int1:=xscreencolor;
if (int1<>iscreen.backcolor) then iscreen.backcolor:=int1;

//.bottom status bar
rootwin.xstatus2.celltext[0]:='Dimensions: '+iscreen.findinfob('wh','-');
rootwin.xstatus2.celltext[1]:='Depth: '+iscreen.findinfob('bpp','0')+' bit';
rootwin.xstatus2.celltext[2]:='Cells: '+iscreen.findinfob('cells','-');

str1:=iscreen.findinfob('delay','0');
rootwin.xstatus2.celltext[3]:='Delay: '+str1+' ms';
rootwin.xstatus2.celltext[4]:='Speed: '+xfps( strint32(str1) )+' fps';

rootwin.xstatus2.celltext[5]:='Colors: '+low__aorbstr('-',iscreen.findinfob('colors','-'),iscreen.countcolors);
rootwin.xstatus2.celltext[6]:='Size: '+low__mbAUTO2(strint64(iscreen.findinfob('bytes','0')),3,true);

bol1:=(inav_filecount>=1) and (inav.itemindex>=inav_firstfile) and (inav.itemindex<=inav_lastfile);
rootwin.xstatus2.celltext[7]:='File: '+low__aorbstr('-',k64(inav.itemindex-inav_firstfile+1)+' / '+k64(inav_filecount),bol1);
rootwin.xstatus2.celltext[8]:='Name: '+io__extractfilename(iscreen.findinfob('file','-'));


//.auto.hide progress
rootwin.xstatus2.cellpert[0]:=low__percentage64(xautohidems(true),xautohidetrigger);


//nav.mask
if xforce or (low__downidle>=2000) then
   begin
   str1:=filter__currentlist('*.png;*.bmp;*.tea');
   if (str1<>inav.omasklist) then inav.omasklist:=str1;
   end;


//cursor
if (xautohidems(false)>=xautohidetrigger) then bol3:=false else bol3:=true;

if bol3 then
   begin
   if (bol3<>gui.showingcursor) then gui.showcursor;
   end
else
   begin
   gui.hidecursor;//keep refreshing hide cursor status as it auto times out after a short time interval
   gui.focuscontrol:=iscreen;
   end;

//image only (bare) view mode
bol2:=rootwin.xhead.visible or rootwin.xstatus2.visible or rootwin.xgrad.visible or rootwin.xgrad2.visible;

if xsliding or xscrolling then
   begin
   if (not gui.showingcursor) then bol1:=false else bol1:=true;
   end
else bol1:=true;

if (bol1<>bol2) then
   begin
   rootwin.osquareframe     :=(not bol1);
   iscreen.osquareframe     :=(not bol1);
   rootwin.xhead.visible    :=bol1;
   rootwin.xstatus2.visible :=bol1;
   rootwin.xgrad.visible    :=bol1;
   rootwin.xgrad2.visible   :=bol1;
   gui.fullalignpaint;

   //faster gamemode
   gui.gamemode             :=not bol1;
   end;

//nav
if xsliding then bol1:=false else bol1:=ishownav;
if (bol1<>ileft.visible) then ileft.visible:=bol1;

//main help
rootwin.rightvisible2:=not xsliding;

//pause ecomode during slideshows etc -> won't drop in performance
if xsliding or xscrolling then app__ecomode_pause;

except;end;
end;

procedure tapp.xnavfilerange;
var
   xselstart,xselcount,xdownindex,xnavindex,xfolderindex,xfileindex,xnavcount,xfoldercount,xfilecount:longint;
   xisnav,xisfolder,xisfile:boolean;
begin
try
inav.findinfo(xselstart,xselcount,xdownindex,xnavindex,xfolderindex,xfileindex,xnavcount,xfoldercount,xfilecount,xisnav,xisfolder,xisfile);
inav_firstfile:=xnavcount+xfoldercount;
inav_lastfile:=xnavcount+xfoldercount+xfilecount-1;
inav_filecount:=inav_lastfile-inav_firstfile+1;

//.once
if ionstartONCE then
   begin
   ionstartONCE:=false;
   case ionstart of
   vScroll:scroll('scroll');
   vSlide:scroll('slide');
   end;
   end;
except;end;
end;

procedure tapp.xonshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
begin
try
//check
if zznil(xmenudata,5000) then exit;

//init
xmenuname:='main-app.'+xstyle;

//menu
if (xstyle='menu') then
   begin
   //file
{
   low__menutitle(xmenudata,tepnone,'File Options','File options');
   low__menuitem2(xmenudata,tepScreen20,'Preview','Preview image in web browser','preview',100,aknone,true);
   low__menuitem2(xmenudata,tepOpen20,'Open...','Open image from file','open',100,aknone,true);
   low__menuitem2(xmenudata,tepSave20,'Save','Save image to file without prompting','save',100,aknone,xcansave);
   low__menuitem2(xmenudata,tepSave20,'Save As...','Save image to file','saveas',100,aknone,aimgok);
   low__menuitem2(xmenudata,tepSave20,'Save A Copy...','Save a copy of image to file','saveas2',100,aknone,aimgok);
   //edit
   low__menutitle(xmenudata,tepnone,'Edit Options','Edit options');
   low__menuitem2(xmenudata,tepCopy20,'Copy','Copy image to clipboard','copy',100,aknone,aimgok);
   low__menuitem2(xmenudata,tepPaste20,'Paste','Paste image from clipboard','paste',100,aknone,acanpaste);
}
   end
//settings
else if (xstyle='settings') then
   begin
   //screen color
   low__menutitle(xmenudata,tepnone,'Screen Color','Screen color');
   low__menuitem2(xmenudata,tep__tick(iscreenstyle=0),'Default','Screen Color|Default color','screenstyle.0',100,aknone,true);
   low__menuitem2(xmenudata,tep__tick(iscreenstyle=1),'Grey','Screen Color|Grey','screenstyle.1',100,aknone,true);
   low__menuitem2(xmenudata,tep__tick(iscreenstyle=2),'Light Grey','Screen Color|Light Grey','screenstyle.2',100,aknone,true);
   low__menuitem2(xmenudata,tep__tick(iscreenstyle=3),'Black','Screen Color|Black','screenstyle.3',100,aknone,true);
   low__menuitem2(xmenudata,tep__tick(iscreenstyle=4),'White','Screen Color|White','screenstyle.4',100,aknone,true);
   low__menuitem2(xmenudata,tep__tick(iscreenstyle=5),'Off White','Screen Color|Off White','screenstyle.5',100,aknone,true);
   low__menuitem2(xmenudata,tep__tick(iscreenstyle=6),'Custom...','Screen Color|Custom color','screenstyle.6',100,aknone,true);
   //settings
   low__menutitle(xmenudata,tepnone,'Settings','Settings');
   low__menuitem2(xmenudata,tep__yes(ishownav),'Show Navigation Panel','Navigation Panel|Tick to show navigation panel','nav',100,aknone,not sliding);
   low__menuitem2(xmenudata,tep__yes(ipastecurrentfolder),'Paste to Current Folder','Paste|Tick to paste to current folder','pastecurrentfolder.toggle',100,aknone,true);


   //settings
   low__menutitle(xmenudata,tepnone,'On App Start','Set what the app should do on start');
   low__menuitem2(xmenudata,tep__tick(ionstart=vlist),'Start Normally','Start normally','onstart.'+intstr32(vList),100,aknone,true);
   low__menuitem2(xmenudata,tep__tick(ionstart=vscroll),'Scroll through List','Scroll through list','onstart.'+intstr32(vScroll),100,aknone,true);
   low__menuitem2(xmenudata,tep__tick(ionstart=vslide),'Play Sideshow','Play slideshow','onstart.'+intstr32(vSlide),100,aknone,true);
   end;
except;end;
end;

function tapp.xonshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
begin
result:=true;
xcmd(sender,xcode,xcode2);
end;

procedure tapp.gamemode__onpaint(sender:tobject);
begin

if (ibuffer=nil) then ibuffer:=miswin24(1,1);//15may2025
if (ibufrows=nil) then ibufrows:=str__new8;

if low__setstr(ibufref,bolstr(ibuffer<>nil)+bolstr(ibufrows<>nil)+'|'+intstr32(gui.width)+'|'+intstr32(gui.height)) then
   begin

   missize(ibuffer,gui.width,gui.height);

   end;

iscreen.xrenderto(24,misw(ibuffer),mish(ibuffer),ibuffer.prows24);

gui.xcopyfrom(ibuffer.dc,misarea(ibuffer),misarea(ibuffer));

app__turbo;

end;

function tapp.gamemode__onnotify(sender:tobject):boolean;
begin
____onnotify(sender);
end;

function tapp.gamemode__onshortcut(sender:tobject):boolean;
begin
result:=false;
end;

procedure tapp.____onclick(sender:tobject);
begin

//click
if (not sliding) and (sender<>iscreen) then scroll('stop');

end;

function tapp.____onnotify(sender:tobject):boolean;
begin
//defaults
result:=true;//handled

try

//screen -> esc key
case gui.key of
akescape:scroll('stop');
akleft,akup:scroll('prev');
akright,akdown:scroll('next');
akctrlLeft,akctrlUp:scroll('first');
akctrlRight,akctrlDown:scroll('last');
end;

//any -> mouse down
if gui.mousedown and (not gui.mousewasdown) then
   begin

   //.scrolling
   if (sender=iscreen) then
      begin

      case sliding of
      true:scroll('stop');
      else
         begin
         case iscreen.mustmode of
         -1:scroll(low__aorbstr('prev','stop',scrolling));
         1 :scroll(low__aorbstr('next','stop',scrolling));
         else scroll('stop');
         end;
         end;
      end;//case

      iscreen.mustmode:=0;

      end
   else scroll('stop');

   end;

//screen -> click + dblclick
if gui.mouseupstroke and (not gui.mousedragging) and gui.mouseleft then ____onclick(sender);

except;end;
end;

end.
